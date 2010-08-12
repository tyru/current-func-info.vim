" vim:foldmethod=marker:fen:
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim



let s:finder = cfi#create_finder('c')

function! s:finder.get_func_name() "{{{
    let NONE = 0
    let pat = '\C'.'\(\w\+\)('
    let lnum = search(pat, 'bnW')
    if lnum == 0
        return NONE
    endif
    if abs(lnum - line('.')) > 1
        return NONE
    endif
    let m = matchlist(getline(lnum), pat)
    if empty(m)
        return NONE
    endif
    return m[1]
endfunction "}}}

function! s:finder.find_begin_normal() "{{{
    let NONE = 0
    let [orig_lnum, orig_col] = [line('.'), col('.')]
    normal! [m
    if line('.') == orig_lnum && col('.') == orig_col
        return NONE
    endif
    let self.is_ready = 1
    return line('.')
endfunction "}}}

function! s:finder.find_end_normal() "{{{
    let NONE = 0
    let [orig_lnum, orig_col] = [line('.'), col('.')]
    normal! ]M
    if line('.') == orig_lnum && col('.') == orig_col
        return NONE
    endif
    let self.is_ready = 1
    return line('.')
endfunction "}}}




let &cpo = s:save_cpo
