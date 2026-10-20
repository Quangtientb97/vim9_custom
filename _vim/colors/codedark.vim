"=============================================================================
" Code Dark (Lean & Minimalist for Vim 9+)
" Tailored for SystemVerilog, C/C++, Make, Python, and Assembly
"=============================================================================
scriptencoding utf-8
set background=dark
highlight clear
if exists("syntax_on")
    syntax reset
endif
let g:colors_name = "codedark"

" 1. Editor UI Highlights
highlight Normal          guifg=#d0d0d0 guibg=#1e1e1e ctermfg=252 ctermbg=234 gui=NONE cterm=NONE
highlight ColorColumn     guibg=#222222 ctermbg=235 gui=NONE cterm=NONE
highlight Cursor          guifg=#ffffff guibg=#ffffff ctermfg=white ctermbg=white gui=NONE cterm=NONE
highlight CursorLine      guibg=#444444 ctermbg=238 gui=NONE cterm=NONE
highlight! link CursorColumn CursorLine
highlight CursorLineNr    guifg=#5fafff guibg=NONE    ctermfg=blue ctermbg=none gui=NONE cterm=NONE
highlight LineNr          guifg=#8a8a8a guibg=NONE    ctermfg=245 ctermbg=none gui=NONE cterm=NONE
highlight Directory       guifg=#5fafff ctermfg=blue  gui=NONE cterm=NONE
highlight EndOfBuffer     guifg=#585858 guibg=NONE    ctermfg=240 ctermbg=none gui=NONE cterm=NONE
highlight NonText         guifg=#585858 guibg=NONE    ctermfg=240 ctermbg=none gui=NONE cterm=NONE
highlight ErrorMsg        guifg=#ffffff guibg=#d70000 ctermfg=001 ctermbg=white cterm=reverse gui=reverse
highlight VertSplit       guifg=#444444 guibg=NONE    ctermfg=238 ctermbg=none gui=NONE cterm=NONE
highlight Folded          guifg=#1c1c1c guibg=#6c6c6c ctermfg=234 ctermbg=242 gui=NONE cterm=NONE
highlight FoldColumn      guifg=#5A5A5A guibg=#1E1E1E ctermfg=240 ctermbg=234 gui=NONE cterm=NONE
highlight SignColumn      guibg=#1E1E1E ctermbg=234 gui=NONE cterm=NONE
highlight MatchParen      guifg=#ffffff guibg=#8b4513 ctermfg=white ctermbg=brown gui=NONE cterm=NONE
highlight Search          guifg=#000000 guibg=#d7d75f ctermfg=black ctermbg=185 cterm=underline gui=underline
highlight IncSearch       guifg=NONE    guibg=#4B5632 ctermfg=NONE ctermbg=58  gui=NONE cterm=NONE
silent! highlight CurSearch guifg=#1c1c1c guibg=#ffaf00 ctermfg=232 ctermbg=214 gui=NONE cterm=NONE
highlight ModeMsg         guifg=#D4D4D4 guibg=#252526 ctermfg=188 ctermbg=235 gui=NONE cterm=NONE
highlight! link MoreMsg ModeMsg
highlight Pmenu           guifg=#808080 guibg=#121212 ctermfg=DarkGray ctermbg=233 gui=NONE cterm=NONE
highlight PmenuSel        guifg=#5fafff guibg=#121212 ctermfg=blue ctermbg=233 gui=NONE cterm=NONE
highlight PmenuSbar       guifg=#585858 guibg=#585858 ctermfg=240 ctermbg=240 gui=NONE cterm=NONE
highlight PmenuThumb      guifg=#8a8a8a guibg=#8a8a8a ctermfg=245 ctermbg=245 gui=NONE cterm=NONE
highlight Question        guifg=#569CD6 guibg=#1E1E1E ctermfg=75  ctermbg=234 gui=NONE cterm=NONE
highlight SpecialKey      guifg=#005faf ctermfg=darkblue gui=NONE cterm=NONE
highlight StatusLine      guifg=#D4D4D4 guibg=#1E1E1E ctermfg=188 ctermbg=234 gui=NONE cterm=NONE
highlight StatusLineNC    guifg=#D4D4D4 guibg=#1E1E1E ctermfg=188 ctermbg=234 gui=NONE cterm=NONE
highlight TabLine         guifg=#D4D4D4 guibg=#2D2D2D ctermfg=188 ctermbg=236 gui=NONE cterm=NONE
highlight TabLineFill     guifg=#D4D4D4 guibg=#252526 ctermfg=188 ctermbg=235 gui=NONE cterm=NONE
highlight TabLineSel      guifg=#D4D4D4 guibg=#1E1E1E ctermfg=188 ctermbg=234 gui=NONE cterm=NONE
highlight Title           guifg=#569CD6 ctermfg=75  gui=NONE cterm=NONE
highlight Visual          guibg=#444444 ctermbg=238 cterm=underline gui=underline
highlight! link VisualNOS Visual
highlight WarningMsg      guifg=#CE9178 guibg=#1E1E1E ctermfg=173 ctermbg=234 gui=NONE cterm=NONE
highlight WildMenu        guibg=#264F78 ctermbg=24  gui=NONE cterm=NONE
highlight netrwExe        guifg=#808080 ctermfg=gray gui=NONE cterm=NONE

