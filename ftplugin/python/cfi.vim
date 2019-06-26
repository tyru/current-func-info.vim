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



let s:BEGIN_PATTERN = '\C'.'^\s*'.'\(def\|class\|async def\)\>'.'\s\+'.'\(\w\+\)'

let s:finder = cfi#create_finder('python')

function! s:finder.find(ctx) "{{{
    let save_view = winsaveview()

    let ini_pos = prevnonblank('.')
    let indent_num = indent(ini_pos)
    let namespace = []
    while 1
        let decl_pos = search(s:BEGIN_PATTERN, 'bW')
        if decl_pos == 0
            break
        endif

        let decl_indent_num = indent(prevnonblank('.'))
        if decl_indent_num < indent_num || (len(namespace) == 0 && ini_pos == decl_pos)
            let m = matchlist(getline(decl_pos), s:BEGIN_PATTERN)
            let indent_num = decl_indent_num
            call insert(namespace, m[2])
        endif
    endwhile

    call winrestview(save_view)

    return join(namespace, '.')
endfunction "}}}

call cfi#register_simple_finder('python', s:finder)
unlet s:finder




let &cpo = s:save_cpo
