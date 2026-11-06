"=============================================================================
" Plugin: tabular_helper.vim
" Description: Tabular Alignment Helpers & Shortcuts
" - Normal mode: Cursor on delimiter, press '_' to align by character under cursor
" - Visual mode: Select delimiter or block, press '_' to align
" - Visual mode: Press 'ta' to prompt :'<,'>Tabularize /
" - Special handling for '(', ')', '.', '"', '[', ']', '{', '}', ':':
"   Align without extra padding spaces (l0)
" - Cursor position is preserved on the aligned delimiter instead of jumping to col 1
"=============================================================================

if exists('g:loaded_tabular_helper')
    finish
endif
let g:loaded_tabular_helper = 1

" Register named Tabular patterns with zero extra padding
function! s:RegisterTabularPatterns() abort
    if exists(':AddTabularPattern')
        AddTabularPattern! (             /(/l0
        AddTabularPattern! )             /)/l0
        AddTabularPattern! .             /\./l0
        AddTabularPattern! "             /"/l0
        AddTabularPattern! [             /\[/l0
        AddTabularPattern! ]             /\]/l0
        AddTabularPattern! {             /{/l0
        AddTabularPattern! }             /}/l0
        AddTabularPattern! :             /:/l0
        AddTabularPattern! paren_open    /(/l0
        AddTabularPattern! paren_close   /)/l0
        AddTabularPattern! dot           /\./l0
        AddTabularPattern! quote         /"/l0
        AddTabularPattern! bracket_open  /\[/l0
        AddTabularPattern! bracket_close /\]/l0
        AddTabularPattern! brace_open    /{/l0
        AddTabularPattern! brace_close   /}/l0
        AddTabularPattern! colon         /:/l0
    endif
endfunction

call s:RegisterTabularPatterns()
augroup TabularPatternsInit
    autocmd!
    autocmd VimEnter * call s:RegisterTabularPatterns()
augroup END

" Helper: Count occurrences of delimiter up to column in line
function! s:CountOccurrences(line_text, col, delim) abort
    let l:prefix = a:line_text[0 : a:col - 1]
    let l:cnt = 0
    let l:idx = -1
    while 1
        let l:idx = stridx(l:prefix, a:delim, l:idx + 1)
        if l:idx == -1 || l:idx > a:col - 1
            break
        endif
        let l:cnt += 1
    endwhile
    return max([l:cnt, 1])
endfunction

" Helper: Find 1-based column of Nth occurrence of delimiter
function! s:FindNthOccurrenceCol(line_text, delim, n) abort
    let l:cnt = 0
    let l:idx = -1
    while 1
        let l:idx = stridx(a:line_text, a:delim, l:idx + 1)
        if l:idx == -1
            return -1
        endif
        let l:cnt += 1
        if l:cnt == a:n
            return l:idx + 1
        endif
    endwhile
endfunction

" Helper function to format and run Tabularize on a given delimiter
function! s:RunTabularize(delim, range_prefix) abort
    let l:delim = a:delim
    if l:delim =~# '^[()."\[\]{}:]$'
        let l:pat = escape(l:delim, '[]/\.*~')
        execute a:range_prefix . 'Tabularize /' . l:pat . '/l0'
    else
        execute a:range_prefix . 'Tabularize /' . escape(l:delim, '/\')
    endif
endfunction

" Normal mode alignment on delimiter under cursor
function! TabularizeUnderCursor() abort
    if !exists(':Tabularize')
        return
    endif

    let l:cur_lnum = line('.')
    let l:cur_col = col('.')
    let l:line = getline('.')
    let l:char = l:line[l:cur_col - 1]
    let l:next_char = l:cur_col < len(l:line) ? l:line[l:cur_col] : ''
    let l:prev_char = l:cur_col > 1 ? l:line[l:cur_col - 2] : ''

    " Check 2-character operators
    let l:delim = l:char
    let l:two = l:char . l:next_char
    let l:prev_two = l:prev_char . l:char
    if l:two =~# '^\(//\|:=\|=>\|==\|<=\|+=\|-=\|::\)$'
        let l:delim = l:two
    elseif l:prev_two =~# '^\(//\|:=\|=>\|==\|<=\|+=\|-=\|::\)$'
        let l:delim = l:prev_two
    endif

    let l:nth = s:CountOccurrences(l:line, l:cur_col, l:delim)

    call s:RunTabularize(l:delim, '')

    " Restore cursor position on the aligned delimiter
    let l:new_line = getline(l:cur_lnum)
    let l:new_col = s:FindNthOccurrenceCol(l:new_line, l:delim, l:nth)
    if l:new_col > 0
        call cursor(l:cur_lnum, l:new_col)
    else
        call cursor(l:cur_lnum, l:cur_col)
    endif
endfunction

" Visual mode alignment
function! TabularizeVisualSelection() range abort
    if !exists(':Tabularize')
        return
    endif

    let l:cur_lnum = line('.')
    let l:cur_col = col('.')
    let l:save_reg = getreg('"')
    let l:save_regtype = getregtype('"')
    normal! gvy
    let l:selection = @"
    call setreg('"', l:save_reg, l:save_regtype)

    if l:selection =~# "[\r\n]"
        call feedkeys(":'<,'>Tabularize /", 'n')
        return
    endif

    let l:delim = trim(l:selection)
    if empty(l:delim)
        let l:delim = l:selection
    endif

    let l:line = getline(l:cur_lnum)
    let l:nth = s:CountOccurrences(l:line, l:cur_col, l:delim)

    call s:RunTabularize(l:delim, "'<,'>")

    " Restore cursor position on the aligned delimiter
    let l:new_line = getline(l:cur_lnum)
    let l:new_col = s:FindNthOccurrenceCol(l:new_line, l:delim, l:nth)
    if l:new_col > 0
        call cursor(l:cur_lnum, l:new_col)
    else
        call cursor(l:cur_lnum, l:cur_col)
    endif
endfunction

" Tabularize Mappings
nnoremap <silent> _ :call TabularizeUnderCursor()<cr>
vnoremap <silent> _ :<C-U>call TabularizeVisualSelection()<cr>
vnoremap ta :Tabularize /
