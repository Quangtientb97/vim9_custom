"=============================================================================
" Native Surround & Delete Matching Pair (Integrated with vim-matchup)
" - Visual mode: Select text, press (, [, {, ', ", ` to wrap text
" - Normal mode: Standing on bracket/quote/pair, press ds to delete pair
"=============================================================================

function! s:VisualSurround(open, close) abort
    let l:reg_save = getreg('"')
    let l:type_save = getregtype('"')
    normal! gvy
    let l:text = getreg('"')
    if visualmode() ==# 'V'
        let l:text = substitute(l:text, '\n$', '', '')
        call setreg('"', a:open . l:text . a:close . "\n", 'V')
    else
        call setreg('"', a:open . l:text . a:close, 'c')
    endif
    normal! gvp
    call setreg('"', l:reg_save, l:type_save)
endfunction

function! s:DeleteSurround() abort
    let l:char = getline('.')[col('.') - 1]
    let l:line = getline('.')
    let l:col = col('.')

    " 1. If standing on or inside quotes (", ', `)
    for l:q in ['"', "'", '`']
        let l:matches = []
        let l:pos = 0
        while 1
            let l:pos = stridx(l:line, l:q, l:pos)
            if l:pos == -1 | break | endif
            call add(l:matches, l:pos + 1)
            let l:pos += 1
        endwhile

        let l:len = len(l:matches)
        let l:i = 0
        while l:i + 1 < l:len
            let l:c1 = l:matches[l:i]
            let l:c2 = l:matches[l:i + 1]
            if l:col >= l:c1 && l:col <= l:c2
                call setline('.', strpart(l:line, 0, l:c1 - 1) . strpart(l:line, l:c1, l:c2 - l:c1 - 1) . strpart(l:line, l:c2))
                call cursor(line('.'), l:c1)
                return
            endif
            let l:i += 2
        endwhile
    endfor

    " 2. For brackets and language words (begin/end, if/endif), delegate to vim-matchup
    execute "normal \<plug>(matchup-ds%)"
endfunction

" Visual mode surround mappings
xnoremap <silent> ( :<C-u>call <SID>VisualSurround('(', ')')<CR>
xnoremap <silent> ) :<C-u>call <SID>VisualSurround('(', ')')<CR>
xnoremap <silent> [ :<C-u>call <SID>VisualSurround('[', ']')<CR>
xnoremap <silent> ] :<C-u>call <SID>VisualSurround('[', ']')<CR>
xnoremap <silent> { :<C-u>call <SID>VisualSurround('{', '}')<CR>
xnoremap <silent> } :<C-u>call <SID>VisualSurround('{', '}')<CR>
xnoremap <silent> ' :<C-u>call <SID>VisualSurround("'", "'")<CR>
xnoremap <silent> " :<C-u>call <SID>VisualSurround('"', '"')<CR>
xnoremap <silent> ` :<C-u>call <SID>VisualSurround('`', '`')<CR>

" Normal mode: ds deletes matching pair (bracket, quote, or matchup pair)
nnoremap <silent> ds :<C-u>call <SID>DeleteSurround()<CR>
