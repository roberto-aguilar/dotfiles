"""Compare a btusb build against the distribution's stock btusb module.

Reads the USB device tables and code sections straight from the ELF files,
so it needs nothing beyond the Python standard library.

Commands:
  contains STOCK VENDOR PRODUCT
      Exit 0 if a device table in STOCK matches VENDOR:PRODUCT, 1 if not.
  reconcile STOCK TRIAL SOURCE VENDOR PRODUCT
      Copy plain USB_DEVICE entries that STOCK has and TRIAL lacks into the
      tables of SOURCE (the C file TRIAL was built from). Exit 0 if nothing
      was missing, 3 if SOURCE was changed.
  verify STOCK TRIAL VENDOR PRODUCT
      Exit 0 if TRIAL's tables equal STOCK's plus exactly the VENDOR:PRODUCT
      entry and every code section is byte-identical.

Any other outcome, including a difference that must not be papered over,
prints the reason and exits 2.
"""

import difflib
import re
import struct
import sys

PREFIX = "btusb-rtl8821ce:"
TABLE_NAMES = ("quirks_table", "btusb_table")

SECTION_TYPE_SYMBOL_TABLE = 2
SECTION_TYPE_RELOCATIONS_WITH_ADDEND = 4
SECTION_TYPE_RELOCATIONS = 9
SECTION_TYPE_NO_BITS = 8
SECTION_FLAG_EXECUTABLE = 0x4
SECTION_FLAG_COMPRESSED = 0x800
ELF_MACHINE_X86_64 = 62

# USB_DEVICE(vendor, product) sets exactly these two match flags.
MATCH_VENDOR = 0x0001
MATCH_PRODUCT = 0x0002
MATCH_DEVICE = MATCH_VENDOR | MATCH_PRODUCT

# struct usb_device_id on x86_64: five u16, seven u8, seven bytes of padding
# so that the kernel_ulong_t driver_info lands on offset 24. 32 bytes total.
USB_DEVICE_ID = struct.Struct("<5H7B7xQ")
FIELD_NAMES = (
    "match_flags", "idVendor", "idProduct", "bcdDevice_lo", "bcdDevice_hi",
    "bDeviceClass", "bDeviceSubClass", "bDeviceProtocol", "bInterfaceClass",
    "bInterfaceSubClass", "bInterfaceProtocol", "bInterfaceNumber", "driver_info",
)
assert USB_DEVICE_ID.size == 32


class ParityError(Exception):
    pass


def say(message):
    print(f"{PREFIX} {message}", flush=True)


