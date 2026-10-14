"=============================================================================
" Plugin: smart_selection.vim
" Description: VS Code-like Smart Selection Expansion & Shrinking (AST / Syntax-Aware)
" Shortcuts:
"   - Normal mode:
"       - <Shift-Alt-Right> (<M-S-Right> / <A-S-Right>): Start & expand selection
"   - Visual mode:
"       - <Shift-Alt-Right> (<M-S-Right> / <A-S-Right>): Expand to next syntax level
"       - <Shift-Alt-Left>  (<M-S-Left> / <A-S-Left>):   Shrink to previous level
"       - <Esc>: Exit visual mode
"=============================================================================

if exists('g:loaded_smart_selection')
    finish
endif
let g:loaded_smart_selection = 1

let g:smart_selection_enable   = get(g:, 'smart_selection_enable', 1)
let g:smart_selection_show_msg = get(g:, 'smart_selection_show_msg', 1)

let s:applying_selection = 0

"-----------------------------------------------------------------------------
" 1. Geometric & Boundary Helper Functions
"-----------------------------------------------------------------------------

function! s:IsRangeContains(r, pos) abort
    let [l:sl, l:sc, l:el, l:ec] = a:r
    let [l:l, l:c] = a:pos

    if l:l < l:sl || l:l > l:el | return 0 | endif
    if l:l == l:sl && l:c < l:sc | return 0 | endif
    if l:l == l:el && l:c > l:ec | return 0 | endif
    return 1
endfunction

function! s:IsStrictlyEnclosing(outer, inner) abort
    let [l:osl, l:osc, l:oel, l:oec] = a:outer
    let [l:isl, l:isc, l:iel, l:iec] = a:inner

    " Outer must contain inner start and inner end
    let l:s_ok = (l:osl < l:isl) || (l:osl == l:isl && l:osc <= l:isc)
    let l:e_ok = (l:oel > l:iel) || (l:oel == l:iel && l:oec >= l:iec)
    if !l:s_ok || !l:e_ok | return 0 | endif

    " Outer must be strictly larger (cannot be identical)
    if l:osl == l:isl && l:osc == l:isc && l:oel == l:iel && l:oec == l:iec
        return 0
    endif
    return 1
endfunction

function! s:RangeLength(r) abort
    let [l:sl, l:sc, l:el, l:ec] = a:r
    if l:sl == l:el
        return l:ec - l:sc + 1
    endif
    return (l:el - l:sl) * 10000 + (l:ec - l:sc + 1)
endfunction

function! s:GetTextObject(obj) abort
    let l:view = winsaveview()
    let l:reg_save = getreg('"')
    let l:regtype_save = getregtype('"')

    " Clear visual marks to detect whether text object actually triggered
    call setpos("'<", [0, 0, 0, 0])
    call setpos("'>", [0, 0, 0, 0])

    execute "normal! \<Esc>"
    execute 'silent! normal! v' . a:obj . "\<Esc>"
    let l:s = getpos("'<")[1 : 2]
    let l:e = getpos("'>")[1 : 2]

    call setreg('"', l:reg_save, l:regtype_save)
    call winrestview(l:view)

    " If marks weren't set or invalid
    if l:s[0] == 0 || l:e[0] == 0
        return []
    endif

    " Validate single-character selection
    if l:s[0] == l:e[0] && l:s[1] == l:e[1]
        " Only 'iw' on an actual keyword character can be 1-character
        if a:obj ==# 'iw'
            let l:line_txt = getline(l:s[0])
            if l:s[1] <= len(l:line_txt) && l:line_txt[l:s[1] - 1] =~# '\k'
                return [l:s[0], l:s[1], l:e[0], l:e[1]]
            endif
        endif
        " Otherwise quotes, brackets, pairs cannot be a 1-character range
        return []
    endif

    " Surrounding objects like a", a), a], a}, a> must have at least 2 chars
    if a:obj =~# '^a' && l:s[0] == l:e[0] && (l:e[1] - l:s[1] < 1)
        return []
    endif

    " Clamp column to line boundaries
    let l:max_sc = max([1, col([l:s[0], '$'])])
    let l:max_ec = max([1, col([l:e[0], '$'])])
    let l:s[1] = min([l:s[1], l:max_sc])
    let l:e[1] = min([l:e[1], l:max_ec])

    return [l:s[0], l:s[1], l:e[0], l:e[1]]
endfunction

