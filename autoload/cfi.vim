" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

" Define g:cfi_disable, and so on.
runtime! plugin/cfi.vim


let s:finder = {}

let s:TYPE_STRING = type("")
let s:TYPE_NUMBER = type(0)
let s:TYPE_DICT = type({})



function! cfi#load() "{{{
    " Dummy function to load this file.
endfunction "}}}

function! cfi#get_func_name(...) "{{{
    let NONE = ""
    if g:cfi_disable
        return NONE
    endif
    let dotfiletypes = a:0 ? a:1 : &l:filetype
    if dotfiletypes ==# ''
        return NONE
    endif
    let filetype = cfi#choose_finder_filetype(dotfiletypes)
    if filetype ==# ''
        return NONE
    endif
    let ctx = {'lnum': line('.'), 'col': col('.')}
    let cache = s:get_cache(ctx, {})
    if !empty(cache)
        return cache.funcname
    endif

    let orig_view = winsaveview()
    try
        let val = s:finder[filetype].find(deepcopy(ctx))
        if type(val) == s:TYPE_DICT
            if !empty(val) && val.funcname !=# ''
                let val.version = s:get_current_version()
                call s:save_cache(ctx, val)
                return val.funcname
            else
                return NONE
            endif
        elseif type(val) == s:TYPE_STRING
            return val
        endif
        return NONE
    finally
        call winrestview(orig_view)
    endtry
endfunction "}}}

if has('*undotree')
    function! s:get_current_version() "{{{
        return undotree().seq_cur
    endfunction "}}}
else
    function! s:get_current_version() "{{{
        return b:changedtick
    endfunction "}}}
endif

function! cfi#format(fmt, default) "{{{
    let name = cfi#get_func_name()
    if name != ''
        return printf(a:fmt, name)
    else
        return a:default
    endif
endfunction "}}}

function! cfi#create_finder(filetype) "{{{
    return extend({'is_ready': 0, 'phase': 0}, deepcopy(s:base_finder), 'keep')
endfunction "}}}

function! cfi#supported_filetype(filetype) "{{{
    return cfi#supported_filetypes(a:filetype)
endfunction "}}}

function! cfi#supported_filetypes(dotfiletypes) "{{{
    return cfi#choose_finder_filetype(a:dotfiletypes) !=# ''
endfunction "}}}

function! cfi#choose_finder_filetype(dotfiletypes) "{{{
    return get(
    \   filter(split(a:dotfiletypes, '\.'), 'has_key(s:finder, v:val)'),
    \   0, '')
endfunction "}}}

function! cfi#register_finder(filetype, finder) "{{{
    if has_key(s:finder, a:filetype)
        return
    endif
    if !has_key(a:finder, 'find')
    \   || !has_key(a:finder, 'get_func_name')
    \   || !has_key(a:finder, 'find_begin')
    \   || !has_key(a:finder, 'find_end')
        call s:error('cfi#register_finder(): finder for ' . a:filetype
        \          . ' does not have all required methods:'
        \          . ' find(), get_func_name(), find_begin(), find_end()')
        return
    endif
    let s:finder[a:filetype] = a:finder
endfunction "}}}

function! cfi#register_simple_finder(filetype, finder) "{{{
    if has_key(s:finder, a:filetype)
        return
    endif
    if !has_key(a:finder, 'find')
        call s:error('cfi#register_finder(): finder for ' . a:filetype
        \          . ' does not have required method:'
        \          . ' find()')
        return
    endif
    let s:finder[a:filetype] = a:finder
endfunction "}}}



" s:base_finder {{{
let s:base_finder = {}

function! s:base_finder.find(ctx) "{{{
    let orig_pos = [a:ctx.lnum, a:ctx.col]
    let NONE = {}
    let ret = {}
    let self._result = ret
    let self.temp = {}

    try
        let self.phase = 1
        let ret.begin_pos = self.find_begin()
        if empty(ret.begin_pos)
            return NONE
        endif
        if self.is_ready
            let ret.funcname = self.get_func_name()
        endif

        let self.phase = 2
        let ret.end_pos = self.find_end()
        if empty(ret.end_pos)
            return NONE
        endif
        if self.is_ready && get(ret, 'funcname', '') ==# ''
            let ret.funcname = self.get_func_name()
        endif
        if ret.funcname ==# ''
            return NONE
        endif

        " function's begin pos -> {original pos} -> function's end pos
        if !self.in_function(orig_pos)
            return NONE
        endif

        return ret
    finally
        let self.is_ready = 0
        let self.phase = 0
    endtry
