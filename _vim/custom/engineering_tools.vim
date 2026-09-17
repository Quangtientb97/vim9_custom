"=============================================================================
" Plugin: engineering_tools.vim
" Description: Hardware/Software Engineering Utilities
"   - ConvertBase (Hex <-> Dec <-> Bin) [Key: sb]
"   - QuickCalc (Inline math & bitwise calculator) [Key: sc]
"   - ShowAscii (ASCII Character & Value Inspector) [Key: sa]
"   - ShowShortcutHints (Quick Cheatsheet / Useful Shortcuts) [Key: sh]
"=============================================================================

"-----------------------------------------------------------------------------
" 1. Number Formatting Helpers & Compatibility Shims
"-----------------------------------------------------------------------------
function! s:Trim(str) abort
    if exists('*trim')
        return trim(a:str)
    endif
    return substitute(a:str, '^\s*\|\s*$', '', 'g')
endfunction

function! s:Matchstrpos(expr, pat, start) abort
    if exists('*matchstrpos')
        return matchstrpos(a:expr, a:pat, a:start)
    endif
    let l:m = matchstr(a:expr, a:pat, a:start)
    if empty(l:m)
        return ['', -1, -1]
    endif
    let l:s = match(a:expr, a:pat, a:start)
    let l:e = matchend(a:expr, a:pat, a:start)
    return [l:m, l:s, l:e]
endfunction

if !hlexists('CustomPopup')
    highlight CustomPopup       ctermfg=254 ctermbg=238 guifg=#e4e4e4 guibg=#2b313c
endif
if !hlexists('CustomPopupBorder')
    highlight CustomPopupBorder ctermfg=75  ctermbg=238 guifg=#5fafff guibg=#2b313c
endif

function! s:ShowPopup(lines, title) abort
    if has('popupwin')
        let l:content = []
        if !empty(a:title)
            call add(l:content, a:title)
            call add(l:content, repeat('─', max([len(a:title), 26])))
        endif
        if type(a:lines) == type([])
            call extend(l:content, a:lines)
        else
            call add(l:content, a:lines)
        endif
        call popup_atcursor(l:content, {
            \ 'moved': 'any',
            \ 'padding': [0, 1, 0, 1],
            \ 'border': [1, 1, 1, 1],
            \ 'borderchars': ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
            \ 'highlight': 'CustomPopup',
            \ 'borderhighlight': ['CustomPopupBorder'],
            \ 'time': get(g:, 'custom_popup_time', 10000),
            \ 'close': 'click',
            \ })
    endif
endfunction

function! s:FormatBin(val, width) abort
    let l:v = a:val
    if l:v == 0
        let l:b = '0'
    else
        let l:b = ''
        while l:v > 0
            let l:b = (and(l:v, 1) ? '1' : '0') . l:b
            let l:v = l:v / 2
        endwhile
    endif
    let l:target_w = a:width > 0 ? a:width : (len(l:b) <= 8 ? 8 : (len(l:b) <= 16 ? 16 : (len(l:b) <= 32 ? 32 : 64)))
    if len(l:b) < l:target_w
        let l:b = repeat('0', l:target_w - len(l:b)) . l:b
    endif
    let l:res = ''
    let l:len = len(l:b)
    let l:rem = l:len % 4
    let l:i = 0
    if l:rem > 0
        let l:res = l:b[0 : l:rem - 1]
        let l:i = l:rem
    endif
    while l:i < l:len
        if !empty(l:res)
            let l:res .= '_'
        endif
        let l:res .= l:b[l:i : l:i + 3]
        let l:i += 4
    endwhile
    return (a:width > 0 ? a:width : l:target_w) . "'b" . l:res
endfunction

function! s:FormatHex(val, width) abort
    let l:h = printf("%X", a:val)
    let l:min_nibbles = a:width > 0 ? ((a:width + 3) / 4) : (len(l:h) <= 2 ? 2 : (len(l:h) <= 4 ? 4 : (len(l:h) <= 8 ? 8 : 16)))
    if len(l:h) < l:min_nibbles
        let l:h = repeat('0', l:min_nibbles - len(l:h)) . l:h
    endif
    if len(l:h) > 4
        let l:res = ''
        let l:len = len(l:h)
        let l:rem = l:len % 4
        let l:i = 0
        if l:rem > 0
            let l:res = l:h[0 : l:rem - 1]
            let l:i = l:rem
        endif
        while l:i < l:len
            if !empty(l:res)
                let l:res .= '_'
            endif
            let l:res .= l:h[l:i : l:i + 3]
            let l:i += 4
        endwhile
        return (a:width > 0 ? a:width . "'h" : "0x") . l:res
    else
        return (a:width > 0 ? a:width . "'h" : "0x") . l:h
    endif
