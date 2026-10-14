"=============================================================================
" Makefile Snippets
"=============================================================================
call snippet_engine#add('if_makefile_Ent', [
            \ 'ifeq ($(${1:variable}), ${2:condition})',
            \ '    ${3:# true condition}',
            \ 'else',
            \ '    ${4:# false condition}',
            \ 'endif',
            \ ], { 'filetype': 'make', 'desc': 'Makefile ifeq conditional' })

call snippet_engine#add('if_bash_in_makefile_Ent', [
            \ '@if [ ${1:condition} ]; then \',
            \ '    ${2:echo "True"}; \',
            \ 'fi',
            \ ], { 'filetype': 'make', 'desc': 'Bash if statement in Makefile recipe' })

call snippet_engine#add('if_exists_dir_bash_in_makefile_Ent', [
            \ '@if [ -d "${1:directory}" ]; then \',
            \ '    ${2:echo "Directory exists"}; \',
            \ 'fi',
            \ ], { 'filetype': 'make', 'desc': 'Bash check directory exists in Makefile' })

call snippet_engine#add('if_exits_dir_bash_in_makefile_Ent', [
            \ '@if [ -d "${1:directory}" ]; then \',
            \ '    ${2:echo "Directory exists"}; \',
            \ 'fi',
            \ ], { 'filetype': 'make', 'desc': 'Bash check directory exists in Makefile' })

call snippet_engine#add('for_bash_in_makefile_Ent', [
            \ 'for item in ${${1:list}}; do \',
            \ '    echo $${item}; \',
            \ 'done',
            \ ], { 'filetype': 'make', 'desc': 'Bash for loop in Makefile recipe' })

call snippet_engine#add('echo_Ent', [
            \ 'echo "${1}" >> ${2:run.csh}${0}',
            \ ], { 'filetype': 'make', 'desc': 'Append echo statement' })
