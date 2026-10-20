" =============================================================================
" Test Suite: SystemVerilog Indentation Rules
" Verifies relative block depth, out-of-body methods, multi-line arguments,
" and idempotency across edits.
" =============================================================================

let s:test_dir = expand('<sfile>:p:h')
execute 'source ' . fnameescape(s:test_dir . '/framework.vim')

function! RunIndentTests()
    call TestInit('SystemVerilog Indentation Suite')

    let l:fixture_file = s:test_dir . '/fixtures/indent_sample.sv'
    execute 'edit ' . fnameescape(l:fixture_file)
    setfiletype verilog_systemverilog

    " 1. Test specific line indentation calculations
    let l:cases = [
    \   [2,  0, 'Class declaration starts at column 0'],
    \   [5,  4, 'Class member prototype (extern virtual function) indents to 4'],
    \   [7,  4, 'Class member prototype (extern task) indents to 4 (no staircase)'],
    \   [8,  4, 'Second sequential extern task remains at 4 (no compounding)'],
    \   [9,  4, 'Multi-line extern task header starts at 4'],
    \   [10, 27, 'Multi-line argument continuation aligns under parenthesis'],
    \   [28, 0, 'endclass keyword aligns to column 0'],
    \   [30, 0, 'Out-of-body function declaration starts at column 0'],
    \   [31, 4, 'Statement inside out-of-body function indents to 4'],
    \   [32, 0, 'endfunction matches declaration indent (0)'],
    \   [34, 0, 'Out-of-body task declaration starts at column 0'],
    \   [35, 4, 'Variable declaration in out-of-body task indents to 4'],
    \   [36, 4, 'foreach loop starts at task body base indent (4)'],
    \   [37, 8, 'if statement inside foreach indents to 8'],
    \   [38, 12, 'Function call reset_task() inside if inside foreach indents to 12'],
    \   [39, 12, 'Statement following reset_task() maintains 12 spaces'],
    \   [40, 8, 'End of if block aligns to 8'],
    \   [41, 4, 'End of foreach block aligns to 4'],
    \   [42, 0, 'endtask aligns to column 0'],
    \   [44, 0, 'Out-of-body task with multi-line parameters starts at 0'],
    \   [46, 4, 'First statement in task with multi-line parameters indents to 4 (NOT param col)'],
    \   [47, 4, 'Subsequent if block in task body indents to 4'],
    \   [48, 8, 'Statement inside if block indents to 8'],
    \   [49, 8, 'Return statement inside if block indents to 8'],
    \   [50, 4, 'End of if block aligns to 4'],
    \   [51, 4, 'Statement after if block aligns to 4'],
    \   [52, 0, 'endtask aligns to column 0']
    \ ]

    for c in l:cases
        let v:lnum = c[0]
        let l:actual = eval(&indentexpr)
        call AssertEq(l:actual, c[1], printf('Line %2d: %s', c[0], c[2]))
    endfor

    " 2. Idempotency Test (Re-indenting must produce 0 changes)
    normal! gg=G
    let l:pass1_lines = getline(1, '$')

    normal! gg=G
    let l:pass2_lines = getline(1, '$')

    let l:idempotent = (l:pass1_lines ==# l:pass2_lines) ? 1 : 0
    call AssertTrue(l:idempotent, 'Full buffer re-indent (gg=G) is strictly idempotent (Pass 1 == Pass 2)')

    call TestSummarize()
endfunction

call RunIndentTests()
