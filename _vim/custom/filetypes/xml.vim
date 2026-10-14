"=============================================================================
" XML Syntax & Snippets Configuration
"=============================================================================
let s:dict_file = expand('<sfile>:p:h:h:h') . '/dict/xml.dict'
if filereadable(s:dict_file)
    execute 'setlocal dictionary+=' . fnameescape(s:dict_file)
endif

" Load snippets from snipet/xml/
if exists('*snippet_engine#load_filetype')
    call snippet_engine#load_filetype('xml')
endif
