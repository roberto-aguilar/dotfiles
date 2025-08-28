# Set vim as the default EDITOR.
export EDITOR=vim

# Escape the ^ character for commands like `git reset HEAD^`.
setopt NO_NOMATCH

# Path to Oh My Zsh.
ZSH="${HOME}/.oh-my-zsh"

# Oh My Zsh theme.
ZSH_THEME="robbyrussell"

# Oh My Zsh plugins.
plugins=(extract git sublime sudo)

# Initialize Oh My Zsh.
source "${ZSH}/oh-my-zsh.sh"

# Load aliases, functions, third-party, and so on.
zsh_files=(
  .aliases.zsh
  .functions.zsh
  .initialize.zsh
  .locale.zsh
)
for file in "${zsh_files[@]}"; do
    filepath="${HOME}/${file}"
    [[ -r "${filepath}" ]] && source "${filepath}"
done
unset filepath
unset file
unset zsh_files

# Laravel Herd
export PATH="/Users/roberto/Library/Application Support/Herd/bin/":$PATH

# Herd injected PHP 8.2 configuration.
export HERD_PHP_82_INI_SCAN_DIR="/Users/roberto/Library/Application Support/Herd/config/php/82/"

# Herd injected PHP 8.4 configuration.
export HERD_PHP_84_INI_SCAN_DIR="/Users/roberto/Library/Application Support/Herd/config/php/84/"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/roberto/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
