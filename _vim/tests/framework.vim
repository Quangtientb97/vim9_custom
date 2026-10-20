" =============================================================================
" Standalone Test Framework for Vim Custom Configuration
" Supports Vim 7.4 through Vim 9.x without external plugin dependencies.
" =============================================================================

if exists('g:loaded_test_framework')
    finish
endif
let g:loaded_test_framework = 1

let s:suite_name = 'Vim Test Suite'
let s:total_count = 0
let s:pass_count = 0
let s:fail_count = 0
let s:failures = []

function! TestInit(suite_name)
    set nomore
    set shortmess+=aItToOF
    let s:suite_name = a:suite_name
    let s:total_count = 0
    let s:pass_count = 0
    let s:fail_count = 0
    let s:failures = []
    echo '====================================================================='
    echo 'RUNNING SUITE: ' . s:suite_name
    echo '====================================================================='
endfunction

function! AssertEq(actual, expected, desc)
    let s:total_count += 1
    if a:actual ==# a:expected
        let s:pass_count += 1
        echo printf('  [PASS] %s', a:desc)
        return 1
    else
        let s:fail_count += 1
        let l:err_msg = printf('FAIL: %s | Expected: %s, Got: %s', a:desc, string(a:expected), string(a:actual))
        call add(s:failures, l:err_msg)
        echohl ErrorMsg
        echo printf('  [FAIL] %s', a:desc)
        echo printf('         Expected: %s', string(a:expected))
        echo printf('         Got:      %s', string(a:actual))
        echohl None
        return 0
    endif
endfunction

function! AssertMatch(pat, str, desc)
    let s:total_count += 1
    if a:str =~# a:pat
        let s:pass_count += 1
        echo printf('  [PASS] %s', a:desc)
        return 1
    else
        let s:fail_count += 1
        let l:err_msg = printf('FAIL: %s | Pattern: %s, String: %s', a:desc, a:pat, string(a:str))
        call add(s:failures, l:err_msg)
        echohl ErrorMsg
        echo printf('  [FAIL] %s', a:desc)
        echo printf('         Pattern: %s', a:pat)
        echo printf('         String:  %s', string(a:str))
        echohl None
        return 0
    endif
endfunction

function! AssertTrue(cond, desc)
    return AssertEq(a:cond ? 1 : 0, 1, a:desc)
endfunction

function! AssertFalse(cond, desc)
    return AssertEq(a:cond ? 1 : 0, 0, a:desc)
endfunction

function! TestSummarize()
    echo '---------------------------------------------------------------------'
    echo printf('SUMMARY: %s', s:suite_name)
    echo printf('  Total Tests: %d | Passed: %d | Failed: %d', s:total_count, s:pass_count, s:fail_count)
    if s:fail_count > 0
        echohl ErrorMsg
        echo '  STATUS: FAILED'
        for err in s:failures
            echo '    - ' . err
        endfor
        echohl None
        echo '---------------------------------------------------------------------'
        cquit 1
    else
        echohl Directory
        echo '  STATUS: ALL TESTS PASSED'
        echohl None
        echo '---------------------------------------------------------------------'
        qall!
    endif
endfunction
