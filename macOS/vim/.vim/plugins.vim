" Disable filetype detection.
filetype off

" Set the runtime path to include Vundle and initialize.
set rtp+=~/.vim/bundle/Vundle.vim

" Begin Vundle settings.
call vundle#begin()

" The plugin manager itself.
Plugin 'VundleVim/Vundle.vim'

" A file system tree explorer.
Plugin 'scrooloose/nerdtree'

" Elixir programming language support
Plugin 'elixir-lang/vim-elixir'

" End Vundle settings.
call vundle#end()

" Enable filetype detection.
filetype plugin indent on

