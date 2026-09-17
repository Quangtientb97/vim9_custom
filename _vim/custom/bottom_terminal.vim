"=============================================================================
" Plugin: bottom_terminal.vim
" Description: Bottom Terminal Drawer & Window Closer
"   - ToggleBottomTerminal [Key: F12 or :Term]
"   - CloseCurrentFileAndTerminal [Key: F1]
"=============================================================================

let g:bottom_term_buf = get(g:, 'bottom_term_buf', -1)

" Toggle Bottom Terminal Drawer (VS Code Ctrl+`)
function! ToggleBottomTerminal() abort
    if !has('terminal')
        echohl WarningMsg | echo "Terminal feature is not supported in this Vim version (requires Vim 8.1+ with +terminal)" | echohl None
        return
    endif
    if g:bottom_term_buf != -1 && bufexists(g:bottom_term_buf)
        let l:win = bufwinnr(g:bottom_term_buf)
        if l:win != -1
            if winnr('$') > 1
                execute l:win . 'close!'
            endif
            return
        endif
        if term_getstatus(g:bottom_term_buf) =~# 'finished'
            execute 'bwipeout! ' . g:bottom_term_buf
            let g:bottom_term_buf = -1
        endif
    endif

    botright 12split
    if g:bottom_term_buf != -1 && bufexists(g:bottom_term_buf)
        execute 'buffer ' . g:bottom_term_buf
    else
        terminal ++curwin ++close
        let g:bottom_term_buf = bufnr('%')
        setlocal nobuflisted
    endif
    setlocal statusline=%#StatusLineTerm#\ [TERMINAL]\ %{bufname('%')}%=\ [F12:\ Toggle]\ 
    startinsert
endfunction

" Smart Close Current File & Associated Terminal
function! CloseCurrentFileAndTerminal() abort
    if &buftype ==# 'terminal' || (get(g:, 'bottom_term_buf', -1) != -1 && bufnr('%') == g:bottom_term_buf)
        if winnr('$') > 1
            close!
        else
            q!
        endif
        return
    endif

    if get(g:, 'bottom_term_buf', -1) != -1 && bufexists(g:bottom_term_buf)
        let l:term_win = bufwinnr(g:bottom_term_buf)
        if l:term_win != -1 && winnr('$') > 1
            execute l:term_win . 'close!'
        endif
    endif

    let l:other_code_windows = 0
    for l:w in range(1, winnr('$'))
        if l:w != winnr()
            let l:b = winbufnr(l:w)
            let l:ft = getbufvar(l:b, '&filetype')
            if l:ft !=# 'nerdtree' && l:ft !=# 'tagbar'
                let l:other_code_windows += 1
            endif
        endif
    endfor

    if l:other_code_windows == 0
        qa!
    else
        q!
    endif
endfunction

" User Command
command! -bang Term call ToggleBottomTerminal()
