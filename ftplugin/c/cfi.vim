" vim:foldmethod=marker:fen:
scriptencoding utf-8


if get(g:, 'cfi_disable') || get(g:, 'loaded_cfi_ftplugin_c')
    finish
endif
let g:loaded_cfi_ftplugin_c = 1

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}



let s:finder = cfi#create_finder('c')

function! s:finder.get_func_name() "{{{
    let NONE = ''
    if self.phase isnot 2
        return NONE
    endif

    let function_pattern = '\C'.'\(\w\+\)\s*('
    let orig_pos = getpos('.')

    try
        if search(function_pattern, 'bW') == 0
            return NONE
        endif
        let funcname_lnum = line('.')

        " Jump to function-like word, and check arguments, and block.
        for [fn; args] in [
        \   ['search', '(', 'W'],
        \   ['searchpair', '(', '', ')'],
        \   ['search', '{'],
        \]
            if call(fn, args) == 0
                return NONE
            endif
        endfor

        if !self.pos_between(
        \   [funcname_lnum, 1],
        \   getpos('.')[1:2],
        \   self.get_end_pos())
            " current position is not in a function.
            return NONE
        endif

        let m = matchlist(getline(funcname_lnum), function_pattern)
        if empty(m)
            return NONE
        endif
        return m[1]
    finally
        call setpos('.', orig_pos)
    endtry
endfunction "}}}

function! s:finder.find_begin() "{{{
    let NONE = []
    let [orig_lnum, orig_col] = [line('.'), col('.')]

    let vb = &vb
    setlocal vb t_vb=
    normal! [m
    let &vb = vb

    if line('.') == orig_lnum && col('.') == orig_col
        return NONE
    endif
    return [line('.'), col('.')]
endfunction "}}}

function! s:finder.find_end() "{{{
    let NONE = []
    let [orig_lnum, orig_col] = [line('.'), col('.')]

    let vb = &vb
    setlocal vb t_vb=
    normal! ]M
    let &vb = vb

    if line('.') == orig_lnum && col('.') == orig_col
        return NONE
    endif
    let self.is_ready = 1
    return [line('.'), col('.')]
endfunction "}}}

call cfi#register_finder('c', s:finder)
unlet s:finder



let &cpo = s:save_cpo
