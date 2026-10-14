"=============================================================================
" Python Syntax, Snippets, Indent Guide & Dictionary Configuration
"=============================================================================
let s:dict_file = expand('<sfile>:p:h:h:h') . '/dict/python.dict'
if filereadable(s:dict_file)
    execute 'setlocal dictionary+=' . fnameescape(s:dict_file)
endif
silent! setlocal dictionary+=~/tiandir/python/tian/auto_complete.py

" Load snippets from snipet/python/
if exists('*snippet_engine#load_filetype')
    call snippet_engine#load_filetype('python')
endif

"-----------------------------------------------------------------------------
" 2. Python Syntax Highlighting
"-----------------------------------------------------------------------------
syn match     python_not         "{\w*"                         containedin=pythonString
syn match     python_not         "}"                            containedin=pythonString
syn match     python_braket      "[;()={}.]"
syn match     python_function    "\%(\.\s*\)\?\<\w\+\>\ze\s*("
syn match     python_constant    "\<[A-Z_][A-Z0-9_]\{2,}\>"
syn match     python_not         "!="
syn match     python_not         "\[\w*\]"
syn match     python_not         "\\n"
syn match     python_constant    "__\d\+__"                     containedin=pythonString
syn match     python_fmtspec     "%[-]*\d*[sxdYMSHm]"           containedin=pythonString
syn match     python_bw          '\.\w\+\.'
syn match     python_csh_var     "\$\w\+"                       containedin=pythonString

syn keyword   python_obj         self
syn keyword   python_csh_cmd     echo rm mkdir cp xrun cd mv    containedin=pythonString

highlight python_function  ctermfg=blue
highlight python_braket    ctermfg=252
highlight python_constant  ctermfg=13
highlight python_statement ctermfg=176
highlight Normal           ctermfg=253
highlight python_not       ctermfg=70
highlight python_fmtspec   ctermfg=13
highlight python_bw        ctermfg=252
highlight python_obj       ctermfg=3
highlight python_csh_cmd   ctermfg=13
highlight python_csh_var   ctermfg=blue

"-----------------------------------------------------------------------------
" 3. IndentLine Guide (show_tab)
"-----------------------------------------------------------------------------
" Script Name: indentLine.vim
" Version:     1.0.2
" Last Change: Dec 22, 2012
" Author:      Yggdroot <archofortune@gmail.com>
"
" Description: To show the indent line

"if !has("conceal") || exists("g:loaded_indentLine")
"    finish
"endif
"let g:loaded_indentLine = 1

if !exists("g:indentLine_char")
    " | ¦ ┆ │
"    let g:indentLine_char = "┆"
"    let g:indentLine_char = "¦"
    let g:indentLine_char = "│"
endif

if !exists("g:indentLine_indentLevel")
    let g:indentLine_indentLevel = 20
endif

setlocal conceallevel=1
setlocal concealcursor=ic

" Display | / │ for tab characters (\t)
let s:indent_char = exists("g:indentLine_char") ? g:indentLine_char : "│"
execute 'setlocal listchars=tab:' . s:indent_char . '\ '
setlocal list

function! <SID>SetIndentLine()
    let space = &l:shiftwidth
    " First indent level (starts with 1 tab = shiftwidth spaces)
    exec 'syn match IndentLine /^ \%( \{' . (space - 1) . '}\)\@=/ containedin=ALL conceal cchar=' . g:indentLine_char
    " Subsequent indent levels
    for i in range(space+1, space * g:indentLine_indentLevel + 1, space)
        exec 'syn match IndentLine /\(^\s\+\)\@<=\%'.i.'v / containedin=ALL conceal cchar=' . g:indentLine_char
    endfor
endfunction

function! <SID>ResetWidth(...)
    if a:0 > 0
        let &l:shiftwidth = a:1
    endif
    syn clear IndentLine
    call <SID>SetIndentLine()
endfunction


if line('$') <= 1500
    call <SID>SetIndentLine()
    hi  Conceal ctermbg=none ctermfg=239 guifg=#4e4e4e
    setlocal concealcursor=ic
endif


command! -nargs=? ResetIndentLines call <SID>ResetWidth(<f-args>)

" vim:et:ts=4:sw=4:fdm=marker:fmr={{{,}}}

finish
"=============================================================================
" Dictionary Keywords (used for autocomplete)
"=============================================================================
listdir getcwd chdir
