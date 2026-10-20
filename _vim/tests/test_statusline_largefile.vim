" =============================================================================
" Test Suite: Statusline and Large File Performance Suite
" Verifies statusline formatting, powerline arrow toggle, CRLF detection,
" and automated buffer performance tuning for large files (>1500 & >5000 lines).
" =============================================================================

let s:test_dir = expand('<sfile>:p:h')
execute 'source ' . fnameescape(s:test_dir . '/framework.vim')

call TestInit('Statusline and Large File Performance Suite')

new
setlocal filetype=verilog_systemverilog buftype=nofile bufhidden=wipe

" -----------------------------------------------------------------------------
" 1. Powerline Arrow Toggling (TogglePowerlineArrow)
" -----------------------------------------------------------------------------
let g:powerline_arrow = 0
call AssertEq(g:powerline_arrow, 0, 'Powerline arrow default is 0 (flat mode)')

call TogglePowerlineArrow()
call AssertEq(g:powerline_arrow, 1, 'TogglePowerlineArrow() enables arrow glyph mode (1)')

let s:st_active_arrow = CustomStatusLine(1)
call AssertMatch('', s:st_active_arrow, 'CustomStatusLine includes glyph  in arrow mode')

call TogglePowerlineArrow()
call AssertEq(g:powerline_arrow, 0, 'TogglePowerlineArrow() toggles back to flat mode (0)')

let s:st_active_flat = CustomStatusLine(1)
call AssertFalse(s:st_active_flat =~# '', 'CustomStatusLine excludes glyph  in flat mode')

" -----------------------------------------------------------------------------
" 2. Line Ending CRLF Warning (StatusLineFileFormat)
" -----------------------------------------------------------------------------
setlocal buftype=
setlocal ff=unix
call AssertEq(StatusLineFileFormat(), '', 'StatusLineFileFormat reports empty for clean UNIX buffers')

setlocal ff=dos
call AssertMatch('⚠️ CRLF', StatusLineFileFormat(), 'StatusLineFileFormat warns on Windows CRLF line endings')

setlocal ff=mac
call AssertMatch('⚠️ MAC-CR', StatusLineFileFormat(), 'StatusLineFileFormat warns on legacy Mac CR line endings')

setlocal ff=unix
setlocal buftype=nofile

" -----------------------------------------------------------------------------
" 3. Custom Statusline Active vs Inactive State
" -----------------------------------------------------------------------------
let s:active_st = CustomStatusLine(1)
call AssertMatch('StatusLineFileActive', s:active_st, 'CustomStatusLine(1) applies active highlight group')
call AssertMatch('%l/%L', s:active_st, 'CustomStatusLine contains line position counters')

let s:inactive_st = CustomStatusLine(0)
call AssertMatch('StatusLineNCFile', s:inactive_st, 'CustomStatusLine(0) applies non-current highlight group')

" -----------------------------------------------------------------------------
" 4. Large File Performance Optimizer (large_file.vim)
" -----------------------------------------------------------------------------
" Normal file <= 1500 lines: unthrottled
%delete _
call setline(1, repeat(['// normal code line'], 100))
doautocmd BufReadPost
call AssertFalse(get(b:, 'large_file_optimized', 0), 'Normal file (<1500 lines) is not throttled')

" Large file > 1500 lines: memory and sync optimizations
%delete _
call setline(1, repeat(['// large simulation line'], 1600))
setlocal swapfile
doautocmd BufReadPost

call AssertTrue(get(b:, 'large_file_optimized', 0), 'Large file (>1500 lines) sets b:large_file_optimized flag')
call AssertFalse(&l:swapfile, 'Large file disables swapfile to eliminate disk I/O')
call AssertEq(&l:synmaxcol, 300, 'Large file restricts synmaxcol to 300')
call AssertEq(get(b:, 'matchup_matchparen_enabled', 1), 0, 'Large file disables vim-matchup matchparen')
call AssertEq(get(b:, 'context_enabled', 1), 0, 'Large file disables sticky context header')

" Very large file > 5000 lines: cursorline disabling
%delete _
call setline(1, repeat(['// huge dump line'], 5500))
setlocal cursorline
doautocmd BufReadPost

call AssertFalse(&l:cursorline, 'Very large file (>5000 lines) disables cursorline to maximize scroll FPS')

bdelete!

call TestSummarize()
