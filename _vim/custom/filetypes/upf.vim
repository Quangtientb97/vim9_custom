"=============================================================================
" UPF (Unified Power Format) Syntax Configuration
"=============================================================================
syn match upf_statement "set_\w*"
syn match upf_statement "create_\w*"
syn match upf_statement "connect_\w*"
syn keyword upf_statement upf_version
syn match upf_option "-\w*"
syn match upf_braket "[{}\\]"

syn keyword upf_sub_statement primary ground

highlight upf_statement     ctermfg=176
highlight upf_option        ctermfg=blue
highlight upf_braket        ctermfg=215
highlight upf_sub_statement ctermfg=215
