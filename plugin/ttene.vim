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

let s:voices_dir = expand('<sfile>:p:h') . '/../voices'

function! s:play() abort
  let voice = s:pick_voice()
  if empty(voice)
    call s:error('no voices installed. see README.md')
    sleep 1
    return
  endif
  if exists(':AsyncRun') isnot 2
    call s:error('you need to install https://github.com/skywind3000/asyncrun.vim')
    sleep 1
    return
  endif
  execute 'AsyncRun' g:ttene_play_command voice
endfunction

function! s:error(msg) abort
  echohl ErrorMsg
  echomsg a:msg
  echohl None
endfunction

function! s:pick_voice() abort
  let voices = glob(s:voices_dir . '/*', 1, 1)
  if empty(voices)
    return ''
  endif
  let match_end = matchend(reltimestr(reltime()), '\d\+\.') + 1
  let i = reltimestr(reltime())[l:match_end : ] % len(voices)
  return voices[i]
endfunction

function! s:prepare_mappings() abort
  inoremap <buffer> <CR> <C-o>:<C-u>call <SID>play()<CR><CR>
  augroup ttene-local
    autocmd!
    autocmd InsertLeave <buffer> call s:play()
  augroup END
endfunction

augroup ttene
  autocmd!
  autocmd InsertEnter * call s:prepare_mappings()
augroup END