" 2. Diff Highlights
highlight DiffAdd         guifg=#d787d7 guibg=NONE ctermfg=176 ctermbg=none cterm=underline gui=underline
highlight DiffChange      guifg=#d787d7 guibg=NONE ctermfg=176 ctermbg=none cterm=underline gui=underline
highlight DiffDelete      guifg=#5fafff guibg=NONE ctermfg=blue ctermbg=none gui=NONE cterm=NONE
highlight DiffText        guifg=#ffaf5f guibg=NONE ctermfg=215 ctermbg=none gui=NONE cterm=NONE
highlight! link diffAdded   DiffAdd
highlight! link diffChanged DiffChange
highlight! link diffRemoved DiffDelete

" 3. Standard Syntax Highlights
highlight Comment         guifg=#6A9955 ctermfg=107 gui=NONE cterm=NONE
highlight Constant        guifg=#9170CB ctermfg=13  gui=NONE cterm=NONE
highlight String          guifg=#ffaf5f ctermfg=215 gui=NONE cterm=NONE
highlight Character       guifg=#ffaf5f ctermfg=215 gui=NONE cterm=NONE
highlight Number          guifg=#B5CEA8 ctermfg=151 gui=NONE cterm=NONE
highlight Boolean         guifg=#569CD6 ctermfg=75  gui=NONE cterm=NONE
highlight! link Float Number
highlight Identifier      guifg=#5fafff ctermfg=blue gui=NONE cterm=NONE
highlight Function        guifg=#DCDCAA ctermfg=187 gui=NONE cterm=NONE
highlight Statement       guifg=#C586C0 ctermfg=176 gui=NONE cterm=NONE
highlight! link Conditional Statement
highlight! link Repeat      Statement
highlight! link Label       Statement
highlight! link Keyword     Statement
highlight! link Exception   Statement
highlight Operator        guifg=#D4D4D4 ctermfg=188 gui=NONE cterm=NONE
highlight PreProc         guifg=#9170CB ctermfg=13  gui=NONE cterm=NONE
highlight! link Include   PreProc
highlight! link Define    PreProc
highlight! link Macro     PreProc
highlight! link PreCondit PreProc
highlight Type            guifg=#5fafff ctermfg=blue gui=NONE cterm=NONE
highlight! link StorageClass Type
highlight! link Structure    Type
highlight! link Typedef      Type
highlight Special         guifg=#9170CB ctermfg=13  gui=NONE cterm=NONE
highlight! link SpecialChar Special
highlight! link Tag         Special
highlight! link Delimiter   Special
highlight! link SpecialComment Comment
highlight! link Debug       Special
highlight Underlined      guifg=NONE    gui=underline cterm=underline
highlight Conceal         guifg=#D4D4D4 guibg=#1E1E1E ctermfg=188 ctermbg=234 gui=NONE cterm=NONE
highlight Ignore          guifg=#1E1E1E ctermfg=234 gui=NONE cterm=NONE
highlight Error           guifg=#F44747 guibg=#1E1E1E ctermfg=203 ctermbg=234 gui=NONE cterm=NONE
highlight Todo            guifg=#D4D4D4 guibg=#373737 ctermfg=188 ctermbg=237 gui=NONE cterm=NONE
