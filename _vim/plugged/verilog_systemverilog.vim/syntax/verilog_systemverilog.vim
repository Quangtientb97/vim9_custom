" Vim syntax file
" Language:	Systemverilog (superset extension of verilog)

" Extends verilog syntax
" Requires $VIMRUNTIME/syntax/verilog.vim to exist

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
   syntax clear
elseif exists("b:current_syntax")
   finish
endif

syntax clear
" Override 'iskeyword'
if version >= 600
   setlocal iskeyword=48-57,_,192-255,64
else
   set iskeyword=48-57,_,192-255,64
endif

" Store cpoptions
let oldcpo=&cpoptions
set cpo-=C

syn sync lines=1000

"##########################################################
"       Systemverilog Syntax
"##########################################################

syn keyword verilogStatement   always and assign automatic buf always_ff endmodule module   "function class endfunction endclass
syn keyword verilogStatement   bufif0 bufif1 cell cmos endtask endclass
syn keyword verilogStatement   config deassign defparam design
syn keyword verilogStatement	edge endconfig
syn keyword verilogStatement   endgenerate super
syn keyword verilogStatement   endprimitive endtable
syn keyword verilogStatement   event force fork join
syn keyword verilogStatement   join_any join_none forkjoin
syn keyword verilogStatement   generate genvar highz0 highz1 ifnone
syn keyword verilogStatement   incdir include initial 
syn keyword verilogStatement   instance integer large liblist
syn keyword verilogStatement   library localparam macromodule medium
syn keyword verilogStatement   nand nmos nor
syn keyword verilogStatement   noshowcancelled not notif0 notif1 or
syn keyword verilogStatement   pmos primitive
syn keyword verilogStatement   pull0 pull1 pulldown pullup
syn keyword verilogStatement   pulsestyle_onevent pulsestyle_ondetect
syn keyword verilogStatement   rcmos real realtime reg release
syn keyword verilogStatement   rnmos rpmos rtran rtranif0 rtranif1
syn keyword verilogStatement   scalared showcancelled signed small
syn keyword verilogStatement   specparam strong0 strong1
syn keyword verilogStatement   supply0 supply1 table time tran
syn keyword verilogStatement   tranif0 tranif1 tri tri0 tri1 triand
syn keyword verilogStatement   trior trireg unsigned use vectored wait
syn keyword verilogStatement   wand weak0 weak1 wire wor xnor xor
syn keyword verilogStatement   semaphore mailbox 

syn keyword verilogStatement   always_comb always_ff always_latch
syn keyword verilogStatement   checker endchecker
syn keyword verilogStatement   local const protected
syn keyword verilogStatement   package endpackage
syn keyword verilogStatement   rand randc constraint
syn keyword verilogStatement   with inside dist
syn keyword verilogStatement   randcase this
syn keyword verilogStatement   randsequence
syn keyword verilogStatement   get_randstate set_randstate
syn keyword verilogStatement   srandom
syn keyword verilogNumber   	logic bit byte time parameter posedge negedge
syn keyword verilogNumber   	int longint shortint write read randomize boolean True False
syn keyword verilogStatement   struct packed
syn keyword verilogStatement   final
syn keyword verilogStatement   import
syn keyword verilogStatement   context pure
syn keyword verilogStatement   shortreal chandle 
syn keyword verilogStatement   modport
syn keyword verilogStatement   cover coverpoint
syn keyword verilogStatement   program endprogram
syn keyword verilogStatement   bins binsof illegal_bins ignore_bins
syn keyword verilogStatement   alias matches solve static assert
syn keyword verilogStatement   assume before expect bind
syn keyword verilogStatement   extends tagged extern
syn keyword verilogStatement   first_match throughout timeprecision
syn keyword verilogStatement   timeunit priority type union
syn keyword verilogStatement   uwire var cross ref wait_order intersect
syn keyword verilogStatement   wildcard within
syn keyword verilogStatement   triggered
syn keyword verilogStatement   std 
syn keyword verilogStatement   accept_on eventually global implements implies
syn keyword verilogStatement   interconnect let nettype nexttime reject_on restrict soft
syn keyword verilogStatement   s_always s_eventually s_nexttime s_until s_until_with
syn keyword verilogStatement   strong sync_accept_on sync_reject_on unique unique0


syn keyword verilogTypeDef     enum 

