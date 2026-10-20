" =============================================================================
" Test Suite: Snippet Engine Suite (snippet_engine.vim)
" Verifies snippet registration, normalisation, filetype loading, variable
" resolution, buffer template expansion, and tabstop jumping.
" =============================================================================

let s:test_dir = expand('<sfile>:p:h')
execute 'source ' . fnameescape(s:test_dir . '/framework.vim')

call TestInit('Snippet Engine Suite')

" -----------------------------------------------------------------------------
" 1. Custom Snippet Registration & Normalization
" -----------------------------------------------------------------------------
call snippet_engine#add('test_trigger', [
    \ '// Snippet Header: ${1:name}',
    \ 'void ${1:name}_init(void) {',
    \ '    ${0}',
    \ '}'
    \ ], { 'filetype': 'c', 'desc': 'Custom C init function' })

new
setlocal filetype=c buftype=nofile bufhidden=wipe

call AssertTrue(snippet_engine#has('test_trigger'), 'snippet_engine#has resolves trigger without _Ent suffix')
call AssertTrue(snippet_engine#has('test_trigger_Ent'), 'snippet_engine#has resolves trigger with _Ent suffix')
call AssertFalse(snippet_engine#has('non_existent_snippet'), 'snippet_engine#has returns false for unregistered triggers')

" Global alias SnippetAdd
call SnippetAdd('test_global_alias', ['// Global alias line'], { 'filetype': 'c' })
call AssertTrue(snippet_engine#has('test_global_alias'), 'SnippetAdd global alias registers snippet successfully')

" -----------------------------------------------------------------------------
" 2. Dynamic Filetype Snippet Loading
" -----------------------------------------------------------------------------
" SystemVerilog filetype snippets
setlocal filetype=verilog_systemverilog
call AssertTrue(snippet_engine#has('sv_case'), 'Auto-loads verilog_systemverilog snippets: sv_case')
call AssertTrue(snippet_engine#has('sv_module'), 'Auto-loads verilog_systemverilog snippets: sv_module')
call AssertTrue(snippet_engine#has('sv_class'), 'Auto-loads verilog_systemverilog snippets: sv_class')
call AssertTrue(snippet_engine#has('sv_ifndef'), 'Auto-loads verilog_systemverilog snippets: sv_ifndef')

" Makefile filetype snippets
setlocal filetype=make
call AssertTrue(snippet_engine#has('if_makefile'), 'Auto-loads make snippets: if_makefile')
call AssertTrue(snippet_engine#has('echo'), 'Auto-loads make snippets: echo')

" -----------------------------------------------------------------------------
" 3. Snippet Expansion in Buffer
" -----------------------------------------------------------------------------
setlocal filetype=verilog_systemverilog
call setline(1, '    sv_case_Ent')
call cursor(1, 15)

let s:exp_res = snippet_engine#expand('sv_case_Ent')
call AssertTrue(s:exp_res, 'snippet_engine#expand returns 1 on success')

let s:line1 = getline(1)
let s:line2 = getline(2)
let s:line3 = getline(3)
call AssertMatch('\Vcase (expression)', s:line1, 'Line 1 expanded case with placeholder default')
call AssertMatch('\Vval1: begin', s:line2, 'Line 2 expanded branch val1: begin')
call AssertMatch('\V// TBD', s:line3, 'Line 3 expanded branch body')

" Verify cursor position landed on placeholder 1 (expression)
call AssertEq(line('.'), 1, 'Cursor positioned on line 1 for placeholder 1')

" -----------------------------------------------------------------------------
" 4. Tabstop Navigation (Jump Next / Jump Prev)
" -----------------------------------------------------------------------------
" Jump to placeholder 2 (val1)
call snippet_engine#jump_next()
call AssertEq(line('.'), 2, 'jump_next() moves cursor to placeholder 2 on line 2')

" Jump back to placeholder 1 (expression)
call snippet_engine#jump_prev()
call AssertEq(line('.'), 1, 'jump_prev() moves cursor back to placeholder 1 on line 1')

bdelete!

call TestSummarize()
