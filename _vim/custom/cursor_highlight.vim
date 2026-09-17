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
    if exists('w:cursor_match_id')
        silent! call matchdelete(w:cursor_match_id)
        unlet! w:cursor_match_id
    endif
    if exists('*getmatches')
        for l:m in getmatches()
            if l:m.group ==# 'WordUnderCursor'
                silent! call matchdelete(l:m.id)
            endif
        endfor
    endif
    2match none
endfunction

function! HighlightCursorWord() abort
    if &filetype =~# '^\%(nerdtree\|tagbar\|qf\|log\|logfile\)$' || mode() ==# 'c' || mode() =~# '^[vV\x16]' || line('$') > 10000
        call ClearCursorWordHighlight()
        return
    endif
    let l:word = expand('<cword>')
    if empty(l:word) || l:word !~# '^[a-zA-Z0-9_]\+$'
        call ClearCursorWordHighlight()
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
    " Priority -1 ensures hlsearch (priority 0) always takes precedence over WordUnderCursor
    let w:cursor_match_id = matchadd('WordUnderCursor', '\V\<' . escape(l:word, '\') . '\>', -1)
endfunction
