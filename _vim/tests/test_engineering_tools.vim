" =============================================================================
" Test Suite: Engineering Utilities Suite (ConvertBase, QuickCalc, ShowAscii)
" Verifies radix conversion, inline mathematical/bitwise calculation, and
" ASCII character inspection in hardware/software design workflows.
" =============================================================================

let s:test_dir = expand('<sfile>:p:h')
execute 'source ' . fnameescape(s:test_dir . '/framework.vim')

call TestInit('Engineering Utilities Suite (ConvertBase, QuickCalc, ShowAscii)')

" Helper to capture echoed output from functions
function! s:CaptureOutput(cmd) abort
    let l:out = ''
    redir => l:out
    silent! execute a:cmd
    redir END
    return substitute(l:out, '[\r\n]', ' ', 'g')
endfunction

" -----------------------------------------------------------------------------
" 1. ConvertBase Tests (sb)
" -----------------------------------------------------------------------------
new
setlocal buftype=nofile bufhidden=wipe

" Test 1.1: Standard Decimal
call setline(1, 'int count = 100;')
call cursor(1, 14)
let s:res = s:CaptureOutput('call ConvertBase(0)')
call AssertMatch('\[100\]', s:res, 'ConvertBase identifies decimal 100')
call AssertMatch('Dec: 100', s:res, 'ConvertBase decimal value is 100')
call AssertMatch('Hex: 0x64', s:res, 'ConvertBase hex representation is 0x64')
call AssertMatch("Bin: 8'b0110_0100", s:res, "ConvertBase binary representation is 8'b0110_0100")

" Test 1.2: Standard Hexadecimal (0xABCD)
call setline(1, 'uint16_t mask = 0xABCD;')
call cursor(1, 20)
let s:res = s:CaptureOutput('call ConvertBase(0)')
call AssertMatch('\[0xABCD\]', s:res, 'ConvertBase identifies 0xABCD')
call AssertMatch('Dec: 43981', s:res, 'ConvertBase dec value is 43981')
call AssertMatch('Hex: 0xABCD', s:res, 'ConvertBase hex representation is 0xABCD')

" Test 1.3: SystemVerilog 32-bit Hex Literal (32'hDEAD_BEEF)
call setline(1, "logic [31:0] data = 32'hDEAD_BEEF;")
call cursor(1, 26)
let s:res = s:CaptureOutput('call ConvertBase(0)')
call AssertMatch("\\[32'hDEAD_BEEF\\]", s:res, "ConvertBase identifies 32'hDEAD_BEEF")
call AssertMatch('Dec: 3735928559', s:res, 'ConvertBase dec value is 3735928559')
call AssertMatch("Hex: 32'hDEAD_BEEF", s:res, "ConvertBase hex value preserves width 32'hDEAD_BEEF")
call AssertMatch("Bin: 32'b1101_1110_1010_1101_1011_1110_1110_1111", s:res, 'ConvertBase bin value preserves 32-bit width and nibble grouping')

" Test 1.4: SystemVerilog 8-bit Binary Literal (8'b1010_0101)
call setline(1, "logic [7:0] pattern = 8'b1010_0101;")
call cursor(1, 27)
let s:res = s:CaptureOutput('call ConvertBase(0)')
call AssertMatch("\\[8'b1010_0101\\]", s:res, "ConvertBase identifies 8'b1010_0101")
call AssertMatch('Dec: 165', s:res, 'ConvertBase dec value is 165')
call AssertMatch("Hex: 8'hA5", s:res, "ConvertBase hex value is 8'hA5")

" -----------------------------------------------------------------------------
" 2. QuickCalc Tests (sc)
" -----------------------------------------------------------------------------
" Test 2.1: Simple arithmetic (10 + 20 * 2)
call setline(1, 'int val = 10 + 20 * 2;')
call cursor(1, 15)
let s:res = s:CaptureOutput('call QuickCalc(0)')
call AssertMatch('\V[10 + 20 * 2] = 50 (Dec)', s:res, 'QuickCalc calculates arithmetic precedence 10 + 20 * 2 = 50')
call AssertMatch('\V0x32 (Hex)', s:res, 'QuickCalc hex representation is 0x32')
call AssertMatch("8'b0011_0010", s:res, "QuickCalc bin representation is 8'b0011_0010")

" Test 2.2: Bitwise Shift (1 << 8)
call setline(1, 'val = 1 << 8;')
call cursor(1, 9)
let s:res = s:CaptureOutput('call QuickCalc(0)')
call AssertMatch('\V256 (Dec)', s:res, 'QuickCalc bitwise shift 1 << 8 = 256')
call AssertMatch('\V0x0100 (Hex)', s:res, 'QuickCalc bitwise shift hex is 0x0100')

" Test 2.3: Bitwise Masking (0xFF & 0x0F)
call setline(1, 'val = 0xFF & 0x0F;')
call cursor(1, 12)
let s:res = s:CaptureOutput('call QuickCalc(0)')
call AssertMatch('\V15 (Dec)', s:res, 'QuickCalc bitwise AND 0xFF & 0x0F = 15')
call AssertMatch('\V0x0F (Hex)', s:res, 'QuickCalc bitwise AND hex is 0x0F')

" Test 2.4: SystemVerilog Hex Addition (32'h100 + 32'h20)
call setline(1, "logic [31:0] sum = 32'h100 + 32'h20;")
call cursor(1, 25)
let s:res = s:CaptureOutput('call QuickCalc(0)')
call AssertMatch('\V288 (Dec)', s:res, "QuickCalc SV hex expression 32'h100 + 32'h20 = 288")
call AssertMatch("32'h0000_0120", s:res, "QuickCalc formats 32-bit width hex 32'h0000_0120")

" -----------------------------------------------------------------------------
" 3. ShowAscii Tests (sa)
" -----------------------------------------------------------------------------
" Test 3.1: Printable ASCII character 'A' (65, 0x41)
call setline(1, "char c = 'A';")
call cursor(1, 11)
let s:res = s:CaptureOutput('call ShowAscii(0)')
call AssertMatch('\V[A]', s:res, 'ShowAscii identifies character A')
call AssertMatch('Dec: 65', s:res, 'ShowAscii decimal code is 65')
call AssertMatch('Hex: 0x41', s:res, 'ShowAscii hex code is 0x41')
call AssertMatch('Oct: 0101', s:res, 'ShowAscii octal code is 0101')
call AssertMatch("Bin: 8'b0100_0001", s:res, "ShowAscii binary is 8'b0100_0001")

" Test 3.2: Numeric ASCII string under cursor (e.g. 0x5A -> 'Z')
call setline(1, 'int ascii_val = 0x5A;')
call cursor(1, 18)
let s:res = s:CaptureOutput('call ShowAscii(0)')
call AssertMatch('\V0x5A -> ''Z''', s:res, "ShowAscii resolves 0x5A to character 'Z'")
call AssertMatch('Dec: 90', s:res, 'ShowAscii resolves 0x5A to Dec 90')

bdelete!

call TestSummarize()
