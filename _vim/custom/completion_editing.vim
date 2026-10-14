"=============================================================================
" Plugin: completion_editing.vim
" Description: Smart Completion, Snippets, Supertab & Code Editing Utilities
"   - AutoComplete(), Snipet(), Supertab()
"   - ToggleNERDTree(), Fold(), Comment(), AddMinus(), RemovePair()
"=============================================================================

"-----------------------------------------------------------------------------
" 1. Auto-Completion & Snippets
"-----------------------------------------------------------------------------
let g:auto_complete     = get(g:, 'auto_complete', 1)
let g:auto_complete_len = get(g:, 'auto_complete_len', 4)

function! AutoComplete() abort
    if pumvisible() || &paste || v:char !~# '\k'
        return
    endif

    let l:c = col('.')
    let l:line = getline('.')

    " Do not trigger if typing in the middle of an existing identifier
    if l:c <= len(l:line) && l:line[l:c - 1] =~# '\k'
        return
    endif

    let l:pre = l:c > 1 ? l:line[0 : l:c - 2] : ''
    let l:word = matchstr(l:pre, '\k*$')
    let l:min_len = get(g:, 'auto_complete_len', 3)

    let l:is_member_access = (l:pre =~# '\%(\.\|->\|::\)$' && len(l:word) == 0)
    let l:should_trigger   = (len(l:word) == (l:min_len - 1)) || l:is_member_access

    if l:should_trigger
        call feedkeys("\<C-n>\<C-p>", 'n')
    endif
endfunction

" Snippet expansion on Enter
function! Snipet() abort
    let c = col('.')
    let line = getline('.')
    let _Ent   = c >= 5 ? line[c - 5 : c - 2] : ''
    let _begin = c >= 6 ? line[c - 6 : c - 2] : ''

    let cursor        = line[c - 1]
    let cursor_before = c > 1 ? line[c - 2] : ''

    " 1. Check if word before cursor is a registered snippet in snippet_engine
    if exists('*snippet_engine#check_word_before_cursor')
        let l:snip_trig = snippet_engine#check_word_before_cursor()
        if !empty(l:snip_trig)
            return "\<Esc>:call snippet_engine#expand(" . string(l:snip_trig) . ")\<CR>"
        endif
    endif

    if (_Ent ==# '_Ent')
        return "\<space>\<left>"
    elseif (cursor_before ==# '(' && cursor ==# ')')
        if &filetype =~# '^\%(verilog\|systemverilog\|verilog_systemverilog\|c\|cpp\|systemC\)$'
            return "\<C-3>\<esc>A;\<esc>O"
        else
            return "\<C-3>\<esc>O"
        endif
    elseif (cursor_before ==# '{' && cursor ==# '}')
        return "\<C-3>\<esc>O"
    elseif (_begin ==# 'begin')
        return "\<space>\<bs>\<C-3>end\<esc>O"
    elseif (line =~ '^\s*case.*)')
        return "\<C-3>endcase\<esc>O"
    elseif ((line =~ '`ifdef') || (line =~ '`ifndef'))
        return "\<esc>$b\"tyeA\<C-3>`endif // \<esc>\"tp==O"
    elseif (pumvisible())
        return "\<C-y>"
    else
        return "\<C-3>"
    endif
endfunction

" SuperTab completion handler
function! Supertab() abort
    let c = col('.')
    let char_before = c > 1 ? getline('.')[c - 2] : ''
    if char_before !~ '[_a-zA-Z0-9]'
        return "\<F10>"
    elseif (pumvisible())
        return "\<c-n>"
    else
        return "\<c-n>\<c-p>"
    endif
endfunction

"-----------------------------------------------------------------------------
" 2. Code Editing Helpers
"-----------------------------------------------------------------------------
" NERDTree Toggle Wrapper
let g:stt_tree = get(g:, 'stt_tree', 1)

function! ToggleNERDTree() abort
    if g:stt_tree == 1
        NERDTree
        let g:stt_tree = 0
    else
        NERDTreeClose
        let g:stt_tree = 1
    endif
endfunction

function! NERDTree() abort
    call ToggleNERDTree()
endfunction

" Smart Folding
function! Fold() abort
    let cur_line = getline('.')
    if (cur_line =~# '\v.*(begin|function|task|ifdef|case|module|class|\{|\})')
                \ && (cur_line !~# '\v.*(\*\{\{\{\*|\*\}\}\}\*)')
        normal! zf%
    else
        normal! za
    endif
endfunction

" Helper: Detect comment delimiters based on filetype or &commentstring
function! s:GetCommentConfig() abort
    let l:ft = &filetype
    " Prefer standard single-line comment markers for common languages
    if l:ft =~# '^\%(verilog\|systemverilog\|verilog_systemverilog\|c\|cpp\|systemC\|lisa\|java\|javascript\|typescript\|rust\|go\|php\|swift\|scala\|dart\|cs\)$'
        return ['//', '']
    elseif l:ft ==# 'vim'
        return ['"', '']
    elseif l:ft =~# '^\%(python\|sh\|bash\|csh\|tcsh\|zsh\|make\|tcl\|upf\|perl\|ruby\|yaml\|toml\|dockerfile\)$'
        return ['#', '']
    elseif l:ft =~# '^\%(lua\|sql\|haskell\|vhdl\)$'
        return ['--', '']
    elseif l:ft =~# '^\%(asm\)$'
        return [';', '']
    elseif l:ft =~# '^\%(matlab\|octave\)$'
        return ['%', '']
    elseif l:ft =~# '^\%(xml\|html\|markdown\)$'
        return ['<!--', '-->']
    endif

    " Fallback to &commentstring
    let l:cms = !empty(&commentstring) ? &commentstring : '// %s'
    if l:cms !~# '%s'
        let l:cms = '// %s'
    endif
    let l:parts = split(l:cms, '%s', 1)
    let l:pfx = exists('*trim') ? trim(l:parts[0]) : substitute(l:parts[0], '^\s*\|\s*$', '', 'g')
    let l:sfx = len(l:parts) > 1 ? (exists('*trim') ? trim(l:parts[1]) : substitute(l:parts[1], '^\s*\|\s*$', '', 'g')) : ''
    if empty(l:pfx)
        let l:pfx = '//'
    endif
    return [l:pfx, l:sfx]
endfunction

" Smart Multi-line Comment / Uncomment (Universal, supports all filetypes)
" - 1 single line (a:firstline == a:lastline): Indent-aligned comment marker
" - Multiple lines / Block (a:firstline < a:lastline, e.g. Shift+V): Comment marker at beginning of line (column 0)
function! Comment() range abort
    let [l:pfx, l:sfx] = s:GetCommentConfig()
    let l:esc_pfx = escape(l:pfx, '/*~.^$[]\')
    let l:esc_sfx = escape(l:sfx, '/*~.^$[]\')
    let l:is_block = (a:firstline < a:lastline)
    let l:sep = (l:pfx ==# '"' ? ' ' : '')

    " Check if all non-empty lines in range are already commented
    let l:all_commented = 1
    let l:has_non_empty = 0
    for lnum in range(a:firstline, a:lastline)
        let l:line = getline(lnum)
        if l:line =~# '^\s*$'
            continue
        endif
        let l:has_non_empty = 1
        if !empty(l:sfx)
            if l:line !~# '^\s*' . l:esc_pfx . '.*' . l:esc_sfx . '\s*$'
                let l:all_commented = 0
                break
            endif
        else
            if l:line !~# '^\s*' . l:esc_pfx
                let l:all_commented = 0
                break
            endif
        endif
    endfor

    if !l:has_non_empty
        return
    endif

    for lnum in range(a:firstline, a:lastline)
        let l:line = getline(lnum)
        if l:line =~# '^\s*$'
            continue
        endif
        if l:all_commented
            " Uncomment: remove comment markers
            if !empty(l:sfx)
                let l:line = substitute(l:line, '^\(\s*\)' . l:esc_pfx . '\s\?', '\1', '')
                let l:line = substitute(l:line, '\s\?' . l:esc_sfx . '\(\s*\)$', '\1', '')
            else
                if l:line =~# '^' . l:esc_pfx
                    " Comment marker is at column 0 (beginning of line)
                    " Remove marker without altering following indentation
                    let l:line = substitute(l:line, '^' . l:esc_pfx . (l:pfx ==# '"' ? '\s\?' : ''), '', '')
                else
                    " Comment marker is indented
                    let l:line = substitute(l:line, '^\(\s*\)' . l:esc_pfx . '\s\?', '\1', '')
                endif
            endif
        else
            " Comment:
            if l:is_block
                " Block comment (Shift+V / multiple lines): comment marker at beginning of line (column 0)
                if !empty(l:sfx)
                    let l:line = l:pfx . ' ' . l:line . ' ' . l:sfx
                else
                    let l:line = l:pfx . l:sep . l:line
                endif
            else
                " Single line comment: indent-aligned
                if !empty(l:sfx)
                    let l:line = substitute(l:line, '^\(\s*\)\(.*\)$', '\1' . l:pfx . ' \2 ' . l:sfx, '')
                else
                    let l:line = substitute(l:line, '^\(\s*\)', '\1' . l:pfx . l:sep, '')
                endif
            endif
        endif
        call setline(lnum, l:line)
    endfor
endfunction

" Smart Block Comment Generator
" - Normal mode: Wrap current line into a block comment box
" - Visual mode: Wrap selected lines into a block comment box
function! BlockComment() range abort
    let [l:pfx, l:sfx] = s:GetCommentConfig()
    let l:esc_pfx = escape(l:pfx, '/*~.^$[]\')
    let l:width = get(g:, 'block_comment_width', 71)
    let l:style = get(g:, 'block_comment_style', 'box')

    let l:first = a:firstline
    let l:last  = a:lastline

    " 1. Expand range if cursor/selection is part of an existing box comment
    let l:border_pat = '^\s*' . l:esc_pfx . '\s*[-=]\{5,\}\s*[+]\=\s*$'
    let l:content_pat = '^\s*' . l:esc_pfx . '.*|\s*$'

    " Scan upwards from l:first to find existing top border
    if getline(l:first) =~# l:content_pat
        let l:scan = l:first
        while l:scan > 1 && getline(l:scan - 1) =~# l:content_pat
            let l:scan -= 1
        endwhile
        if l:scan > 1 && getline(l:scan - 1) =~# l:border_pat
            let l:first = l:scan - 1
        endif
    elseif getline(l:first) =~# l:border_pat
        if l:first > 1 && (getline(l:first - 1) =~# l:content_pat || getline(l:first - 1) =~# l:border_pat)
            let l:scan = l:first - 1
            while l:scan > 1 && getline(l:scan) =~# l:content_pat
                let l:scan -= 1
            endwhile
            if getline(l:scan) =~# l:border_pat
                let l:first = l:scan
            endif
        endif
    elseif l:first > 1 && getline(l:first - 1) =~# l:border_pat
        let l:first = l:first - 1
    endif
    " Absorb any duplicate border lines directly above
    while l:first > 1 && getline(l:first - 1) =~# l:border_pat
        let l:first -= 1
    endwhile

    " Scan downwards from l:last to find existing bottom border
    if getline(l:last) =~# l:content_pat
        let l:scan = l:last
        while l:scan < line('$') && getline(l:scan + 1) =~# l:content_pat
            let l:scan += 1
        endwhile
        if l:scan < line('$') && getline(l:scan + 1) =~# l:border_pat
            let l:last = l:scan + 1
        endif
    elseif getline(l:last) =~# l:border_pat
        if l:last < line('$') && (getline(l:last + 1) =~# l:content_pat || getline(l:last + 1) =~# l:border_pat)
            let l:scan = l:last + 1
            while l:scan < line('$') && getline(l:scan) =~# l:content_pat
                let l:scan += 1
            endwhile
            if getline(l:scan) =~# l:border_pat
                let l:last = l:scan
            endif
        endif
    elseif l:last < line('$') && getline(l:last + 1) =~# l:border_pat
        let l:last = l:last + 1
    endif
    " Absorb any duplicate border lines directly below
    while l:last < line('$') && getline(l:last + 1) =~# l:border_pat
        let l:last += 1
    endwhile

    " 2. Detect minimum indentation of non-empty content lines
    let l:min_indent = ''
    let l:min_indent_len = 9999
    for lnum in range(l:first, l:last)
        let l:line = getline(lnum)
        if l:line !~# '^\s*$' && l:line !~# l:border_pat
            let l:ind = matchstr(l:line, '^\s*')
            if len(l:ind) < l:min_indent_len
                let l:min_indent = l:ind
                let l:min_indent_len = len(l:ind)
            endif
        endif
    endfor
    if l:min_indent_len == 9999
        let l:min_indent = matchstr(getline(l:first), '^\s*')
    endif

    " 3. Clean content lines: strip existing comment markers, borders and trailing margin chars
    let l:clean_lines = []
    for lnum in range(l:first, l:last)
        let l:raw = getline(lnum)
        " If line is purely a border divider, skip it completely
        if l:raw =~# l:border_pat
            continue
        endif
        " Strip trailing box border characters '|' or '+' with whitespace
        let l:text = substitute(l:raw, '\s*[|+]\s*$', '', '')
        " Strip leading indentation
        let l:text = substitute(l:text, '^\s*', '', '')
        " Strip leading comment markers
        let l:text = substitute(l:text, '^' . l:esc_pfx . '\s\?', '', '')
        " If line was purely a divider of dashes/equals, skip it
        if l:text =~# '^[-=]\+$'
            continue
        endif
        call add(l:clean_lines, l:text)
    endfor

    if empty(l:clean_lines)
        let l:clean_lines = ['']
    endif

    " 3. Build formatted block comment lines
    let l:comment_prefix = l:min_indent . l:pfx . ' '
    let l:pfx_width = exists('*strdisplaywidth') ? strdisplaywidth(l:comment_prefix) : len(l:comment_prefix)

    let l:result = []
    if l:style ==# 'line'
        " Style 'line': Divider with ====================
        let l:bar_len = max([10, l:width - l:pfx_width])
        let l:border = l:comment_prefix . repeat('=', l:bar_len)
        call add(l:result, l:border)
        for l:line in l:clean_lines
            call add(l:result, l:comment_prefix . l:line)
        endfor
        call add(l:result, l:border)
    else
        " Style 'box' (default): Box with --------------------+ and |
        let l:dash_len = max([5, l:width - l:pfx_width - 1])
        let l:border = l:comment_prefix . repeat('-', l:dash_len) . '+'
        call add(l:result, l:border)
        for l:line in l:clean_lines
            let l:lead = l:comment_prefix . l:line
            let l:cur_w = exists('*strdisplaywidth') ? strdisplaywidth(l:lead) : len(l:lead)
            let l:pad = max([1, l:width - l:cur_w - 1])
            call add(l:result, l:lead . repeat(' ', l:pad) . '|')
        endfor
        call add(l:result, l:border)
    endif

    " 4. Replace lines in the buffer cleanly
    execute l:first . ',' . l:last . 'delete _'
    call append(l:first - 1, l:result)
    " Move cursor to the first content line
    call cursor(l:first + 1, len(l:comment_prefix) + 1)
endfunction

" Fast Header Comment Divider
function! AddMinus() abort
    let cur_line = getline('.')
    let max_col  = virtcol('$') - 1
    let num_char = max([0, 70 - max_col])
    let is_alpha = (cur_line =~ '[a-zA-Z]')
    let fill_char = is_alpha ? ' ' : '-'
    let end_char  = is_alpha ? '|' : '+'
    call setline('.', cur_line . repeat(fill_char, num_char) . end_char)
    normal! $
endfunction

" Bracket Pair Deletion
function! RemovePair() abort
    let c = col('.')
    let line = getline('.')
    let pair_before = c > 1 ? line[c - 2] : ''
    let pair_after  = line[c - 1]

    if ((pair_before ==# '(' && pair_after ==# ')')
                \ || (pair_before ==# '{' && pair_after ==# '}')
                \ || (pair_before ==# '[' && pair_after ==# ']')
                \ || (pair_before ==# '"' && pair_after ==# '"'))
        return "\<del>\<bs>"
    elseif c > 2 && line[c - 3] =~ '\W'
        return "\<bs>\<esc>a"
    elseif pumvisible()
        return "\<left>\<right>\<bs>\<c-n>\<c-p>"
    else
        return "\<bs>"
    endif
endfunction
