"=============================================================================
" C Language Syntax & Dictionary Configuration
let s:dict_file = expand('<sfile>:p:h:h:h') . '/dict/c.dict'
if filereadable(s:dict_file)
    execute 'setlocal dictionary+=' . fnameescape(s:dict_file)
endif
if exists('*snippet_engine#load_filetype')
    call snippet_engine#load_filetype('c')
endif

syn match C_braket 	        "[=*,;]"
syn match C_variable            "\<[a-zA-Z_][a-zA-Z0-9_$]*\>"
syn region C_String             start=+"+ skip=+\\"+ end=+"+ contains=C_format,C_escape
syn match C_constant 	        "\<[A-Z_][A-Z0-9_]\{2,}\>"
syn match C_funtion 		"\%(\*\?\s*\)\@<=\<\w\+\>\ze\s*("
syn match C_function 		"\%(\*\?\s*\)\@<=\<\w\+\>\ze\s*("
syn match C_addr 		"[&|]"
syn match C_not 		"!\w\+"
syn match C_not 		"^\s*#\s*ifndef\>"
syn match C_not 		"!="
syn match C_escape 		"\\["\\abfnrtv0]" contained
syn match C_format 		"\%(0x\)\?%[-+0-9#]*\%(\.[0-9]*\)\?\%(ll\|l\|h\|hh\|z\)\?[diouxXeEfFgGaAcspn%]" contained
syn match C_not 		"\~\w\+"
syn match C_index 		"\[\w\+\]"
syn match C_include 		"^\s*#\s*\w\+"
syn match C_include 		"^\s*#\s*include\>" nextgroup=C_included,C_String skipwhite
syn match C_included 		"<[^>]\+>" contained
syn match C_number 		"\<0b[01]\+\>\|\<0x[0-9a-fA-F]\+\>\|\<\d\+\>"
syn match C_property 	        "->\w\+"
syn match C_struct 	        "\.\w\+"
syn keyword C_condition         if else return do while for switch case default break continue
syn keyword C_void              void

syn match C_type 		"\<u\d\+\>"
syn match C_type 		"\<\w\+_t\>"
syn match C_type 		"\<\w\+_c\>"
syn match C_type 		"\<\w\+_e\>"
syn match Ccomment 		"//.*"

" Highlight palette matching SystemVerilog & VS Code Dark+
highlight C_constant    cterm=none ctermfg=13 gui=none guifg=#ff87ff
highlight C_type        ctermfg=75 guifg=#569cd6
highlight Type          ctermfg=75 guifg=#569cd6
highlight C_void        ctermfg=75 guifg=#569cd6
highlight C_funtion     ctermfg=186 guifg=#ebe198
highlight C_function    ctermfg=186 guifg=#ebe198
highlight! link Function C_funtion
highlight! link cCustomFunc C_funtion
highlight C_variable    ctermfg=117 guifg=#9cdcfe
highlight C_property    ctermfg=117 guifg=#9cdcfe
highlight C_struct      ctermfg=117 guifg=#9cdcfe
highlight C_number      ctermfg=151 guifg=#b5cea8
highlight! link cNumber C_number
highlight! link Number  C_number
highlight C_string      term=none ctermfg=173 guifg=#ce9178
highlight C_String      term=none ctermfg=173 guifg=#ce9178
highlight! link cString    C_String
highlight! link cCharacter C_String
highlight C_format      ctermfg=42 guifg=#00d787
highlight C_escape      ctermfg=42 guifg=#00d787
highlight! link cFormat  C_format
highlight! link cSpecial C_escape
highlight C_condition   ctermfg=176 guifg=#d787d7
highlight Statement     ctermfg=176 guifg=#d787d7
highlight C_addr        ctermfg=red guifg=#e06c75
highlight C_not         ctermfg=42 guifg=#00d787
highlight C_index       ctermfg=42 guifg=#00d787
highlight C_braket      ctermfg=252 guifg=#d4d4d4
highlight C_include     ctermfg=139 guifg=#af87af
highlight C_included    ctermfg=139 guifg=#af87af
highlight Normal        ctermfg=252 guifg=#d0d0d0
highlight default link Ccomment Comment

silent! setlocal dictionary+=~/gen_aarch32_reg/cpu.c
