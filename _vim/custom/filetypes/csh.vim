"=============================================================================
" Csh / Tcsh Syntax, Snippets & Dictionary Configuration
"=============================================================================
execute "setlocal dictionary+=" . expand("<sfile>:p")

" Keyword
" UVM_TESTNAME UVM_TIMEOUT
" +uvm_set_type_override
" UVM_VEBOSITY UVM_CONFIG_DB_TRACE
syn keyword csh_statement force run force value 

highlight csh_statement ctermfg=yellow

inorea csh_env_Ent <esc>:set formatoptions-=cro<cr>i
            \#!/usr/bin/csh<cr>
            \#--------------------------------------------------------------------<cr>
            \#  File name     : <esc>:r!basename %<cr>i<bs><esc>o
            \#  Function      : <empty><cr>
            \Author        : Tian<cr>
            \Email         : tientq@coasia.com<cr>
            \Created time  : <esc>:r !date '+\%Y-\%m-\%d \%H:\%M:\%S'<cr>i<bs><esc>o
            \#--------------------------------------------------------------------<cr>
            \set curfile  = `realpath $0`<cr>
            \set workdir  = `dirname $curfile`<cr>
            \<cr>
            \# number of argument: $#argv<cr>
            \echo $workdir<cr>
            \<esc>:set formatoptions+=cro<cr>

inorea csh_if_Ent <esc>:set formatoptions-=cro<cr>i
            \if (__f_condition0) then<cr>
            \    # TBD <cr>
            \else if (__f_condition1) then<cr>
            \    # TBD <cr>
            \else<cr>
            \    # TBD<cr>
            \endif<cr>
            \<esc>:set formatoptions+=cro<cr>/__f_\w\w*<cr>

inorea csh_xrun_Ent <esc>:setl noai nocin nosi inde=<cr>i
            \xrun -64 \<cr>
            \    -uvm \<cr>
            \    -uvmhome CDNS-1.2 \<cr>
            \    -timescale 1ns/1ns \<cr>
            \    -loadpli1 debpli:novas_pli_boot \<cr>
            \    +access+rwc \<cr>
            \    top.sv<cr>
            \<esc>:set autoindent<cr><esc>:set formatoptions+=cro<cr>

inorea csh_is_exist_var # check if not exist<cr>
            \<bs><bs>if (! $?__f_var) setenv __f_var=""<esc>

inorea csh_is_exist_file if ( -e /home/tientq/.vimrc) then<cr>
            \# TODO<cr>
            \<bs><bs>endif

inorea csh_for foreach item (list_of_items)<cr>
            \command $item<cr>
            \end<cr>

inorea csh_get_choice <esc>:setl noai nocin nosi inde=<cr>i
            \echo "Do you want to builddbs again? yes/no"<cr>
            \set input=$<<cr>
            \if ("$input" == "yes") then<cr>
            \    prun builddbs-nwp_pcie-$config<cr>
            \else<cr>
            \    echo "exit"<cr>
            \    exit 1<cr>
            \endif<cr>
            \<esc>:set autoindent<cr><esc>:set formatoptions+=cro<cr>
            
inorea csh_git_promt <esc>:set formatoptions-=cro<cr>i
            \set BLACK       = "%{\033[1;30m%}"	;set DARK_BLACK       = "%{\033[0;30m%}"	<cr>
            \set RED         = "%{\033[1;31m%}"	;set DARK_RED         = "%{\033[0;31m%}"	<cr>
            \set GREEN       = "%{\033[1;32m%}"	;set DARK_GREEN       = "%{\033[0;32m%}"	<cr>
            \set YELLOW      = "%{\033[1;33m%}"	;set DARK_YELLOW      = "%{\033[0;33m%}"	<cr>
            \set BLUE        = "%{\033[1;34m%}"	;set DARK_BLUE        = "%{\033[0;34m%}"	<cr>
            \set MAGENTA     = "%{\033[1;35m%}"	;set DARK_MAGENTA     = "%{\033[0;35m%}"	<cr>
            \set CYAN        = "%{\033[1;36m%}"	;set DARK_CYAN        = "%{\033[0;36m%}"	<cr>
            \set WHITE       = "%{\033[1;37m%}"	;set DARK_WHITE       = "%{\033[0;37m%}"	<cr>
            \set RESET_COLOR = "%{\033[0m%}"		<cr>
            \<cr>
            \set 	  	git_branch = `git symbolic-ref --short HEAD`<cr>
            \set     	prompt = "\n${GREEN}[${GREEN}`hostname` ${GREEN}  : ${GREEN}`pwd`${GREEN}] ${RED}*${git_branch}\n${BLUE}  (${BLUE}>.<${BLUE})${MAGENTA}  @${RESET_COLOR} "<cr>
            \alias 	cd       'chdir \!*; set prompt = "\n${GREEN}[${GREEN}`hostname` ${GREEN}  : ${GREEN}`pwd`${GREEN}] ${RED}*${git_branch}\n${BLUE}  (${BLUE}>.<${BLUE})${MAGENTA}  @${RESET_COLOR} "; ls'<cr>
            \<esc>:set formatoptions+=cro<cr>
