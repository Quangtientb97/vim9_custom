"=============================================================================
" Jinja2 Syntax & Snippets Configuration
"=============================================================================
let s:dict_file = expand('<sfile>:p:h:h:h') . '/dict/jinja2.dict'
if filereadable(s:dict_file)
    execute 'setlocal dictionary+=' . fnameescape(s:dict_file)
endif

" Load snippets from snipet/jinja2/
if exists('*snippet_engine#load_filetype')
    call snippet_engine#load_filetype('jinja2')
endif

syn region  jinja2_var       start =+{{+ end=+}}+
syn region  jinja2_statement start =+{%+ end=+%}+
syn region  jinja2_comment   start =+{#+ end=+#}+

highlight jinja2_var       ctermfg=42
highlight jinja2_statement ctermfg=176
highlight jinja2_comment   ctermfg=107

"syn keyword jj2_statement for in if endif endfor set containedin=jinja2_statement
"highlight jj2_statement   ctermfg=3


"syn match jj2_command_braket "{%"  containedin=ALLBUT,jinja2_comment
"syn match jj2_command_braket "{%-" containedin=ALLBUT,jinja2_comment
"syn match jj2_command_braket "%}"  containedin=ALLBUT,jinja2_comment
"
"syn match jj2_command "{%.*%}"                       containedin=ALLBUT,jj2_command_braket,jinja2_comment
"syn keyword jj2_statement for in if endif endfor set containedin=jj2_command
"
"syn match jj2_str_in_command "\".*\""                containedin=jj2_command
"
"highlight jj2_command   ctermfg=252
"highlight jj2_statement ctermfg=3
"highlight jj2_command_braket ctermfg=176
"highlight jj2_str_in_command ctermfg=215
