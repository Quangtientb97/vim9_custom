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
syn match make_comment          "^#.*"
syn match make_init_variable    "\%(^\s*\|\s\)\w\+\s*[?:+]*="
syn match make_link             "\<\%([a-zA-Z0-9_.-]\+/\)\+[a-zA-Z0-9_.-]\+\>"
syn region make_string          start=+"+ skip=+\\"+ end=+"+
syn region make_string          start=+'+ skip=+\\'+ end=+'+
syn match make_var_in_bash      "$$\w\+"
syn match make_var_in_bash      "-%\|%"
syn match make_var_in_bash      "@"
syn match make_variable         "$(\w\+)"
syn match make_variable         "\$\*"
syn match make_variable         "\$\w\+"
syn match make_variable         "${\w\+}"


syn keyword make_keyword      if ifeq endif else define endef findstring call
syn keyword make_command      subst word patsubst addsuffix include export strip addprefix
syn keyword make_bash_keyword echo mkdir make cd rm chmod sed pwd csh
syn keyword make_bash_keyword fi exit tee do for in done read then error elif
syn keyword make_bash_keyword cp bsub ssh xrun shell

syn match make_bash_keyword "else" containedin=ALLBUT,make_keyword
syn match make_keyword "^else" containedin=ALLBUT


highlight make_var_in_bash   ctermfg=13
highlight make_command       ctermfg=228
highlight make_variable      ctermfg=blue
highlight make_init_variable ctermfg=13
highlight make_braket        ctermfg=253
highlight make_keyword       ctermfg=176
highlight make_bash_keyword  ctermfg=3"brown
highlight make_link          ctermfg=215
highlight make_and           ctermfg=red
highlight make_string        ctermfg=215
highlight make_comment       ctermfg=107
highlight make_action        ctermfg=blue

" Load snippets from snipet/make/
if exists('*snippet_engine#load_filetype')
    call snippet_engine#load_filetype('make')
endif
