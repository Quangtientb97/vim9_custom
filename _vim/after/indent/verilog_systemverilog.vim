" Vim after-indent file for SystemVerilog
" Extends standard verilog_systemverilog indent to align multi-line function/task/method arguments

function! VerilogSystemVerilogIndentCustom()
    " Check if current line is inside parentheses
    let l:skip_arg  = 'synIDattr(synID(".", col("."), 0), "name") == "verilogComment"'
    let l:skip_arg .= ' || synIDattr(synID(".", col("."), 0), "name") == "verilogString"'
    call cursor(v:lnum, 1)
    let [l:p_lnum, l:p_col] = searchpairpos('(', '', ')', 'bW', l:skip_arg)
    if l:p_lnum > 0
        " If current line starts with ')', let default indent handle it
        if getline(v:lnum) !~ '^\s*)'
            let l:after_paren = getline(l:p_lnum)[l:p_col :]
            let l:first_char = match(l:after_paren, '\S')
            if l:first_char >= 0
                return l:p_col + l:first_char
            endif
        endif
    endif

    if exists('*GetVerilogSystemVerilogIndent')
        return GetVerilogSystemVerilogIndent()
    endif
    return -1
endfunction

setlocal indentexpr=VerilogSystemVerilogIndentCustom()
