" vim:foldmethod=marker:fen:
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim



let s:finder = cfi#create_finder('perl')
function! s:finder.find() "{{{
    let begin_pattern = '\C'.'^\s*'.'sub\>'.'\s\+'.'\(\w\+\)'
    let NONE = -1

    if !s:in_sub()
    endif

    let [begin_lnum, end_lnum] = [search(begin_pattern, 'nW'), search(end_pattern, 'nW')]
    if end_lnum == 0 || begin_lnum < end_lnum
        return NONE
    endif

    let begin_lnum = search(begin_pattern, 'bnW')
    if begin_lnum == 0
        return NONE
    endif

    let m = matchlist(getline(begin_lnum), begin_pattern)
    if empty(m)
        return NONE
    endif
    return m[1]
endfunction "}}}
unlet s:finder


function! s:in_sub() "{{{
endfunction "}}}




let &cpo = s:save_cpo