class ElfModule:
    def __init__(self, path):
        self.path = path
        with open(path, "rb") as module_file:
            self.data = module_file.read()
        data = self.data
        if data[:4] != b"\x7fELF" or data[4] != 2 or data[5] != 1:
            raise ParityError(f"{path} is not a little-endian 64-bit ELF file")
        machine = struct.unpack_from("<H", data, 0x12)[0]
        if machine != ELF_MACHINE_X86_64:
            raise ParityError(f"{path} is not an x86_64 module")
        section_header_offset = struct.unpack_from("<Q", data, 0x28)[0]
        section_header_size, section_count, section_names_index = struct.unpack_from("<HHH", data, 0x3A)
        self.sections = []
        for index in range(section_count):
            fields = struct.unpack_from(
                "<IIQQQQIIQQ", data, section_header_offset + index * section_header_size
            )
            self.sections.append({
                "name_offset": fields[0], "type": fields[1], "flags": fields[2],
                "offset": fields[4], "size": fields[5], "link": fields[6], "info": fields[7],
                "entry_size": fields[9],
            })
        names = self.sections[section_names_index]
        for section in self.sections:
            section["name"] = self.string_at(names["offset"] + section["name_offset"])
        self.symbols = self.read_symbols()

    def string_at(self, offset):
        end = self.data.index(b"\0", offset)
        return self.data[offset:end].decode("utf-8", "replace")

    def contents(self, section):
        if section["type"] == SECTION_TYPE_NO_BITS:
            return b""
        return self.data[section["offset"]:section["offset"] + section["size"]]

    def read_symbols(self):
        symbols = []
        for section in self.sections:
            if section["type"] != SECTION_TYPE_SYMBOL_TABLE:
                continue
            strings = self.sections[section["link"]]
            for offset in range(section["offset"], section["offset"] + section["size"], 24):
                name_offset, _, _, section_index, value, size = struct.unpack_from("<IBBHQQ", self.data, offset)
                symbols.append({
                    "name": self.string_at(strings["offset"] + name_offset),
                    "section_index": section_index, "value": value, "size": size,
                })
        return symbols

    def find_table_symbol(self, table_name):
        exact = [symbol for symbol in self.symbols if symbol["name"] == table_name]
        if exact:
            return exact[0]
        # MODULE_DEVICE_TABLE aliases look like __mod_device_table__kmod_btusb__usb__btusb_table.
        aliases = [
            symbol for symbol in self.symbols
            if symbol["name"].startswith("__mod_device_table__") and symbol["name"].endswith("__usb__" + table_name)
        ]
        return aliases[0] if aliases else None

    def relocations_inside(self, section_index, start, end):
        for section in self.sections:
            if section["type"] not in (SECTION_TYPE_RELOCATIONS_WITH_ADDEND, SECTION_TYPE_RELOCATIONS):
                continue
            if section["info"] != section_index:
                continue
            for offset in range(section["offset"], section["offset"] + section["size"], section["entry_size"]):
                relocation_offset = struct.unpack_from("<Q", self.data, offset)[0]
                if start <= relocation_offset < end:
                    return True
        return False

    def device_table(self, table_name):
        symbol = self.find_table_symbol(table_name)
        if symbol is None:
            raise ParityError(f"no {table_name} symbol in {self.path}")
        section = self.sections[symbol["section_index"]]
        if section["type"] == SECTION_TYPE_NO_BITS or section["flags"] & SECTION_FLAG_COMPRESSED:
            raise ParityError(f"{table_name} in {self.path} is in an unreadable section")
        if symbol["size"] == 0 or symbol["size"] % USB_DEVICE_ID.size:
            raise ParityError(f"{table_name} in {self.path} has unexpected size {symbol['size']}")
        start, end = symbol["value"], symbol["value"] + symbol["size"]
        # Every field is a compile-time constant, so a relocation here means the layout is not what we expect.
        if self.relocations_inside(symbol["section_index"], start, end):
            raise ParityError(f"{table_name} in {self.path} has relocations, refusing to guess its values")
        raw = self.contents(section)[start:end]
        entries = [USB_DEVICE_ID.unpack_from(raw, offset) for offset in range(0, len(raw), USB_DEVICE_ID.size)]
        if any(entries[-1]):
            raise ParityError(f"{table_name} in {self.path} does not end with an empty terminating entry")
        return entries[:-1]

    def code_sections(self):
        return {
            section["name"]: self.contents(section)
            for section in self.sections
            if section["flags"] & SECTION_FLAG_EXECUTABLE
        }

    def compiler(self):
        for section in self.sections:
            if section["name"] == ".comment":
                strings = [part.decode("utf-8", "replace") for part in self.contents(section).split(b"\0") if part]
                return ", ".join(sorted(set(strings)))
        return "unknown"


def is_plain_usb_device(entry):
    return entry[0] == MATCH_DEVICE and not any(entry[3:12])


def matches_device(entry, vendor, product):
    return entry[0] & MATCH_DEVICE == MATCH_DEVICE and entry[1] == vendor and entry[2] == product


def is_added_entry(entry, vendor, product):
    return is_plain_usb_device(entry) and entry[1] == vendor and entry[2] == product


def describe(entry):
    if is_plain_usb_device(entry):
        return f"USB_DEVICE(0x{entry[1]:04x}, 0x{entry[2]:04x}) driver_info=0x{entry[12]:x}"
    fields = ", ".join(f"{name}=0x{value:x}" for name, value in zip(FIELD_NAMES, entry) if value)
    return "{" + fields + "}"


