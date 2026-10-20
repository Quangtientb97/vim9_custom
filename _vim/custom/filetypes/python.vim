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

highlight python_function  ctermfg=186 guifg=#ebe198
highlight python_braket    ctermfg=252 guifg=#d4d4d4
highlight python_constant  ctermfg=13  guifg=#9170cb
highlight! link Constant   python_constant
highlight python_statement ctermfg=176 guifg=#d787d7
highlight Normal           ctermfg=252 guifg=#d0d0d0
highlight python_not       ctermfg=70  guifg=#5faf00
highlight python_fmtspec   ctermfg=13  guifg=#9170cb
highlight python_bw        ctermfg=252 guifg=#d4d4d4
highlight python_obj       ctermfg=179 guifg=#d7ba7d
highlight python_csh_cmd   ctermfg=13  guifg=#9170cb
highlight python_csh_var   ctermfg=75  guifg=#569cd6

" 3. IndentLine Guide (show_tab)
let g:indentLine_char = get(g:, 'indentLine_char', '│')
let g:indentLine_indentLevel = get(g:, 'indentLine_indentLevel', 20)

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
