"=============================================================================
" Plugin: verilog_align.vim
" Description: Smart Aligner for SystemVerilog & Verilog Declarations
"   - Automatically aligns Port lists, Internal Signals & Clocking blocks:
"     [direction]  [type]  [range]  [name / assign]  [comments]
"   - Automatically pads empty ranges on scalar signals to match vector widths
"   - Supports multi-variable declarations (e.g. reg [31:0] a, b, c;)
"   - Supports continuous assignments/inits (e.g. wire [31:0] addr = mem_addr;)
"   - Command: :AP (or :AlignPorts)
"       * Normal mode : Just type :AP to auto-detect and align the entire block!
"       * Visual mode : Select lines and type :AP to align selected range.
"=============================================================================

if exists('g:loaded_verilog_align')
    finish
endif
let g:loaded_verilog_align = 1

"-----------------------------------------------------------------------------
" Core Algorithm: AlignVerilogDecls
"-----------------------------------------------------------------------------
function! AlignVerilogDecls(first, last) abort
    let l:lines = []
    let l:max_dir = 0
    let l:max_type = 0
    let l:max_range = 0
    let l:max_assign_name = 0
    let l:max_tail = 0
    let l:has_dir = 0
    let l:has_type = 0
    let l:has_range = 0
    let l:has_assign = 0
    let l:has_comment = 0

    let l:type_pattern = '^\(\%(\%(logic\|wire\|reg\|bit\|int\|integer\|byte\|shortint\|longint\|time\|real\|string\|event\|genvar\|parameter\|localparam\|\w\+_t\|\w\+::\w\+_t\)\%(\s\+\%(signed\|unsigned\)\)\?\|signed\|unsigned\)\)\>\%(\s*\(.*\)\|\)$'

    for l:lnum in range(a:first, a:last)
        let l:line = getline(l:lnum)

        " 1. Indent
        let l:indent = matchstr(l:line, '^\s*')
        let l:rem = substitute(l:line, '^\s*', '', '')

        if empty(l:rem)
            call add(l:lines, {'raw': l:line, 'matched': 0})
            continue
        endif

        " 2. Trailing comment (// ...)
        let l:comment = ''
        let l:c_idx = match(l:rem, '\/\/.*$')
        if l:c_idx != -1
            let l:comment = l:rem[l:c_idx :]
            let l:rem = substitute(l:rem[: l:c_idx - 1], '\s*$', '', '')
            let l:has_comment = 1
        endif

        " 3. Direction (input, output, inout, ref)
        let l:dir = ''
        let l:m_dir = matchlist(l:rem, '^\(input\|output\|inout\|ref\)\>\%(\s*\(.*\)\|\)$')
        if !empty(l:m_dir)
            let l:dir = l:m_dir[1]
            let l:rem = l:m_dir[2]
        endif

        " 4. Type
        let l:type = ''
        let l:m_type = matchlist(l:rem, l:type_pattern)
        if !empty(l:m_type)
            let l:type = l:m_type[1]
            let l:rem = l:m_type[2]
        endif

        " 5. Range (packed ranges e.g. [31:0] or [3:0][7:0] or [ 3:0])
        let l:range = ''
        let l:m_range = matchlist(l:rem, '^\(\%(\[[^\]]\+\]\s*\)\+\)\(.*\)$')
        if !empty(l:m_range)
            let l:range = substitute(l:m_range[1], '\s*$', '', '')
            let l:rem = l:m_range[2]
        endif

        let l:rem = substitute(l:rem, '^\s*', '', '')

        if empty(l:dir) && empty(l:type) && empty(l:range)
            call add(l:lines, {'raw': l:line, 'matched': 0})
            continue
        endif

        if !empty(l:dir)
            let l:has_dir = 1
            if len(l:dir) > l:max_dir
                let l:max_dir = len(l:dir)
            endif
        endif

        if !empty(l:type)
            let l:has_type = 1
            if len(l:type) > l:max_type
                let l:max_type = len(l:type)
            endif
        endif

        if !empty(l:range)
            let l:has_range = 1
            if len(l:range) > l:max_range
                let l:max_range = len(l:range)
            endif
        endif

        " 6. Remainder: check for single assignment (e.g. name = val;)
        let l:m_assign = matchlist(l:rem, '^\([a-zA-Z_0-9$]\+\)\s*=\s*\(.*\)$')
        if !empty(l:m_assign)
            let l:has_assign = 1
            let l:assign_name = l:m_assign[1]
            let l:assign_val  = '= ' . substitute(l:m_assign[2], '^\s*', '', '')
            if len(l:assign_name) > l:max_assign_name
                let l:max_assign_name = len(l:assign_name)
            endif
            let l:item = {
                \ 'matched': 1,
                \ 'indent': l:indent,
                \ 'dir': l:dir,
                \ 'type': l:type,
                \ 'range': l:range,
                \ 'is_assign': 1,
                \ 'assign_name': l:assign_name,
                \ 'assign_val': l:assign_val,
                \ 'rest': '',
                \ 'comment': l:comment
                \ }
        else
            let l:item = {
                \ 'matched': 1,
                \ 'indent': l:indent,
                \ 'dir': l:dir,
                \ 'type': l:type,
                \ 'range': l:range,
                \ 'is_assign': 0,
                \ 'assign_name': '',
                \ 'assign_val': '',
                \ 'rest': l:rem,
                \ 'comment': l:comment
                \ }
        endif

        call add(l:lines, l:item)
    endfor

    " Compute tail strings for comment alignment
    for l:info in l:lines
        if !l:info.matched
            continue
        endif
        if l:info.is_assign
            let l:tail = printf('%-*s %s', l:max_assign_name, l:info.assign_name, l:info.assign_val)
        else
            let l:tail = l:info.rest
        endif
        let l:info.tail = l:tail
        if len(l:tail) > l:max_tail
            let l:max_tail = len(l:tail)
        endif
    endfor

    let l:idx = 0
    for l:lnum in range(a:first, a:last)
        let l:info = l:lines[l:idx]
        let l:idx += 1
        if !l:info.matched
            continue
        endif

        let l:dir_str = ''
        if l:has_dir
            if !empty(l:info.dir)
                let l:dir_str = printf('%-*s', l:max_dir, l:info.dir)
            else
                let l:dir_str = repeat(' ', l:max_dir)
            endif
        endif

        let l:type_str = ''
        if l:has_type
            if !empty(l:info.type)
                let l:type_str = (l:has_dir ? ' ' : '') . printf('%-*s', l:max_type, l:info.type)
            else
                let l:type_str = (l:has_dir ? ' ' : '') . repeat(' ', l:max_type)
            endif
        endif

        let l:range_str = ''
        if l:has_range
            let l:need_space = l:has_dir || l:has_type
            if !empty(l:info.range)
                let l:range_str = (l:need_space ? ' ' : '') . printf('%-*s', l:max_range, l:info.range)
            else
                let l:range_str = (l:need_space ? ' ' : '') . repeat(' ', l:max_range)
            endif
        endif

        let l:need_space_before_tail = l:has_dir || l:has_type || l:has_range
        let l:tail_prefix = l:need_space_before_tail ? ' ' : ''

        if l:has_comment && !empty(l:info.comment)
            let l:tail_formatted = printf('%-*s', l:max_tail, l:info.tail)
            let l:newline = l:info.indent . l:dir_str . l:type_str . l:range_str . l:tail_prefix . l:tail_formatted . ' ' . l:info.comment
        else
            let l:newline = l:info.indent . l:dir_str . l:type_str . l:range_str . l:tail_prefix . l:info.tail
        endif

        call setline(l:lnum, l:newline)
    endfor
