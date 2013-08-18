" vim:foldmethod=marker:fen:
scriptencoding utf-8


if get(g:, 'cfi_disable') || get(g:, 'loaded_cfi_ftplugin_go')
    finish
endif
let g:loaded_cfi_ftplugin_go = 1

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}



let s:BEGIN_PATTERN = '\C'.'^\s*'.'func\>'.'\s\+'.'\((\w\+\s\+[^)]\+)\s\+\)\='.'\('.'[^(]\+'.'\)'.'\%('.'\s*'.'('.'\=\)'

let s:finder = cfi#create_finder('go')

function! s:finder.find(ctx) "{{{
    let NONE = ''

    if search(s:BEGIN_PATTERN, 'bW') == 0
        return NONE
    endif

    let m = matchlist(getline('.'), s:BEGIN_PATTERN)
    if empty(m)
        return NONE
    endif

    return m[1].m[2]
endfunction "}}}

call cfi#register_simple_finder('go', s:finder)
unlet s:finder




let &cpo = s:save_cpo

