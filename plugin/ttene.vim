scriptencoding utf-8
if exists('g:loaded_ttenesana')
  finish
endif

let g:loaded_ttenesana = 1

if has('mac')
  let g:command = 'afplay'
endif
if has('unix')
  let g:command = 'mplayer'
endif

let g:voices = expand('<sfile>:p:h') . '/../voices'
let g:onEnter = ":AsyncRun find " . g:voices . " | shuf | head -n1 | xargs -In1 " . g:command . " n1"
autocmd InsertEnter * imap <script> <CR> <ESC>:<C-u>execute g:onEnter<CR>a<CR>
