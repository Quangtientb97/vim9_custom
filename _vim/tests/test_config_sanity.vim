" =============================================================================
" Test Suite: Vimrc Configuration Sanity & Performance Options
" Verifies core editing settings, compatibility guards, performance parameters,
" and custom functions.
" =============================================================================

let s:test_dir = expand('<sfile>:p:h')
execute 'source ' . fnameescape(s:test_dir . '/framework.vim')

function! RunConfigSanityTests()
    call TestInit('Vimrc Configuration & Sanity Suite')

    " 1. Core Tab & Indentation Settings
    call AssertEq(&shiftwidth, 4, 'shiftwidth is set to 4')
    call AssertEq(&tabstop, 4, 'tabstop is set to 4')
    call AssertEq(&expandtab, 1, 'expandtab is enabled')
    call AssertMatch('indent', &backspace, 'backspace allows indent backspacing')

    " 2. Performance & Search Optimizations
    call AssertEq(&tagbsearch, 1, 'tagbsearch is enabled for O(log N) binary tag search')
    call AssertEq(g:matchup_matchparen_stopline, 100, 'matchup stopline is limited to 100 lines for fast scrolling')
    call AssertEq(g:matchup_matchparen_offscreen, {}, 'matchup offscreen popup is disabled for scroll performance')

    " 3. Vim 7.4 Compatibility Guards
    if has('timers') && exists('*timer_pause')
        call AssertTrue(exists('g:matchup_matchparen_deferred'), 'Deferred matchup is guarded by timer support')
    else
        call AssertFalse(exists('g:matchup_matchparen_deferred'), 'Deferred matchup is suppressed on older Vim without timers')
    endif

    " 4. Colorscheme & Visual Integrity
    call AssertEq(g:colors_name, 'codedark', 'Active colorscheme is codedark')
    call AssertTrue(hlexists('StatusLine'), 'StatusLine highlight group is defined')
    call AssertTrue(hlexists('StatusLineNC'), 'StatusLineNC highlight group is defined')

    " 5. Custom Engineering Functions & Performance Guards
    call AssertTrue(exists('#BufReadPre'), 'Large file performance guard (BufReadPre) is registered')
    call AssertTrue(exists('*StatusLineSearchCount'), 'StatusLineSearchCount() throttling function is defined')
    call AssertTrue(exists('*HighlightCursorWord'), 'HighlightCursorWord() function is defined')
    call AssertTrue(exists('*ToggleNERDTree'), 'ToggleNERDTree() wrapper is defined')

    " 6. FileType Autocmd Registration & Indent Engine Availability
    call AssertTrue(exists('#filetypedetect#BufRead#*.sv'), 'SystemVerilog file extension detection is registered')
    call AssertTrue(exists('#filetypedetect#BufRead#*.svh'), 'SystemVerilog header extension detection is registered')

    setfiletype verilog_systemverilog
    call AssertTrue(exists('*VerilogSystemVerilogIndentCustom'), 'VerilogSystemVerilogIndentCustom() engine loads on SV buffer')

    " 7. Terminal Escape Leakage Prevention (modifyOtherKeys & Terminal Queries)
    if !has('gui_running')
        call AssertEq(&t_TI, '', 't_TI is cleared to prevent modifyOtherKeys escape leakage (^[>4;2m)')
        call AssertEq(&t_TE, '', 't_TE is cleared to prevent exit escape leakage (^[>4;m)')
        call AssertEq(&t_u7, '', 't_u7 cursor position query is cleared to prevent buffer pollution')
        call AssertEq(&t_RV, '', 't_RV terminal version query is cleared to prevent delayed escape leakage')
    endif

    call TestSummarize()
endfunction

call RunConfigSanityTests()