syn keyword verilogStatement      forever repeat while for contained=ALLBUT,verilogComment
syn keyword verilogStatement      return break continue contained=ALLBUT,verilogComment
syn keyword verilogStatement      do while foreach contained=ALLBUT,verilogComment





syn match   verilogGlobal      "`[a-zA-Z_][a-zA-Z0-9_$]\+" 
syn match   verilogGlobal      "$[a-zA-Z0-9_$]\+"


if !exists('g:verilog_disable_constant_highlight')
    syn match   verilogConstant    "\<[A-Z][A-Z0-9_$]*\>"
    syn match   verilogConstant    "\<[_A-Z][A-Z0-9_$]*\>"
endif

syn match   verilogNumber      "\(\d\+\)\?'[sS]\?[bB]\s*[0-1_xXzZ?]\+"
syn match   verilogNumber      "\(\d\+\)\?'[sS]\?[oO]\s*[0-7_xXzZ?]\+"
syn match   verilogNumber      "\(\d\+\)\?'[sS]\?[dD]\s*[0-9_xXzZ?]\+"
syn match   verilogNumber      "\(\d\+\)\?'[sS]\?[hH]\s*[0-9a-fA-F_xXzZ?]\+"
syn match   verilogNumber      "\<[+-]\?[0-9_]\+\(\.[0-9_]*\)\?\(e[0-9_]*\)\?\>"
syn match   verilogNumber      "\<\d[0-9_]*\(\.[0-9_]\+\)\=\([fpnum]\)\=s\>"

syn keyword verilogNumber      1step string void virtual null disable uvm_bitstream_t write_here create new add
syn keyword verilogTodo        contained TODO FIXME NOTE

syn match   verilogOperator    "[&|~><!*#%@+/=?:;}{,\^\-\[\]]"

