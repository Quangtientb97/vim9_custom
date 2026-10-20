" =============================================================================
" Test Suite: Makefile Syntax Highlighting Rules
" Verifies single-quote escaping, variable interpolation (${VAR}, $(VAR), $@),
" indented comments, and redirection operators.
" =============================================================================

let s:test_dir = expand('<sfile>:p:h')
execute 'source ' . fnameescape(s:test_dir . '/framework.vim')

function! RunMakeSyntaxTests()
    call TestInit('Makefile Syntax Highlighting Suite')

    let l:fixture_file = s:test_dir . '/fixtures/makefile_sample.mk'
    execute 'edit ' . fnameescape(l:fixture_file)
    setfiletype make

    " Helper to get syntax group name at line, col
    function! s:SynName(line, col)
        return synIDattr(synID(a:line, a:col, 1), 'name')
    endfunction

    " 1. Target rule
    call AssertEq(s:SynName(2, 1), 'make_action', 'Line 2: Target name "opt.fsdb_all:" highlighted as make_action')

    " 2. Recipe silent @ and bash keyword
    call AssertEq(s:SynName(3, 2), 'make_var_in_bash', 'Line 3: Recipe prefix "@" highlighted as make_var_in_bash')
    call AssertEq(s:SynName(3, 3), 'make_bash_keyword', 'Line 3: Command "echo" highlighted as make_bash_keyword')

    " 3. Automatic variable $@
    call AssertEq(s:SynName(3, 16), 'make_variable', 'Line 3: Dollar "$" in "$@" highlighted as make_variable')
    call AssertEq(s:SynName(3, 17), 'make_variable', 'Line 3: At "@" in "$@" highlighted as make_variable (atomic)')

    " 4. Indented comment
    call AssertEq(s:SynName(4, 2), 'make_comment', 'Line 4: Indented comment "#" highlighted as make_comment')

    " 5. Single-quote string with trailing backslash (Line 7)
    let l:line7 = getline(7)
    let l:quote_start = match(l:line7, "'") + 1
    let l:quote_end   = match(l:line7, "'", l:quote_start) + 1
    let l:redir_col   = match(l:line7, '>>') + 1
    let l:var_col     = match(l:line7, '\${MAKE_DIR_TEMP}') + 1
    let l:runfile_col = match(l:line7, '\${RUN_FILE}') + 1

    call AssertEq(s:SynName(7, l:quote_start), 'make_string', 'Line 7: Opening single quote starts make_string')
    call AssertEq(s:SynName(7, l:quote_end),   'make_string', 'Line 7: Closing single quote after backslash ends make_string')
    call AssertEq(s:SynName(7, l:redir_col),   'make_and',    'Line 7: Redirection ">>" outside string highlighted as make_and')
    call AssertEq(s:SynName(7, l:var_col),     'make_variable', 'Line 7: "${MAKE_DIR_TEMP}" outside string highlighted as make_variable')
    call AssertEq(s:SynName(7, l:runfile_col), 'make_variable', 'Line 7: "${RUN_FILE}" outside string highlighted as make_variable')

    " 6. Lines 8 and 9 are not corrupted by line 7
    let l:line8 = getline(8)
    let l:l8_echo_col = match(l:line8, 'echo') + 1
    let l:l8_quote_col = match(l:line8, "'") + 1
    let l:l8_redir_col = match(l:line8, '>>') + 1

    call AssertEq(s:SynName(8, l:l8_echo_col),  'make_bash_keyword', 'Line 8: "echo" is NOT swallowed by string from line 7')
    call AssertEq(s:SynName(8, l:l8_quote_col), 'make_string',       'Line 8: String opens properly on line 8')
    call AssertEq(s:SynName(8, l:l8_redir_col), 'make_and',          'Line 8: Redirection ">>" highlighted as make_and')

    " 7. Double-quote string with escaped quotes
    let l:line10 = getline(10)
    let l:dq_start = match(l:line10, '"') + 1
    let l:dq_inside = match(l:line10, 'escaped') + 1
    let l:log_var = match(l:line10, '\$(LOG_FILE)') + 1

    call AssertEq(s:SynName(10, l:dq_start),  'make_string',   'Line 10: Double quote starts make_string')
    call AssertEq(s:SynName(10, l:dq_inside), 'make_string',   'Line 10: Content inside escaped quotes remains make_string')
    call AssertEq(s:SynName(10, l:log_var),   'make_variable', 'Line 10: "$(LOG_FILE)" highlighted as make_variable')

    call TestSummarize()
endfunction

call RunMakeSyntaxTests()
