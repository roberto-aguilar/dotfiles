# Get colors in manual pages.
function man() {
    env \
    LESS_TERMCAP_mb=$(printf "\e[1;31m")    \
    LESS_TERMCAP_md=$(printf "\e[1;31m")    \
    LESS_TERMCAP_me=$(printf "\e[0m")       \
    LESS_TERMCAP_se=$(printf "\e[0m")       \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m")       \
    LESS_TERMCAP_us=$(printf "\e[1;32m")    \
    man "$@"
}

# Creates a temporary directory and cd into it.
function tmp() {
    cd $(mktemp -d)
}

# Handy way to open Neovim.
n() {
  if [[ "$#" -eq 0 ]]; then
    nvim .
  else
    nvim "$@"
  fi
}

# Improvements over zoxide's z command.
zd() {
  if [ $# -eq 0 ]; then
    builtin cd ~ && return
  elif [ -d "$1" ]; then
    builtin cd "$1"
  else
    z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
  fi
}

# Create a Tmux Dev Layout with editor, Claude Code, and terminal.
tdl() {
  [[ -z $TMUX ]] && { echo "You must start tmux to use tdl."; return 1; }

  local current_dir="${PWD}"
  local editor_pane ai_pane

  editor_pane="$TMUX_PANE"

  tmux rename-window -t "$editor_pane" "$(basename "$current_dir")"

  # Split window vertically - top 85%, bottom 15%.
  tmux split-window -v -p 15 -t "$editor_pane" -c "$current_dir"

  # Split editor pane horizontally - Claude Code on right 30%.
  ai_pane=$(tmux split-window -h -p 30 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')

  tmux send-keys -t "$ai_pane" "claude --permission-mode bypassPermissions" C-m
  tmux send-keys -t "$editor_pane" "$EDITOR ." C-m
  tmux select-pane -t "$editor_pane"
}

# Toggle whether closing the lid puts the MacBook to sleep.
toggle-system-sleep() {
  local sleep_disabled
  sleep_disabled=$(pmset -g | awk '/SleepDisabled/ { print $2 }')

  if [[ "$sleep_disabled" == "1" ]]; then
    sudo pmset -a disablesleep 0
  else
    sudo pmset -a disablesleep 1
  fi

  # Re-read so a failed sudo cannot report a change that never happened.
  sleep_disabled=$(pmset -g | awk '/SleepDisabled/ { print $2 }')

  if [[ "$sleep_disabled" == "1" ]]; then
    echo "System sleep is disabled. Closing the lid keeps this MacBook awake."
  else
    echo "System sleep is enabled. Closing the lid puts this MacBook to sleep."
  fi
}
