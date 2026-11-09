-- Personal Hyprland rules. Required last, so they override Omarchy's defaults.

-- US and Spanish layouts, switched with Left Alt + Right Alt.
hl.config({
  input = {
    kb_layout = "us,es",
    kb_options = "compose:caps,shift:both_capslock_cancel,grp:alts_toggle",
    repeat_delay = 600,
  },
})

-- Keep a lone window at column width in the scrolling layout, not full width.
hl.config({
  scrolling = { fullscreen_on_one_column = false },
})

-- Tearing lowers input lag. Adaptive sync stays off: vrr = 2 makes the LG
-- UltraGear drop its DisplayPort link every 13 seconds on the NVIDIA driver.
hl.config({
  general = { allow_tearing = true },
  misc = { vrr = 0 },
})

-- Steam games take the tearing path.
o.window("^steam_app_", { immediate = true })

-- DOOM Eternal never fullscreens on its own. Target the game, not its launcher.
o.window({ class = "^steam_app_782330$", title = "DOOMEternal" }, { fullscreen = true })

-- Content Manager's dropdowns share the game's class, so a blanket fullscreen
-- blacked out the screen. Float everything. The race fullscreens itself.
o.window("^steam_app_244210$", { float = true })

-- The stock launcher saves whatever size tiling gives it, so its menu ends up
-- tiny. Fullscreen it before it can measure itself.
o.window({ class = "^steam_app_244210$", title = "^Assetto Corsa Launcher$" }, { fullscreen = true })

-- Omarchy (default/hypr/apps/steam.lua) floats every Steam window because its
-- menus and dialogs share the class. Tile just the main client. Popups keep floating.
o.window({ class = "^steam$", title = "^Steam$" }, { tile = true })
