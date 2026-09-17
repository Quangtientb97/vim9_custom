"=============================================================================
" EDA Simulation & Tool Logfile Syntax & Performance Optimizer
" Supports: VCS, Xcelium, Questa, Verilator, UVM, UPF, Python, C/C++
"=============================================================================

" Fast syntax synchronization: log lines are self-contained (no multiline construct).
" Restricting sync to 30-60 lines drastically improves scrolling in massive logs.
syntax sync minlines=30 maxlines=60

" General log buffer optimizations
setlocal synmaxcol=500
setlocal foldmethod=manual
setlocal nowrap
setlocal noswapfile

" Disable matchup and paren matching for all log files (prevents regex backtracking on large logs/symbols)
let b:matchup_matchparen_enabled = 0
let b:matchup_matchparen_fallback = 0

" Additional optimizations for large log files (> 1500 lines)
if line('$') > 1500
    setlocal synmaxcol=250
    syntax sync minlines=15 maxlines=30
    silent! GitGutterBufferDisable
endif

" 1. Fast Keywords (Hash/Trie Lookup)
syn keyword log_Info    INFO info UVM_INFO
syn keyword log_Waring  WARNING warnings warning WARN warn UVM_WARNING
syn keyword log_Error   Error errors ERROR error UVM_ERROR
syn keyword log_Fatal   FATAL fatal UVM_FATAL
syn keyword log_Pass    PASS PASSED SUCCESS SUCCEEDED OK TEST_PASS

" 2. Optimized Matches (DFA friendly, non-backtracking)
" Cadence (*W, *E, *F), Synopsys (Warning-, Error-, Fatal-), Questa (** Warning/Error/Fatal)
syn match log_Waring  "\*W\%(,\k\+\)\?"
syn match log_Waring  "\*\* Warning:"
syn match log_Waring  "\<Warning-\k\+"
syn match log_Error   "\*E\%(,\k\+\)\?"
syn match log_Error   "\*\* Error:"
syn match log_Error   "\<Error-\k\+"
syn match log_Fatal   "\*F\%(,\k\+\)\?"
syn match log_Fatal   "\*\* Fatal:"
syn match log_Fatal   "\<Fatal-\k\+"

" Instance Hierarchy (e.g. uvm_test_top.env.agent.driver or top.tb.dut.u_core[0].reg)
syn match log_Hierachy "\<\w\+\%(\.\w\+\%(\[\d\+\]\)\?\)\+\>"

" Simulation Timestamps (e.g. @ 12500 ns, @123_456ps, @0:)
syn match log_Time "@\s*\d[0-9_]*\%(\s*\%(fs\|ps\|ns\|us\|ms\|s\)\)\?\>"

" Log Message ID / Tag (e.g. [RNTST], [UVM/RELNOTES], [DRV_RUN], [RegModel])
syn match log_Id "\[[A-Za-z0-9_/\-]*[A-Za-z_/\-][A-Za-z0-9_/\-]*\%(\s\+[A-Za-z0-9_/\-]\+\)*\]"

" Array / Vector Index (e.g. [0], [255])
syn match log_Index "\[\d\+\]"

" File Paths (e.g. /home/user/.../test.sv)
syn match log_Link "\%(^\|\s\)\zs\/[a-zA-Z0-9_./-]\+\>"

" Source Code Locations (e.g. driver.sv(85), .../uvm_report_server.svh(338))
syn match log_Source_sv "\%(^\|\s\|\.\.\.\)\zs[a-zA-Z0-9_./-]\+\.\%(sv\|v\|svh\|vhd\|c\|cpp\|h\|py\)(\d\+)"
syn match log_Source_sv "\.\.\.\S\+(\d\+)"

