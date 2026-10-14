"=============================================================================
" EasyAlign Helpers & Intelligent Auto-Alignment
" - Normal mode: Cursor on delimiter (=, :, ,, <=, //, etc.), press '_' to align paragraph
" - Visual mode: Press '_' to auto-detect delimiter and align instantly
" - Visual 'ta': Custom regex prompt :'<,'>EasyAlign //
"=============================================================================

let g:easy_align_delimiters = {
\ '(': { 'pattern': '(',  'left_margin': 1, 'right_margin': 0, 'stick_to_left': 0 },
\ ')': { 'pattern': ')',  'left_margin': 0, 'right_margin': 0, 'stick_to_left': 1 },
\ '[': { 'pattern': '\[', 'left_margin': 1, 'right_margin': 0, 'stick_to_left': 0 },
\ ']': { 'pattern': '\]', 'left_margin': 0, 'right_margin': 1, 'stick_to_left': 1 },
\ ',': { 'pattern': ',\(\s*$\)\@!', 'left_margin': 0, 'right_margin': 1, 'stick_to_left': 0 },
\ }

function! s:GetAlignBlockRange() abort
    let l:cur = line('.')
    let l:first = l:cur
    while l:first > 1 && getline(l:first - 1) !~# '^\s*$'
        let l:first -= 1
    endwhile
    let l:last = l:cur
    let l:total = line('$')
    while l:last < l:total && getline(l:last + 1) !~# '^\s*$'
        let l:last += 1
    endwhile
    return [l:first, l:last]
endfunction

function! s:GetMatchingBlockRange(cur_line, pattern) abort
    let l:cur = a:cur_line
    let l:pat = a:pattern

    " Search upwards for contiguous lines containing the pattern
    let l:first = l:cur
    while l:first > 1
        let l:prev_line = getline(l:first - 1)
        if l:prev_line =~# '^\s*$'
            break
        endif
        if l:prev_line =~# l:pat
            let l:first -= 1
        else
            break
        endif
    endwhile

    " Search downwards for contiguous lines containing the pattern
    let l:last = l:cur
    let l:total = line('$')
    while l:last < l:total
        let l:next_line = getline(l:last + 1)
        if l:next_line =~# '^\s*$'
            break
        endif
        if l:next_line =~# l:pat
            let l:last += 1
        else
            break
        endif
    endwhile

    return [l:first, l:last]
endfunction

