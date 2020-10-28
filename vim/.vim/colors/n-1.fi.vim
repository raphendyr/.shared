" Vim color file

set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "n-1.fi"

" Status Line & window frame
hi  StatusLine term=bold,reverse cterm=NONE ctermfg=Black ctermbg=DarkYellow gui=NONE guifg=White guibg=Brown
hi  StatusLineNC term=bold,reverse cterm=NONE ctermfg=White ctermbg=DarkGray gui=NONE guifg=White guibg=DarkGray
hi  VertSplit term=bold,reverse cterm=NONE ctermfg=LightGray ctermbg=DarkGray gui=NONE guifg=White guibg=DarkGray
" Tab Line
hi Title cterm=NONE ctermfg=DarkYellow ctermbg=Black gui=NONE guifg=DarkYellow guibg=Black
hi TabLineSel cterm=NONE ctermfg=Black ctermbg=DarkYellow gui=NONE guifg=White guibg=Brown
hi TabLine cterm=NONE ctermfg=White ctermbg=DarkGray gui=NONE guifg=White guibg=DarkGray
hi TabLineFill cterm=NONE ctermfg=White ctermbg=DarkGray gui=NONE guifg=White guibg=DarkGray

" vim: tw=0 ts=2 sw=2 et
