"=============================================================================
" Python Syntax, Snippets, Indent Guide & Dictionary Configuration
"=============================================================================
let s:dict_file = expand('<sfile>:p:h:h:h') . '/dict/python.dict'
if filereadable(s:dict_file)
    execute 'setlocal dictionary+=' . fnameescape(s:dict_file)
endif
silent! setlocal dictionary+=~/tiandir/python/tian/auto_complete.py

" Load snippets from snipet/python/
if exists('*snippet_engine#load_filetype')
    call snippet_engine#load_filetype('python')
endif

"-----------------------------------------------------------------------------
" 2. Python Syntax Highlighting (VS Code Dark+ Palette matching python.png)
"-----------------------------------------------------------------------------

" 2.1 Declaration & Structural Keywords
syn keyword pythonDeclaration    def lambda global nonlocal
syn keyword pythonClassDecl      class nextgroup=pythonClassName skipwhite
syn keyword pythonInclude        import from as
syn keyword pythonBoolean        True False None
syn keyword pythonOperator       not and or is

" 2.2 Control Flow Statements (Magenta #c586c0)
syn keyword pythonConditional    if elif else containedin=@pythonRainbowRegions
syn keyword pythonRepeat         for while in containedin=@pythonRainbowRegions
syn keyword pythonStatement      return continue break pass yield containedin=@pythonRainbowRegions
syn keyword pythonException      try except finally raise assert with containedin=@pythonRainbowRegions

" 2.3 Function Definitions & Calls (Yellow #dcdcaa)
syn match pythonFunctionCall     "\<\h\w*\>\ze\s*(" containedin=@pythonRainbowRegions

" 2.4 Classes & Types (Teal #4ec9b0 matching python.png)
syn match pythonClassName        "\h\w*" contained
syn match pythonClassRef         "\<\h\w*_\%(c\|base_c\|t\|pkg\)\>" containedin=@pythonRainbowRegions
syn match pythonClassRef         "\<[A-Z][a-zA-Z0-9_]*[a-z][a-zA-Z0-9_]*\>" containedin=@pythonRainbowRegions
syn match pythonClassArg         "\%(\<class\s\+\h\w*\s*([^)]*\)\@<=\<\h\w*\>\ze\%([^)]*)\s*:\)" containedin=@pythonRainbowRegions
syn keyword pythonBuiltinType    int str float bool list dict set tuple bytes bytearray complex range frozenset memoryview object super type enumerate filter map zip slice containedin=@pythonRainbowRegions

" 2.5 Parameters & Keyword Arguments (Light Blue #9cdcfe)
" Parameter definitions in def func(param1, param2=...):
syn match pythonParamDef         "\%(\<def\s\+\h\w*\s*([^)]*\)\@<=\<\h\w*\>\ze\%([^)]*)\s*:\)" containedin=@pythonRainbowRegions
" Keyword arguments in function calls: func(arg=val, ...)
syn match pythonKeywordArg       "\<\h\w*\>\ze\s*=[^=]" contained containedin=@pythonRainbowRegions

" 2.5 String Prefixes (Blue #569cd6)
syn match pythonStrPrefix        "\c\<[rubf]\{1,2\}\ze['"]" nextgroup=pythonString,pythonRawString,pythonFString,pythonRawFString,pythonTripleString,pythonTripleFString

" 2.6 Strings (Warm Orange #ce9178)
syn region pythonString          matchgroup=pythonQuotes start=+\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1" contained contains=pythonEscape,pythonUnicodeEscape,@Spell
syn region pythonString          matchgroup=pythonQuotes start=+\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1" contains=pythonEscape,pythonUnicodeEscape,@Spell

syn region pythonTripleString    matchgroup=pythonTripleQuotes start=+\z('''\|"""\)+ end="\z1" keepend contained contains=pythonEscape,pythonUnicodeEscape,pythonSpaceError,pythonDoctest,@Spell
syn region pythonTripleString    matchgroup=pythonTripleQuotes start=+\z('''\|"""\)+ end="\z1" keepend contains=pythonEscape,pythonUnicodeEscape,pythonSpaceError,pythonDoctest,@Spell

syn region pythonRawString       matchgroup=pythonQuotes start=+\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1" contained contains=pythonEscape,@Spell
syn region pythonTripleRawString matchgroup=pythonTripleQuotes start=+\z('''\|"""\)+ end="\z1" keepend contained contains=pythonSpaceError,pythonDoctest,@Spell

