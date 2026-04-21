# File executed before the python's repl runs
if [[ -e "${HOME}/.pythonrc" ]]; then
    export PYTHONSTARTUP="${HOME}/.pythonrc"
fi

# Initialize `zoxide` if available.
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# Initialize `mise` if available.
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# Initialize `az` completion if available.
if command -v az &> /dev/null; then
    autoload -Uz bashcompinit && bashcompinit
    source "$(brew --prefix)/etc/bash_completion.d/az"
fi