syn region  verilogString      start=+"+ skip=+\\"+ end=+"+ contains=verilogEscape,@Spell
syn match   verilogEscape      +\\[nt"\\]+ contained
syn match   verilogEscape      "\\\o\o\=\o\=" contained

syn keyword verilogMethod      new input output inout 

if v:version >= 704
    syn match   verilogMethod  "\(\(\s\|[(/]\|^\)\.\)\@2<!\<\w\+\ze#\?("
else
    syn match   verilogMethod  "\(\(\s\|[(/]\|^\)\.\)\@<!\<\w\+\ze#\?("
endif

syn match   verilogLabel       "\<\k\+\>\ze\s*:\s*\<\(assert\|assume\|cover\(point\)\?\|cross\)\>"
if v:version >= 704
    syn match   verilogLabel   "\(\<\(begin\|end\)\>\s*:\s*\)\@20<=\<\k\+\>"
else
    syn match   verilogLabel   "\(\<\(begin\|end\)\>\s*:\s*\)\@<=\<\k\+\>"
endif

"syn keyword verilogObject       null 
syn match   verilogObject      "\<\w\+\ze\(::\|\.\)" contains=verilogNumber

" Create syntax definition from g:verilog_syntax dictionary
function! s:SyntaxCreate(name, verilog_syntax)
    if exists('a:verilog_syntax[a:name]') 
        let verilog_syn_region_name = 'verilog'.substitute(a:name, '.*', '\u&', '')
        for entry in a:verilog_syntax[a:name]
            if exists('entry["match"]')
                " syn-match definitions
                let match = entry["match"]
                let verilog_syn_match_cmd = 'syn match '.verilog_syn_region_name.' "'.match.'"'

                if exists('entry["syn_argument"]')
                    let verilog_syn_match_cmd .= ' '.entry["syn_argument"]
                endif

                execute verilog_syn_match_cmd
            elseif exists('entry["match_start"]') && exists('entry["match_end"]')
                " syn-region definitions

                let region_start = entry["match_start"]
                let region_end = entry["match_end"]

                if verilog_systemverilog#VariableExists('verilog_quick_syntax')
                    execute 'syn keyword verilogStatement '.region_start.' '.region_end
                else
                    let verilog_syn_region_cmd = 'syn region '.verilog_syn_region_name

                    if exists('entry["highlight"]')
                        let verilog_syn_region_cmd .= ' matchgroup='.entry["highlight"]
                    endif

                    let verilog_syn_region_cmd .=
                        \  ' start="'.region_start.'"'
                        \ .' end="'.region_end.'"'

                    " Always skip inline comments
                    if a:name != "comment" && exists('a:verilog_syntax["comment"]')
                        let verilog_syn_region_cmd .= ' skip="'
                        for comment_entry in a:verilog_syntax["comment"]
                            if exists('comment_entry["match"]')
                                let verilog_syn_region_cmd .= comment_entry["match"]
                            endif
                        endfor
                        let verilog_syn_region_cmd .= '"'
                    endif

                    if exists('entry["syn_argument"]')
                        let verilog_syn_region_cmd .= ' '.entry["syn_argument"]
                    endif

                    if !exists('entry["no_fold"]')
                        if (index(s:verilog_syntax_fold, a:name) >= 0 || index(s:verilog_syntax_fold, "all") >= 0)
                            let verilog_syn_region_cmd .= ' fold'
                        endif
                    endif

                    execute verilog_syn_region_cmd
                endif
            elseif exists('entry["cluster"]')
                " syn-cluster definitions

                execute 'syn cluster '.verilog_syn_region_name.' contains='.entry["cluster"]
            elseif exists('entry["keyword"]')
                " syn-cluster definitions

                execute 'syn keyword '.verilog_syn_region_name.' '.entry["keyword"]
            else
                echoerr 'Incorrect syntax defintion for '.a:name
            endif
        endfor
    end
endfunction

" Only enable folding if verilog_syntax_fold_lst is defined
let s:verilog_syntax_fold=verilog_systemverilog#VariableGetValue("verilog_syntax_fold_lst")

" Syntax priority list
let s:verilog_syntax_order = [
            \ 'baseCluster',
            \ 'statement',
            \ 'assign',
            \ 'attribute',
            \ 'instance',
            \ 'prototype',
            \ 'class',
            \ 'clocking',
            \ 'covergroup',
            \ 'define',
            \ 'export',
            \ 'expression',
            \ 'function',
            \ 'interface',
            \ 'module',
            \ 'property',
            \ 'sequence',
            \ 'specify',
            \ 'task',
            \ 'typedef',
            \ ]

" Generate syntax definitions for supported types
for name in s:verilog_syntax_order
    call s:SyntaxCreate(name, g:verilog_syntax)
endfor

if index(s:verilog_syntax_fold, "block_nested") >= 0 || index(s:verilog_syntax_fold, "block_named") >= 0
    if index(s:verilog_syntax_fold, "block_nested") >= 0
        syn region verilogBlock
            \ matchgroup=verilogStatement
            \ start="\<begin\>"
            \ end="\<end\>.*\<begin\>"ms=s-1,me=s-1
            \ fold
            \ transparent
            \ contained
            \ nextgroup=verilogBlockEnd
            \ contains=TOP
        syn region verilogBlockEnd
            \ matchgroup=verilogStatement
            \ start="\<end\>.*\<begin\>"
            \ end="\<end\>\ze.*\(\<begin\>\)\@!"
            \ fold
            \ transparent
            \ contained
            \ contains=TOP
        syn match verilogStatement "\<end\>"
    else "block_named
        syn region verilogBlock
            \ matchgroup=verilogStatement
            \ start="\<begin\>"
            \ end="\<end\>"
            \ transparent
            \ contained
            \ contains=TOP
        syn region verilogBlockNamed
            \ matchgroup=verilogStatement
            \ start="\<begin\>\ze\s*:\s*\z(\w\+\)"
            \ end="\<end\>"
            \ transparent
            \ fold
            \ contained
            \ contains=TOP
        "TODO break up if...else statements
    endif
    syn region verilogBlockContainer
        \ start="\<begin\>"
        \ end="\<end\>"
        \ skip="/[*/].*"
        \ transparent
        \ keepend extend
        \ contains=verilogBlock,verilogBlockNamed,verilogBlockEnd
elseif index(s:verilog_syntax_fold, "block") >= 0 || index(s:verilog_syntax_fold, "all") >= 0
    syn region verilogBlock
        \ matchgroup=verilogStatement
        \ start="\<begin\>"
        \ end="\<end\>"
        \ transparent
        \ fold
else
    syn keyword verilogStatement  begin end
endif

if index(s:verilog_syntax_fold, "define") >= 0 || index(s:verilog_syntax_fold, "all") >= 0
    syn region verilogIfdef
        \ start="`ifn\?def\>"
        \ end="^\s*`els\(e\|if\)\>"ms=s-1,me=s-1
        \ fold transparent
        \ keepend
        \ contained
        \ nextgroup=verilogIfdefElse,verilogIfdefEndif
        \ contains=TOP
    syn region verilogIfdefElse
        \ start="`els\(e\|if\)\>"
        \ end="^\s*`els\(e\|if\)\>"ms=s-1,me=s-1
        \ fold transparent
        \ keepend
        \ contained
        \ nextgroup=verilogIfdefElse,verilogIfdefEndif
        \ contains=TOP
    syn region verilogIfdefEndif
        \ start="`else\>"
        \ end="`endif\>"
        \ fold transparent
        \ keepend
        \ contained
        \ contains=TOP
    syn region verilogIfdefContainer
        \ start="`ifn\?def\>"
        \ end="`endif\>"
        \ skip="/[*/].*"
        \ transparent
        \ keepend extend
        \ contains=verilogIfdef,verilogIfdefElse,verilogIfdefEndif
endif

" Generate syntax definitions for comments after other standard syntax
" definitions to guarantee highest priority
for name in ['comment']
    call s:SyntaxCreate(name, g:verilog_syntax)
endfor

" Generate syntax definitions for custom types last to allow overriding
" standard syntax
if exists('g:verilog_syntax_custom')
    for name in keys(g:verilog_syntax_custom)
        call s:SyntaxCreate(name, g:verilog_syntax_custom)
    endfor
endif

" Special comments: Synopsys directives
syn match   verilogDirective   "//\s*synopsys\>.*$"
syn region  verilogDirective   start="/\*\s*synopsys\>" end="\*/"
syn region  verilogDirective   start="//\s*synopsys \z(\w*\)begin\>" end="//\s*synopsys \z1end\>"

syn match   verilogDirective   "//\s*\$s\>.*$"
syn region  verilogDirective   start="/\*\s*\$s\>" end="\*/"
syn region  verilogDirective   start="//\s*\$s dc_script_begin\>" end="//\s*\$s dc_script_end\>"






"Modify the following as needed.  The trade-off is performance versus
"functionality.
syn sync minlines=50



  

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
"---------------------------------------------------------------------
"	Mydefine
syn match   verilogAndor                "[&|^{}]"           containedin=ALLBUT,verilogComment
syn match   verilogProperty             "\\"                containedin=verilogComment
syn match   verilogRoundbracket         "[();,+<>]"         containedin=ALLBUT,verilogComment,verilogString
syn match	verilogProperty			    "::\w*"             containedin=ALLBUT,verilogComment
syn match 	verilogProperty 			"\.\w* "            containedin=ALLBUT,verilogComment
syn match 	verilogProperty 			"\.\w*[;,=)]"       containedin=ALLBUT,verilogComment
syn match 	verilogProperty 			"\.\w+\s*("         containedin=ALLBUT,verilogRoundbracket,verilogComment,verilogAndor
syn match 	verilogUvm		 			"\w\w*_t\W"         containedin=ALLBUT,verilogComment,verilogMacro,verilogString,verilogNot
syn match 	verilogUvm		 			"\suvm_\w*"         containedin=ALLBUT,verilogComment,verilogMacro,verilogString,verilogNot
syn match 	verilogUvm		 			"\s*cdn[A-Z]\w*"    containedin=ALLBUT,verilogComment,verilogMacro,verilogString,verilogNot
syn match 	verilogUvm		 			"\s*\w\w*_[ct]\s"   containedin=ALLBUT,verilogComment,verilogString
syn match 	verilogUvm		 			"\s*\w\w*_[ct];"    containedin=ALLBUT,verilogComment,verilogString
syn match 	verilogNot		 			"\s*\w\w*_e\s"      containedin=ALLBUT,verilogComment,verilogString
syn match 	verilogNot		 			"\s*\w\w*_e;"       containedin=ALLBUT,verilogComment,verilogString
syn match 	verilogNot					"!\w*"              containedin=ALLBUT,verilogComment
syn match 	verilogNot					"!="                containedin=ALLBUT,verilogComment
syn match 	verilogNot					"%\d*[a-z]"         containedin=ALLBUT,verilogComment
syn match 	verilogNot					"%\d*\.\d*[a-z]"    containedin=ALLBUT,verilogComment
syn match 	verilogNot					"%-\d*[a-z]"        containedin=ALLBUT,verilogComment
syn match 	verilogNot					"``[a-zA-Z0-9_][a-zA-Z0-9_]*``"         containedin=ALLBUT,verilogComment
syn match 	verilogNot					"%[a-z]"            containedin=ALLBUT,verilogComment
syn match 	verilogNot					"\[[a-z$0-9_]*\]"   containedin=ALLBUT,verilogComment,verilogStatement
syn match 	verilogNot					"`ifndef"           containedin=ALLBUT,verilogComment,verilogStatement
syn match 	verilogMacro				"`\w\w*"            containedin=ALLBUT,verilogComment,verilogNot,verilogErrorKeyword
syn match 	verilogMethod    			"\s\w\w*_\w\w*\s*(" containedin=ALLBUT,verilogComment,verilogStatement,verilogString
syn match 	verilogErrorKeyword	        "\$tests\$"         containedin=ALLBUT,verilogComment
syn match 	verilogErrorKeyword	        "\$bit("            containedin=ALLBUT,verilogComment
syn match 	verilogErrorKeyword	        "$plusarg("         containedin=ALLBUT,verilogComment
syn match 	verilogErrorKeyword	        "\$xm_miror"        containedin=ALLBUT,verilogComment
syn match 	verilogErrorKeyword	        "`elif"             containedin=ALLBUT,verilogComment
syn match   verilogTypeDef              "\s\w\w*_t\s"       containedin=ALLBUT,verilogComment
syn match   verilogConstant             "\<[_A-Z][A-Z0-9_$]*[a-z]\>"
syn keyword verilogAssign               assign containedin=ALLBUT,verilogComment,verilogString



syn keyword verilogConditional      until until_with untyped weak iff if else case casex casez default endcase

"---------------------------------------------------------------------
"	End Mydefine
"---------------------------------------------------------------------
"  Start highlighting
if version >= 508 || !exists("did_verilog_syn_inits")
	 if version < 508
		  let did_verilog_syn_inits = 1
		  command -nargs=+ HiLink hi link <args>
	 else
		  command -nargs=+ HiLink hi def link <args>
	 endif

	 " The default highlighting.
	 HiLink	    verilogStatement      Constant
	 HiLink 	verilogMethod 	      Statement
	 HiLink     verilogCharacter      Special
	 HiLink     verilogConditional    Tag
	 HiLink     verilogConstant       Special
	 HiLink     verilogDirective      SpecialComment
	 HiLink     verilogPrototype      Statement
	 HiLink     verilogRepeat         Repeat
	 HiLink     verilogStatement      Tag
	 HiLink     verilogString         Statement
	 HiLink     verilogTodo           Todo

	 highlight  verilogProperty      ctermfg=215 guifg=#ffaf5f
	 highlight  verilogRoundbracket  ctermfg=white guifg=#ffffff     "ctermfg =254
	 highlight  verilogUvm           ctermfg=blue guifg=#5fafff
	 highlight  verilogAndor         ctermfg=red guifg=#ff5f5f
	 highlight  verilogComment       ctermfg=107 guifg=#87af5f
	 highlight  verilogConditional   ctermfg=176 guifg=#d787d7
	 highlight  verilogEscape        ctermfg=42 guifg=#00d787
	 highlight  verilogGlobal        ctermfg=229 guifg=#ffffaf
	 highlight  verilogLabel         ctermfg=51 guifg=#00ffff
	 highlight  verilogMethod        ctermfg=blue guifg=#5fafff
	 highlight  verilogNumber        ctermfg=blue guifg=#5fafff
	 highlight  verilogObject        ctermfg=252 guifg=#d0d0d0
	 highlight  verilogOperator      ctermfg=252 guifg=#d0d0d0
	 highlight  verilogStatement     ctermfg=176 guifg=#d787d7
	 highlight  verilogAssign        ctermfg=176 guifg=#d787d7
	 highlight  verilogString        term=none ctermfg=228 guifg=#ffff87
	 highlight  verilogTypeDef       ctermfg=215 guifg=#ffaf5f
	 highlight  verilogVariableClass ctermfg=215 guifg=#ffaf5f
	 highlight  verilogMacro         ctermfg=229 guifg=#ffffaf
	 highlight  verilogNot           ctermfg=42 guifg=#00d787
	 highlight  verilogErrorKeyword  ctermfg=235 ctermbg=red guifg=#262626 guibg=#ff0000
     highlight  verilogConstant      cterm=bold ctermfg=13 gui=bold guifg=#ff87ff
	 highlight  Normal               ctermfg=252 guifg=#d0d0d0

	 delcommand HiLink



endif

let b:current_syntax = "verilog_systemverilog"

" Restore cpoptions
let &cpoptions=oldcpo

" vim: sts=4 sw=4
