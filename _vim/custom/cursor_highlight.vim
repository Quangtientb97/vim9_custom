"=============================================================================
" Plugin: cursor_highlight.vim
" Description: Auto-Highlight Word Under Cursor (VS Code Document Highlight)
"   - HighlightCursorWord() called on CursorHold, CursorHoldI
"   - ClearCursorWordHighlight() called on WinLeave, BufLeave
"=============================================================================

if !hlexists('WordUnderCursor')
    highlight WordUnderCursor cterm=underline ctermbg=237 guibg=#3a3a3a gui=underline
endif

function! ClearCursorWordHighlight() abort
    if exists('w:last_cursor_word')
        unlet! w:last_cursor_word
    endif
    if exists('w:last_cursor_top')
        unlet! w:last_cursor_top
    endif
    if exists('w:last_cursor_bot')
        unlet! w:last_cursor_bot
    endif
    if exists('w:cursor_match_id')
        silent! call matchdelete(w:cursor_match_id)
        unlet! w:cursor_match_id
    endif
    2match none
endfunction

function! HighlightCursorWord() abort
    if &filetype =~# '^\%(nerdtree\|tagbar\|qf\|log\|logfile\)$' || mode() ==# 'c' || mode() =~# '^[vV\x16]' || line('$') > 50000
        call ClearCursorWordHighlight()
        return
    endif
    let l:word = expand('<cword>')
    if empty(l:word) || len(l:word) < 2 || l:word !~# '^[a-zA-Z0-9_]\+$'
        call ClearCursorWordHighlight()
        return
    endif

    let l:w0 = line('w0')
    let l:w_dollar = line('w$')
    if l:w0 > 0 && l:w_dollar > 0
        let l:top = max([1, l:w0 - 15])
        let l:bot = min([line('$'), l:w_dollar + 15])
        let l:line_limit = '\%>' . (l:top - 1) . 'l\%<' . (l:bot + 1) . 'l'
    else
        let l:top = 1
        let l:bot = line('$')
        let l:line_limit = ''
    endif

    " Early return if cursor is still on the same word within the same viewport
    if exists('w:last_cursor_word') && w:last_cursor_word ==# l:word
        \ && exists('w:last_cursor_top') && w:last_cursor_top == l:top
        \ && exists('w:last_cursor_bot') && w:last_cursor_bot == l:bot
        \ && exists('w:cursor_match_id')
        return
    endif

    " If search highlighting is active and the word matches the search pattern,
    " do not overwrite hlsearch with cursor highlight.
    if v:hlsearch && !empty(@/)
        let l:matched_search = 0
        try
            if l:word =~# @/ || l:word =~? @/
                let l:matched_search = 1
            endif
        catch
        endtry
        if l:matched_search
            call ClearCursorWordHighlight()
            return
        endif
    endif

    call ClearCursorWordHighlight()
    let w:last_cursor_word = l:word
    let w:last_cursor_top  = l:top
    let w:last_cursor_bot  = l:bot

    " Priority -1 ensures hlsearch (priority 0) always takes precedence over WordUnderCursor
    let l:pattern = l:line_limit . '\V\<' . escape(l:word, '\') . '\>'
    let l:mid = matchadd('WordUnderCursor', l:pattern, -1)
    if l:mid != -1
        let w:cursor_match_id = l:mid
    endif
endfunction
