"=============================================================================
" Custom Module: splitjoin.vim
" Description: Intelligent Split & Join Engine for SystemVerilog, Verilog & C/C++
"   - Keybindings:
"       * gS : Split single-line construct into multiline
"       * gJ : Join multiline construct into single-line
"   - Supports:
"       * Port lists in module declarations & instances: my_inst u1 (.clk(clk), ...)
"       * Parameter blocks: #(parameter A = 1, parameter B = 2)
"       * Function & Task arguments (SV & C/C++)
"       * Structs, Enums, Concatenations & Arrays: '{a: 1, b: 2}, {a, b, c}, [x, y]
"       * Nested brackets awareness: preserves nested commas (.data({a, b}))
"=============================================================================

if exists('g:loaded_custom_splitjoin')
    finish
endif
let g:loaded_custom_splitjoin = 1

" Parse items inside delimiter, respecting nested brackets and quotes
function! s:SplitItems(str) abort
    let l:items = []
    let l:current = ''
    let l:depth = 0
    let l:in_quote = ''
    let l:len = len(a:str)
    let l:i = 0

    while l:i < l:len
        let l:ch = a:str[l:i]

        " Handle string literals
        if (l:ch ==# '"' || l:ch ==# "'") && l:in_quote ==# ''
            let l:in_quote = l:ch
        elseif l:ch ==# l:in_quote && (l:i == 0 || a:str[l:i-1] !=# '\')
            let l:in_quote = ''
        endif

        if l:in_quote ==# ''
            if l:ch ==# '(' || l:ch ==# '{' || l:ch ==# '['
                let l:depth += 1
            elseif l:ch ==# ')' || l:ch ==# '}' || l:ch ==# ']'
                let l:depth -= 1
            elseif l:ch ==# ',' && l:depth == 0
                let l:trimmed = substitute(l:current, '^\s*\|\s*$', '', 'g')
                if !empty(l:trimmed)
                    call add(l:items, l:trimmed)
                endif
                let l:current = ''
                let l:i += 1
                continue
            endif
        endif

        let l:current .= l:ch
        let l:i += 1
    endwhile

    let l:trimmed = substitute(l:current, '^\s*\|\s*$', '', 'g')
    if !empty(l:trimmed)
        call add(l:items, l:trimmed)
    endif
    return l:items
endfunction

" Find enclosing pair on the current line
function! s:FindEnclosingPair(line, col) abort
    let l:pairs = [['(', ')'], ['{', '}'], ['[', ']']]
    let l:best_open = -1
    let l:best_close = -1
    let l:best_p = []

    for [l:op, l:cl] in l:pairs
        let l:pos = 0
        while 1
            let l:o = stridx(a:line, l:op, l:pos)
            if l:o == -1 | break | endif

            " Find matching close on this line
            let l:depth = 1
            let l:c = l:o + 1
            while l:c < len(a:line)
                if a:line[l:c] ==# l:op
                    let l:depth += 1
                elseif a:line[l:c] ==# l:cl
                    let l:depth -= 1
                    if l:depth == 0
                        break
                    endif
                endif
                let l:c += 1
            endwhile

            if l:depth == 0
                " Prioritize pair containing the cursor
                if a:col >= l:o && a:col <= l:c
                    return [l:o, l:c, l:op, l:cl]
                elseif l:best_open == -1
                    let l:best_open = l:o
                    let l:best_close = l:c
                    let l:best_p = [l:op, l:cl]
                endif
            endif
            let l:pos = l:o + 1
        endwhile
    endfor

    if l:best_open != -1
        return [l:best_open, l:best_close, l:best_p[0], l:best_p[1]]
    endif
    return [-1, -1, '', '']
endfunction

" gS: Split single-line construct into multiline
function! CustomSplit() abort
    let l:lnum = line('.')
    let l:line = getline(l:lnum)
    let l:col = col('.') - 1

    let [l:open_idx, l:close_idx, l:op, l:cl] = s:FindEnclosingPair(l:line, l:col)
    if l:open_idx == -1 || l:close_idx <= l:open_idx
        return
    endif

    let l:header = strpart(l:line, 0, l:open_idx + 1)
    let l:inner  = strpart(l:line, l:open_idx + 1, l:close_idx - l:open_idx - 1)
    let l:footer = strpart(l:line, l:close_idx)

    let l:items = s:SplitItems(l:inner)
    if len(l:items) <= 1
        " Check if logical operators && or ||
        if l:inner =~# '\(&&\|||\)'
            let l:items = split(l:inner, '\s*\ze\(&&\|||\)\s*')
        else
            return
        endif
    endif

    let l:base_indent = matchstr(l:line, '^\s*')
    let l:sw = &shiftwidth > 0 ? &shiftwidth : 4
    let l:item_indent = l:base_indent . repeat(' ', l:sw)

    let l:lines = [l:header]
    let l:count = len(l:items)
    let l:idx = 0
    for l:it in l:items
        let l:sep = (l:idx == l:count - 1 || l:it =~# ',$') ? '' : ','
        call add(l:lines, l:item_indent . l:it . l:sep)
        let l:idx += 1
    endfor
    call add(l:lines, l:base_indent . substitute(l:footer, '^\s*', '', ''))

    " Replace single line with formatted multiline block
    call setline(l:lnum, l:lines[0])
    call append(l:lnum, l:lines[1:])
    call cursor(l:lnum + 1, len(l:item_indent) + 1)
endfunction

" gJ: Join multiline construct into single-line
function! CustomJoin() abort
    let l:cur_lnum = line('.')

    " Scan backward to find line containing unclosed opening delimiter
    let l:start_lnum = l:cur_lnum
    let l:found = 0
    let l:open_char = ''
    let l:close_char = ''

    while l:start_lnum >= 1 && l:start_lnum >= l:cur_lnum - 60
        let l:txt = getline(l:start_lnum)
        for [l:o, l:c] in [['(', ')'], ['{', '}'], ['[', ']']]
            let l:idx = stridx(l:txt, l:o)
            if l:idx != -1
                if stridx(l:txt, l:c, l:idx + 1) == -1
                    let l:open_char = l:o
                    let l:close_char = l:c
                    let l:found = 1
                    break
                endif
            endif
        endfor
        if l:found | break | endif
        let l:start_lnum -= 1
    endwhile

    if !l:found | return | endif

    " Find matching closing delimiter using % motion
    let l:orig_pos = getpos('.')
    let l:col_open = stridx(getline(l:start_lnum), l:open_char) + 1
    call cursor(l:start_lnum, l:col_open)
    normal! %
    let l:end_lnum = line('.')
    let l:end_col = col('.')

    if l:end_lnum <= l:start_lnum
        call setpos('.', l:orig_pos)
        return
    endif

    let l:start_line = getline(l:start_lnum)
    let l:end_line = getline(l:end_lnum)

    let l:prefix = strpart(l:start_line, 0, l:col_open)
    let l:suffix = strpart(l:end_line, l:end_col - 1)

    let l:items = []
    let l:i = l:start_lnum + 1
    while l:i < l:end_lnum
        let l:t = substitute(getline(l:i), '^\s*\|\s*$', '', 'g')
        let l:t = substitute(l:t, ',$', '', '')
        if !empty(l:t)
            call add(l:items, l:t)
        endif
        let l:i += 1
    endwhile

    let l:joined_body = join(l:items, ', ')
    let l:pad_open = l:open_char ==# '{' ? ' ' : ''
    let l:pad_close = l:close_char ==# '}' ? ' ' : ''
    let l:new_line = l:prefix . l:pad_open . l:joined_body . l:pad_close . l:suffix

    call setline(l:start_lnum, l:new_line)
    if l:end_lnum > l:start_lnum
        execute 'silent! ' . (l:start_lnum + 1) . ',' . l:end_lnum . 'delete _'
    endif
    call cursor(l:start_lnum, l:col_open)
endfunction

" Keybindings (gs = Split, gj = Join)
nnoremap <silent> gs :<C-u>call CustomSplit()<CR>
nnoremap <silent> gj :<C-u>call CustomJoin()<CR>
nnoremap <silent> gS :<C-u>call CustomSplit()<CR>
nnoremap <silent> gJ :<C-u>call CustomJoin()<CR>

" Commands
command! -nargs=0 SplitBlock call CustomSplit()
command! -nargs=0 JoinBlock  call CustomJoin()
