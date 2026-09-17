"=============================================================================
" Python Syntax, Snippets, Indent Guide & Dictionary Configuration
"=============================================================================
execute "setlocal dictionary+=" . expand("<sfile>:p")
silent! setlocal dictionary+=~/tiandir/python/tian/auto_complete.py

"-----------------------------------------------------------------------------
" 1. Python Snippets
"-----------------------------------------------------------------------------
inorea py_env_Ent <esc>:set formatoptions-=cro<cr>i
            \#!/usr/bin/python3<cr>
            \#----------------------------------------------------------------------<cr>
            \#  File name     : <esc>:r!basename %<cr>i<bs><esc>o
            \#  Function      : <empty><cr>
            \#  Author        : Tian<cr>
            \#  Email         : tientq@coasia.com<cr>
            \#  Created time  : <esc>:r !date '+\%Y-\%m-\%d \%H:\%M:\%S'<cr>i<bs><esc>o
            \#----------------------------------------------------------------------<cr>
            \import re, os, argparse<cr>
            \import sys ; sys.path.append("/home/tientq/tiandir/python/")<cr>
            \import tian; sys.path.append(tian.user_library_path)<cr>
            \from   tian           import this_file, this_dir<cr>
            \<cr>
            \# --------------------------------------------------------------------+<cr>
            \# Function declare                                                    \|<cr>
            \# --------------------------------------------------------------------+<cr>
            \def get_args():<cr>
            \parser = argparse.ArgumentParser(description="File description")<cr>
            \# Add arguments<cr>
            \parser.add_argument("-f", "--file", type=str, required=True, help="input file link")<cr>
            \parser.add_argument(      "--on"  , action="store_true", required=False, help="boolean variable take True/False")<cr>
            \return parser.parse_args()<cr>
            \<cr>
            \<cr>
            \<bs># --------------------------------------------------------------------+<cr>
            \# main                                                                \|<cr>
            \# --------------------------------------------------------------------+<cr>
            \def main() -> int:<cr>
            \args = get_args()<cr>
            \print("Start...")<cr>
            \<cr>
            \<cr>
            \<bs># --------------------------------------------------------------------+<cr>
            \# Script entry point                                                  \|<cr>
            \# --------------------------------------------------------------------+<cr>
            \if __name__ == "__main__":<cr>
            \tian.time.start()<cr>
            \rc = main()<cr>
            \print(f"Command: 'python3 {' '.join(sys.argv)}'")<cr>
            \tian.time.end()<cr>
            \sys.exit(rc)<cr>
            \<esc>:set formatoptions+=cro<cr><esc>

inorea py_parallel_Ent <esc>:set formatoptions-=cro<cr>i
            \from concurrent.futures import ThreadPoolExecutor<cr>
            \with ThreadPoolExecutor() as executor:<cr>
            \# Create sheets in parallel<cr>
            \executor.map(lambda register: create_reg_sheet(workexcel, register), registers)<cr>
            \<esc>:set formatoptions+=cro<cr>

inorea py_help <esc>:set formatoptions-=cro<cr>i
            \if (tian.argv.get_argument_by_prefix("-h")) or (len(sys.argv) == 1):<cr>
            \    fd = os.path.dirname(__file__)<cr>
            \    tian.run(f"cat {fd}/README")<cr><cr>
            \<esc>:set formatoptions+=cro<cr>

inorea py_try_Ent <esc>:set formatoptions-=cro<cr>i
            \try:<cr>
            \__fill()<cr>
            \except Exception as e:<cr>
            \print("Error:", e)<cr>
            \<esc>:set formatoptions+=cro<cr>

inorea py_excel_Ent <esc>:set formatoptions-=cro<cr>i
            \tian.excel.create_excel_file("__fill")<cr>
            \workexcel = tian.excel("__fill")<cr>
            \workbook  = tian.wb<cr>
            \#workexcel.create_sheet("Summary")<cr>
            \#workexcel.remove_sheet("Sheet")<cr>
            \<esc>:set formatoptions+=cro<cr>

inorea py_tqdm_Ent <esc>:set formatoptions-=cro<cr>i
            \from tqdm import tqdm<cr>
            \pbar = tqdm(__fill, bar_format="{n_fmt}/{total_fmt} \| {desc}")<cr>
            \pbar.set_description("Processing...")<cr>
            \<esc>:set formatoptions+=cro<cr>

"-----------------------------------------------------------------------------
" 2. Python Syntax Highlighting
"-----------------------------------------------------------------------------
syn match     python_not         "{\w*"                         containedin=pythonString
syn match     python_not         "}"                            containedin=pythonString
syn match     python_braket      "[;()={}.]"                    containedin=ALLBUT,pythonString,python_not,pythonComment,pythonString
syn match     python_function    "\.\w*("                       containedin=ALLBUT,python_braket,pythonString,pythonComment
syn match     python_function    "\s\w*("                       containedin=ALLBUT,python_braket,pythonString,pythonComment
syn match     python_function    "^\w\w*("                      containedin=ALLBUT,python_braket,pythonString,pythonComment
syn match     python_constant    "\s[A-Z][A-Z][A-Z_0-9]*\s"     containedin=ALLBUT,pythonString,python_not,pythonComment
syn match     python_not         "!="                           containedin=ALLBUT,pythonComment
syn match     python_not         "\[\w*\]"                      containedin=ALLBUT,pythonComment
syn match     python_not         "\\n"                          containedin=ALLBUT,pythonComment
syn match     python_constant    "__\d\d*__"                    containedin=pythonString
syn match     python_fmtspec     "%[-]*\d*[sxdYMSHm]"           containedin=pythonString
syn match     python_bw          '\.\w\w*\.'                    containedin=ALLBUT,pythonString,pythonComment
syn match     python_csh_var     "$\w\w*"                       containedin=pythonString


syn keyword   python_obj         self                           containedin=ALLBUT,pythonString
syn keyword   python_csh_cmd     echo rm mkdir cp xrun cd       containedin=pythonString
syn keyword   python_csh_cmd     mv                             containedin=pythonString


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
