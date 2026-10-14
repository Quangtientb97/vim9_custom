"=============================================================================
" Csh / Tcsh Syntax, Snippets & Dictionary Configuration
"=============================================================================
let s:dict_file = expand('<sfile>:p:h:h:h') . '/dict/csh.dict'
if filereadable(s:dict_file)
    execute 'setlocal dictionary+=' . fnameescape(s:dict_file)
endif

" Keyword
" UVM_TESTNAME UVM_TIMEOUT
" +uvm_set_type_override
" UVM_VEBOSITY UVM_CONFIG_DB_TRACE
syn keyword csh_statement force run force value 

highlight csh_statement ctermfg=yellow

" Load snippets from snipet/csh/
if exists('*snippet_engine#load_filetype')
    call snippet_engine#load_filetype('csh')
endif
