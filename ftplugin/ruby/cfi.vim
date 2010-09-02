" vim:foldmethod=marker:fen:
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


if exists('s:loaded') && s:loaded
    finish
endif
let s:loaded = 1



let s:BEGIN_PATTERN = '\C'.'^\s*'.'def\>'.'\s\+'.'\('.'[^(]\+'.'\)'.'\%('.'\s*'.'('.'\=\)'

let s:finder = cfi#create_finder('ruby')

function s:finder.find() "{{{
    let NONE = 0

    if search(s:BEGIN_PATTERN, 'bW') == 0
        return NONE
    endif

    let m = matchlist(getline('.'), s:BEGIN_PATTERN)
    if empty(m)
        return NONE
    endif

    return m[1]
endfunction "}}}

unlet s:finder




let &cpo = s:save_cpo
