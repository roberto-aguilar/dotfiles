" Override default <Leader> character
let mapleader = ','

" Show the line and column number of the cursor position
set ruler

" Sane text files
set fileformat=unix
set encoding=utf-8

" Sane tabs
set tabstop=4
set shiftwidth=4
set softtabstop=4

" Convert all typed tabs to spaces
set expandtab

" Display line numbers
set number

" Enable syntax highlight
syntax enable

" Enable auto indenting
set autoindent
set smartindent

" Highligth search ocurrences
set hlsearch

" Enable incremental search hightlight
set incsearch

" Setup theme
colorscheme desert

" Make backspace behave like any other editor
set backspace=indent,eol,start

" Keep more context when scrolling off the end of a buffer
set scrolloff=4

" Avoid line wrapping
set nowrap

" Turn off the highlight in search ocurrences
nmap <Leader><space> :nohlsearch<cr>

" |---Automatic commands---|

" Reload the .vimrc file each time is saved
augroup autosourcing
    autocmd!
    autocmd BufWritePost .vimrc source %
augroup END

