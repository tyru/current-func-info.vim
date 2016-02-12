scriptencoding utf-8

if !exists('plugs["current-func-info.vim"]') | finish | endif

" ============================================================================
" Bootstrap
" ============================================================================

if get(g:, 'cfi_disable') || get(g:, 'loaded_cfi_ftplugin_javascript')
    finish
endif
let g:loaded_cfi_ftplugin_javascript = 1

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

" ============================================================================
" Options
" ============================================================================

if !exists('g:cfi_javascript_show_params')
    let g:cfi_javascript_show_params = 0
endif

" ============================================================================
" Regexes
" magic mode!
" ============================================================================

" anystring
let s:FUNCTION_NAME       = '\(\S\+\)'

" matches es6 classes and generator functions
" @TODO es6 member function shorthand `func() {}`
let s:FUNCTION_TYPE       = '\(get\|set\|static\|function\*\=\)'

" (...)
let s:FUNCTION_ARGUMENTS  = '\(' . '([^)]*)' . '\)'

" ----------------------------------------------------------------------------
" Composite regexes
" ----------------------------------------------------------------------------

let s:VARIABLE = ''
      \.  s:FUNCTION_NAME
      \.  '\%(\s*=\)\+'

let s:ANONYMOUS_FUNCTION = '\%('
      \.  s:FUNCTION_TYPE
      \.  '\s\+'
      \.  s:FUNCTION_ARGUMENTS
      \.'\)'

let s:NAMED_FUNCTION = '\%('
      \.  s:FUNCTION_TYPE
      \.  '\s\+'
      \.  s:FUNCTION_NAME
      \.  '\s*'
      \.  s:FUNCTION_ARGUMENTS
      \.'\)'

let s:ARROW_FUNCTION = ''
      \.  '\%(' . s:FUNCTION_ARGUMENTS . '\s*=>\s*' . '\)'

let s:BEGIN_PATTERN = '\C'
      \.'\%(' . s:ANONYMOUS_FUNCTION . '\|' . s:NAMED_FUNCTION .'\)\{1}'

" ============================================================================
" Create cfi finder dictionary of functions
" ============================================================================

let s:finder = cfi#create_finder('javascript')

" Matcher run on function start line if find_begin search found a starter
" @return {String}
function! s:finder.get_func_name() "{{{
  if l:self.phase !=# 1
    return ''
  endif

  let l:done = 0
  let l:variable_name = ''        " '[var ][abc.]xyz =  '
  let l:function_type = ''        " generator star
  let l:function_name = ''        " string
  let l:function_arguments = ''   " (arg, arg)
  let l:function_body = ' { ... }'       " => { }

  let l:matcher = matchlist(getline('.'), s:VARIABLE)
  if !empty(l:matcher)
    let l:variable_name = l:matcher[0] . ' '
  endif

  " hmm... maybe return early instead of storing values?
  " or use a map that returns a dict for a function that generates formatted
  " return value?

  let l:matcher = matchlist(getline('.'), s:NAMED_FUNCTION)
  if !empty(l:matcher)
    let l:function_type = l:matcher[1]
    let l:function_name = l:matcher[2]
    let l:function_arguments = l:matcher[3]
    let l:done = 1
  endif

  if !l:done
    let l:matcher = matchlist(getline('.'), s:ANONYMOUS_FUNCTION)
    if !empty(l:matcher)
      let l:function_type = l:matcher[1]
      let l:function_arguments = l:matcher[2]
      let l:done = 2
    endif
  endif

  if !l:done
    let l:matcher = matchlist(getline('.'), s:ARROW_FUNCTION)
    if !empty(l:matcher)
      let l:function_arguments = l:matcher[1]
      let l:function_body = ' => { ... }'
      let l:done = 3
    endif
  endif

  if !l:done
    return ''
  endif

  return l:variable_name
        \. (!empty(l:function_type) ? l:function_type . ' ' : '')
        \. l:function_name
        \. l:function_arguments
        \. l:function_body

endfunction "}}}

" Find line where function starts
" @return {List}
function! s:finder.find_begin() "{{{
  "if search(s:BEGIN_PATTERN, 'bW') == 0
  if search(').*{', 'bW') == 0
    return []
  endif

  let l:self.is_ready = 1
  return [line('.'), col('.')]
endfunction "}}}

" Find line where function ends
" @return {List}
function! s:finder.find_end() "{{{
  let l:self.is_ready = 0

  if search('{', 'W') == 0
    return []
  endif

  if searchpair('{', '', '}', 'W') == 0
    return []
  endif

    return [line('.'), col('.')]
endfunction "}}}

" ============================================================================
" Register
" ============================================================================

call cfi#register_finder('javascript', s:finder)
unlet s:finder

" ============================================================================
" Unbootstrap
" ============================================================================

let &cpo = s:save_cpo