" vim:foldmethod=marker:fen:
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let s:BEGIN_PATTERN = '\C'.'^\s*'.'fu\%[nction]\>'.'!\='.'\s\+'.'\([^(]\+\)'.'('
let s:END_PATTERN = '\C'.'^\s*'.'endf*\%[unction]\>'


let s:finder = cfi#create_finder('vim')
function! s:finder.find()
    let NONE = -1

    if !s:in_function()
        return NONE
    endif

    le begin_lnum = s:search(s:BEGIN_PATTERN)
    let m = matchlist(getline(begin_lnum), s:BEGIN_PATTERN)
    if empty(m)
        return NONE
    endif
    return m[1]
endfunction
unlet s:finder

function! s:in_function() "{{{
    let [begin_lnum, end_lnum] = [s:search(s:BEGIN_PATTERN), s:search(s:END_PATTERN)]
    if begin_lnum == 0 || end_lnum == 0 || begin_lnum < end_lnum
        return 0
    endif

    let begin_lnum = s:rsearch(s:BEGIN_PATTERN)
    if begin_lnum == 0
        return 0
    endif

    return 1
endfunction "}}}

function! s:search(pattern) "{{{
    let r = match(getline('.', '$'), a:pattern)
    if r == -1
        return 0
    endif
    return line('.') + r
endfunction "}}}

function! s:rsearch(pattern) "{{{
    let r = match(getline(1, '.'), a:pattern)
    if r == -1
        return 0
    endif
    return r + 1
endfunction "}}}




let &cpo = s:save_cpo
