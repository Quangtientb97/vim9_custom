"=============================================================================
" SystemVerilog & UVM Snippets, Functions & Dictionary Configuration
"=============================================================================
let s:dict_file = expand('<sfile>:p:h:h:h') . '/dict/verilog_systemverilog.dict'
if filereadable(s:dict_file)
    execute 'setlocal dictionary+=' . fnameescape(s:dict_file)
endif
silent! setlocal dictionary+=~/tiandir/sv/tian_pkg/tian_macros.svh

" Load snippets from snipet/verilog_systemverilog.vim
if exists('*snippet_engine#load_filetype')
    call snippet_engine#load_filetype('verilog_systemverilog')
endif

"-----------------------------------------------------------------------------
" 2. Syntax Extensions (Format Specifiers & Method Calls)
"-----------------------------------------------------------------------------
syn match   verilogFormat      "\%(0x\)\?%[-+0-9#]*\%(\.[0-9]*\)\?[hHxXdDbBoOcCsStTmMlLpPuUzZvVfFeEgG%]" contained
syn match   verilogEscape      +\\["\\abfnrtv0]+ contained
syn match   verilogEscape      "\\\o\o\=\o\=" contained
syn region  verilogString      start=+"+ skip=+\\"+ end=+"+ contains=verilogEscape,verilogFormat,@Spell
highlight   verilogString      term=none ctermfg=173 guifg=#ce9178
highlight   verilogFormat      ctermfg=179 guifg=#d7ba7d
highlight   verilogEscape      ctermfg=179 guifg=#d7ba7d

" Base identifier match for all variables (e.g. i, nbytes, gp, bus_item, rw)
syn match   verilogVariable     "\<[a-zA-Z_][a-zA-Z0-9_$]*\>"

" Constants and enum literals (e.g. UVM_PORT, UVM_UNBOUNDED_CONNECTIONS, UVM_WRITE, UVM_READ)
syn match   verilogConstant     "\<[A-Z][A-Z0-9_$]*\>"
syn match   verilogConstant     "\<_[A-Z0-9_$]*\>"
highlight   verilogConstant     cterm=none ctermfg=13 gui=none guifg=#ff87ff

" Function, task, class, and statement keywords
syn match   verilogStatement    "\<\(function\|task\|class\|endfunction\|endtask\|endclass\)\>"

" Standard UVM classes, types, and enums highlighted in dark blue (#569cd6) matching VS Code
syn match   verilogUvm          "\<uvm_\k\+\>"
syn match   verilogUvm          "\<\k\+_t\>"
syn match   verilogUvm          "\<\k\+_c\>"
syn match   verilogUvm          "\<\k\+_e\>"
highlight   verilogUvm          ctermfg=75 guifg=#569cd6

" Class declaration and inheritance names highlighted in teal (#4ec9b0) strictly on same-line keywords
silent! syn clear verilogClass
syn match   verilogClass        "\%(\<class\s\+\)\@<=[a-zA-Z_]\w*"
syn match   verilogClass        "\%(\<extends\s\+\)\@<=[a-zA-Z_]\w*"
syn match   verilogClass        "\%(\<implements\s\+\)\@<=[a-zA-Z_]\w*"
syn match   verilogClass        "\%(\<covergroup\s\+\)\@<=[a-zA-Z_]\w*"
highlight   verilogClass        ctermfg=79 guifg=#4ec9b0

" Covergroup definition keywords (covergroup, endgroup) highlighted in soft yellow (#dcdcaa) matching VS Code
syn match   verilogCovergroup   "\<\(covergroup\|endgroup\)\>"
syn region  verilogCovergroupRegion matchgroup=verilogCovergroup start="\<covergroup\>" end="\<endgroup\>" transparent keepend
highlight   verilogCovergroup   ctermfg=186 guifg=#dcdcaa

" Coverpoint and cross labels before colon highlighted in teal (#4ec9b0)
syn match   verilogCoverpointLabel "\<[a-zA-Z_]\w*\ze\s*:\s*\%(coverpoint\|cross\)\>"
highlight   verilogCoverpointLabel ctermfg=79 guifg=#4ec9b0

" Coverage keywords (coverpoint, cross, bins, etc.) highlighted in pink (#d787d7)
syn match   verilogCoverpoint   "\<\(coverpoint\|cross\|bins\|binsof\|illegal_bins\|ignore_bins\)\>"
highlight   verilogCoverpoint   ctermfg=176 guifg=#d787d7

" Dot-preceded member properties (e.g. gp.m_byte_enable, rw.addr)
syn match   verilogProperty     "\.\k\+" contains=verilogMethodDot

" Method calls preceded by dot (e.g. gp.get_address(), super.new())
syn match   verilogMethod       "\.\k\+\ze\s*(" contains=verilogMethodDot
syn match   verilogMethodDot    "\." contained
highlight default link verilogMethodDot verilogOperator

" Objects and instance variables (e.g. gp, rw before dot)
syn match   verilogObject       "\<\w\+\ze\."

" Function and method calls / declarations with optional whitespace before parenthesis (e.g. set (a, b))
syn match   verilogMethod       "\<\w\+\ze\s*("

" System functions/tasks ($display, $time, etc.) highlighted as method
syn match   verilogMethod       "\$[a-zA-Z0-9_$]\+\ze\s*("

" Macro identifiers and $cast highlighted in soft warm sand (#dfaf87 / ctermfg=180)
syn match   verilogMacro        "\$cast\>"
syn match   verilogMacro        "\$cast\ze\s*("
syn match   verilogMacro        "`[a-zA-Z0-9_$]\+\>"
highlight   verilogMacro        ctermfg=180 guifg=#dfaf87

" Scope resolution operator and scope members (e.g. uvm_tlm_gp::type_id::create)
syn match   verilogOperator     "::" contained
syn match   verilogScopeMethod  "::\k\+\ze\s*(" contains=verilogOperator
syn match   verilogScopeMethod  "::create\>" contains=verilogOperator
syn match   verilogScopeType    "::\k\+\ze::" contains=verilogOperator
syn match   verilogScopeType    "\<\w\+\ze::" contains=verilogOperator
syn keyword verilogMethod       create

highlight default link verilogScopeMethod verilogMethod
highlight   verilogScopeType    ctermfg=79 guifg=#4ec9b0

" Variables and properties highlighted in light sky blue (#9cdcfe) matching VS Code
highlight   verilogVariable     ctermfg=117 guifg=#9cdcfe
highlight   verilogObject       ctermfg=117 guifg=#9cdcfe
highlight   verilogProperty     ctermfg=117 guifg=#9cdcfe

" Include statements, scope items, objects, properties, constants, types, numbers, and covergroups in base cluster for assignments
syn cluster verilogBaseCluster add=verilogStatement,verilogNot,verilogScopeMethod,verilogScopeType,verilogClass,verilogCovergroup,verilogCoverpointLabel,verilogCoverpoint,verilogUvm,verilogObject,verilogProperty,verilogVariable,verilogConstant,verilogType,verilogNumber

" Assignment region terminating before closing parentheses/brackets and allowing nested transparent syntax
syn region  verilogAssign       matchgroup=verilogOperator start="[^><=!]\@<=<\?=\%(=\)\@!" end="\ze[)\]]\|[;,]" transparent

" Built-in types, modifiers, and keywords highlighted in dark blue (#569cd6) matching VS Code
syn keyword verilogType        input output inout virtual void bit int logic byte longint shortint integer string time null disable reg wire real shortreal chandle parameter posedge negedge boolean True False
highlight   verilogType        ctermfg=75 guifg=#569cd6

" Numeric constants and literals highlighted in mint green (#b5cea8) matching VS Code
syn match   verilogNumber      "\(\d\+\)\?'[sS]\?[bB]\s*[0-1_xXzZ?]\+"
syn match   verilogNumber      "\(\d\+\)\?'[sS]\?[oO]\s*[0-7_xXzZ?]\+"
syn match   verilogNumber      "\(\d\+\)\?'[sS]\?[dD]\s*[0-9_xXzZ?]\+"
syn match   verilogNumber      "\(\d\+\)\?'[sS]\?[hH]\s*[0-9a-fA-F_xXzZ?]\+"
syn match   verilogNumber      "\<[+-]\?[0-9_]\+\(\.[0-9_]*\)\?\(e[0-9_]*\)\?\>"
syn match   verilogNumber      "\<\d[0-9_]*\(\.[0-9_]\+\)\=\([fpnum]\)\=s\>"
syn match   verilogNumber      "\<0[xX][0-9a-fA-F_]\+\>"
syn keyword verilogNumber      1step
highlight   verilogNumber      ctermfg=151 guifg=#b5cea8

" Functions and methods highlighted in balanced soft yellow (#ebe198)
highlight   verilogMethod      ctermfg=186 guifg=#ebe198

" Punctuation marks (; , :), delimiters, and operators softened to match VS Code Dark+ (#d4d4d4)
highlight   verilogRoundbracket ctermfg=252 guifg=#d4d4d4
highlight   verilogOperator     ctermfg=252 guifg=#d4d4d4