endfunction

"-----------------------------------------------------------------------------
" 2. Base Converter (ConvertBase)
"-----------------------------------------------------------------------------
function! ConvertBase(is_visual) abort
    let l:raw = ''
    if a:is_visual
        let [l:line_start, l:col_start] = getpos("'<")[1:2]
        let [l:line_end, l:col_end] = getpos("'>")[1:2]
        let l:lines = getline(l:line_start, l:line_end)
        if empty(l:lines)
            return
        endif
        if len(l:lines) == 1
            let l:raw = l:lines[0][l:col_start - 1 : l:col_end - 1]
        else
            let l:raw = l:lines[0][l:col_start - 1 :]
        endif
    else
        let l:line = getline('.')
        let l:col = col('.') - 1
        let l:num_pat = '\v%(\d+)?''[sS]?([hHbBdDoO])([0-9a-fA-F_xXzZ]+)|0[xX]([0-9a-fA-F_]+)|0[bB]([01_]+)|\d+'
        let l:start = 0
        while 1
            let [l:m, l:m_start, l:m_end] = s:Matchstrpos(l:line, l:num_pat, l:start)
            if empty(l:m)
                break
            endif
            if l:col >= l:m_start && l:col < l:m_end
                let l:raw = l:m
                break
            endif
            let l:start = l:m_end
        endwhile
        if empty(l:raw)
            let l:cword = expand('<cword>')
            if l:cword =~# '^\%(0[xX]\)\?[0-9a-fA-F]\+$'
                let l:raw = l:cword
            endif
        endif
    endif

    let l:raw = s:Trim(l:raw)
    if empty(l:raw)
        echohl WarningMsg | echo "No number found under cursor" | echohl None
        return
    endif

    let l:s = substitute(l:raw, '_', '', 'g')
    let l:width = 0
    let l:val = 0
    let l:parsed = 0

    if l:s =~# '^\%(\d\+\)\?''[sS]\?[hHbBdDoO]'
        let l:w_str = matchstr(l:s, '^\d\+')
        if !empty(l:w_str)
            let l:width = str2nr(l:w_str)
        endif
        let l:base = tolower(matchstr(l:s, '''[sS]\?\zs[hHbBdDoO]\ze'))
        let l:digits = matchstr(l:s, '''[sS]\?[hHbBdDoO]\zs.*$')
        if l:base ==# 'h'
            let l:val = str2nr(l:digits, 16)
        elseif l:base ==# 'b'
            let l:val = str2nr(l:digits, 2)
        elseif l:base ==# 'd'
            let l:val = str2nr(l:digits, 10)
        elseif l:base ==# 'o'
            let l:val = str2nr(l:digits, 8)
        endif
        let l:parsed = 1
    elseif l:s =~# '^0[xX]'
        let l:val = str2nr(l:s[2:], 16)
        let l:parsed = 1
    elseif l:s =~# '^0[bB]'
        let l:val = str2nr(l:s[2:], 2)
        let l:parsed = 1
    elseif l:s =~# '^\d\+$'
        let l:val = str2nr(l:s, 10)
        let l:parsed = 1
    elseif l:s =~# '^[0-9a-fA-F]\+$'
        let l:val = str2nr(l:s, 16)
        let l:parsed = 1
    endif

    if !l:parsed
        echohl WarningMsg | echo "Cannot parse number: " . l:raw | echohl None
        return
    endif

    let l:dec_str = string(l:val)
    let l:hex_str = s:FormatHex(l:val, l:width)
    let l:bin_str = s:FormatBin(l:val, l:width)

    if has('popupwin')
        call s:ShowPopup([
            \ 'Dec: ' . l:dec_str,
            \ 'Hex: ' . l:hex_str,
            \ 'Bin: ' . l:bin_str,
            \ ], '[' . l:raw . ']')
    endif

    redraw | echohl Title | echon "[" . l:raw . "]  " | echohl None
    echohl Identifier | echon "Dec: " | echohl None | echon l:dec_str . "  "
    echohl Type       | echon "Hex: " | echohl None | echon l:hex_str . "  "
    echohl Special    | echon "Bin: " | echohl None | echon l:bin_str
endfunction

"-----------------------------------------------------------------------------
" 3. Quick Calculator (QuickCalc)
"-----------------------------------------------------------------------------
function! s:EvaluateExpr(expr) abort
    let l:p = a:expr
    let l:p = substitute(l:p, '\s*\%(//\|#\).*$', '', '')
    let l:p = substitute(l:p, '/\*\_.\{-}\*/', '', 'g')
    let l:p = substitute(l:p, '\s*;\s*$', '', '')

    let l:width = 0
    let l:w_match = matchstr(l:p, '\v<(\d+)''[sS]?[hHbBdDoO]')
    if !empty(l:w_match)
        let l:width = str2nr(matchstr(l:w_match, '^\d\+'))
    endif

    let l:p = substitute(l:p, '\v%(\d+)?''[sS]?[hH]([0-9a-fA-F_]+)', '0x\1', 'g')
    let l:p = substitute(l:p, '\v%(\d+)?''[sS]?[bB]([01_]+)', '0b\1', 'g')
    let l:p = substitute(l:p, '\v%(\d+)?''[sS]?[dD]([0-9_]+)', '\1', 'g')
    let l:p = substitute(l:p, '\v%(\d+)?''[sS]?[oO]([0-7_]+)', '0o\1', 'g')
    let l:p = substitute(l:p, '\v(0[xXbBoO][0-9a-fA-F_]+|\d[0-9_]*)', '\=substitute(submatch(1), "_", "", "g")', 'g')

    let l:res = 0
    let l:success = 0

    if has('python3')
        try
            let l:res = py3eval(l:p)
            let l:success = 1
        catch
        endtry
    endif

    if !l:success
        try
            let l:res = eval(l:p)
            let l:success = 1
        catch
        endtry
    endif

    return [l:res, l:success, l:width]
endfunction

function! s:DisplayCalcResult(raw, res, width) abort
    redraw | echohl Title | echon "[" . a:raw . "] = " | echohl None

    let l:is_int = (type(a:res) == type(0))
    let l:is_float_int = (type(a:res) == type(0.0) && a:res == floor(a:res) && a:res >= -9223372036854775808.0 && a:res <= 9223372036854775807.0)

    if l:is_int || l:is_float_int
        let l:val = l:is_int ? a:res : float2nr(a:res)
        if a:width > 0 && a:width <= 62 && l:val < 0
            let l:mask = float2nr(pow(2, a:width)) - 1
            let l:val = and(l:val, l:mask)
        endif

        let l:dec_str = string(l:val)
        let l:hex_str = s:FormatHex(l:val, a:width)
        let l:bin_str = s:FormatBin(l:val, a:width)

        if has('popupwin')
            call s:ShowPopup([
                \ 'Dec: ' . l:dec_str,
                \ 'Hex: ' . l:hex_str,
                \ 'Bin: ' . l:bin_str,
                \ ], '[' . a:raw . ']')
        endif

        echohl Identifier | echon l:dec_str . " (Dec)  " | echohl None
        echohl Type       | echon "|  " . l:hex_str . " (Hex)  " | echohl None
        echohl Special    | echon "|  " . l:bin_str | echohl None
    else
        if has('popupwin')
            call s:ShowPopup(['Float: ' . string(a:res)], '[' . a:raw . ']')
        endif
        echohl Identifier | echon string(a:res) . " (Float)" | echohl None
    endif
endfunction

function! QuickCalc(is_visual) abort
    let l:raw = ''
    let l:from_prompt = 0
    if a:is_visual
        let [l:line_start, l:col_start] = getpos("'<")[1:2]
        let [l:line_end, l:col_end] = getpos("'>")[1:2]
        let l:lines = getline(l:line_start, l:line_end)
        if empty(l:lines)
            return
        endif
        if len(l:lines) == 1
            if l:col_start > l:col_end
                let [l:col_start, l:col_end] = [l:col_end, l:col_start]
            endif
            let l:raw = l:lines[0][l:col_start - 1 : l:col_end - 1]
        else
            let l:lines[0] = l:lines[0][l:col_start - 1 :]
            let l:lines[-1] = l:lines[-1][: l:col_end - 1]
            let l:raw = join(l:lines, ' ')
        endif
    else
        let l:line = getline('.')
        if l:line =~# '<=\|='
            let l:after_eq = matchstr(l:line, '\%(<=\|=\)\s*\zs[^;]\+\ze\%(;\|$\)')
            if !empty(l:after_eq)
                let l:raw = l:after_eq
            endif
        endif
        if empty(l:raw)
            let l:clean = substitute(l:line, '\s*\%(//\|#\).*$', '', '')
            let l:clean = substitute(l:clean, '/\*\_.\{-}\*/', '', 'g')
            let l:clean = substitute(l:clean, '^\s*\|\s*;\s*$', '', 'g')
            if l:clean =~# '[-+*/%&|^<>]'
                let l:raw = l:clean
            endif
        endif
    endif

    let l:raw = s:Trim(l:raw)
    let l:raw = substitute(l:raw, '\s*\%(//\|#\).*$', '', '')
    let l:raw = substitute(l:raw, '\s*;\s*$', '', '')
    let l:raw = s:Trim(l:raw)

    if empty(l:raw)
        let l:raw = input("Calc: ")
        let l:raw = s:Trim(l:raw)
        let l:from_prompt = 1
        if empty(l:raw)
            return
        endif
    endif

    let [l:res, l:success, l:width] = s:EvaluateExpr(l:raw)
    if !l:success && !a:is_visual && !l:from_prompt
        let l:raw = input("Calc: ", l:raw)
        let l:raw = s:Trim(l:raw)
        if empty(l:raw)
            return
        endif
        let [l:res, l:success, l:width] = s:EvaluateExpr(l:raw)
    endif

    if !l:success
        echohl WarningMsg | echo "Cannot calculate: " . l:raw | echohl None
        return
    endif

    call s:DisplayCalcResult(l:raw, l:res, l:width)
endfunction

"-----------------------------------------------------------------------------
" 4. ASCII Inspector & Converter (ShowAscii)
"-----------------------------------------------------------------------------
let s:ascii_ctrl = {
\ 0: ['NUL', 'Null \0'],
\ 1: ['SOH', 'Start of Heading'],
\ 2: ['STX', 'Start of Text'],
\ 3: ['ETX', 'End of Text'],
\ 4: ['EOT', 'End of Transmission'],
\ 5: ['ENQ', 'Enquiry'],
\ 6: ['ACK', 'Acknowledge'],
\ 7: ['BEL', 'Bell \a'],
\ 8: ['BS',  'Backspace \b'],
\ 9: ['TAB', 'Horizontal Tab \t'],
\ 10: ['LF', 'Line Feed \n'],
\ 11: ['VT', 'Vertical Tab \v'],
\ 12: ['FF', 'Form Feed \f'],
\ 13: ['CR', 'Carriage Return \r'],
\ 14: ['SO', 'Shift Out'],
\ 15: ['SI', 'Shift In'],
\ 16: ['DLE', 'Data Link Escape'],
\ 17: ['DC1', 'Device Control 1'],
\ 18: ['DC2', 'Device Control 2'],
\ 19: ['DC3', 'Device Control 3'],
\ 20: ['DC4', 'Device Control 4'],
\ 21: ['NAK', 'Negative Acknowledge'],
\ 22: ['SYN', 'Synchronous Idle'],
\ 23: ['ETB', 'End of Trans. Block'],
\ 24: ['CAN', 'Cancel'],
\ 25: ['EM',  'End of Medium'],
\ 26: ['SUB', 'Substitute'],
\ 27: ['ESC', 'Escape'],
\ 28: ['FS',  'File Separator'],
\ 29: ['GS',  'Group Separator'],
\ 30: ['RS',  'Record Separator'],
\ 31: ['US',  'Unit Separator'],
\ 32: ['SPACE', 'Space'],
\ 127: ['DEL', 'Delete']
\ }

function! s:GetAsciiMeta(val) abort
    let l:val = a:val
    let l:tag = ''
    let l:desc = ''
    if has_key(s:ascii_ctrl, l:val)
        let l:info = s:ascii_ctrl[l:val]
        let l:tag = '<' . l:info[0] . '>'
        let l:desc = l:info[1]
    elseif l:val >= 33 && l:val <= 126
        let l:tag = nr2char(l:val)
    elseif l:val >= 128 && l:val <= 255
        let l:tag = nr2char(l:val)
        let l:desc = printf("Ext ASCII 0x%02X", l:val)
    else
        let l:tag = nr2char(l:val)
        let l:desc = printf("Unicode U+%04X", l:val)
    endif
    let l:dec = string(l:val)
    let l:hex = (l:val <= 255) ? printf("0x%02X", l:val) : printf("0x%X", l:val)
    let l:oct = (l:val == 0) ? "000" : (l:val <= 255) ? printf("0%o", l:val) : printf("0%o", l:val)
    let l:bin = (l:val <= 255) ? s:FormatBin(l:val, 8) : s:FormatBin(l:val, 0)
    return {
    \ 'val': l:val,
    \ 'tag': l:tag,
    \ 'desc': l:desc,
    \ 'dec': l:dec,
    \ 'hex': l:hex,
    \ 'oct': l:oct,
    \ 'bin': l:bin
    \ }
endfunction

function! s:ParseAsciiNum(raw) abort
    let l:s = substitute(a:raw, '_', '', 'g')
    let l:s = s:Trim(l:s)
    let l:val = 0
    let l:parsed = 0

    if l:s =~# '^\%(\d\+\)\?''[sS]\?[hHbBdDoO]'
        let l:base = tolower(matchstr(l:s, '''[sS]\?\zs[hHbBdDoO]\ze'))
        let l:digits = matchstr(l:s, '''[sS]\?[hHbBdDoO]\zs.*$')
        if l:base ==# 'h'
            let l:val = str2nr(l:digits, 16)
        elseif l:base ==# 'b'
            let l:val = str2nr(l:digits, 2)
        elseif l:base ==# 'd'
            let l:val = str2nr(l:digits, 10)
        elseif l:base ==# 'o'
            let l:val = str2nr(l:digits, 8)
        endif
        let l:parsed = 1
    elseif l:s =~# '^0[xX][0-9a-fA-F]\+$'
        let l:val = str2nr(l:s[2:], 16)
        let l:parsed = 1
    elseif l:s =~# '^0[bB][01]\+$'
        let l:val = str2nr(l:s[2:], 2)
        let l:parsed = 1
    elseif l:s =~# '^\d\+$'
        let l:val = str2nr(l:s, 10)
        let l:parsed = 1
    endif

    return [l:val, l:parsed]
endfunction

function! s:NumToAsciiStr(val) abort
    let l:v = a:val
    let l:chars = []
    while l:v > 0
        let l:byte = and(l:v, 0xFF)
        if l:byte >= 32 && l:byte <= 126
            let l:chars = [nr2char(l:byte)] + l:chars
        elseif l:byte == 10
            let l:chars = ['\n'] + l:chars
        elseif l:byte == 9
            let l:chars = ['\t'] + l:chars
        elseif l:byte == 0
            let l:chars = ['\0'] + l:chars
        else
            let l:chars = [printf('\x%02X', l:byte)] + l:chars
        endif
        let l:v = l:v / 256
    endwhile
    return join(l:chars, '')
endfunction

function! s:FindNumberUnderCursor() abort
    let l:line = getline('.')
    let l:col = col('.') - 1
    let l:num_pat = '\v%(\d+)?''[sS]?([hHbBdDoO])([0-9a-fA-F_xXzZ]+)|0[xX]([0-9a-fA-F_]+)|0[bB]([01_]+)|\d+'
    let l:start = 0
    while 1
        let [l:m, l:m_start, l:m_end] = s:Matchstrpos(l:line, l:num_pat, l:start)
        if empty(l:m)
            break
        endif
        if l:col >= l:m_start && l:col < l:m_end
            let l:is_prefix_ok = (l:m_start == 0 || l:line[l:m_start - 1] !~# '\k')
            let l:is_suffix_ok = (l:m_end >= len(l:line) || l:line[l:m_end] !~# '\k')
            if l:is_prefix_ok && l:is_suffix_ok
                return l:m
            endif
        endif
        let l:start = l:m_end
    endwhile
    return ''
endfunction

function! s:DisplayAsciiSingle(header, meta, ...) abort
    let l:extra = a:0 > 0 ? a:1 : ''
    if has('popupwin')
        let l:pop_lines = [
            \ 'Dec: ' . a:meta.dec . '    Oct: ' . a:meta.oct,
            \ 'Hex: ' . a:meta.hex . '    Bin: ' . a:meta.bin,
            \ ]
        if !empty(a:meta.desc)
            call add(l:pop_lines, 'Desc: ' . a:meta.desc)
        endif
        if !empty(l:extra)
            call add(l:pop_lines, 'Info: ' . l:extra)
        endif
        call s:ShowPopup(l:pop_lines, '[' . a:header . ']')
    endif
    redraw
    echohl Title      | echon "[" . a:header . "]  " | echohl None
    echohl Identifier | echon "Dec: " | echohl None | echon a:meta.dec . "  "
    echohl Type       | echon "Hex: " | echohl None | echon a:meta.hex . "  "
    echohl Constant   | echon "Oct: " | echohl None | echon a:meta.oct . "  "
    echohl Special    | echon "Bin: " | echohl None | echon a:meta.bin
    if !empty(a:meta.desc)
        echohl Comment | echon "  (" . a:meta.desc . ")" | echohl None
    endif
    if !empty(l:extra)
        echohl Directory | echon "  " . l:extra | echohl None
    endif
endfunction

function! s:DisplayAsciiNumberAndChar(char, char_meta, raw, num_meta) abort
    redraw
    echohl Title      | echon "[" . a:raw . " -> '" . a:num_meta.tag . "']  " | echohl None
    echohl Identifier | echon "Dec: " | echohl None | echon a:num_meta.dec . "  "
    echohl Type       | echon "Hex: " | echohl None | echon a:num_meta.hex . "  "
    echohl Constant   | echon "Oct: " | echohl None | echon a:num_meta.oct . "  "
    echohl Special    | echon "Bin: " | echohl None | echon a:num_meta.bin
    if !empty(a:num_meta.desc)
        echohl Comment | echon "  (" . a:num_meta.desc . ")" | echohl None
    endif
    echohl Directory  | echon "  | char: '" . a:char_meta.tag . "' (" . a:char_meta.dec . "/" . a:char_meta.hex . ")" | echohl None
endfunction

function! s:DisplayAsciiString(str) abort
    let l:len = strchars(a:str)
    redraw
    echohl Title | echon "[" . a:str . "]  " | echohl None
    if l:len <= 6
        echohl Identifier | echon "Chars: " | echohl None
        let l:i = 0
        while l:i < l:len
            let l:c = strcharpart(a:str, l:i, 1)
            let l:nr = char2nr(l:c)
            let l:meta = s:GetAsciiMeta(l:nr)
            echon "'" . l:meta.tag . "'(" . l:meta.dec . "/" . l:meta.hex . ") "
            let l:i += 1
        endwhile
    endif
    let l:hexes = []
    let l:decs = []
    let l:i = 0
    while l:i < l:len
        let l:c = strcharpart(a:str, l:i, 1)
        let l:nr = char2nr(l:c)
        call add(l:hexes, printf("%02X", l:nr))
        call add(l:decs, string(l:nr))
        let l:i += 1
    endwhile
    echohl Type | echon "Hex: " | echohl None | echon join(l:hexes, ' ') . "  "
    echohl Identifier | echon "Dec: " | echohl None | echon join(l:decs, ' ')
endfunction

function! ShowAscii(is_visual) abort
    if a:is_visual
        let [l:line_start, l:col_start] = getpos("'<")[1:2]
        let [l:line_end, l:col_end] = getpos("'>")[1:2]
        let l:lines = getline(l:line_start, l:line_end)
        if empty(l:lines)
            return
        endif
        if len(l:lines) == 1
            if l:col_start > l:col_end
                let [l:col_start, l:col_end] = [l:col_end, l:col_start]
            endif
            let l:raw = l:lines[0][l:col_start - 1 : l:col_end - 1]
        else
            let l:lines[0] = l:lines[0][l:col_start - 1 :]
            let l:lines[-1] = l:lines[-1][: l:col_end - 1]
            let l:raw = join(l:lines, "\n")
        endif

        if empty(l:raw)
            return
        endif

        if strchars(l:raw) == 1
            let l:val = char2nr(l:raw)
            let l:meta = s:GetAsciiMeta(l:val)
            call s:DisplayAsciiSingle(l:meta.tag, l:meta)
            return
        endif

        let l:trimmed = s:Trim(l:raw)

        if (l:trimmed =~# "^'.*'$" || l:trimmed =~# '^".*"$') && len(l:trimmed) >= 2
            let l:unquoted = l:trimmed[1 : -2]
            if l:unquoted ==# '\n'
                let l:meta = s:GetAsciiMeta(10)
                call s:DisplayAsciiSingle(l:meta.tag, l:meta)
                return
            elseif l:unquoted ==# '\t'
                let l:meta = s:GetAsciiMeta(9)
                call s:DisplayAsciiSingle(l:meta.tag, l:meta)
                return
            elseif l:unquoted ==# '\r'
                let l:meta = s:GetAsciiMeta(13)
                call s:DisplayAsciiSingle(l:meta.tag, l:meta)
                return
            elseif l:unquoted ==# '\0'
                let l:meta = s:GetAsciiMeta(0)
                call s:DisplayAsciiSingle(l:meta.tag, l:meta)
                return
            elseif strchars(l:unquoted) == 1
                let l:val = char2nr(l:unquoted)
                let l:meta = s:GetAsciiMeta(l:val)
                call s:DisplayAsciiSingle(l:meta.tag, l:meta)
                return
            endif
        endif

        let [l:val, l:parsed] = s:ParseAsciiNum(l:trimmed)
        if l:parsed
            if l:val >= 0 && l:val <= 255
                let l:meta = s:GetAsciiMeta(l:val)
                call s:DisplayAsciiSingle(l:trimmed . " -> '" . l:meta.tag . "'", l:meta)
                return
            elseif l:val > 255
                let l:str = s:NumToAsciiStr(l:val)
                redraw
                echohl Title   | echon "[" . l:trimmed . "] -> ASCII: \"" . l:str . "\"  " | echohl None
                echohl Identifier | echon "Dec: " | echohl None | echon string(l:val) . "  "
                echohl Type       | echon "Hex: " | echohl None | echon printf("0x%X", l:val)
                return
            endif
        endif

        let l:hex_clean = substitute(l:trimmed, '[,;]', ' ', 'g')
        let l:hex_clean = substitute(l:hex_clean, '\<0[xX]', '', 'g')
        let l:hex_parts = split(l:hex_clean)
        let l:is_hex_seq = (len(l:hex_parts) >= 2)
        if l:is_hex_seq
            for l:p in l:hex_parts
                if l:p !~# '^[0-9a-fA-F]\{1,2}$'
                    let l:is_hex_seq = 0
                    break
                endif
            endfor
        endif
        if l:is_hex_seq
            let l:ascii_chars = []
            for l:p in l:hex_parts
                let l:byte_val = str2nr(l:p, 16)
                if has_key(s:ascii_ctrl, l:byte_val)
                    call add(l:ascii_chars, '<' . s:ascii_ctrl[l:byte_val][0] . '>')
                elseif l:byte_val >= 32 && l:byte_val <= 126
                    call add(l:ascii_chars, nr2char(l:byte_val))
                else
                    call add(l:ascii_chars, printf('\x%02X', l:byte_val))
                endif
            endfor
            redraw
            echohl Title   | echon "[" . l:trimmed . "] -> ASCII: \"" . join(l:ascii_chars, '') . "\"" | echohl None
            return
        endif

        call s:DisplayAsciiString(l:trimmed)
        return
    else
        let l:line = getline('.')
        let l:col = col('.')
        if empty(l:line) || l:col > len(l:line)
            let l:char = "\n"
        else
            let l:char = matchstr(l:line, '\%' . l:col . 'c.')
            if empty(l:char)
                let l:char = "\n"
            endif
        endif
        let l:char_val = char2nr(l:char)
        let l:char_meta = s:GetAsciiMeta(l:char_val)

        let l:num_str = s:FindNumberUnderCursor()
        if !empty(l:num_str)
            let [l:val, l:parsed] = s:ParseAsciiNum(l:num_str)
            if l:parsed
                if l:num_str =~# '^\d\+$'
                    if l:val <= 255
                        let l:num_meta = s:GetAsciiMeta(l:val)
                        call s:DisplayAsciiNumberAndChar(l:char, l:char_meta, l:num_str, l:num_meta)
                        return
                    endif
                else
                    if l:val <= 255
                        let l:num_meta = s:GetAsciiMeta(l:val)
                        call s:DisplayAsciiSingle(l:num_str . " -> '" . l:num_meta.tag . "'", l:num_meta, "(cursor: '" . l:char_meta.tag . "')")
                        return
                    else
                        let l:str = s:NumToAsciiStr(l:val)
                        redraw
                        echohl Title   | echon "[" . l:num_str . "] -> ASCII: \"" . l:str . "\"  " | echohl None
                        echohl Identifier | echon "Dec: " | echohl None | echon string(l:val) . "  "
                        echohl Type       | echon "Hex: " | echohl None | echon printf("0x%X", l:val)
                        return
                    endif
                endif
            endif
        endif

        call s:DisplayAsciiSingle(l:char_meta.tag, l:char_meta)
        return
    endif
endfunction


"-----------------------------------------------------------------------------
" 5. Shortcut Hints Cheatsheet (Key: sh)
"-----------------------------------------------------------------------------
let s:shortcut_help_winid = -1

function! ShowShortcutHints() abort
    if has('popupwin')
        if s:shortcut_help_winid != -1 && !empty(popup_getpos(s:shortcut_help_winid))
            call popup_close(s:shortcut_help_winid)
            let s:shortcut_help_winid = -1
            return
        endif
    endif

    let l:lines = [
        \ '── [ Tools & Calculation ] ──────────────────────────',
        \ '  sb        : Convert Base (Dec <-> Hex <-> Bin)',
        \ '  sc        : Quick Calculator (Math expression)',
        \ '  sa        : Show ASCII info under cursor',
        \ '  sh        : Show Which-Key Menu (Interactive Cheatsheet)',
        \ '  _ / ta    : EasyAlign alignment (press _ on delimiter, or ta)',
        \ '  :AP       : Smart align SV/Verilog ports & signals (:AP)',
        \ '',
        \ '── [ Files & Navigation ] ───────────────────────────',
        \ '  ss        : Quick Save (:w!)',
        \ '  <Tab>     : Switch split window (<C-w>w)',
        \ '  tn        : New tab with file explorer (:E)',
        \ '  <F1>      : Close window / terminal cleanly',
        \ '  <F3>      : Toggle NERDTree file explorer',
        \ '  <F4>      : Toggle NERDTree + Tagbar',
        \ '  <F5>      : Reload current file (:e!)',
        \ '  <F12>     : Toggle bottom Terminal drawer',
        \ '',
        \ '── [ Editing & Motion ] ────────────────────────────',
        \ '  gS / gJ   : Split / Join code block (SV/Verilog & C)',
        \ '  ( / [ / { : Visual wrap selection in brackets/quotes',
        \ '  ds        : Delete matching pair (bracket, quote, begin/end)',
        \ '  <Alt-j/k> : Move line or selection up / down',
        \ '  # / <C-f> : Find & Replace word under cursor',
        \ '  * (vis)   : Search visual selection',
        \ '  <C-a>     : Select all file (ggVG)',
        \ '  sw / sm   : Toggle Line Wrap / Modifiable',
        \ ]

    if has('popupwin')
        let s:shortcut_help_winid = popup_create(l:lines, {
            \ 'title': ' VIM SHORTCUT CHEATSHEET ',
            \ 'pos': 'center',
            \ 'padding': [0, 1, 0, 1],
            \ 'border': [1, 1, 1, 1],
            \ 'borderchars': ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
            \ 'highlight': 'CustomPopup',
            \ 'borderhighlight': ['CustomPopupBorder'],
            \ 'time': get(g:, 'custom_popup_help_time', 20000),
            \ 'moved': 'any',
            \ 'close': 'click',
            \ })
    else
        " Fallback for Vim 7.4 (echo list)
        redraw
        let l:save_more = &more
        set nomore
        try
            echohl Title | echo "─── [ VIM SHORTCUT CHEATSHEET ] ───" | echohl None
            for l:line in l:lines
                if l:line =~# '^──'
                    echohl Identifier | echo l:line | echohl None
                elseif !empty(l:line)
                    let l:colon = stridx(l:line, ':')
                    if l:colon > 0
                        echohl Special | echon l:line[: l:colon] | echohl None
                        echo l:line[l:colon + 1 :]
                    else
                        echo l:line
                    endif
                else
                    echo ""
                endif
            endfor
        finally
            let &more = l:save_more
        endtry
    endif
endfunction

" User Commands
command! -bang Ascii         call ShowAscii(0)
command! -bang ConvertBase   call ConvertBase(0)
command! -bang QuickCalc     call QuickCalc(0)
command! -bang ShortcutHints call ShowShortcutHints()