endfunction "}}}

function! s:base_finder.in_function(pos) "{{{
    return self.pos_between(
    \   self._result.begin_pos,
    \   a:pos,
    \   self._result.end_pos,
    \)
endfunction "}}}

function! s:base_finder.pos_between(pos1, pos2, pos3) "{{{
    return s:pos_is_less_than(a:pos1, a:pos2)
    \   && s:pos_is_less_than(a:pos2, a:pos3)
endfunction "}}}

function! s:base_finder.get_begin_pos() "{{{
    return self._result.begin_pos
endfunction "}}}

function! s:base_finder.get_end_pos() "{{{
    return self._result.end_pos
endfunction "}}}

" }}}



function! s:get_cache(ctx, else) "{{{
    if exists('b:cfi_last_result')
        let key = join([s:get_current_version(), a:ctx.lnum, a:ctx.col], '|')
        if has_key(b:cfi_last_result, key)
            return b:cfi_last_result[key]
        endif
    endif
    if exists('b:cfi_cache_list')
        let [index, found] = s:bsearch_nearest_index(b:cfi_cache_list, a:ctx)
        if found && b:cfi_cache_list[index].version is s:get_current_version()
            return b:cfi_cache_list[index]
        endif
    endif
    return a:else
endfunction "}}}

function! s:save_cache(ctx, val) "{{{
    call s:save_cache_list(a:ctx, a:val)
    if !exists('b:cfi_last_result')
        let b:cfi_last_result = {}
    endif
    let key = join([s:get_current_version(), a:ctx.lnum, a:ctx.col], '|')
    let b:cfi_last_result = {key : a:val}
endfunction "}}}

function! s:save_cache_list(ctx, val) "{{{
    if !exists('b:cfi_cache_list')
        let b:cfi_cache_list = []
    endif

    " Search cache.
    let [index, found] = s:bsearch_nearest_index(b:cfi_cache_list, a:ctx)
    if found
        " Update cache.
        let b:cfi_cache_list[index] = a:val
    else
        " Save cache.
        call insert(b:cfi_cache_list, a:val)
    endif

    " TODO: Get rid of old cache.
    " if len(b:cfi_cache_list) ># 30
    "   ...
    " endif
endfunction "}}}

function! s:bsearch_nearest_index(list, ctx) "{{{
    if empty(a:list)
        return [0, 0]
    endif
    let [begin, end] = [0, len(a:list) - 1]
    let found = 0
    while 1
        let middle = (begin + end) / 2
        let ret = s:compare_pos_to_range(a:ctx, a:list[middle])
        if ret is 0
            let found = 1
            break
        elseif ret <# 0
            let begin = middle
        else
            let end = middle
        endif
        if middle is (begin + end) / 2
            break
        endif
    endwhile
    return [middle, found]
endfunction "}}}

function! s:compare_pos_to_range(pos, range) "{{{
    let [lnum, col] = [a:pos.lnum, a:pos.col]
    let [begin_lnum, begin_col] = a:range.begin_pos
    let [end_lnum, end_col] = a:range.end_pos
    if lnum <# begin_lnum ||
    \   (lnum is begin_lnum && col <# begin_col)
        return -1
    elseif lnum ># end_lnum ||
    \   (lnum is end_lnum && col ># end_col)
        return 1
    else
        return 0
    endif
endfunction "}}}

function! s:pos_is_less_than(pos1, pos2) "{{{
    let [lnum1, col1] = a:pos1
    let [lnum2, col2] = a:pos2
    return
    \   lnum1 <# lnum2
    \   || (lnum1 is lnum2
    \       && col1 <# col2)
endfunction "}}}

function! s:error(msg) "{{{
    call s:echomsg("ErrorMsg", a:msg)
endfunction "}}}

function! s:echomsg(hl, msg) "{{{
    execute 'echohl' a:hl
    try
        echomsg a:msg
    finally
        echohl None
    endtry
endfunction "}}}



" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
