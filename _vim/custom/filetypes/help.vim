syntax clear

syn match help_bracket   "[.()|]"
syn match help_upcase    "\n[A-Z]\{3,\}"
syn match help_func      "\<\w\+\ze("
syn keyword help_statement class self
syn match help_property  "|\s\+\w\+\ze\n"

highlight help_upcase    ctermfg=13
highlight help_func      ctermfg=blue
highlight help_statement ctermfg=yellow
highlight help_property  ctermfg=yellow