function! EasyAlignUnderCursor() abort
    if !exists(':EasyAlign')
        return
    endif

    let l:line = getline('.')
    let l:col = col('.')
    let l:char = l:line[l:col - 1]
    let l:next_char = l:col < len(l:line) ? l:line[l:col] : ''
    let l:prev_char = l:col > 1 ? l:line[l:col - 2] : ''

    " Detect multi-char operators like <=, ==, !=, +=, -=, :=, =>, //
    let l:two_char = l:char . l:next_char
    let l:prev_two = l:prev_char . l:char
    if l:two_char =~# '^\(<=\|==\|!=\|+=\|-=\|:=\|=>\|//\)$' || l:prev_two =~# '^\(<=\|==\|!=\|+=\|-=\|:=\|=>\|//\)$'
        if l:two_char ==# '//' || l:prev_two ==# '//'
            let l:delim = '/'
            let l:pat = '//'
        else
            let l:delim = '='
            let l:pat = l:two_char =~# '^\(<=\|==\|!=\|+=\|-=\|:=\|=>\)$' ? l:two_char : l:prev_two
        endif
        let [l:start, l:end] = s:GetMatchingBlockRange(line('.'), l:pat)
        if l:start >= l:end
            let [l:start, l:end] = s:GetAlignBlockRange()
        endif
        if l:start >= l:end
            return
        endif
        execute printf('%d,%dEasyAlign %s', l:start, l:end, l:delim)
        return
    endif

    " Explicit single-character delimiters: =, :, ,, |, &, #, "
    if l:char =~# '^[=:,|&#"]$'
        let l:delim = l:char
        if l:delim ==# ','
            let l:pat = ',\(\s*$\)\@!'
            let l:star = '* '
        elseif l:delim ==# '|'
            let l:pat = '|'
            let l:star = '* '
        else
            let l:pat = escape(l:char, '~^$[]*\./')
            let l:star = ''
        endif

        let [l:start, l:end] = s:GetMatchingBlockRange(line('.'), l:pat)
        if l:start >= l:end
            let [l:start, l:end] = s:GetAlignBlockRange()
        endif
        if l:start >= l:end
            return
        endif
        execute printf('%d,%dEasyAlign %s%s', l:start, l:end, l:star, l:delim)
        return
    endif

    " Explicit brackets/parentheses: (, ), [, ]
    if l:char =~# '^[()[\]]$'
        let l:delim = l:char
        let l:pat = escape(l:char, '~^$[]*\./')
        let [l:start, l:end] = s:GetMatchingBlockRange(line('.'), l:pat)
        if l:start >= l:end
            let [l:start, l:end] = s:GetAlignBlockRange()
        endif
        if l:start >= l:end
            return
        endif
        execute printf('%d,%dEasyAlign %s', l:start, l:end, l:delim)
        return
    endif

    " Explicit dot delimiter (e.g. Verilog port connections .clk(clk))
    if l:char ==# '.'
        let l:delim = '.'
        let l:pat = '\.'
        let [l:start, l:end] = s:GetMatchingBlockRange(line('.'), l:pat)
        if l:start >= l:end
            let [l:start, l:end] = s:GetAlignBlockRange()
        endif
        if l:start >= l:end
            return
        endif
        execute printf('%d,%dEasyAlign %s', l:start, l:end, l:delim)
        return
    endif

    " Cursor is NOT on an explicit delimiter (e.g. on whitespace, identifier, or { / }):
    " Auto-detect the best delimiter for the current block (same as visual mode)
    let [l:start, l:end] = s:GetAlignBlockRange()
    if l:start >= l:end
        return
    endif
    let l:delim = s:DetectBestDelimiter(l:start, l:end)
    let l:star = (l:delim =~# '^[,|]$') ? '* ' : ''
    let l:pat = (l:delim ==# ',') ? ',\(\s*$\)\@!' : escape(l:delim, '~^$[]*\./')

    " Narrow to matching contiguous lines if current line contains this delimiter
    if getline('.') =~# l:pat
        let [l:m_start, l:m_end] = s:GetMatchingBlockRange(line('.'), l:pat)
        if l:m_start < l:m_end
            let l:start = l:m_start
            let l:end = l:m_end
        endif
    endif

    execute printf('%d,%dEasyAlign %s%s', l:start, l:end, l:star, l:delim)
endfunction

function! s:DetectBestDelimiter(first_line, last_line) abort
    let l:eq_count = 0
    let l:colon_count = 0
    let l:comma_count = 0
    let l:comment_count = 0
    let l:bar_count = 0
    let l:dot_paren_count = 0
    let l:bracket_count = 0

    for l:lnum in range(a:first_line, a:last_line)
        let l:line = getline(l:lnum)
        if l:line =~# '^\s*$'
            continue
        endif
        if l:line =~# '\%(<=\|==\|!=\|+=\|-=\|:=\|=>\|[^=!<+->]=[^=]\)'
            let l:eq_count += 1
        endif
        " Strip bit-ranges like [31:0] before counting colons so range ':' isn't confused with dict/label ':'
        let l:stripped = substitute(l:line, '\[[^\]]*\]', '', 'g')
        if l:stripped =~# ':'
            let l:colon_count += 1
        endif
        if l:line =~# '^\s*\.\w\+\s*('
            let l:dot_paren_count += 1
        endif
        if l:line =~# '\s\+\['
            let l:bracket_count += 1
        endif
        if l:line =~# ','
            let l:comma_count += 1
        endif
        if l:line =~# '//'
            let l:comment_count += 1
        endif
        if l:line =~# '|'
            let l:bar_count += 1
        endif
    endfor

    if l:bar_count >= 2 && l:bar_count >= l:eq_count
        return '|'
    endif
    if l:dot_paren_count >= 2
        return '('
    endif
    if l:eq_count >= 2
        return '='
    endif
    if l:bracket_count >= 2 && l:colon_count == 0 && l:eq_count == 0
        return '['
    endif
    if l:colon_count >= 2
        return ':'
    endif
    if l:comma_count >= 2
        return ','
    endif
    if l:comment_count >= 2
        return '/'
    endif
    if l:eq_count >= 1
        return '='
    endif
    return '='
endfunction

function! s:VisualAutoAlign() abort
    let l:start = line("'<")
    let l:end = line("'>")

    " Case 1: user selected a delimiter within a single line (characterwise v, e.g. highlighted <=)
    if l:start == l:end
        let l:line = getline(l:start)
        let l:sel = l:line[col("'<") - 1 : col("'>") - 1]
        if !empty(l:sel)
            let l:pat = (l:sel ==# ',') ? ',\(\s*$\)\@!' : escape(l:sel, '~^$[]*\./')
            let [l:first, l:last] = s:GetMatchingBlockRange(l:start, l:pat)
            if l:first < l:last
                if l:sel =~# '^\(<=\|==\|!=\|+=\|-=\|:=\|=>\|=\)$'
                    execute printf('%d,%dEasyAlign =', l:first, l:last)
                elseif l:sel =~# '^[=:,|.#\"&{}()[\] ]$'
                    let l:star = (l:sel =~# '^[,|]$') ? '* ' : ''
                    execute printf('%d,%dEasyAlign %s%s', l:first, l:last, l:star, l:sel)
                else
                    execute printf('%d,%dEasyAlign /%s/', l:first, l:last, escape(l:sel, '/\'))
                endif
                return
            endif
        endif
    endif

    " Case 2: user selected multiple lines (linewise V)
    let l:delim = s:DetectBestDelimiter(l:start, l:end)
    let l:star = (l:delim =~# '^[,|]$') ? '* ' : ''
    execute printf('%d,%dEasyAlign %s%s', l:start, l:end, l:star, l:delim)
endfunction

" EasyAlign Mappings:
" - Normal mode: Cursor on delimiter (=, :, ,, <=, //, etc.), press '_' to align paragraph
nnoremap <silent> _ :call EasyAlignUnderCursor()<cr>

" - Visual mode:
"   * '_' : Auto-detect delimiter (=, :, ,, etc.) and align block instantly
"   * 'ta': Prompt :'<,'>EasyAlign // for custom regex
vnoremap <silent> _  :<C-u>call <SID>VisualAutoAlign()<cr>
vnoremap ta :EasyAlign //<left>

xmap ga <Plug>(EasyAlign)
xmap gA <Plug>(LiveEasyAlign)
nmap ga <Plug>(EasyAlign)
nmap gA <Plug>(LiveEasyAlign)

" Command alias for Tabularize compatibility
command! -nargs=* -range -bang Tabularize <line1>,<line2>EasyAlign<bang> <args>
