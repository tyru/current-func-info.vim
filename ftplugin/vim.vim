" vim:foldmethod=marker:fen:
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim



let s:finder = cfi#create_finder('vim')
function! s:finder.find()
    let begin_pattern = '\C'.'^\s*'.'fu\%[nction]\>'.'!\='.'\s\+'.'\([^(]\+\)'.'('
    let end_pattern = '\C'.'^\s*'.'endf*\%[unction]\>'
    let NONE = -1

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
endfunction
unlet s:finder




let &cpo = s:save_cpo