def compare_tables(stock_entries, our_entries, table_name):
    """Return the stock entries we lack as (insert_position_in_ours, entries) pairs."""
    matcher = difflib.SequenceMatcher(None, our_entries, stock_entries, autojunk=False)
    insertions = []
    problems = []
    for tag, our_start, our_end, stock_start, stock_end in matcher.get_opcodes():
        if tag == "equal":
            continue
        if tag == "insert":
            insertions.append((our_start, stock_entries[stock_start:stock_end]))
            continue
        for entry in our_entries[our_start:our_end]:
            problems.append(f"our {table_name} has {describe(entry)} which the stock module lacks")
        for entry in stock_entries[stock_start:stock_end]:
            problems.append(f"stock {table_name} has {describe(entry)} at a position we cannot match")
    return insertions, problems


def skip_comment_or_literal(text, position):
    """If a comment or literal starts at position, return the index just after it."""
    if text.startswith("/*", position):
        end = text.find("*/", position + 2)
        if end < 0:
            raise ParityError("unterminated comment in btusb.c")
        return end + 2
    if text.startswith("//", position):
        end = text.find("\n", position)
        return len(text) if end < 0 else end
    if text[position] in "\"'":
        quote = text[position]
        index = position + 1
        while index < len(text) and text[index] != quote:
            index += 2 if text[index] == "\\" else 1
        return index + 1
    return None


def table_entries_in_source(text, table_name):
    """Return the (start, end) span of each top-level { } entry in a table definition."""
    definitions = list(re.finditer(r"struct\s+usb_device_id\s+" + table_name + r"\s*\[\s*\]\s*=\s*\{", text))
    if len(definitions) != 1:
        raise ParityError(f"found {len(definitions)} definitions of {table_name} in btusb.c, expected 1")
    depth = 1
    position = definitions[0].end()
    entries = []
    entry_start = None
    while depth > 0:
        if position >= len(text):
            raise ParityError(f"{table_name} in btusb.c is not closed")
        skipped = skip_comment_or_literal(text, position)
        if skipped is not None:
            position = skipped
            continue
        character = text[position]
        if character == "{":
            if depth == 1:
                entry_start = position
            depth += 1
        elif character == "}":
            depth -= 1
            if depth == 1:
                entries.append((entry_start, position + 1))
        position += 1
    if re.search(r"^[ \t]*#", text[definitions[0].end():position], re.MULTILINE):
        raise ParityError(f"{table_name} in btusb.c contains preprocessor lines, cannot map entries to source")
    return entries


def check_source_matches_build(text, spans, entries, table_name):
    if len(spans) != len(entries) + 1 or text[spans[-1][0] + 1:spans[-1][1] - 1].strip():
        raise ParityError(f"{table_name} in btusb.c does not line up with the compiled table")
    plain = re.compile(r"\{\s*USB_DEVICE\(\s*(0x[0-9a-fA-F]+)\s*,\s*(0x[0-9a-fA-F]+)\s*\)")
    for (start, end), entry in zip(spans, entries):
        match = plain.match(text, start, end)
        if match and (entry[1], entry[2]) != (int(match.group(1), 16), int(match.group(2), 16)):
            raise ParityError(f"{table_name} in btusb.c does not line up with the compiled table")


def insertion_point(text, spans, position):
    """Index in text where an entry that should come at position in the table is inserted."""
    if position == 0:
        return text.rfind("\n", 0, spans[0][0]) + 1
    previous_end = spans[position - 1][1]
    comma = text.index(",", previous_end)
    line_end = text.find("\n", comma)
    if line_end < 0 or "{" in text[comma:line_end]:
        return comma + 1
    return line_end + 1


def render_entry(entry):
    return (
        f"\t{{ USB_DEVICE(0x{entry[1]:04x}, 0x{entry[2]:04x}), .driver_info = 0x{entry[12]:x}UL }},"
        " /* copied from the stock module */\n"
    )


