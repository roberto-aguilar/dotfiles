# File executed before the python's repl runs
if [ -e "${HOME}/.pythonrc" ]; then
    export PYTHONSTARTUP="${HOME}/.pythonrc"
fi

# Initialize `zoxide` if available.
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi
