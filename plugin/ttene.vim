scriptencoding utf-8
if exists('g:loaded_ttenesana')
  finish
endif

let g:loaded_ttenesana = 1

if executable('mplayer')
  let g:play_command = 'mplayer'
elseif executable('afplay')
  let g:play_command = 'afplay'
else
  finish
endif

if executable('shuf')
  let g:shuf = 'shuf'
elseif executable('gshuf')
  let g:shuf = 'gshuf'
else
  finish
endif

let g:voices = expand('<sfile>:p:h') . '/../voices'
let g:on_enter = ":AsyncRun find " . g:voices . " | " . g:shuf . "| head -n1 | xargs -In1 " . g:play_command . " n1"
autocmd InsertEnter * imap <script> <CR> <ESC>:<C-u>execute g:on_enter<CR>a<CR>