def reconcile(stock_path, trial_path, source_path, vendor, product):
    stock = ElfModule(stock_path)
    trial = ElfModule(trial_path)
    with open(source_path) as source_file:
        text = source_file.read()
    problems = []
    edits = []
    added_entries_seen = 0
    for table_name in TABLE_NAMES:
        stock_entries = stock.device_table(table_name)
        trial_entries = trial.device_table(table_name)
        added_positions = [index for index, entry in enumerate(trial_entries) if is_added_entry(entry, vendor, product)]
        added_entries_seen += len(added_positions)
        our_trial_indices = [index for index in range(len(trial_entries)) if index not in added_positions]
        our_entries = [trial_entries[index] for index in our_trial_indices]
        insertions, table_problems = compare_tables(stock_entries, our_entries, table_name)
        problems.extend(table_problems)
        if not insertions:
            continue
        spans = table_entries_in_source(text, table_name)
        check_source_matches_build(text, spans, trial_entries, table_name)
        for position_in_ours, missing in insertions:
            for entry in missing:
                if not is_plain_usb_device(entry):
                    problems.append(f"stock {table_name} has {describe(entry)}, which is not a plain USB_DEVICE entry")
            # Map the position back to the trial table, which still contains our added entry.
            if position_in_ours < len(our_trial_indices):
                position = our_trial_indices[position_in_ours]
            else:
                position = len(trial_entries)
            edits.append((insertion_point(text, spans, position), table_name, missing))
    if added_entries_seen != 1:
        problems.append(
            f"expected one USB_DEVICE(0x{vendor:04x}, 0x{product:04x}) entry in our tables, found {added_entries_seen}"
        )
    if problems:
        for problem in problems:
            say(problem)
        raise ParityError("our device tables differ from the stock module in a way we cannot copy over")
    if not edits:
        return 0
    for point, table_name, missing in sorted(edits, key=lambda edit: edit[0], reverse=True):
        for entry in missing:
            say(f"copying {describe(entry)} from the stock {table_name}")
        text = text[:point] + "".join(render_entry(entry) for entry in missing) + text[point:]
    with open(source_path, "w") as source_file:
        source_file.write(text)
    return 3


def verify(stock_path, trial_path, vendor, product):
    stock = ElfModule(stock_path)
    trial = ElfModule(trial_path)
    problems = []
    added_entries_seen = 0
    for table_name in TABLE_NAMES:
        stock_entries = stock.device_table(table_name)
        trial_entries = trial.device_table(table_name)
        our_entries = [entry for entry in trial_entries if not is_added_entry(entry, vendor, product)]
        added_entries_seen += len(trial_entries) - len(our_entries)
        if our_entries != stock_entries:
            problems.append(f"{table_name} still differs from the stock module")
    if added_entries_seen != 1:
        problems.append(
            f"expected one USB_DEVICE(0x{vendor:04x}, 0x{product:04x}) entry in our tables, found {added_entries_seen}"
        )
    stock_code = stock.code_sections()
    trial_code = trial.code_sections()
    for name in sorted(set(stock_code) | set(trial_code)):
        if name not in trial_code:
            problems.append(f"code section {name} exists only in the stock module")
        elif name not in stock_code:
            problems.append(f"code section {name} exists only in our build")
        elif stock_code[name] != trial_code[name]:
            problems.append(f"code section {name} differs from the stock module")
    if any(problem.startswith("code section") for problem in problems) and stock.compiler() != trial.compiler():
        problems.append(f"stock was built by {stock.compiler()}, ours by {trial.compiler()}")
    if problems:
        for problem in problems:
            say(problem)
        raise ParityError("our build is not the stock module plus one device entry")
    sections = ", ".join(sorted(stock_code))
    say(f"parity confirmed: tables equal stock plus 0x{vendor:04x}:0x{product:04x}, identical code in {sections}")
    return 0


def contains(stock_path, vendor, product):
    stock = ElfModule(stock_path)
    for table_name in TABLE_NAMES:
        for entry in stock.device_table(table_name):
            if matches_device(entry, vendor, product):
                return 0
    return 1


def main(arguments):
    try:
        if len(arguments) == 4 and arguments[0] == "contains":
            return contains(arguments[1], int(arguments[2], 16), int(arguments[3], 16))
        if len(arguments) == 6 and arguments[0] == "reconcile":
            return reconcile(arguments[1], arguments[2], arguments[3], int(arguments[4], 16), int(arguments[5], 16))
        if len(arguments) == 5 and arguments[0] == "verify":
            return verify(arguments[1], arguments[2], int(arguments[3], 16), int(arguments[4], 16))
    except (ParityError, OSError, ValueError) as error:
        say(str(error))
        return 2
    print(__doc__, file=sys.stderr)
    return 64


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
