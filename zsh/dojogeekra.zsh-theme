# dojogeekra.zsh-theme

PROMPT=' %{$FG[064]%}%n%{$reset_color%} %{$FG[245]%}in%{$reset_color%} %{$FG[202]%}%~$(git_prompt_info) %(!.%{$fg_bold[red]%}#.%{$fg_bold[green]%}❯)%{$reset_color%} '

BRANCH_CHARACTER="\ue0a0"
ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[blue]%}$BRANCH_CHARACTER%{$reset_color%} %{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"

