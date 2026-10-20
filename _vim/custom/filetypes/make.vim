"=============================================================================
" Makefile Syntax, Snippets & Dictionary Configuration
let s:dict_file = expand('<sfile>:p:h:h:h') . '/dict/make.dict'
if filereadable(s:dict_file)
    execute 'setlocal dictionary+=' . fnameescape(s:dict_file)
endif

syntax clear

syn match make_action           "^\S\+:"
syn match make_and              "&&\|>>\|\\"
syn match make_braket           "[:=;,?+]"
syn match make_comment          "^\s*#.*"
syn match make_init_variable    "\%(^\s*\|\s\)\w\+\ze\s*[?:+]*="
syn match make_link             "\<\%([a-zA-Z0-9_.-]\+/\)\+[a-zA-Z0-9_.-]\+\>"
syn region make_string          start=+"+ skip=+\\"+ end=+"+
syn region make_string          start=+'+ end=+'+
syn match make_var_in_bash      "$$\w\+"
syn match make_var_in_bash      "-%\|%"
syn match make_var_in_bash      "^\s*@"
syn match make_variable         "\$\%([a-zA-Z0-9_.*@<^?%+-]\|([a-zA-Z0-9_.*@<^?%+-]\+)\|{[a-zA-Z0-9_.*@<^?%+-]\+}\)"


syn keyword make_keyword      if ifeq endif else define endef findstring call
syn keyword make_command      subst word patsubst addsuffix include export strip addprefix wildcard filter filter-out shell abspath dir notdir lastword origin flavor foreach eval value info warning error
syn keyword make_bash_keyword echo mkdir make cd rm chmod sed pwd csh
syn keyword make_bash_keyword fi exit tee do for in done read then error elif
syn keyword make_bash_keyword cp bsub ssh xrun

syn match make_bash_keyword "else" containedin=ALLBUT,make_keyword
syn match make_keyword "^else" containedin=ALLBUT


highlight make_var_in_bash   ctermfg=13  guifg=#9170cb
highlight make_command       ctermfg=228 guifg=#ffff87
highlight make_variable      ctermfg=75  guifg=#569cd6
highlight make_init_variable ctermfg=13  guifg=#9170cb
highlight make_braket        ctermfg=253 guifg=#dbdbdb
highlight make_keyword       ctermfg=176 guifg=#d787d7
highlight make_bash_keyword  ctermfg=179 guifg=#d7ba7d
highlight make_link          ctermfg=215 guifg=#ffaf5f
highlight make_and           ctermfg=red guifg=#e06c75
highlight make_string        ctermfg=215 guifg=#ffaf5f
highlight make_comment       ctermfg=107 guifg=#6a9955
highlight make_action        ctermfg=75  guifg=#569cd6

" Load snippets from snipet/make/
if exists('*snippet_engine#load_filetype')
    call snippet_engine#load_filetype('make')
endif
