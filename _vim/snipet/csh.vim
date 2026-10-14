"=============================================================================
" CSH / TCSH Snippets
"=============================================================================
call snippet_engine#add('csh_env_Ent', [
            \ '#!/usr/bin/csh',
            \ '#--------------------------------------------------------------------',
            \ '#  File name     : ${FILENAME}',
            \ '#  Function      : <empty>',
            \ '#  Author        : ${AUTHOR}',
            \ '#  Email         : ${EMAIL}',
            \ '#  Created time  : ${DATETIME}',
            \ '#--------------------------------------------------------------------',
            \ 'set curfile  = `realpath $0`',
            \ 'set workdir  = `dirname $curfile`',
            \ '',
            \ '# number of argument: $#argv',
            \ 'echo $workdir',
            \ ], { 'filetype': 'csh', 'desc': 'CSH script header and template' })

call snippet_engine#add('csh_if_Ent', [
            \ 'if (${1:condition0}) then',
            \ '    # ${2:TBD}',
            \ 'else if (${3:condition1}) then',
            \ '    # ${4:TBD}',
            \ 'else',
            \ '    # ${5:TBD}',
            \ 'endif',
            \ ], { 'filetype': 'csh', 'desc': 'CSH if-else conditional' })

call snippet_engine#add('csh_xrun_Ent', [
            \ 'xrun -64 \',
            \ '    -uvm \',
            \ '    -uvmhome ${1:CDNS-1.2} \',
            \ '    -timescale 1ns/1ns \',
            \ '    -loadpli1 debpli:novas_pli_boot \',
            \ '    +access+rwc \',
            \ '    ${2:top.sv}',
            \ ], { 'filetype': 'csh', 'desc': 'Cadence xrun simulation command' })

call snippet_engine#add('csh_is_exist_var_Ent', [
            \ '# check if variable does not exist',
            \ 'if (! $?${1:var_name}) setenv ${1:var_name} "${2}"',
            \ ], { 'filetype': 'csh', 'desc': 'CSH check environment variable exists' })

call snippet_engine#add('csh_is_exist_file_Ent', [
            \ 'if ( -e ${1:~/.vimrc}) then',
            \ '    ${2:# TODO}',
            \ 'endif',
            \ ], { 'filetype': 'csh', 'desc': 'CSH check file exists' })

call snippet_engine#add('csh_for_Ent', [
            \ 'foreach ${1:item} (${2:list_of_items})',
            \ '    ${3:command} $${1:item}',
            \ 'end',
            \ ], { 'filetype': 'csh', 'desc': 'CSH foreach loop' })

call snippet_engine#add('csh_get_choice_Ent', [
            \ 'echo "${1:Do you want to build again? yes/no}"',
            \ 'set input=$<',
            \ 'if ("$input" == "yes") then',
            \ '    ${2:# command on yes}',
            \ 'else',
            \ '    echo "exit"',
            \ 'exit 1',
            \ 'endif',
            \ ], { 'filetype': 'csh', 'desc': 'CSH interactive prompt choice' })

call snippet_engine#add('csh_git_prompt_Ent', [
            \ 'set BLACK       = "%{\033[1;30m%}" ;set DARK_BLACK       = "%{\033[0;30m%}"',
            \ 'set RED         = "%{\033[1;31m%}" ;set DARK_RED         = "%{\033[0;31m%}"',
            \ 'set GREEN       = "%{\033[1;32m%}" ;set DARK_GREEN       = "%{\033[0;32m%}"',
            \ 'set YELLOW      = "%{\033[1;33m%}" ;set DARK_YELLOW      = "%{\033[0;33m%}"',
            \ 'set BLUE        = "%{\033[1;34m%}" ;set DARK_BLUE        = "%{\033[0;34m%}"',
            \ 'set MAGENTA     = "%{\033[1;35m%}" ;set DARK_MAGENTA     = "%{\033[0;35m%}"',
            \ 'set CYAN        = "%{\033[1;36m%}" ;set DARK_CYAN        = "%{\033[0;36m%}"',
            \ 'set WHITE       = "%{\033[1;37m%}" ;set DARK_WHITE       = "%{\033[0;37m%}"',
            \ 'set RESET_COLOR = "%{\033[0m%}"',
            \ '',
            \ 'set git_branch = `git symbolic-ref --short HEAD`',
            \ 'set prompt = "\n${GREEN}[${GREEN}`hostname` ${GREEN}  : ${GREEN}`pwd`${GREEN}] ${RED}*${git_branch}\n${BLUE}  (${BLUE}>.<${BLUE})${MAGENTA}  @${RESET_COLOR} "',
            \ 'alias cd ''chdir \!*; set prompt = "\n${GREEN}[${GREEN}`hostname` ${GREEN}  : ${GREEN}`pwd`${GREEN}] ${RED}*${git_branch}\n${BLUE}  (${BLUE}>.<${BLUE})${MAGENTA}  @${RESET_COLOR} "; ls''',
            \ ], { 'filetype': 'csh', 'desc': 'CSH colored git prompt' })

call snippet_engine#add('csh_git_promt_Ent', [
            \ 'set BLACK       = "%{\033[1;30m%}" ;set DARK_BLACK       = "%{\033[0;30m%}"',
            \ 'set RED         = "%{\033[1;31m%}" ;set DARK_RED         = "%{\033[0;31m%}"',
            \ 'set GREEN       = "%{\033[1;32m%}" ;set DARK_GREEN       = "%{\033[0;32m%}"',
            \ 'set YELLOW      = "%{\033[1;33m%}" ;set DARK_YELLOW      = "%{\033[0;33m%}"',
            \ 'set BLUE        = "%{\033[1;34m%}" ;set DARK_BLUE        = "%{\033[0;34m%}"',
            \ 'set MAGENTA     = "%{\033[1;35m%}" ;set DARK_MAGENTA     = "%{\033[0;35m%}"',
            \ 'set CYAN        = "%{\033[1;36m%}" ;set DARK_CYAN        = "%{\033[0;36m%}"',
            \ 'set WHITE       = "%{\033[1;37m%}" ;set DARK_WHITE       = "%{\033[0;37m%}"',
            \ 'set RESET_COLOR = "%{\033[0m%}"',
            \ '',
            \ 'set git_branch = `git symbolic-ref --short HEAD`',
            \ 'set prompt = "\n${GREEN}[${GREEN}`hostname` ${GREEN}  : ${GREEN}`pwd`${GREEN}] ${RED}*${git_branch}\n${BLUE}  (${BLUE}>.<${BLUE})${MAGENTA}  @${RESET_COLOR} "',
            \ 'alias cd ''chdir \!*; set prompt = "\n${GREEN}[${GREEN}`hostname` ${GREEN}  : ${GREEN}`pwd`${GREEN}] ${RED}*${git_branch}\n${BLUE}  (${BLUE}>.<${BLUE})${MAGENTA}  @${RESET_COLOR} "; ls''',
            \ ], { 'filetype': 'csh', 'desc': 'CSH colored git prompt' })
