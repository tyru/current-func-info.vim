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
    runtime! plugin/cfi.vim
endfunction "}}}

function! cfi#get_func_name(...) "{{{
    let filetype = a:0 ? a:1 : &l:filetype
    let NONE = ""

    if !has_key(s:finder, filetype)
        " TODO
        " If there is [[ keymapping, use it.
        " (In C (especially C++), it had better use [m keymapping)
        return NONE
    endif

    if !s:finder[filetype]._mixed
        call extend(s:finder[filetype], deepcopy(s:base_finder), 'keep')
        let s:finder[filetype]._mixed = 1
    endif

    if !has_key(s:finder[filetype], 'find')
        return NONE
    endif

    let val = s:finder[filetype].find()
    return type(val) == type("") ? val : NONE
endfunction "}}}

function! cfi#create_finder(filetype) "{{{
    if !has_key(s:finder, a:filetype)
        let s:finder[a:filetype] = {'_mixed': 0, 'is_ready': 0, 'phase': 0, 'is_normal_used': 0}
    endif
    return s:finder[a:filetype]
endfunction "}}}

function! cfi#has_supported_for(filetype) "{{{
    return has_key(s:finder, a:filetype)
endfunction "}}}



let s:base_finder = {}

function! s:base_finder.find() "{{{
    " TODO Cache while being in function.
    let NONE = 0
    let orig_view = winsaveview()
    let [orig_lnum, orig_col] = [line('.'), col('.')]
    let match = NONE
    let skipped_find_end = 0

    if !s:has_base_finder_find_must_methods(self)
        return NONE
    endif

    try
        let self.phase = 1
        if self.find_begin() == 0
            return NONE
        endif
        if self.is_ready
            let match = self.get_func_name()
        endif

        let [begin_lnum, begin_col] = [line('.'), col('.')]

        let self.phase = 2
        if match is NONE
            if self.find_end() == 0
                return NONE
            endif
            if self.is_ready
                let match = self.get_func_name()
            endif
            if match is NONE
                return NONE
            endif
        else
            let skipped_find_end = 1
        endif

        " function's begin pos -> {original pos} -> function's end pos
        let in_function =
        \   self.pos_is_less_than([begin_lnum, begin_col], [orig_lnum, orig_col])
        \   && (skipped_find_end
        \       || self.pos_is_less_than([orig_lnum, orig_col], [line('.'), col('.')]))
        if !in_function
            return NONE
        endif

        return match
    finally
        let self.is_ready = 0
        let self.phase = 0
        let self.is_normal_used = 0

        call winrestview(orig_view)
    endtry
endfunction "}}}

function! s:has_base_finder_find_must_methods(this) "{{{
    if !has_key(a:this, 'get_func_name')
        return 0
    endif
    if !has_key(a:this, 'find_begin')
        return 0
    endif
    if !has_key(a:this, 'find_end')
        return 0
    endif
    return 1
endfunction "}}}

function! s:base_finder.pos_is_less_than(pos1, pos2) "{{{
    let [lnum1, col1] = a:pos1
    let [lnum2, col2] = a:pos2
    return
    \   lnum1 < lnum2
    \   || (lnum1 == lnum2
    \       && col1 < col2)
endfunction "}}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
