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
