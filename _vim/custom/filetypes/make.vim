"=============================================================================
" Makefile Syntax, Snippets & Dictionary Configuration
"=============================================================================
execute "setlocal dictionary+=" . expand("<sfile>:p")

syntax clear

syn match make_action           "^\S\S*:"              containedin=ALLBUT,make_comment
syn match make_and              "&&"                   containedin=ALLBUT
syn match make_and              ">>"                   containedin=ALLBUT
syn match make_and              "[\\]"                 containedin=ALLBUT,make_comment
syn match make_braket           "[:=;,?+]"             containedin=ALLBUT,make_comment,make_string
syn match make_comment          "^#.*"                 containedin=ALL
syn match make_init_variable    "\s[a-zA-Z0-9_]*="     containedin=ALLBUT,make_string
syn match make_init_variable    "^\s*\w*\s*[?:+]*="    containedin=ALLBUT,make_string
syn match make_init_variable    "^\w*\s*[?:]*="        containedin=ALLBUT,make_string
syn match make_link             "\(\S*/\)\(\S*/\)*\S*" containedin=ALLBUT,make_comment,make_variable
syn match make_string           "\".*\""               containedin=ALLBUT,make_comment
syn match make_string           "\'.*\'"               containedin=ALLBUT,make_comment
syn match make_var_in_bash      "$$\w*"                containedin=ALL
syn match make_var_in_bash      "%"                    containedin=ALL
syn match make_var_in_bash      "-%"                   containedin=ALL
syn match make_var_in_bash      "@"                    containedin=ALLBUT,make_variable,make_comment
syn match make_variable         "$(\w*)"               containedin=ALLBUT,make_comment
syn match make_variable         "$\*"                  containedin=ALLBUT,make_comment
syn match make_variable         "$\w*"                 containedin=ALLBUT,make_comment
syn match make_variable         "${\w*}"               containedin=ALLBUT,make_comment


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


inorea if_makefile_Ent ifeq ($(__f_variable), __f_condition)<cr>
			\#condition<cr>
			\else<cr>
			\#condition<cr>
			\endif<esc>:/__f_\w*<cr>ggn

inorea if_bash_in_makefile_Ent @if [__f_condition]; then \<cr>
			\__f_; \<cr>
			\<bs>fi<esc>:/__f_\w*<cr>ggn

inorea if_exits_dir_bash_in_makefile_Ent @if [-d "__f_directory"]; then \<cr>
			\__f_; \<cr>
			\<bs>fi<esc>:/__f_\w*<cr>ggn

inorea for_bash_in_makefile_Ent for item in ${__f_list}; do \<cr>
			\<bs><tab>echo $${item}; \<cr>
			\<bs>done<esc>:/__f_\w*<cr>ggn

inorea echo_Ent echo "" >> run.csh<esc>11h


finish
"=============================================================================
" Dictionary Keywords (used for autocomplete)
"=============================================================================
wildcard
patsubst
shell
patsubst
notdir
dir
abspath
addsuffix 
addprefix
strip
error warning
if else ifdef ifndef endif PHONY export for unique head tail foreach
echo then

