"=============================================================================
" LISA / LISA+ Syntax, Dictionary & Indentation Configuration
" Used for: ARM Fast Models (LISA+) & Synopsys Processor Designer (LISA 2.0)
"=============================================================================
execute "setlocal dictionary+=" . expand("<sfile>:p")

"-----------------------------------------------------------------------------
" 1. Indentation & Formatting
"-----------------------------------------------------------------------------
setlocal cindent
setlocal cinoptions=:0,g0,t0,(0,W4
setlocal comments=s1:/*,mb:*,ex:*/,://
setlocal commentstring=//\ %s

"-----------------------------------------------------------------------------
" 2. Syntax Highlighting
"-----------------------------------------------------------------------------
syntax clear

" Comments
syn region  lisa_comment_block keepend start=+\/\*+ end=+\*\/+ containedin=ALL
syn match   lisa_comment       "//.*" containedin=ALL

" Strings & Characters
syn region  lisa_string start=+"+ skip=+\\"+ end=+"+ contains=lisa_escape
syn match   lisa_escape "\\[ntr\\'"]" contained

" Numbers
syn match   lisa_number "\<0x[0-9a-fA-F]\+\>"
syn match   lisa_number "\<0b[01]\+\>"
syn match   lisa_number "\<\d\+\>"

" Preprocessor
syn match   lisa_preproc "^\s*#\s*\(include\|define\|undef\|ifdef\|ifndef\|endif\|if\|else\|elif\|pragma\)\>"

" LISA / LISA+ Declarative Blocks & Keywords
syn keyword lisa_block     component subcomponent protocol connection composition
syn keyword lisa_block     properties resources behavior ports includes
syn keyword lisa_keyword   implements instantiates parameter port master slave in out
syn keyword lisa_keyword   pipeline register memory

" Synopsys / CoWare LISA 2.0 Keywords (Uppercase constructs)
syn keyword lisa_snps_block RESOURCE OPERATION INSTRUCTION SYNTAX CODING BEHAVIOR
syn keyword lisa_snps_block EXPRESSION MAPPING DOCUMENTATION PIPELINE REGISTER MEMORY PIN
syn keyword lisa_snps_block GROUP ALIAS SECTION RESET INIT

" C / C++ Flow Control
syn keyword lisa_condition if else return do while for switch case default break continue

" Data Types
syn keyword lisa_type bool void char int short long float double unsigned signed string
syn keyword lisa_type int8_t int16_t int32_t int64_t
syn keyword lisa_type uint8_t uint16_t uint32_t uint64_t
syn keyword lisa_type size_t uintptr_t intptr_t

" Function / Method calls
syn match   lisa_function  "\<\w\+\s*("me=e-1 containedin=ALLBUT,lisa_comment,lisa_comment_block,lisa_string,lisa_condition,lisa_block,lisa_snps_block

" Constants
syn match   lisa_constant  "\<[A-Z_][A-Z0-9_]\{2,}\>" containedin=ALLBUT,lisa_comment,lisa_comment_block,lisa_string

" Brackets & Operators
syn match   lisa_bracket   "[{}[\]();,.]" containedin=ALLBUT,lisa_comment,lisa_comment_block,lisa_string

"-----------------------------------------------------------------------------
" 3. Highlight Links & Colors (Desert Scheme Compatible)
"-----------------------------------------------------------------------------
highlight default link lisa_comment_block Comment
highlight default link lisa_comment       Comment
highlight default link lisa_string        String
highlight default link lisa_escape        Special
highlight default link lisa_preproc       PreProc
highlight default link lisa_number        Number
highlight default link lisa_constant      Constant
highlight default link lisa_block         Structure
highlight default link lisa_snps_block    Structure
highlight default link lisa_keyword       Keyword
highlight default link lisa_condition     Conditional
highlight default link lisa_type          Type
highlight default link lisa_function      Function
highlight default link lisa_bracket       Delimiter

highlight lisa_comment       ctermfg=107 guifg=#6A9955
highlight lisa_comment_block ctermfg=107 guifg=#6A9955
highlight lisa_string        ctermfg=215 guifg=#ffaf5f
highlight lisa_preproc       ctermfg=13  guifg=#ff55ff
highlight lisa_number        ctermfg=brown guifg=#d7875f
highlight lisa_block         ctermfg=176 guifg=#d787d7
highlight lisa_snps_block    ctermfg=176 guifg=#d787d7
highlight lisa_keyword       ctermfg=176 guifg=#d787d7
highlight lisa_condition     ctermfg=176 guifg=#d787d7
highlight lisa_type          ctermfg=blue guifg=#5fafff
highlight lisa_function      ctermfg=blue guifg=#5fafff
highlight lisa_constant      ctermfg=cyan guifg=#5ffdff
highlight lisa_bracket       ctermfg=251 guifg=#d0d0d0

finish
"=============================================================================
" Dictionary Keywords (used for <C-n>/<C-x><C-k> autocomplete)
"=============================================================================
component
subcomponent
protocol
connection
composition
properties
resources
behavior
ports
includes
implements
instantiates
parameter
master
slave
port
pipeline
register
memory
init
reset
terminate
interconnect
post_init
uint8_t
uint16_t
uint32_t
uint64_t
int8_t
int16_t
int32_t
int64_t
bool
string
RESOURCE
OPERATION
INSTRUCTION
SYNTAX
CODING
BEHAVIOR
EXPRESSION
MAPPING
DOCUMENTATION
PIPELINE
REGISTER
MEMORY
PIN
