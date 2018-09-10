" vim:foldmethod=marker:fen:
scriptencoding utf-8


if get(g:, 'cfi_disable') || get(g:, 'loaded_cfi_ftplugin_python')
    finish
endif
let g:loaded_cfi_ftplugin_python = 1

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}



let s:BEGIN_PATTERN = '\C'.'^\s*'.'\(def\|class\)\>'.'\s\+'.'\(\w\+\)'

let s:finder = cfi#create_finder('python')

function! s:finder.find(ctx) "{{{
    let save_view = winsaveview()

    let indent_num = indent(prevnonblank('.'))
    let namespace = []
    while 1
        let decl_pos = search(s:BEGIN_PATTERN, 'bW')
        if decl_pos == 0
            break
        endif

        let decl_indent_num = indent(prevnonblank('.'))
        if decl_indent_num < indent_num
            let m = matchlist(getline(decl_pos), s:BEGIN_PATTERN)
            let indent_num = decl_indent_num
            call insert(namespace, m[2])
        endif
    endwhile

    call winrestview(save_view)

    return join(namespace, '.')
endfunction "}}}

function! s:get_indent_num(lnum) "{{{
    let lnum = a:lnum
    if lnum == "."
        let lnum = line(lnum)
    endif
    if lnum == 0
        return 0
    endif
    if match(getline(lnum), '^[ \t]*$') >= 0
        return s:get_indent_num(lnum - 1)
    endif
    return strlen(matchstr(getline(lnum), '^[ \t]*'))
endfunction "}}}

function! s:get_multiline_string_range(search_begin, search_end) "{{{
    let MULTI_STR_RX = '\%('.'"""'.'\|'."'''".'\)'
    let range = []

    while 1
        " begin of multi string
        let begin = search(MULTI_STR_RX, 'W')
        if begin == 0 || !(a:search_begin <= begin && begin <= a:search_end)
            return range
        endif
        " end of multi string
        let end = search(MULTI_STR_RX, 'W')
        if end == 0 || !(a:search_begin <= end && end <= a:search_end)
            return range
        endif

        call add(range, [begin, end])
    endwhile
endfunction "}}}

function! s:in_multiline_string(range, lnum) "{{{
    " Ignore `begin` and `end` lnum.
    " Because they are lnums where """ or ''' is.
    for [begin, end] in a:range
        if begin < a:lnum && a:lnum < end
            return 1
        endif
    endfor
    return 0
endfunction "}}}

call cfi#register_simple_finder('python', s:finder)
unlet s:finder




let &cpo = s:save_cpo
