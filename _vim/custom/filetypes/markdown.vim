syntax clear

syn match   md_heading       "^##* .*"
syn match   md_link          "https:\S\S*"
syn match   md_highlight     "\*\*..*\*\*"
syn match   md_highlight     "\*..*\*"
syn region  md_code_block    start=+```+ end=+```+
syn region  md_inline_code   start=+`+   end=+`+
"syn region  md_highlight     start=+\*\*\*+ end=+\*\*\*+
"syn region  md_highlight     start=+\*\*+   end=+\*\*+
"syn region  md_highlight     start=+\*+     end=+\*+
syn match   md_heading_count "^\s*[0-9][0-9]*\. "
syn match   md_heading_count "^\s*-"

highlight md_heading        ctermfg=13
highlight md_heading_count  ctermfg=blue
highlight md_highlight      ctermfg=blue
highlight md_inline_code    ctermfg=215
highlight md_link           ctermfg=blue cterm=underline
