" vim:foldmethod=marker:fen:
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim



let s:finder = cfi#create_finder('perl')
function! s:finder.find() "{{{
    let noignorecase = '\C'
    let funcname = '\(\w\+\)'
    let attr = '\%('.'\s*'.'([^()]*)'.'\)\='
    let begin_pattern = noignorecase.'^\s*'.'sub\>'.'\s\+'.funcname.attr
    let whites_and_newlines = '[[:space:][:return:]]*'
    let block_first_brace = whites_and_newlines.'\zs{'

    let NONE = -1
    let orig_pos = getpos('.')
    let [orig_lnum, orig_col] = [orig_pos[1], orig_pos[2]]

    try
        let begin_lnum = search(begin_pattern.block_first_brace, 'bW')
        if begin_lnum == 0
            return NONE
        endif

        let [block_lnum, block_col] = [line('.'), col('.')]
        let pos = searchpair('{', '', '}')
        if pos == 0
            return NONE
        endif
        " sub { -> {original pos} -> }
        let in_sub =
        \   s:pos_is_less_than([block_lnum, block_col], [orig_lnum, orig_col])
        \   && s:pos_is_less_than([orig_lnum, orig_col], [line('.'), col('.')])
        if !in_sub
            return NONE
        endif

        let m = matchlist(getline(begin_lnum), begin_pattern)
        if empty(m)
            return NONE
        endif
        return m[1]
    finally
        call setpos('.', orig_pos)
    endtry
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
