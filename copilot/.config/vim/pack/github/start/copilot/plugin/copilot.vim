" Copilot
let s:node_version='18.12.1'
let s:nvm_base=(exists("$XDG_DATA_DIR") ? $XDG_DATA_DIR : $HOME."/.local/share").'/nvm'
let s:nvm_sh=s:nvm_base.'/nvm.sh'
let g:copilot_node_command=s:nvm_base.'/versions/node/v'.s:node_version.'/bin/node'

" Download if node doesn't exists
if !filereadable(g:copilot_node_command)
    echo 'Copilot requires Node '.s:node_version.', installing...'
    execute '!bash -c "echo; . \"'.s:nvm_sh.'\"; nvm install '.s:node_version.';"'
endif

" Map right arrow to Accept
imap <script><silent><nowait><expr> <Right> copilot#Accept("\<Right>")
nnoremap <silent> <Leader>c :let b:copilot_enabled = !get(b:, 'copilot_enabled', 1)<CR>

" Delay status line, until buffer is read
function! s:update_status(...)
    if exists('*copilot#Enabled')
        let b:copilot_statusline = copilot#Enabled()
    endif
endfunction
function! s:update_delay(...)
    let s:update_timer = timer_start(200, 's:update_status', {'repeat': -1})
endfunction
autocmd VimEnter,OptionSet * call s:update_delay()

" Disable copilot for specific projects
autocmd BufNewFile,BufRead */Projects/* let b:copilot_enabled = 0

" Load the real plugin
packadd copilot.vim
