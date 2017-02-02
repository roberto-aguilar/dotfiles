# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# PATH environment variables.
export WORKON_HOME=$HOME/.virtualenvwrapper/envs
export RVM_PATH=$HOME/.rvm/bin
export COMPOSER_PATH=$HOME/.composer/vendor/bin
export PATH=$PATH:$COMPOSER_PATH:$RVM_PATH

# Escape the ^ for commands like `git reset HEAD^`.
setopt NO_NOMATCH

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="robbyrussell"
ZSH_THEME="dojogeekra"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(composer git laravel5 npm rvm sublime sudo virtualenvwrapper)

source $ZSH/oh-my-zsh.sh

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

alias reload="source ~/.zshrc"
alias nuke="rm -rf"
alias dal="composer dumpautoload"
alias u="vendor/bin/phpunit"

# Third party software

# File executed before the python's repl runs.
export PYTHONSTARTUP=$HOME/.pythonrc

# python's virtualenvwrapper
source /usr/local/bin/virtualenvwrapper.sh

# Z command
source ~/Bin/z.sh

# Homestead
function hs() {
    ( cd ~/Homestead && vagrant $* )
}
