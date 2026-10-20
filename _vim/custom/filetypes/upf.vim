"=============================================================================
" UPF (Unified Power Format) Syntax Configuration
"=============================================================================
let s:dict_file = expand('<sfile>:p:h:h:h') . '/dict/upf.dict'
if filereadable(s:dict_file)
    execute 'setlocal dictionary+=' . fnameescape(s:dict_file)
endif
if exists('*snippet_engine#load_filetype')
    call snippet_engine#load_filetype('upf')
endif
syn match upf_statement "set_\w*"
syn match upf_statement "create_\w*"
syn match upf_statement "connect_\w*"
syn keyword upf_statement upf_version
syn match upf_option "-\w*"
syn match upf_braket "[{}\\]"

syn keyword upf_sub_statement primary ground

highlight upf_statement     ctermfg=176 guifg=#d787d7
highlight upf_option        ctermfg=75  guifg=#569cd6
highlight upf_braket        ctermfg=215 guifg=#ffaf5f
highlight upf_sub_statement ctermfg=215 guifg=#ffaf5f