" Literal Numbers: SV ('h, 'd, 'b, 'o) and C-style hex (0x...)
syn match log_Num "\%(^\|[^\w.]\)\zs\%(\d\+\)\?'[hH][0-9a-fA-F_]\+\>"
syn match log_Num "\%(^\|[^\w.]\)\zs\%(\d\+\)\?'[dD][0-9_]\+\>"
syn match log_Num "\%(^\|[^\w.]\)\zs\%(\d\+\)\?'[bB][01_]\+\>"
syn match log_Num "\%(^\|[^\w.]\)\zs\%(\d\+\)\?'[oO][0-7_]\+\>"
syn match log_Num "\<0x[0-9a-fA-F_]\+\>"

" Test Verdict Highlights
syn match log_Pass "\<\%(TEST\|SIMULATION\|VERIFICATION\|CHECK\)\s\+\%(PASSED\|SUCCESSFUL\)\>"

" 3. Highlights (Preserve user colors & support terminal 256 / GUI)
highlight default log_Hierachy  ctermfg=blue          guifg=#5fafff
highlight default log_Link      ctermfg=blue          guifg=#5fafff
highlight default log_Info      cterm=underline       ctermfg=blue     guifg=#5fafff gui=underline
highlight default log_Error     cterm=bold,underline  ctermfg=196      guifg=#ff5f5f gui=bold,underline
highlight default log_Fatal     cterm=bold,underline  ctermfg=176      guifg=#d787d7 gui=bold,underline
highlight default log_Waring    cterm=underline       ctermfg=228      guifg=#ffff87 gui=underline
highlight default log_Time      ctermfg=blue          guifg=#5fafff
highlight default log_Id        ctermfg=brown         guifg=#af875f
highlight default log_Source_sv ctermfg=249           guifg=#b2b2b2
highlight default log_Index     ctermfg=215           guifg=#ffaf5f
highlight default log_Num       ctermfg=blue          guifg=#5fafff
highlight default log_Pass      cterm=bold            ctermfg=114      guifg=#87d787 gui=bold

" 4. Buffer-local Navigation Shortcuts for Log Review
" ]e / [e : Jump to Next / Previous Error or Fatal
" ]w / [w : Jump to Next / Previous Warning
" ]p / [p : Jump to Next / Previous Passed Verdict
function! LogJump(type, forward) abort
    let l:cur_line = line('.')
    let l:flags = a:forward ? 'W' : 'bW'
    if a:type ==# 'error'
        let l:pat = '\c\%(UVM_ERROR\|UVM_FATAL\|\*E,\|\*F,\|\*\* Error:\|\*\* Fatal:\|\<Error-\|\<Fatal-\|\<ERROR\>\|\<FATAL\>\)'
    elseif a:type ==# 'warning'
        let l:pat = '\c\%(UVM_WARNING\|\*W,\|\*\* Warning:\|\<Warning-\|\<WARNING\>\)'
    else
        let l:pat = '\c\%(\<TEST\s\+PASSED\>\|\<PASSED\>\|\<SUCCESS\>\)'
    endif

    if a:forward
        call cursor(l:cur_line, col([l:cur_line, '$']))
    else
        call cursor(l:cur_line, 1)
    endif

    let l:match = search(l:pat, l:flags)
    if l:match == 0
        call cursor(l:cur_line, 1)
        echohl WarningMsg | echo "No " . (a:forward ? "more " : "previous ") . a:type . " lines found" | echohl None
    else
        let @/ = l:pat
        call histadd('/', l:pat)
        normal! zz
    endif
endfunction

nnoremap <buffer><silent> ]e :call LogJump('error', 1)<cr>
nnoremap <buffer><silent> [e :call LogJump('error', 0)<cr>
nnoremap <buffer><silent> ]w :call LogJump('warning', 1)<cr>
nnoremap <buffer><silent> [w :call LogJump('warning', 0)<cr>
nnoremap <buffer><silent> ]p :call LogJump('pass', 1)<cr>
nnoremap <buffer><silent> [p :call LogJump('pass', 0)<cr>
