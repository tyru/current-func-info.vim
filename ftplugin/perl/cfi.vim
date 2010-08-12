" vim:foldmethod=marker:fen:
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


if exists('s:loaded') && s:loaded
    finish
endif
let s:loaded = 1



let s:BEGIN_PATTERN = '\C'.'^\s*'.'sub\>'.'\s\+'.'\(\w\+\)'.'\%('.'\s*'.'([^()]*)'.'\)\='
let s:BLOCK_FIRST_BRACE = '[[:space:][:return:]]*'.'\zs{'

let s:finder = cfi#create_finder('perl')

function! s:finder.find() "{{{
    let NONE = 0
    let orig_pos = getpos('.')
    let [orig_lnum, orig_col] = [orig_pos[1], orig_pos[2]]

    try
        if self.find_begin() == 0
            return NONE
        endif
        let [begin_lnum, begin_col] = [line('.'), col('.')]
        if self.find_end() == 0
            return NONE
        endif

        " sub { -> {original pos} -> }
        let in_function =
        \   s:pos_is_less_than([begin_lnum, begin_col], [orig_lnum, orig_col])
        \   && s:pos_is_less_than([orig_lnum, orig_col], [line('.'), col('.')])
        if !in_function
            return NONE
        endif

        let m = matchlist(getline(begin_lnum), s:BEGIN_PATTERN)
        if empty(m)
            return NONE
        endif
        return m[1]
    finally
        call setpos('.', orig_pos)
    endtry
endfunction "}}}

function! s:finder.find_begin() "{{{
    let NONE = 0
    let begin_lnum = search(s:BEGIN_PATTERN.s:BLOCK_FIRST_BRACE, 'bW')
    if begin_lnum == 0
        return NONE
    endif
    return line('.')
endfunction "}}}

function! s:finder.find_end() "{{{
    let NONE = 0
    let pos = searchpair('{', '', '}')
    if pos == 0
        return NONE
    endif
    return line('.')
endfunction "}}}

unlet s:finder


function! s:pos_is_less_than(pos1, pos2)
    let [lnum1, col1] = a:pos1
    let [lnum2, col2] = a:pos2
    return
    \   lnum1 < lnum2
    \   || (lnum1 == lnum2
    \       && col1 < col2)
endfunction




let &cpo = s:save_cpo
