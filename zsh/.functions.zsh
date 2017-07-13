# Get colors in manual pages
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

# Extract archives based on the extension
function extract () {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2) tar xvjf $1   ;;
            *.tar.gz)  tar xvzf $1   ;;
            *.bz2)     bunzip2 $1    ;;
            *.rar)     unrar x $1    ;;
            *.gz)      gunzip $1     ;;
            *.tar)     tar xvf $1    ;;
            *.tbz2)    tar xvjf $1   ;;
            *.tgz)     tar xvzf $1   ;;
            *.zip)     unzip $1      ;;
            *.Z)       uncompress $1 ;;
            *.7z)      7z x $1       ;;
            *)         echo "don't know how to extract '$1'..." ;;
        esac
    else
       echo "'$1' is not a valid file!"
    fi
}

# Run homestead anywhere
function hs() {
    ( cd ~/Homestead && vagrant $* )
}

# Creates a temporary directory and cd into it
function tmp() {
    cd $(mktemp -d)
}

# Open the current git repository in the browser
function github() {
    if [ ! -d .git ]; then
        echo "ERROR: This isnt a git directory" && exit 1;
    fi

    local option="${1:-NA}"
    local remote=$(git config --get remote.origin.url)
    local github_url github_help

    read -r -d '' github_help<<EOF
github opens the current git repository in the browser.
Usage:
  github [options]
Options:
  -b, --branch        open repository on the current branch
  -c, --commit        open repository current commit
  -d, --diff          open a diff with two commits or refs [default: "develop", "master"]
  -p, --pulls         open the pull requests page
  -s, --settings      open settings page for the project
  -w, --wiki          open wiki page for the project
EOF

    if [[ $remote != *github* ]]; then
        echo "ERROR: Remote origin is invalid" && exit 1;
    fi

    github_url="${remote%.git}" # remove ".git" suffix

    if [[ $github_url =~ git@github.com:* ]]; then
        # remove "git@github.com:" prefix
        github_url="https://github.com/${github_url#*:}"
    fi

    case "$option" in
        '-b' | '--branch' ) option="/tree/$(git rev-parse --abbrev-ref HEAD)" ;;
        '-c' | '--commit' ) option="/tree/$(git rev-parse HEAD)" ;;
        '-d' | '--diff' ) option="/compare/${2:-develop}...${3:-master}" ;;
        '-h' | '--help' ) echo $github_help && return ;;
        '-p' | '--pulls' ) option="/pulls" ;;
        '-s' | '--settings' ) option="/settings" ;;
        '-w' | '--wiki' ) option="/wiki" ;;
        'NA' | *) option="" ;;
    esac

    open -a '/Applications/Google Chrome.app' "$github_url$option"
}

