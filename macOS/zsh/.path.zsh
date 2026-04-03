# Tracked PATH additions.
# Entries here are tools managed by the dotfiles repo or its Brewfile.
# Machine-specific paths belong in ~/.local.zsh instead.

# Initialize Homebrew.
if [[ -x "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# User-local binaries (Claude CLI, Copilot CLI, etc.)
[[ -d "${HOME}/.local/bin" ]] && export PATH="${HOME}/.local/bin:${PATH}"

# Composer global binaries (Brewfile: php, composer)
[[ -d "${HOME}/.composer/vendor/bin" ]] && export PATH="${HOME}/.composer/vendor/bin:${PATH}"

# mysql-client (Brewfile: mysql-client, keg-only)
[[ -d "/opt/homebrew/opt/mysql-client/bin" ]] && export PATH="/opt/homebrew/opt/mysql-client/bin:${PATH}"
