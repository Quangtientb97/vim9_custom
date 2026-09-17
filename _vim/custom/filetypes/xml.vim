"=============================================================================
" XML Syntax & Snippets Configuration
"=============================================================================
execute "setlocal dictionary+=" . expand("<sfile>:p")

inorea xml_template_Ent <esc>:set formatoptions-=cro<cr>i
            \<?xml version="1.0" encoding="UTF-8"?><cr>
            \<component><cr>
            \<foo>this_is_foo</foo><cr>
            \<foo1>this_is_foo1</foo1><cr>
            \</component><cr>
            \<esc>:set formatoptions+=cro<cr>

inorea xml_tag_Ent <esc>:set formatoptions-=cro<cr>i
            \<__f_tag></__f_tag><esc>/__f_\w*<cr>ggn
            \<esc>:set formatoptions+=cro<cr>
