" Load debian default options
runtime! debian.vim

" Vim files
let g:vim_cache_dir = (exists("$XDG_CACHE_DIR") ? $XDG_CACHE_DIR : $HOME."/.cache")."/vim"
if !isdirectory(g:vim_cache_dir)
    call mkdir(g:vim_cache_dir, 'p')
endif
execute "set viminfofile=".escape(g:vim_cache_dir."/viminfo", ' ')

" Uncomment the next line to make Vim more Vi-compatible
" NOTE: debian.vim sets 'nocompatible'.  Setting 'compatible' changes numerous
" options, so any other options should be set AFTER setting 'compatible'.
"set compatible

" define leader key
let mapleader = ','

" Automatically jump to the last position
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif

"
" Syntax & indent
"
syntax on
set background=dark
set ts=4 sw=4
set formatoptions-=tc

if has("autocmd")
    " Load indentation rules according to the detected filetype.
    filetype plugin indent on

    " Makefile sanity
    autocmd BufNewFile,BufRead ?akefile* set noet ts=4 sw=4
    autocmd BufNewFile,BufRead */debian/rules set noet ts=4 sw=4
    " Special Dockerfile matches
    autocmd BufNewFile,BufRead Dockerfile.* setf dockerfile
endif

" Fancy features
set autowrite       " Automatically save before commands like :next and :make
"set hidden          " Hide buffers when they are abandoned
set ignorecase      " Do case insensitive matching
set incsearch       " Incremental search
set modeline        " Parse vim modelines
"set mouse=a         " Enable mouse usage (all modes) in terminals
set showcmd         " Show (partial) command in status line.
set showmatch       " Show matching brackets.
set smartcase       " Do smart case matching

" Keybindings
nnoremap <silent> <Leader>w :w<CR>
nnoremap <silent> <Leader>q :q<CR>

"
" Plugin Config
"

" netrw + vinegar
let g:netrw_home = g:vim_cache_dir
let g:netrw_liststyle = 3
let g:netrw_nogx = 1
nnoremap <silent> <Leader>o :Lexplore<CR>

" Better Whitespace
let g:better_whitespace_ctermcolor='DarkGreen'
let g:better_whitespace_guicolor='DarkGreen'
let g:better_whitespace_filetypes_blacklist=['diff']

" Editorconfig
"let g:EditorConfig_verbose = 1
let g:EditorConfig_max_line_indicator = 'exceeding'
let g:EditorConfig_preserve_formatoptions = 1

" latex
let g:tex_flavor = 'latex'
