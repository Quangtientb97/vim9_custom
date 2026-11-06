" =============================================================================
" Test Suite: Python Syntax Highlighting Rules (VS Code Dark+ from python.png)
" Verifies def/control keywords, parameters, kwargs, booleans, string prefixes,
" f-strings, rainbow brackets, and escape sequences.
" =============================================================================

let s:test_dir = expand('<sfile>:p:h')
execute 'source ' . fnameescape(s:test_dir . '/framework.vim')

function! RunPythonSyntaxTests()
    call TestInit('Python Syntax Highlighting Suite')

    let l:fixture_file = s:test_dir . '/fixtures/sample_python.py'
    execute 'edit ' . fnameescape(l:fixture_file)
    setfiletype python

    " Ensure rainbow is loaded
    if exists('*rainbow_main#load')
        silent! call rainbow_main#load()
    endif

    " Helper to get syntax group name at line, col
    function! s:SynName(line, col)
        return synIDattr(synID(a:line, a:col, 1), 'name')
    endfunction

    " 1. Line 1: Function call and method chaining
    call AssertEq(s:SynName(1, 34), 'pythonFunctionCall', 'Line 1: Method ".sub(" is pythonFunctionCall')
    call AssertEq(s:SynName(1, 33), 'pythonDelimiter', 'Line 1: Dot "." before sub is pythonDelimiter')
    call AssertEq(s:SynName(1, 52), 'pythonFunctionCall', 'Line 1: Method ".strip(" is pythonFunctionCall')

    " 2. Line 2: if not clean_line:
    call AssertEq(s:SynName(2, 1), 'pythonConditional', 'Line 2: "if" is pythonConditional')
    call AssertEq(s:SynName(2, 4), 'pythonOperator', 'Line 2: "not" is pythonOperator')

    " 3. Line 3: continue
    call AssertEq(s:SynName(3, 5), 'pythonStatement', 'Line 3: "continue" is pythonStatement')

    " 4. Line 4: String prefix and regex escape
    call AssertEq(s:SynName(4, 14), 'pythonStrPrefix', 'Line 4: "r" in r"..." is pythonStrPrefix')
    call AssertEq(s:SynName(4, 19), 'pythonEscape', 'Line 4: "\s" is pythonEscape')

    " 5. Line 9: Number 0
    call AssertEq(s:SynName(9, 26), 'pythonNumber', 'Line 9: Number "0" in parts[0] is pythonNumber')

    " 6. Line 12: return
    call AssertEq(s:SynName(12, 1), 'pythonStatement', 'Line 12: "return" is pythonStatement')

    " 7. Line 15: def run_rename(old_name, new_name):
    call AssertEq(s:SynName(15, 1), 'pythonDeclaration', 'Line 15: "def" is pythonDeclaration')
    call AssertEq(s:SynName(15, 5), 'pythonFunctionCall', 'Line 15: "run_rename" is pythonFunctionCall')
    call AssertEq(s:SynName(15, 16), 'pythonParamDef', 'Line 15: "old_name" is pythonParamDef')
    call AssertEq(s:SynName(15, 26), 'pythonParamDef', 'Line 15: "new_name" is pythonParamDef')

    " 8. Line 16: Comment
    call AssertEq(s:SynName(16, 5), 'pythonComment', 'Line 16: "# Attempt..." is pythonComment')

    " 9. Line 17: F-string prefix and delimiter
    call AssertEq(s:SynName(17, 12), 'pythonStrPrefix', 'Line 17: "f" in f"..." is pythonStrPrefix')
    call AssertEq(s:SynName(17, 14), 'pythonFStringDelimiter', 'Line 17: "{" in f-string is pythonFStringDelimiter')

    " 10. Line 18: Keyword arguments and booleans
    call AssertEq(s:SynName(18, 32), 'pythonKeywordArg', 'Line 18: "shell" in shell=True is pythonKeywordArg')
    call AssertEq(s:SynName(18, 38), 'pythonBoolean', 'Line 18: "True" in shell=True is pythonBoolean')
    call AssertEq(s:SynName(18, 44), 'pythonKeywordArg', 'Line 18: "stdout" in stdout=... is pythonKeywordArg')
    call AssertEq(s:SynName(18, 98), 'pythonKeywordArg', 'Line 18: "check" in check=False is pythonKeywordArg')
    call AssertEq(s:SynName(18, 104), 'pythonBoolean', 'Line 18: "False" in check=False is pythonBoolean')

    " 11. Line 20: return True
    call AssertEq(s:SynName(20, 9), 'pythonStatement', 'Line 20: "return" is pythonStatement')
    call AssertEq(s:SynName(20, 16), 'pythonBoolean', 'Line 20: "True" is pythonBoolean')

    " 12. Line 26: else:
    call AssertEq(s:SynName(26, 5), 'pythonConditional', 'Line 26: "else" is pythonConditional')

    " 13. Lines 37-38: import, from, as (pythonInclude)
    call AssertEq(s:SynName(37, 1), 'pythonInclude', 'Line 37: "import" is pythonInclude')
    call AssertEq(s:SynName(38, 1), 'pythonInclude', 'Line 38: "from" is pythonInclude')
    call AssertEq(s:SynName(38, 9), 'pythonInclude', 'Line 38: "import" in from...import is pythonInclude')
    call AssertEq(s:SynName(38, 21), 'pythonInclude', 'Line 38: "as" in from...import...as is pythonInclude')

    " 14. Line 41: class register_c(register_base_c):
    call AssertEq(s:SynName(41, 1), 'pythonClassDecl', 'Line 41: "class" is pythonClassDecl')
    call AssertEq(s:SynName(41, 7), 'pythonClassName', 'Line 41: "register_c" is pythonClassName')
    call AssertEq(s:SynName(41, 18), 'pythonClassArg', 'Line 41: "register_base_c" is pythonClassArg')

    " 15. Line 42: def compose(self):
    call AssertEq(s:SynName(42, 5), 'pythonDeclaration', 'Line 42: "def" is pythonDeclaration')
    call AssertEq(s:SynName(42, 9), 'pythonFunctionCall', 'Line 42: "compose" is pythonFunctionCall')
    call AssertEq(s:SynName(42, 17), 'pythonObj', 'Line 42: "self" is pythonObj')

    " 16. Line 43: super().compose()
    call AssertEq(s:SynName(43, 9), 'pythonBuiltinType', 'Line 43: "super" is pythonBuiltinType')
    call AssertEq(s:SynName(43, 17), 'pythonFunctionCall', 'Line 43: "compose" is pythonFunctionCall')

    " 17. Line 46: class field_c(field_base_c):
    call AssertEq(s:SynName(46, 1), 'pythonClassDecl', 'Line 46: "class" is pythonClassDecl')
    call AssertEq(s:SynName(46, 7), 'pythonClassName', 'Line 46: "field_c" is pythonClassName')
    call AssertEq(s:SynName(46, 15), 'pythonClassArg', 'Line 46: "field_base_c" is pythonClassArg')

    " 18. Line 51: for reserved_field in ...:
    call AssertEq(s:SynName(51, 1), 'pythonRepeat', 'Line 51: "for" is pythonRepeat')
    call AssertEq(s:SynName(51, 20), 'pythonRepeat', 'Line 51: "in" is pythonRepeat')

    " 19. Line 52: field = field_c()
    call AssertEq(s:SynName(52, 13), 'pythonClassRef', 'Line 52: "field_c" is pythonClassRef')

    " 20. Line 53: addr_val = int("0x10", 16)
    call AssertEq(s:SynName(53, 16), 'pythonBuiltinType', 'Line 53: "int" is pythonBuiltinType')

    call TestSummarize()
endfunction

call RunPythonSyntaxTests()
