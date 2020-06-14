" Append modeline after last line in buffer.
"  note: Use substitute() instead of printf() to handle '%%s' modeline
"  in LaTeX files.

if !exists('AppendModeline')
    function s:AppendModeline()
        let l:modeline = printf(
            \ " vim: set ts=%d sw=%d tw=%d %set syn=%s ft=%s :",
            \ &tabstop, &shiftwidth, &textwidth, &expandtab ? '' : 'no',
            \ &syntax, &filetype)
        let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
        call append(line("$"), l:modeline)
    endfunction

    nnoremap <silent> <Leader>ml :call <SID>AppendModeline()<CR>
endif
