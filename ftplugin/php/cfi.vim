" vim:foldmethod=marker:fen:
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


if exists('s:loaded') && s:loaded
    finish
endif
let s:loaded = 1



if !exists('g:cfi_php_show_params')
    let g:cfi_php_show_params = 0
endif



if g:cfi_php_show_params
    let s:BEGIN_PATTERN = '\C'.'^\s*'.'\%(public\s\+\|static\s\+\|abstract\s\+\|protected\s\+\|private\s\+\)\{-}'.'function\>'.'\s\+'.'\('.'.*$'.'\)'
else
    let s:BEGIN_PATTERN = '\C'.'^\s*'.'\%(public\s\+\|static\s\+\|abstract\s\+\|protected\s\+\|private\s\+\)\{-}'.'function\>'.'\s\+'.'\('.'[^(]\+'.'\)'.'\%('.'\s*'.'('.'\=\)'
endif

let s:finder = cfi#create_finder('php')

function! s:finder.get_func_name() "{{{
    let NONE = 0

    if self.phase !=# 1
        return NONE
    endif

    let m = matchlist(getline('.'), s:BEGIN_PATTERN)
    if empty(m)
        return NONE
    endif

    return m[1]
endfunction "}}}

function! s:finder.find_begin() "{{{
    let NONE = 0
    let [orig_lnum, orig_col] = [line('.'), col('.')]
    normal! [m
    if line('.') == orig_lnum && col('.') == orig_col
        return NONE
    endif
    let self.is_ready = 1
    return line('.')
endfunction "}}}

function! s:finder.find_end() "{{{
    let NONE = 0
    let [orig_lnum, orig_col] = [line('.'), col('.')]
    normal! ]M
    if line('.') == orig_lnum && col('.') == orig_col
        return NONE
    endif
    let self.is_ready = 1
    return line('.')
endfunction "}}}

unlet s:finder




let &cpo = s:save_cpo
