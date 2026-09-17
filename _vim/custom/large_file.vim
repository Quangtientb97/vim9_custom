"=============================================================================
" Automated Large File Optimizer (for files with line count > 1500)
" Keeps scrolling and buffer navigation fast by disabling slow syntax sync
"=============================================================================

function! s:OptimizeLargeFile() abort
    if line('$') > 1500
        let b:large_file_optimized = 1
        " Disable swapfile to eliminate disk I/O on large buffers
        setlocal noswapfile
        " Prevent long simulation lines from locking the syntax engine
        setlocal synmaxcol=300
        " Restrict syntax synchronization scope
        syntax sync minlines=50 maxlines=100
        " Disable heavy real-time bracket/block matching in vim-matchup
        let b:matchup_matchparen_enabled = 0
        let b:matchup_matchparen_fallback = 0
        " Disable gitgutter diffing on large buffers
        silent! GitGutterBufferDisable
        " Switch slow folding methods to manual to keep scrolling smooth
        if &l:foldmethod ==# 'syntax' || &l:foldmethod ==# 'indent' || &l:foldmethod ==# 'expr'
            setlocal foldmethod=manual
        endif
    endif
endfunction

augroup VimrcLargeFile
    autocmd!
    autocmd BufReadPost * call s:OptimizeLargeFile()
augroup END

" Auto-load Rainbow Brackets on supported buffers (skipped for large files > 1500 lines)
augroup VimrcRainbow
    autocmd!
    autocmd FileType * if &ft !~# '^\%(nerdtree\|tagbar\|log\|logfile\)$' && line('$') <= 1500 | silent! call rainbow_main#load() | endif
augroup END
