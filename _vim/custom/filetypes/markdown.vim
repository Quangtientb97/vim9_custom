"=============================================================================
" Markdown Syntax & Color Configuration
"=============================================================================

" 1. Markdown configuration
let g:markdown_syntax_conceal = 0
let g:markdown_fenced_languages = []
setlocal conceallevel=0

" 2. Load standard syntax engine (provides robust markdown parsing)
unlet! b:current_syntax
runtime! syntax/markdown.vim

" 3. Syntax sync (prevent highlight desync in long docs)
if line('$') <= 3000
    syntax sync fromstart
else
    syntax sync minlines=100
endif

" 4. Enhanced Syntax Elements (GFM tables, checkboxes, math)
syn match mdTablePipe containedin=markdownRule,markdownListMarker,NONE "|"
syn match mdTableDivider "^\s*|[-:| ]\+|\s*$"
syn match mdCheckboxEmpty "\[ \]"
syn match mdCheckboxDone  "\[[xX]\]"
syn region mdMath start="\$" end="\$" skip="\\\$" oneline
syn region mdMathBlock start="\$\$" end="\$\$"

" 5. Highlights matching custom vim aesthetic
highlight! markdownH1          ctermfg=13  guifg=#9170cb cterm=none gui=none
highlight! markdownH2          ctermfg=13  guifg=#9170cb cterm=none gui=none
highlight! markdownH3          ctermfg=176 guifg=#d787d7 cterm=none gui=none
highlight! markdownH4          ctermfg=176 guifg=#d787d7 cterm=none gui=none
highlight! markdownH5          ctermfg=215 guifg=#ffaf5f cterm=none gui=none
highlight! markdownH6          ctermfg=215 guifg=#ffaf5f cterm=none gui=none
highlight! markdownHeadingDelimiter ctermfg=139 guifg=#af87af cterm=none gui=none
highlight! markdownH1Delimiter ctermfg=13  guifg=#9170cb cterm=none gui=none
highlight! markdownH2Delimiter ctermfg=13  guifg=#9170cb cterm=none gui=none
highlight! markdownH3Delimiter ctermfg=176 guifg=#d787d7 cterm=none gui=none
highlight! markdownH4Delimiter ctermfg=176 guifg=#d787d7 cterm=none gui=none
highlight! markdownH5Delimiter ctermfg=215 guifg=#ffaf5f cterm=none gui=none
highlight! markdownH6Delimiter ctermfg=215 guifg=#ffaf5f cterm=none gui=none

" Code blocks and inline code: all characters in ``` ``` and ` ` are string color (orange / peach: 215)
highlight! markdownCode          ctermfg=215 guifg=#ffaf5f
highlight! markdownCodeBlock     ctermfg=215 guifg=#ffaf5f
highlight! markdownCodeDelimiter ctermfg=215 guifg=#ffaf5f

" Bold and Italic
highlight! markdownBold          ctermfg=blue guifg=#5fafff cterm=none gui=none
highlight! markdownBoldDelimiter ctermfg=245  guifg=#8a8a8a
highlight! markdownItalic        ctermfg=176  guifg=#d787d7 cterm=italic gui=italic
highlight! markdownItalicDelimiter ctermfg=245 guifg=#8a8a8a

" Lists and Bullets
highlight! markdownListMarker        ctermfg=blue guifg=#5fafff
highlight! markdownOrderedListMarker ctermfg=blue guifg=#5fafff

" Links and URLs
highlight! markdownLinkText      ctermfg=blue guifg=#5fafff cterm=underline gui=underline
highlight! markdownUrl           ctermfg=75   guifg=#5fafff cterm=underline gui=underline
highlight! markdownAutomaticLink ctermfg=75   guifg=#5fafff cterm=underline gui=underline

" Horizontal Rule / Separator (---, ***)
highlight! markdownRule          ctermfg=242  guifg=#6c6c6c

" Blockquotes (> ...)
highlight! markdownBlockquote    ctermfg=107  guifg=#6A9955 cterm=italic gui=italic

" GFM Tables
highlight! mdTablePipe           ctermfg=blue guifg=#5fafff
highlight! mdTableDivider        ctermfg=242  guifg=#6c6c6c

" Task Checkboxes
highlight! mdCheckboxEmpty       ctermfg=245  guifg=#8a8a8a
highlight! mdCheckboxDone        ctermfg=114  guifg=#87d787 cterm=none gui=none

" Math
highlight! mdMath                ctermfg=215  guifg=#ffaf5f
highlight! mdMathBlock           ctermfg=215  guifg=#ffaf5f

" Backward-compatible aliases
highlight default link md_heading markdownH1
highlight default link md_heading_count markdownOrderedListMarker
highlight default link md_highlight markdownBold
highlight default link md_inline_code markdownCode
highlight default link md_code_block markdownCodeBlock
highlight default link md_link markdownLinkText
