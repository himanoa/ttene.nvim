scriptencoding utf-8
if exists('g:loaded_ttene')
  finish
endif

let g:loaded_ttene = 1

if !exists('g:ttene_play_command') || !executable(g:ttene_play_command)
  if executable('mplayer')
    let g:ttene_play_command = 'mplayer'
  elseif executable('afplay')
    let g:ttene_play_command = 'afplay'
  else
    finish
  endif
endif

if !exists('g:ttene_shuf') || !executable(g:ttene_shuf)
  if executable('shuf')
    let g:ttene_shuf = 'shuf'
  elseif executable('gshuf')
    let g:ttene_shuf = 'gshuf'
  else
    finish
  endif
endif

let s:voices = expand('<sfile>:p:h') . '/../voices'

function! s:play() abort
  execute 'AsyncRun find ' . s:voices . ' | ' . g:ttene_shuf . '| head -n1 | xargs -In1 ' . g:ttene_play_command . ' n1'
endfunction

function! s:prepare_mappings() abort
  inoremap <buffer> <CR> <C-o>:<C-u>call <SID>play()<CR><CR>
endfunction

augroup ttene
  autocmd!
  autocmd InsertEnter * call s:prepare_mappings()
augroup END