endfunction

function! AlignVerilogPorts(first, last) abort
    call AlignVerilogDecls(a:first, a:last)
endfunction

"-----------------------------------------------------------------------------
" Helper: Auto-detect contiguous block of declarations around cursor
"-----------------------------------------------------------------------------
function! s:IsDeclLine(line) abort
    if a:line =~# '^\s*$' || a:line =~# '^\s*//'
        return 0
    endif
    return a:line =~# '^\s*\%(input\|output\|inout\|ref\|logic\|wire\|reg\|bit\|int\|integer\|byte\|shortint\|longint\|time\|real\|string\|event\|genvar\|parameter\|localparam\|\w\+_t\)\>'
endfunction

function! s:GetDeclBlockRange() abort
    let l:cur = line('.')
    if !s:IsDeclLine(getline(l:cur))
        return [l:cur, l:cur]
    endif

    let l:first = l:cur
    while l:first > 1 && s:IsDeclLine(getline(l:first - 1))
        let l:first -= 1
    endwhile

    let l:last = l:cur
    let l:total = line('$')
    while l:last < l:total && s:IsDeclLine(getline(l:last + 1))
        let l:last += 1
    endwhile

    return [l:first, l:last]
endfunction

"-----------------------------------------------------------------------------
" Command Handler: :AP & :AlignPorts
"   - If no range given (:AP)           -> Auto-detect contiguous block!
"   - If range given (:'<,'>AP, 1,10AP) -> Align specified range.
"-----------------------------------------------------------------------------
function! s:DispatchAP(line1, line2, count) abort
    if a:count < 0
        let [l:first, l:last] = s:GetDeclBlockRange()
        call AlignVerilogDecls(l:first, l:last)
    else
        call AlignVerilogDecls(a:line1, a:line2)
    endif
endfunction

command! -range AlignPorts call s:DispatchAP(<line1>, <line2>, <count>)
command! -range AP         call s:DispatchAP(<line1>, <line2>, <count>)

