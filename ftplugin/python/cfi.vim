" vim:foldmethod=marker:fen:
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


if exists('s:loaded') && s:loaded
    finish
endif
let s:loaded = 1



let s:BEGIN_PATTERN = '\C'.'^\s*'.'def\>'.'\s\+'.'\(\w\+\)'

let s:finder = cfi#create_finder('python')

function! s:finder.find() "{{{
    let NONE = 0
    let orig_lnum = line('.')
    let indent_num = s:get_indent_num('.')
    let save_view = winsaveview()

    try
        let pos = search(s:BEGIN_PATTERN, 'bW')
        if pos == 0
            return NONE
        endif

        " Function's indent must be lower than indent_num or same.
        if s:get_indent_num('.') > indent_num
            return NONE
        endif

        " XXX: This does not suppose here document.
        if 0
            " The range from function name to current pos
            " must has stepwise indent num.
            let n = s:get_indent_num('.')
            for lnum in range(line('.'), orig_lnum)
                if s:get_indent_num(lnum) < n
                    return NONE
                endif
            endfor
        endif

        let m = matchlist(getline('.'), s:BEGIN_PATTERN)
        if empty(m)
            return NONE
        endif
        return m[1]
    finally
        call winrestview(save_view)
    endtry
endfunction "}}}

function! s:get_indent_num(lnum)
    return strlen(matchstr(getline(a:lnum), '^[ \t]*'))
endfunction "}}}

unlet s:finder




let &cpo = s:save_cpo