"-----------------------------------------------------------------------------
" 2. Syntax & Structural Candidate Extractors
"-----------------------------------------------------------------------------

function! s:GetStatementRange(line_num, col_num) abort
    let l:line_str = getline(a:line_num)
    let l:semi_idx = stridx(l:line_str, ';')
    let l:first_nb = match(l:line_str, '\S') + 1

    " Single-line statement ending with ;
    if l:semi_idx != -1 && a:col_num >= l:first_nb && a:col_num <= l:semi_idx + 1
        return [a:line_num, l:first_nb, a:line_num, l:semi_idx + 1]
    endif
    return []
endfunction

function! s:GetIndentBlocks(start_line) abort
    let l:cur_indent = indent(a:start_line)
    let l:total_lines = line('$')
    let l:blocks = []

    if getline(a:start_line) =~# '^\s*$' | return [] | endif

    let l:test_indent = l:cur_indent
    while l:test_indent >= 0
        let l:top = a:start_line
        while l:top > 1
            let l:prev = l:top - 1
            if getline(l:prev) =~# '^\s*$'
                let l:top = l:prev
                continue
            endif
            if indent(l:prev) >= l:test_indent
                let l:top = l:prev
            else
                break
            endif
        endwhile

        let l:bot = a:start_line
        while l:bot < l:total_lines
            let l:nxt = l:bot + 1
            if getline(l:nxt) =~# '^\s*$'
                let l:bot = l:nxt
                continue
            endif
            if indent(l:nxt) >= l:test_indent
                let l:bot = l:nxt
            else
                break
            endif
        endwhile

        " Trim empty lines on boundaries
        while l:top < l:bot && getline(l:top) =~# '^\s*$' | let l:top += 1 | endwhile
        while l:bot > l:top && getline(l:bot) =~# '^\s*$' | let l:bot -= 1 | endwhile

        if l:top <= l:bot
            call add(l:blocks, {
                \ 'range': [l:top, 1, l:bot, max([1, col([l:bot, '$']) - 1])],
                \ 'label': 'Block (Lines ' . l:top . '-' . l:bot . ')',
                \ 'mode': 'V'
            \ })

            " Check if top - 1 has a header (e.g. if/always/def/class/for)
            if l:top > 1
                let l:header = l:top - 1
                while l:header > 1 && getline(l:header) =~# '^\s*$'
                    let l:header -= 1
                endwhile
                if indent(l:header) < l:test_indent
                    call add(l:blocks, {
                        \ 'range': [l:header, 1, l:bot, max([1, col([l:bot, '$']) - 1])],
                        \ 'label': 'Block with Header (Lines ' . l:header . '-' . l:bot . ')',
                        \ 'mode': 'V'
                    \ })
                    let l:test_indent = indent(l:header)
                else
                    let l:test_indent -= 4
                endif
            else
                break
            endif
        else
            break
        endif
    endwhile

    return l:blocks
endfunction

"-----------------------------------------------------------------------------
" 3. Build Monotonic Hierarchy
"-----------------------------------------------------------------------------

