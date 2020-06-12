"
" Naive automatic indentation detection
"

" Disable if editorconfig has configured the buffer
function s:MySettabsEC(config)
    let b:MySettabsDone = 
        \ index(g:EditorConfig_disable_rules, 'indent_style') < 0 &&
        \ has_key(a:config, 'indent_style') &&
        \ index(['tab', 'space'], a:config['indent_style']) >= 0
    return 0
endfunction

" Naive detection
function s:MySettabs()
    "echo printf("MySettabs(): expandtab: %s, ts: %d, sw: %d", &expandtab, &tabstop, &shiftwidth)
    if !exists("b:MySettabsDone") || b:MySettabsDone
        let l:endline = 100 " '$'
        let l:tabs = len(filter(getbufline(winbufnr(0), 1, l:endline), 'v:val =~ "^\\t"'))
        let l:spaces = len(filter(getbufline(winbufnr(0), 1, l:endline), 'v:val =~ "^ "'))
        if l:tabs > l:spaces
            setl noexpandtab
        else
            setl expandtab
        endif
    let b:MySettabsDone = 1
    endif
    " mark tabs when we indent with spaces
    if &expandtab
        setl list listchars=tab:►\ " > and spaces
    endif
endfunction

" Delay loading, so editorconfig is before us
function s:MySettabsInit()
    if exists("g:loaded_EditorConfig")
        call editorconfig#AddNewHook(function('s:MySettabsEC'))
    endif
    augroup MySettabs
        autocmd!
        autocmd BufReadPost,BufFilePost * call s:MySettabs()
    augroup END
endfunction

" Automatically load when first buffer is populated
augroup MySettabs
    autocmd BufNewFile,BufReadPre,BufFilePre * call s:MySettabsInit()
augroup END
