syntax clear

syn match help_normal               "[a-zA-Z0-9|#]"      containedin=ALLBUT,help_bracket,help_upcase,help_func,help_statement,help_property
syn match help_bracket              "[.()|]"             containedin=ALL
syn match help_upcase               "\n[A-Z][A-Z][A-Z]*"   containedin=ALL
syn match help_func                 "\w\w*("             containedin=ALLBUT,help_bracket
syn keyword help_statement    class self                 containedin=ALLBUT,help_bracket
syn match help_property             "|  \w*\n"           containedin=ALLBUT,help_bracket

highlight help_upcase    ctermfg=13
highlight help_func      ctermfg=blue
highlight help_statement ctermfg=yellow
highlight help_normal    ctermfg=250
highlight help_property  ctermfg=yellow