function! s:BuildHierarchy(pos) abort
    let l:cur = a:pos
    let l:candidates = []

    " 1. Text objects
    let l:objs = [
        \ ['iw', 'Word'],
        \ ['aW', 'WORD'],
        \ ['i"', 'Inside String ""'],
        \ ['a"', 'Around String ""'],
        \ ['i''', 'Inside String '''''],
        \ ['a''', 'Around String '''''],
        \ ['i`', 'Inside Identifier ``'],
        \ ['a`', 'Around Identifier ``'],
        \ ['i)', 'Inside Parens ()'],
        \ ['a)', 'Around Parens ()'],
        \ ['i]', 'Inside Brackets []'],
        \ ['a]', 'Around Brackets []'],
        \ ['i}', 'Inside Braces {}'],
        \ ['a}', 'Around Braces {}'],
        \ ['i>', 'Inside Tag <>'],
        \ ['a>', 'Around Tag <>'],
        \ ['i%', 'Inside Matching Pair (i%)'],
        \ ['a%', 'Around Matching Pair (a%)'],
        \ ['ip', 'Inside Paragraph'],
        \ ['ap', 'Around Paragraph']
    \ ]

    for [l:obj, l:label] in l:objs
        let l:r = s:GetTextObject(l:obj)
        if !empty(l:r) && s:IsRangeContains(l:r, l:cur)
            call add(l:candidates, {'range': l:r, 'label': l:label, 'mode': 'v'})
        endif
    endfor

    " 2. Statement (; terminated)
    let l:stmt = s:GetStatementRange(l:cur[0], l:cur[1])
    if !empty(l:stmt)
        call add(l:candidates, {'range': l:stmt, 'label': 'Statement (;)', 'mode': 'v'})
    endif

    " 3. Current Trimmed Line
    let l:line_str = getline(l:cur[0])
    let l:first_nb = match(l:line_str, '\S') + 1
    let l:last_nb = len(l:line_str)
    if l:first_nb > 0 && l:last_nb >= l:first_nb
        call add(l:candidates, {'range': [l:cur[0], l:first_nb, l:cur[0], l:last_nb], 'label': 'Line (Trimmed)', 'mode': 'v'})
    endif

    " 4. Full Line
    call add(l:candidates, {'range': [l:cur[0], 1, l:cur[0], max([1, col([l:cur[0], '$']) - 1])], 'label': 'Full Line', 'mode': 'V'})

    " 5. Indent & Parent Blocks
    for l:b in s:GetIndentBlocks(l:cur[0])
        call add(l:candidates, l:b)
    endfor

    " 6. Entire Buffer
    let l:last_lnum = line('$')
    let l:last_col = max([1, col([l:last_lnum, '$']) - 1])
    call add(l:candidates, {'range': [1, 1, l:last_lnum, l:last_col], 'label': 'Entire Buffer', 'mode': 'V'})

    " Sort by range length
    call sort(l:candidates, {a, b -> s:RangeLength(a.range) - s:RangeLength(b.range)})

    " Strict enclosure deduplication
    let l:filtered = []
    for l:c in l:candidates
        if empty(l:filtered)
            call add(l:filtered, l:c)
        else
            let l:prev = l:filtered[-1]
            if s:IsStrictlyEnclosing(l:c.range, l:prev.range)
                call add(l:filtered, l:c)
            endif
        endif
    endfor

    return l:filtered
endfunction

"-----------------------------------------------------------------------------
" 4. Selection Application & UX
"-----------------------------------------------------------------------------

function! s:ApplySelection(item) abort
    let s:applying_selection = 1
    try
        let [l:sl, l:sc, l:el, l:ec] = a:item.range
        let l:mode = get(a:item, 'mode', 'v')

        " Reset visual anchor cleanly
        execute "normal! \<Esc>"

        if l:mode ==# 'V'
            call cursor(l:sl, 1)
            execute "normal! V"
            call cursor(l:el, 1)
        else
            call cursor(l:sl, l:sc)
            execute "normal! v"
            call cursor(l:el, l:ec)
        endif
    finally
        let s:applying_selection = 0
    endtry
endfunction

function! s:ShowFeedback(idx, total, label) abort
    if !g:smart_selection_show_msg
        return
    endif
    let l:msg = printf('-- [Smart Selection %d/%d] %s  (<Shift-Alt-Right>: expand | <Shift-Alt-Left>: shrink | Esc: done) --',
        \ a:idx + 1, a:total, a:label)
    echohl ModeMsg
    echo l:msg
    echohl None
endfunction

"-----------------------------------------------------------------------------
" 5. Public API: Expand & Shrink
"-----------------------------------------------------------------------------

function! SmartSelectionExpand() abort
    if !g:smart_selection_enable
        return
    endif

    let l:in_visual = (mode() =~# '^[vV\x16]')
    let l:cur_pos = [line('.'), col('.')]

    " Check if we have an active smart selection session in this buffer
    if exists('b:smart_sel_active') && b:smart_sel_active && exists('b:smart_sel_stack') && !empty(b:smart_sel_stack)
        if b:smart_sel_idx + 1 < len(b:smart_sel_stack)
            let b:smart_sel_idx += 1
            let l:item = b:smart_sel_stack[b:smart_sel_idx]
            call s:ApplySelection(l:item)
            call s:ShowFeedback(b:smart_sel_idx, len(b:smart_sel_stack), l:item.label)
        else
            let l:item = b:smart_sel_stack[b:smart_sel_idx]
            call s:ApplySelection(l:item)
            if g:smart_selection_show_msg
                echohl ModeMsg
                echo printf('-- [Smart Selection %d/%d] %s  (Max level reached) --',
                    \ b:smart_sel_idx + 1, len(b:smart_sel_stack), l:item.label)
                echohl None
            endif
        endif
        return
    endif

    " Initialize new smart selection session
    let b:smart_sel_origin = l:cur_pos
    let b:smart_sel_stack = s:BuildHierarchy(l:cur_pos)

    if empty(b:smart_sel_stack)
        execute "normal! viw"
        return
    endif

    let b:smart_sel_active = 1

    if l:in_visual
        " If already in visual mode, find the first candidate strictly larger than current active selection
        let l:v_pos = getpos('v')[1 : 2]
        let l:c_pos = getpos('.')[1 : 2]
        if l:v_pos[0] < l:c_pos[0] || (l:v_pos[0] == l:c_pos[0] && l:v_pos[1] <= l:c_pos[1])
            let l:cur_vis_range = [l:v_pos[0], l:v_pos[1], l:c_pos[0], l:c_pos[1]]
        else
            let l:cur_vis_range = [l:c_pos[0], l:c_pos[1], l:v_pos[0], l:v_pos[1]]
        endif

        let l:target_idx = 0
        let l:found = 0
        for l:i in range(len(b:smart_sel_stack))
            if s:IsStrictlyEnclosing(b:smart_sel_stack[l:i].range, l:cur_vis_range)
                let l:target_idx = l:i
                let l:found = 1
                break
            endif
        endfor
        if !l:found
            let l:target_idx = len(b:smart_sel_stack) - 1
        endif
        let b:smart_sel_idx = l:target_idx
    else
        let b:smart_sel_idx = 0
    endif

    let l:item = b:smart_sel_stack[b:smart_sel_idx]
    call s:ApplySelection(l:item)
    call s:ShowFeedback(b:smart_sel_idx, len(b:smart_sel_stack), l:item.label)
endfunction

function! SmartSelectionShrink() abort
    if !g:smart_selection_enable
        return
    endif

    if exists('b:smart_sel_active') && b:smart_sel_active && exists('b:smart_sel_stack') && !empty(b:smart_sel_stack)
        if b:smart_sel_idx > 0
            let b:smart_sel_idx -= 1
            let l:item = b:smart_sel_stack[b:smart_sel_idx]
            call s:ApplySelection(l:item)
            call s:ShowFeedback(b:smart_sel_idx, len(b:smart_sel_stack), l:item.label)
        else
            " Past minimum level: exit visual mode and restore cursor
            execute "normal! \<Esc>"
            if exists('b:smart_sel_origin')
                call cursor(b:smart_sel_origin[0], b:smart_sel_origin[1])
            endif
            let b:smart_sel_active = 0
            if g:smart_selection_show_msg
                echo "-- Smart Selection exited --"
            endif
        endif
    else
        " Normal visual exit
        execute "normal! \<Esc>"
    endif
endfunction

function! s:OnVisualLeave() abort
    if s:applying_selection
        return
    endif
    if exists('b:smart_sel_active')
        let b:smart_sel_active = 0
    endif
endfunction

" Reset active state ONLY when exiting Visual mode to Normal mode
if exists('##ModeChanged')
    autocmd ModeChanged [vV\x16]:n call s:OnVisualLeave()
endif

"-----------------------------------------------------------------------------
" 6. Commands & Keybindings
"-----------------------------------------------------------------------------
command! SmartSelectExpand call SmartSelectionExpand()
command! SmartSelectShrink call SmartSelectionShrink()

" Ensure terminal interprets Shift-Alt-Right / Shift-Alt-Left correctly
if !has('gui_running')
    silent! execute "set <M-S-Right>=\<Esc>[1;4C"
    silent! execute "set <M-S-Left>=\<Esc>[1;4D"
endif

" Normal mode: Start & Expand (Shift-Alt-Right)
nnoremap <silent> <M-S-Right>  <Cmd>call SmartSelectionExpand()<CR>
nnoremap <silent> <A-S-Right>  <Cmd>call SmartSelectionExpand()<CR>

" Visual mode: Expand & Shrink (Shift-Alt-Right / Shift-Alt-Left)
xnoremap <silent> <M-S-Right>  <Cmd>call SmartSelectionExpand()<CR>
xnoremap <silent> <A-S-Right>  <Cmd>call SmartSelectionExpand()<CR>

xnoremap <silent> <M-S-Left>   <Cmd>call SmartSelectionShrink()<CR>
xnoremap <silent> <A-S-Left>   <Cmd>call SmartSelectionShrink()<CR>
