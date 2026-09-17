"=============================================================================
" Plugin/Module: git_diff.vim
" Description: Instant Side-by-Side Git Diff Toggle using vim-fugitive
" Shortcuts:
"   - 'gd' or 'sg': Toggle side-by-side Git Diff with HEAD / index
"   - ':Diff [rev]': Open diff (against HEAD, index, or specific branch/commit)
"=============================================================================

function! ToggleGitDiff(...) abort
    if &diff
        " Turn off diff mode across windows in current tab
        diffoff!
        " Close any fugitive diff split windows
        let l:closed = 0
        for w in range(winnr('$'), 1, -1)
            let l:bname = bufname(winbufnr(w))
            if l:bname =~# '^fugitive:'
                execute w . 'close'
                let l:closed = 1
            endif
        endfor
        if l:closed
            echohl MoreMsg | echo "Git Diff closed" | echohl None
        else
            echo "Diff mode off"
        endif
    else
        " Check if fugitive is available
        if !exists('*FugitiveGitDir')
            echohl ErrorMsg | echo "vim-fugitive is not loaded!" | echohl None
            return
        endif
        let l:git_dir = FugitiveGitDir()
        if empty(l:git_dir)
            echohl WarningMsg | echo "Not inside a Git repository!" | echohl None
            return
        endif

        " If user provided a revision (e.g. :Diff master or :Diff HEAD~1)
        let l:target = a:0 > 0 && !empty(a:1) ? a:1 : ''
        if empty(l:target)
            Gvdiffsplit!
        else
            execute 'Gvdiffsplit ' . fnameescape(l:target)
        endif
        echohl ModeMsg | echo "Git Diff active (press 'gd' or 'sg' to close)" | echohl None
    endif
endfunction

" Command :Diff with fugitive branch/commit auto-completion
if exists('*fugitive#EditComplete')
    command! -nargs=? -complete=customlist,fugitive#EditComplete Diff call ToggleGitDiff(<f-args>)
else
    command! -nargs=? Diff call ToggleGitDiff(<f-args>)
endif

" Normal mode shortcuts
nnoremap <silent> gd :call ToggleGitDiff()<cr>
nnoremap <silent> sg :call ToggleGitDiff()<cr>
