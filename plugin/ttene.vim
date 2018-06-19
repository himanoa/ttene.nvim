scriptencoding utf-8
if exists('g:loaded_ttenesana')
  finish
endif

let g:loaded_ttenesana = 1

if executable('mplayer')
  let g:ttene_play_command = 'mplayer'
elseif executable('afplay')
  let g:ttene_play_command = 'afplay'
else
  finish
endif

if executable('shuf')
  let g:ttene_shuf = 'shuf'
elseif executable('gshuf')
  let g:ttene_shuf = 'gshuf'
else
  finish
endif

let s:voices = expand('<sfile>:p:h') . '/../voices'

function! s:on_enter() abort
  execute 'AsyncRun find ' . s:voices . ' | ' . g:ttene_shuf . '| head -n1 | xargs -In1 ' . g:ttene_play_command . ' n1'
  execute "normal! \<CR>"
endfunction

function! s:prepare_mappings() abort
  inoremap <buffer> <CR> <ESC>:<C-u>call <SID>on_enter()<CR>
endfunction

augroup ttene
  autocmd!
  autocmd InsertEnter * call s:prepare_mappings()
augroup END
