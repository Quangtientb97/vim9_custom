" Vim after-indent file for SystemVerilog
" Extends standard verilog_systemverilog indent:
"   - Aligns multi-line function/task/method arguments inside parentheses
"   - Fixes method header and endfunction/endtask alignment (including out-of-body class::method)
"   - Preserves natural block indentation inside methods (delegating to GetVerilogSystemVerilogIndent)
"   - Handles direct method body statements gracefully without flattening

function! s:IsOutsideClass(lnum)
    call cursor(a:lnum, 1)
    let l:stop = max([1, a:lnum - 1000])
    let l:c = search('^\s*\%(\%(virtual\)\s\+\)\?\<class\>', 'bWn', l:stop)
    if l:c == 0
        return 1
    endif
    call cursor(a:lnum, 1)
    let l:ec = search('^\s*\<endclass\>', 'bWn', l:stop)
    return (l:ec >= l:c)
endfunction

let s:method_decl_pat = '^\s*\%(extern\s\+\|pure\s\+virtual\s\+\|import\s\+"DPI\)\@!\%(\%(virtual\|protected\|local\|static\)\s\+\)*\%(\<function\>\s\+\%(\%(automatic\|static\)\s\+\)\?\%(\%(void\|\k\+\%(\s*\[[^]]*\]\)*\)\s\+\)\?\|\<task\>\s\+\%(\%(automatic\|static\)\s\+\)\?\)\%(\k\+::\)*\k\+'

function! VerilogSystemVerilogIndentCustom()
    let l:curr_line = getline(v:lnum)

    " 1. Multi-line parameter/argument continuation (inside unclosed parentheses)
    let l:prev_lnum = prevnonblank(v:lnum - 1)
    if l:prev_lnum > 0
        let l:prev_line = getline(l:prev_lnum)
        if l:curr_line !~# '^\s*//' && l:prev_line !~# '^\s*//' && l:prev_line !~# ';\s*\%(//.*\)\?$' && l:prev_line !~# '\<begin\>\%(\s*:\s*\w\+\)\?\s*$' && l:prev_line !~# '^\s*\%(end\|endclass\|endtask\|endfunction\|endmodule\|`endif\)\>'
            let l:stopline = max([1, v:lnum - 30])
            call cursor(v:lnum, 1)
            let l:skip_arg = 'synIDattr(synID(".", col("."), 0), "name") =~# "^verilog\\%(Comment\\|String\\)"'
            let [l:p_lnum, l:p_col] = searchpairpos('(', '', ')', 'bW', l:skip_arg, l:stopline, 30)
            if l:p_lnum > 0
                if l:curr_line !~# '^\s*)'
                    let l:after_paren = getline(l:p_lnum)[l:p_col :]
                    let l:first_char = match(l:after_paren, '\S')
                    if l:first_char >= 0
                        return l:p_col + l:first_char
                    endif
                endif
            endif
        endif
    endif

    " 2. End of method (endfunction / endtask) matches declaration indent
    if l:curr_line =~# '^\s*\<end\%(function\|task\)\>'
        call cursor(v:lnum, 1)
        let l:fl = search(s:method_decl_pat, 'bWn', max([1, v:lnum - 1000]))
        if l:fl > 0
            return indent(l:fl)
        endif
        return 0
    endif

    " 3. Out-of-body method declaration line itself (starts at column 0)
    if l:curr_line =~# s:method_decl_pat && l:curr_line !~# '^\s*\%(extern\|pure\s\+virtual\|import\s\+"DPI\)\>'
        if s:IsOutsideClass(v:lnum)
            return 0
        endif
    endif

    " 4. Delegate to standard plugin for relative block indentation
    let l:ind = -1
    if exists('*GetVerilogSystemVerilogIndent')
        let l:ind = GetVerilogSystemVerilogIndent()
    endif

    " 5. Guard for statements directly inside a method body (outside any begin..end block)
    " When standard plugin does not see method boundaries, prevent flattening to column 0 or class indent
    call cursor(v:lnum, 1)
    let l:fl = search(s:method_decl_pat, 'bWn', max([1, v:lnum - 500]))
    if l:fl > 0
        let l:el = search('^\s*\<end\%(function\|task\)\>', 'bWn', l:fl)
        if l:el < l:fl
            " We are inside a method body. Check if inside an unclosed begin...end block
            call cursor(v:lnum, 1)
            let l:unclosed_begin = searchpair('\<begin\>', '', '\<end\>', 'bWn', '', l:fl)
            if l:unclosed_begin == 0
                " Directly in method body at top-level.
                " Base indent is indent(method) + shiftwidth()
                let l:base_ind = indent(l:fl) + shiftwidth()
                if l:ind < l:base_ind
                    let l:ind = l:base_ind
                endif
            endif
        endif
    endif

    return l:ind
endfunction

setlocal indentexpr=VerilogSystemVerilogIndentCustom()
