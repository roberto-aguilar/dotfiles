" Disable compatibility mode to use the latest vim features.
set nocompatible

" Load Vundle plugin manager
so ~/.vim/plugins.vim

" Reload the .vimrc file each time is saved.
augroup autosourcing
    autocmd!
    autocmd BufWritePost .vimrc source %
augroup END

" Define the <Leader> character.
let mapleader = ','

" Enable persistent undo
set undofile
set undodir=$HOME/.vim/undo

" Show the line and column number of the cursor position.
set ruler

" Define the file format.
set fileformat=unix

" Set the character encoding.
set encoding=utf-8

" Insert spaces when the <Tab> key is pressed.
set expandtab

" Define the number of <Space> that a <Tab> in the file counts for.
set tabstop=4
set softtabstop=4

" Define the number of <Space> that the reindent operators (<< and >>) will indent.
set shiftwidth=4

" Display line numbers.
set number

" Enable syntax highlight.
syntax enable

" Copy indent from current line when starting a new line.
set autoindent
set copyindent

" Enable smart autoindenting when starting a new line.
set smartindent

" Highligth search pattern matches.
set hlsearch

" Show matches as the search pattern is being typed.
set incsearch

" Define the color scheme.
colorscheme tomorrow-night

" Define the number of lines to keep above and below the cursor.
set scrolloff=4

" Avoid line wrapping.
set nowrap

" Turn off the highlight in search ocurrences.
nmap <Leader><space> :nohlsearch<cr>

" Place horizontal splits below.
set splitbelow

" Place vertical splits to the right.
set splitright

" Display spaces, tabs and trailing spaces.
set list
set listchars=tab:!·,space:⋅,trail:⋅

" Setup a keymap to toggle NERDTree.
nmap <Leader>1 :NERDTreeToggle<cr>

