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
colorscheme n-1.fi
set ts=4 sw=4
set formatoptions-=tc

if has("autocmd")
    " Load indentation rules according to the detected filetype.
    filetype plugin indent on

    " Makefile sanity
    autocmd BufNewFile,BufRead ?akefile* set noet ts=4 sw=4
    autocmd BufNewFile,BufRead */debian/rules set noet ts=4 sw=4
    autocmd BufNewFile,BufRead */debian/control* set noet ts=4 sw=4 textwidth=74 colorcolumn=75
    " Special Dockerfile matches
    autocmd BufNewFile,BufRead Dockerfile.* setf dockerfile
    " Some json files are really json5 files
    autocmd BufNewFile,BufRead tsconfig.json set ft=json5 ts=2 sw=2
endif

" Fancy features
set autowrite       " Automatically save before commands like :next and :make
"set hidden          " Hide buffers when they are abandoned
set ignorecase      " Do case insensitive matching
set incsearch       " Incremental search
set modeline        " Parse vim modelines
set modelines=4
"set mouse=a         " Enable mouse usage (all modes) in terminals
set showcmd         " Show (partial) command in status line.
set showmatch       " Show matching brackets.
set smartcase       " Do smart case matching

" Keybindings
nnoremap <silent> <Leader>h :split<CR>
nnoremap <silent> <Leader>q :q<CR>
nnoremap <silent> <Leader>s :vsplit<CR>
nnoremap <silent> <Leader>v :vsplit<CR>
nnoremap <silent> <Leader>w :w<CR>

" Statusline
function! LinterStatus() abort
    let l:counts = ale#statusline#Count(bufnr(''))
    let l:errors = l:counts.error + l:counts.style_error
    let l:warnings = l:counts.total - l:errors
    return ''
    \ . warnings > 0 ? printf('%dW', warnings) : ''
    \ . warnings > 0 && errors > 0 ? ' ' : ''
    \ . errors > 0 ? printf('%dE', errors) : ''
endfunction

hi User1 cterm=None ctermfg=White ctermbg=DarkRed gui=None guifg=White guibg=DarkRed
set laststatus=2
set showmode
let &statusline  = ' %n %<%f '                          " Buffer number, File path, modified
let &statusline .= '%1*%{&ma && &mod?"[+]":""}%0*'      " highlighted modified tag
let &statusline .= '%(%1* %{LinterStatus()} %0*%)'       " Linter problems
let &statusline .= ' %( %R%W %)'                        " opt: readonly, preview
let &statusline .= ' %{&ft}'                            " FileType
let &statusline .= '%(,%{&fenc!="utf-8"?&fenc:""}%)'    " Encoding
let &statusline .= '%(,%{&ff!="unix"?&ff:""}%)'         " FileFormat
let &statusline .= '%='                                 " Right Side
let &statusline .= ' %c%V,%02l/%L (%P) '                " Column (-Visual column), Line / Total lines, Percentage
" DEFAULT: set statusline=%f\ %h%w%m%r\ %=%(%l,%c%V\ %=\ %P%)


"
" Plugin Config
"

" set regex engine, 0=auto
set regexpengine=0

" netrw + vinegar
let g:netrw_home = g:vim_cache_dir
let g:netrw_liststyle = 3
let g:netrw_nogx = 1
nnoremap <silent> <Leader>o :Explore!<CR>

" ALE
let g:ale_echo_msg_format = '[%linter%] %s [%severity%] %code%'
let g:ale_sign_error = '✘'
let g:ale_sign_warning = '‼'
let g:ale_lint_on_text_changed = 'never'

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