syn region pythonFString         matchgroup=pythonQuotes start=+\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1" contained contains=pythonFStringField,pythonFStringSkip,pythonEscape,pythonUnicodeEscape,@Spell
syn region pythonTripleFString   matchgroup=pythonTripleQuotes start=+\z('''\|"""\)+ end="\z1" keepend contained contains=pythonFStringField,pythonFStringSkip,pythonEscape,pythonUnicodeEscape,pythonSpaceError,pythonDoctest,@Spell

" F-string interpolation delimiters { and } (Yellow #ffd710 matching Rainbow Bracket lv1)
syn region pythonFStringField    matchgroup=pythonFStringDelimiter start=/{/ end=/}/ contained contains=TOP,pythonFStringField

" 2.7 Escapes & Format Specifiers (Gold/Khaki #d7ba7d)
syn match pythonEscape           "\\[abfnrtv'\"\\0-9a-zA-Z+]" contained containedin=pythonString,pythonRawString,pythonFString,pythonRawFString,pythonTripleString,pythonTripleFString
syn match pythonFmtSpec          "%[-+0-9#]*\%(\.[0-9]*\)\?[sxdYMSHm]" contained containedin=pythonString,pythonRawString,pythonFString,pythonRawFString

" 2.8 Punctuation & Operators (Light Gray #d4d4d4, brackets left to Rainbow plugin)
syn match pythonDelimiter        "[;:,.]"
syn match pythonOperatorChar     "[=+\-*/%&|^~<>!]="
syn match pythonOperatorChar     "[=+\-*/%&|^~<>]"

" 2.9 Built-in identifiers & Objects
syn keyword pythonObj            self cls

" Highlight definitions
highlight pythonDeclaration      ctermfg=75  guifg=#569cd6
highlight pythonClassDecl        ctermfg=75  guifg=#569cd6
highlight pythonInclude          ctermfg=176 guifg=#c586c0
highlight pythonBoolean          ctermfg=75  guifg=#569cd6
highlight pythonOperator         ctermfg=75  guifg=#569cd6
highlight pythonStrPrefix        ctermfg=75  guifg=#569cd6
highlight pythonObj              ctermfg=176 guifg=#c586c0

highlight pythonStatement        ctermfg=176 guifg=#c586c0
highlight pythonConditional      ctermfg=176 guifg=#c586c0
highlight pythonRepeat           ctermfg=176 guifg=#c586c0
highlight pythonException        ctermfg=176 guifg=#c586c0

highlight pythonFunctionCall     ctermfg=186 guifg=#ede4a4
highlight pythonFunction         ctermfg=186 guifg=#ede4a4
highlight pythonBuiltin          ctermfg=186 guifg=#ede4a4

highlight pythonClassName        ctermfg=73  guifg=#4ec9b0
highlight pythonClassArg         ctermfg=73  guifg=#4ec9b0
highlight pythonClassRef         ctermfg=73  guifg=#4ec9b0
highlight pythonBuiltinType      ctermfg=73  guifg=#4ec9b0

highlight pythonParamDef         ctermfg=117 guifg=#9cdcfe
highlight pythonKeywordArg       ctermfg=117 guifg=#9cdcfe

highlight pythonString           ctermfg=174 guifg=#d29a83
highlight pythonRawString        ctermfg=174 guifg=#d29a83
highlight pythonTripleString     ctermfg=174 guifg=#d29a83
highlight pythonTripleRawString  ctermfg=174 guifg=#d29a83
highlight pythonFString          ctermfg=174 guifg=#d29a83
highlight pythonTripleFString    ctermfg=174 guifg=#d29a83
highlight pythonQuotes           ctermfg=174 guifg=#d29a83
highlight pythonTripleQuotes     ctermfg=174 guifg=#d29a83

highlight pythonFStringDelimiter ctermfg=220 guifg=#ffd710
highlight pythonEscape           ctermfg=180 guifg=#dbc088
highlight pythonFmtSpec          ctermfg=180 guifg=#dbc088

highlight pythonDelimiter        ctermfg=252 guifg=#d4d4d4
highlight pythonOperatorChar     ctermfg=252 guifg=#d4d4d4
highlight pythonConstant         ctermfg=252 guifg=#d4d4d4
highlight pythonComment          ctermfg=107 guifg=#6a9955
highlight pythonNumber           ctermfg=151 guifg=#b5cea8

" 3. IndentLine Guide (show_tab)
let g:indentLine_char = get(g:, 'indentLine_char', '│')
let g:indentLine_indentLevel = get(g:, 'indentLine_indentLevel', 20)

setlocal conceallevel=1
setlocal concealcursor=ic

" Display | / │ for tab characters (\t)
let s:indent_char = exists("g:indentLine_char") ? g:indentLine_char : "│"
execute 'setlocal listchars=tab:' . s:indent_char . '\ '
setlocal list

function! <SID>SetIndentLine()
    let space = &l:shiftwidth
    " First indent level (starts with 1 tab = shiftwidth spaces)
    exec 'syn match IndentLine /^ \%( \{' . (space - 1) . '}\)\@=/ containedin=ALL conceal cchar=' . g:indentLine_char
    " Subsequent indent levels
    for i in range(space+1, space * g:indentLine_indentLevel + 1, space)
        exec 'syn match IndentLine /\(^\s\+\)\@<=\%'.i.'v / containedin=ALL conceal cchar=' . g:indentLine_char
    endfor
endfunction

function! <SID>ResetWidth(...)
    if a:0 > 0
        let &l:shiftwidth = a:1
    endif
    syn clear IndentLine
    call <SID>SetIndentLine()
endfunction


if line('$') <= 1500
    call <SID>SetIndentLine()
    hi  Conceal ctermbg=none ctermfg=239 guifg=#4e4e4e
    setlocal concealcursor=ic
endif


command! -nargs=? ResetIndentLines call <SID>ResetWidth(<f-args>)
