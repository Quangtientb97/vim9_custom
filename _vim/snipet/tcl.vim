"=============================================================================
" TCL Snippets
"=============================================================================
call snippet_engine#add('tcl_write_file_Ent', [
            \ 'set lst {${1:apple banana orange}}',
            \ 'set fh [open "${2:out.txt}" w]',
            \ 'foreach item $lst {',
            \ '    puts $fh $item',
            \ '}',
            \ 'close $fh',
            \ ], { 'filetype': 'tcl', 'desc': 'Write list to file' })

call snippet_engine#add('tcl_find_port_Ent', [
            \ 'set hierarchy "${1:hierarchy_path}"',
            \ 'set tmp_lst [find -newline -scope $hierarchy -ports *]',
            \ '${0}',
            \ ], { 'filetype': 'tcl', 'desc': 'Find ports under hierarchy' })
