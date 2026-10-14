"=============================================================================
" TCL Syntax, Snippets & Dictionary Configuration
"=============================================================================
let s:dict_file = expand('<sfile>:p:h:h:h') . '/dict/tcl.dict'
if filereadable(s:dict_file)
    execute 'setlocal dictionary+=' . fnameescape(s:dict_file)
endif

syn keyword tcl_statement force run force value stop
syn match tcl_not "!="
syn match tcl_shift "<<"
syn match tcl_shift ">>"

"highlight tcl_statement ctermfg=brown
highlight tcl_statement ctermfg=3
highlight tcl_not ctermfg=42
highlight tcl_shift ctermfg=red

" Load snippets from snipet/tcl/
if exists('*snippet_engine#load_filetype')
    call snippet_engine#load_filetype('tcl')
endif
