" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Load Once {{{
if exists('s:loaded') && s:loaded
    finish
endif
let s:loaded = 1
" }}}
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}



let s:finder = {}



function! cfi#load() "{{{
    " dummy function to load this script
endfunction "}}}

function! cfi#get_func_name(...) "{{{
    let filetype = a:0 ? a:1 : &l:filetype
    let NONE = ""

    if !s:has_key_f(s:finder, [filetype, 'find'])
        return NONE
    endif
    let val = s:finder[filetype].find()
    return type(val) == type("") ? val : NONE
endfunction "}}}

function! cfi#create_finder(filetype) "{{{
    if !has_key(s:finder, a:filetype)
        let s:finder[a:filetype] = {}
    endif
    return s:finder[a:filetype]
endfunction "}}}

function! cfi#has_supported_for(filetype) "{{{
    return has_key(s:finder, a:filetype)
endfunction "}}}



function! s:has_key_f(cont, keys) "{{{
    if empty(a:keys)
        echohl ErrorMsg
        echomsg "cfi: sorry, internal error. please report this to author."
        echohl None
        return 0
    elseif len(a:keys) == 1
        return has_key(a:cont, a:keys[0])
    else
        if has_key(a:cont, a:keys[0])
            return s:has_key_f(a:cont[a:keys[0]], a:keys[1:])
        else
            return 0
        endif
    endif
endfunction "}}}



" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
