" =============================================================================
" Test Suite: Advanced Editing Operations (Verilog Align, SplitJoin, Surround, Dox)
" Verifies hardware signal alignment, structural split/join transformations,
" quote/pair deletion, and Doxygen documentation generation.
" =============================================================================

let s:test_dir = expand('<sfile>:p:h')
execute 'source ' . fnameescape(s:test_dir . '/framework.vim')

call TestInit('Advanced Editing Operations Suite')

new
setlocal filetype=verilog_systemverilog buftype=nofile bufhidden=wipe

" -----------------------------------------------------------------------------
" 1. Verilog Alignment Tests (AlignVerilogDecls)
" -----------------------------------------------------------------------------
let s:unaligned_ports = [
    \ '    input logic clk,',
    \ '    input logic [31:0] data_in,',
    \ '    output reg [7:0] data_out,',
    \ '    output logic valid'
    \ ]
call setline(1, s:unaligned_ports)
call AlignVerilogDecls(1, 4)

let s:aligned_l1 = getline(1)
let s:aligned_l2 = getline(2)
let s:aligned_l3 = getline(3)
let s:aligned_l4 = getline(4)

call AssertMatch('^\s*input\s\+logic\s\+clk,', s:aligned_l1, 'Port clk has scalar range padding')
call AssertMatch('^\s*input\s\+logic\s\+\[31:0\]\s\+data_in,', s:aligned_l2, 'Port data_in range and name aligned')
call AssertMatch('^\s*output\s\+reg\s\+\[7:0\]\s\+data_out,', s:aligned_l3, 'Port data_out type reg aligned with logic')
call AssertMatch('^\s*output\s\+logic\s\+valid', s:aligned_l4, 'Port valid scalar padded and aligned')

" -----------------------------------------------------------------------------
" 2. Split & Join Engine Tests (CustomSplit & CustomJoin)
" -----------------------------------------------------------------------------
" 2.1: Function arguments split and join
%delete _
let s:single_func = 'function void test(int a, logic [7:0] b, string c);'
call setline(1, s:single_func)
call cursor(1, 20)

call CustomSplit()
call AssertEq(line('$'), 5, 'CustomSplit expands single-line arguments into 5 lines')
call AssertMatch('^\s*int a,', getline(2), 'CustomSplit places first argument on line 2')
call AssertMatch('^\s*logic \[7:0\] b,', getline(3), 'CustomSplit places second argument on line 3')
call AssertMatch('^\s*string c', getline(4), 'CustomSplit places third argument on line 4')

" Re-join and verify idempotency
call cursor(1, 20)
call CustomJoin()
call AssertEq(line('$'), 1, 'CustomJoin collapses multiline function back to 1 line')
call AssertEq(getline(1), s:single_func, 'CustomJoin perfectly restores original signature')

" 2.2: Nested brackets awareness in port instance (.data({a, b}))
%delete _
let s:nested_inst = 'my_inst u1 (.clk(clk), .data({a, b}), .rst_n(rst_n));'
call setline(1, s:nested_inst)
call cursor(1, 15)

call CustomSplit()
call AssertEq(line('$'), 5, 'CustomSplit respects nested concatenation in .data({a, b})')
call AssertMatch('^\s*\.data({a, b}),', getline(3), 'Nested commas inside {a, b} are preserved without splitting')

" -----------------------------------------------------------------------------
" 3. Surround Deletion Tests (ds)
" -----------------------------------------------------------------------------
%delete _
" Double quote deletion
call setline(1, 'string s = "hello_world";')
call cursor(1, 15)
call setreg('"', '')
execute 'normal ds'
call AssertEq(getline(1), 'string s = hello_world;', 'ds removes double quotes around word')

" Single quote deletion
%delete _
call setline(1, "char c = 'X';")
call cursor(1, 11)
execute 'normal ds'
call AssertEq(getline(1), 'char c = X;', 'ds removes single quotes around character')

" -----------------------------------------------------------------------------
" 4. Doxygen Generator Tests (DoxGenerate)
" -----------------------------------------------------------------------------
%delete _
let s:module_decl = [
    \ 'module my_fifo #(parameter DEPTH = 16)(',
    \ '    input  logic clk,',
    \ '    output logic empty',
    \ ');',
    \ 'endmodule'
    \ ]
call setline(1, s:module_decl)
call cursor(1, 1)

call DoxGenerate()
let s:dox_lines = join(getline(1, 10), "\n")
call AssertMatch('\V@brief my_fifo', s:dox_lines, 'DoxGenerate creates @brief tag with module name')
call AssertMatch('\V@param[param] DEPTH', s:dox_lines, 'DoxGenerate extracts parameter DEPTH')
call AssertMatch('\V@param[in]      clk', s:dox_lines, 'DoxGenerate extracts input port clk')
call AssertMatch('\V@param[out]     empty', s:dox_lines, 'DoxGenerate extracts output port empty')

bdelete!

call TestSummarize()
