# dojogeekra.zsh-theme

BRANCH_CHARACTER="\ue0a0"
ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[blue]%}$BRANCH_CHARACTER%{$reset_color%} %{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"

function date_prompt_info() {
  echo " %{$FG[245]%}$(date +"%d/%m/%Y "%H:%M"")%{$reset_color%}"
}

PROMPT=$'%{$FG[064]%}%n%{$reset_color%} %{$FG[245]%}in%{$reset_color%} %{$FG[202]%}%~$(git_prompt_info)$(date_prompt_info) \n %(!.%{$fg_bold[red]%}#.%{$fg_bold[green]%}❯)%{$reset_color%} '
