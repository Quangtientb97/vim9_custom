syntax clear

syn match help_bracket   "[.()|]"
syn match help_upcase    "\n[A-Z]\{3,\}"
syn match help_func      "\<\w\+\ze("
syn keyword help_statement class self
syn match help_property  "|\s\+\w\+\ze\n"

highlight help_upcase    ctermfg=13  guifg=#9170cb
highlight help_func      ctermfg=75  guifg=#569cd6
highlight help_statement ctermfg=186 guifg=#e5c07b
highlight help_property  ctermfg=186 guifg=#e5c07b

