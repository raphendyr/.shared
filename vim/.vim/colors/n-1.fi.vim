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
" Highlight for the important elements of the status line (e.g., modified)
hi User1 cterm=None ctermfg=White ctermbg=DarkRed gui=None guifg=White guibg=DarkRed
hi User2 cterm=None ctermfg=Magenta ctermbg=Black gui=None guifg=White guibg=DarkRed
" Tab Line
hi Title cterm=NONE ctermfg=DarkYellow ctermbg=Black gui=NONE guifg=DarkYellow guibg=Black
hi TabLineSel cterm=NONE ctermfg=Black ctermbg=DarkYellow gui=NONE guifg=White guibg=Brown
hi TabLine cterm=NONE ctermfg=White ctermbg=DarkGray gui=NONE guifg=White guibg=DarkGray
hi TabLineFill cterm=NONE ctermfg=White ctermbg=DarkGray gui=NONE guifg=White guibg=DarkGray
" :ter[minal] mode
hi StatusLineTerm term=bold,reverse cterm=NONE ctermfg=Black ctermbg=DarkGreen gui=NONE guifg=White guibg=DarkGreen
hi StatusLineTermNC term=bold,reverse cterm=NONE ctermfg=White ctermbg=DarkGray gui=NONE guifg=White guibg=DarkGray
" Left side columns
hi LineNr term=NONE ctermfg=Gray ctermbg=Black
hi clear SignColumn
hi ALEErrorSign term=NONE ctermfg=Red ctermbg=Black
hi ALEWarningSign term=NONE ctermfg=Yellow ctermbg=Black

" vim: tw=0 ts=2 sw=2 et
