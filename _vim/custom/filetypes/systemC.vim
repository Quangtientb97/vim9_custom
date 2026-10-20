"=============================================================================
" SystemC Syntax, Dictionary & Indentation Configuration
"=============================================================================
let s:dict_file = expand('<sfile>:p:h:h:h') . '/dict/systemC.dict'
if filereadable(s:dict_file)
    execute 'setlocal dictionary+=' . fnameescape(s:dict_file)
endif
if exists('*snippet_engine#load_filetype')
    call snippet_engine#load_filetype('systemC')
endif

" 1. SystemC Syntax & Types
syn region  systemC_comment      keepend start=+\/\*+ end=+\*\/+ containedin=ALL
syn region  systemC_string       start=+"+ skip=+\\"+ end=+"+ 

syn match   systemC_braket       "[.;]"
syn match   systemC_comment      "//.*"
syn match   systemC_type         "\<u\d\+\>"
syn match   systemC_type         "\<\w\+_t\>"

syn match   systemC_constant     "\<[A-Z_][A-Z0-9_]\{2,}\>"
syn match   systemC_function     "\%(\*\?\s*\)\@<=\<\w\+\>\ze\s*("
syn match   systemC_function     "\.\w\+\ze\s*("
syn match   systemC_addr         "[&|]"
syn match   systemC_not          "!\w\+"
syn match   systemC_not          "^\s*#\s*ifndef\>"
syn match   systemC_not          "!="
syn match   systemC_not          "\\[nr]"
syn match   systemC_not          "%[-+0-9]*[dx]"
syn match   systemC_index        "\[\w\+\]"
syn match   systemC_include      "^\s*#\s*\w\+"
syn match   systemC_include      "^\s*#\s*include\>" nextgroup=systemC_included,systemC_string skipwhite
syn match   systemC_included     "<[^>]\+>" contained
syn match   systemC_number       "\<0b[01]\+\>\|\<0x[0-9a-fA-F]\+\>"
syn match   systemC_property     "->\w\+"
syn match   systemC_datatype     "\<sc_\w\+\>"
syn match   systemC_len          "<\d\+>"

syn match   systemC_red          "<<"
syn match   systemC_red          "\*"
syn match   systemC_number       "\<\d\+\>"

syn keyword systemC_datatype     bool void virtual cout endl new int constant char
syn keyword systemC_condition    if else return do while for class public private
syn match   systemC_keyword      "\<SC_\w\+\>"

" 2. Highlight Palette
highlight systemC_function   ctermfg=186 guifg=#ebe198
highlight! link systemC_funtion systemC_function
highlight systemC_datatype   ctermfg=75  guifg=#569cd6
highlight systemC_braket     ctermfg=251 guifg=#d0d0d0
highlight systemC_comment    ctermfg=107 guifg=#6a9955
highlight systemC_constant   cterm=none ctermfg=13 gui=none guifg=#9170cb
highlight! link Constant     systemC_constant
highlight systemC_type       ctermfg=75  guifg=#569cd6
highlight systemC_addr       ctermfg=red guifg=#e06c75
highlight systemC_not        ctermfg=42  guifg=#00d787
highlight systemC_index      ctermfg=42  guifg=#00d787
highlight systemC_condition  ctermfg=176 guifg=#d787d7
highlight systemC_keyword    ctermfg=176 guifg=#d787d7
highlight systemC_include    ctermfg=139 guifg=#af87af
highlight systemC_included   ctermfg=139 guifg=#af87af
highlight systemC_number     ctermfg=151 guifg=#b5cea8
highlight systemC_property   ctermfg=215 guifg=#ffaf5f
highlight systemC_len        ctermfg=13  guifg=#9170cb
highlight systemC_string     ctermfg=173 guifg=#ce9178
highlight systemC_red        ctermfg=167 guifg=#e06c75
highlight Statement          ctermfg=176 guifg=#d787d7
highlight Normal             ctermfg=252 guifg=#d0d0d0

silent! setlocal dictionary+=~/gen_aarch32_reg/cpu.c

" 3. Standard C/C++ Indentation
setlocal cindent
