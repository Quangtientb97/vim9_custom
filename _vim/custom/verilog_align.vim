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
    let l:max_qual = 0
    let l:max_dir = 0
    let l:max_type = 0
    let l:max_range = 0
    let l:max_assign_name = 0
    let l:max_tail = 0
    let l:has_qual = 0
    let l:has_dir = 0
    let l:has_type = 0
    let l:has_range = 0
    let l:has_assign = 0
    let l:has_comment = 0

    let l:qual_pat = '^\(\%(\%(local\|protected\|public\|randc\|rand\|const\|static\|pure\s\+virtual\|virtual\|automatic\|extern\)\s\+\)\+\)\(.*\)$'
    let l:dir_pat = '^\(input\|output\|inout\|ref\)\>\%(\s*\(.*\)\|\)$'
    let l:builtin_type_pat = '^\(\%(\%(logic\|wire\|reg\|bit\|int\|integer\|byte\|shortint\|longint\|time\|real\|realtime\|shortreal\|string\|event\|genvar\|chandle\|void\|parameter\|localparam\)\%(\s\+\%(signed\|unsigned\)\)\?\|signed\|unsigned\)\)\>\%(\s*\(.*\)\|\)$'
    let l:custom_type_pat = '^\([a-zA-Z_]\w*\%(::[a-zA-Z_]\w*\)*\%(\s*#\s*([^)]*)\)\?\)\%(\s\+\|$\)\(.*\)$'

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

        " 3. Qualifier (local, protected, rand, const, static, etc.)
        let l:qual = ''
        let l:m_qual = matchlist(l:rem, l:qual_pat)
        if !empty(l:m_qual)
            let l:qual = substitute(l:m_qual[1], '\s\+$', '', '')
            let l:rem = l:m_qual[2]
        endif

        " 4. Direction (input, output, inout, ref)
        let l:dir = ''
        let l:m_dir = matchlist(l:rem, l:dir_pat)
        if !empty(l:m_dir)
            let l:dir = l:m_dir[1]
            let l:rem = l:m_dir[2]
        endif

        " 5. Check if range comes immediately after direction (e.g. input [31:0] data)
        let l:type = ''
        let l:range = ''
        let l:m_range_first = matchlist(l:rem, '^\(\%(\[[^\]]\+\]\s*\)\+\)\(.*\)$')
        if !empty(l:m_range_first)
            let l:range = substitute(l:m_range_first[1], '\s*$', '', '')
            let l:rem = l:m_range_first[2]
        else
            " 6. Type (built-in first, then custom/scoped/parameterized)
            let l:m_type = matchlist(l:rem, l:builtin_type_pat)
            if !empty(l:m_type)
                let l:type = l:m_type[1]
                let l:rem = l:m_type[2]
            endif

            " 7. Range (packed ranges e.g. [31:0] or [3:0][7:0])
            let l:m_range = matchlist(l:rem, '^\(\%(\[[^\]]\+\]\s*\)\+\)\(.*\)$')
            if !empty(l:m_range)
                let l:range = substitute(l:m_range[1], '\s*$', '', '')
                let l:rem = l:m_range[2]
            endif

            " If type was not built-in, check for custom type
            if empty(l:type) && !empty(l:rem)
                let l:m_custom = matchlist(l:rem, l:custom_type_pat)
                if !empty(l:m_custom)
                    let l:after = substitute(l:m_custom[2], '^\s*', '', '')
                    if (empty(l:qual) && !empty(l:dir) && (empty(l:after) || l:after =~# '^[;,=]')) && l:m_custom[1] !~# '_t$'
                        " e.g. 'input clk,' -> type is empty, clk is var name
                    else
                        let l:type = l:m_custom[1]
                        let l:rem = l:m_custom[2]
                        let l:m_range2 = matchlist(l:rem, '^\(\%(\[[^\]]\+\]\s*\)\+\)\(.*\)$')
                        if !empty(l:m_range2)
                            let l:range = substitute(l:m_range2[1], '\s*$', '', '')
                            let l:rem = l:m_range2[2]
                        endif
                    endif
                endif
            endif
        endif

        let l:rem = substitute(l:rem, '^\s*', '', '')

        if empty(l:qual) && empty(l:dir) && empty(l:type) && empty(l:range)
            call add(l:lines, {'raw': l:line, 'matched': 0})
            continue
        endif

        if !empty(l:qual)
            let l:has_qual = 1
            if len(l:qual) > l:max_qual
                let l:max_qual = len(l:qual)
            endif
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

        " 8. Remainder: check for single assignment (e.g. name = val;)
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
                \ 'qual': l:qual,
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
                \ 'qual': l:qual,
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

        let l:parts = []

        if l:has_qual
            if !empty(l:info.qual)
                call add(l:parts, printf('%-*s', l:max_qual, l:info.qual))
            else
                call add(l:parts, repeat(' ', l:max_qual))
            endif
        endif

        if l:has_dir
            if !empty(l:info.dir)
                call add(l:parts, printf('%-*s', l:max_dir, l:info.dir))
            else
                call add(l:parts, repeat(' ', l:max_dir))
            endif
        endif

        if l:has_type
            if !empty(l:info.type)
                call add(l:parts, printf('%-*s', l:max_type, l:info.type))
            else
                call add(l:parts, repeat(' ', l:max_type))
            endif
        endif

        if l:has_range
            if !empty(l:info.range)
                call add(l:parts, printf('%-*s', l:max_range, l:info.range))
            else
                call add(l:parts, repeat(' ', l:max_range))
            endif
        endif

        let l:prefix = join(l:parts, ' ')

        if !empty(l:info.tail)
            if !empty(l:prefix)
                let l:body = l:prefix . ' ' . l:info.tail
            else
                let l:body = l:info.tail
            endif
        else
            let l:body = l:prefix
        endif

        if l:has_comment && !empty(l:info.comment)
            let l:target_width = (!empty(l:prefix) ? len(l:prefix) + 1 : 0) + l:max_tail
            let l:body_padded = printf('%-*s', l:target_width, l:body)
            let l:newline = l:info.indent . l:body_padded . ' ' . l:info.comment
        else
            let l:newline = l:info.indent . l:body
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
    " 1. Qualifiers (local, protected, rand, randc, const, static, virtual, automatic, extern)
    if a:line =~# '^\s*\%(local\|protected\|public\|randc\|rand\|const\|static\|pure\s\+virtual\|virtual\|automatic\|extern\)\>'
        return 1
    endif
    " 2. Directions (input, output, inout, ref)
    if a:line =~# '^\s*\%(input\|output\|inout\|ref\)\>'
        return 1
    endif
    " 3. Built-in types & params
    if a:line =~# '^\s*\%(logic\|wire\|reg\|bit\|int\|integer\|byte\|shortint\|longint\|time\|real\|realtime\|shortreal\|string\|event\|genvar\|chandle\|void\|parameter\|localparam\|signed\|unsigned\)\>'
        return 1
    endif
    " 4. Scoped types or custom types followed by identifier
    if a:line =~# '^\s*[a-zA-Z_]\w*\%(::[a-zA-Z_]\w*\)*\%(\s*#\s*([^)]*)\)\?\s\+\%(\[[^\]]*\]\s*\)*[a-zA-Z_0-9$]\+'
        return 1
    endif
    return 0
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

