"=============================================================================
" Custom Statusline with Powerline Arrow
" Supports both Powerline glyphs () and clean flat rectangular fallback
" Compatible with Vim 7.4, 8.x, and 9.x
"=============================================================================

" 1. Powerline Arrow Option (1 = arrow glyph , 0 = clean flat block fallback)
" Set via variable: let g:powerline_arrow = 0 (or 1)
let g:powerline_arrow = get(g:, 'powerline_arrow', 0)

function! TogglePowerlineArrow() abort
    let g:powerline_arrow = !get(g:, 'powerline_arrow', 0)
    call s:UpdateStatusLine(1)
    redrawstatus!
    echo 'Powerline arrow: ' . (g:powerline_arrow ? 'ON ()' : 'OFF (flat)')
endfunction
command! TogglePowerlineArrow call TogglePowerlineArrow()
command! ToggleArrow call TogglePowerlineArrow()

" 2. Search Match Counter: 🔍 [current/total] (VS Code search style)
function! StatusLineSearchCount() abort
    if !exists('*searchcount') || !v:hlsearch || empty(@/)
        return ''
    endif
    try
        let l:recompute = line('$') > 3000 ? 0 : 1
        let l:res = searchcount({'recompute': l:recompute, 'maxcount': 999, 'timeout': 25})
        if empty(l:res) || l:res.total == 0
            return ''
        endif
        if l:res.incomplete == 1
            return ' 🔍 [>' . l:res.maxcount . '] '
        elseif l:res.current > l:res.maxcount
            return printf(' 🔍 [>%d/%d] ', l:res.maxcount, l:res.total)
        else
            return printf(' 🔍 [%d/%d] ', l:res.current, l:res.total)
        endif
    catch
        return ''
    endtry
endfunction

" 3. Visual Selection Stats: [N lines, M chars] (VS Code selection stats)
function! StatusLineVisualStats() abort
    let l:m = mode()
    if l:m !=# 'v' && l:m !=# 'V' && l:m !=# "\<C-v>"
        return ''
    endif
    let l:lines = abs(line('.') - line('v')) + 1
    if l:m ==# 'V'
        return printf(' [%dL] ', l:lines)
    elseif l:m ==# "\<C-v>"
        return printf(' [%dx%d] ', l:lines, abs(col('.') - col('v')) + 1)
    else
        let l:wc = exists('*wordcount') ? wordcount() : {}
        let l:chars = get(l:wc, 'visual_chars', abs(col('.') - col('v')) + 1)
        if l:lines > 1
            return printf(' [%dL, %dC] ', l:lines, l:chars)
        else
            return printf(' [%d chars] ', l:chars)
        endif
    endif
endfunction

" 4. Line Ending Warning: warns on Windows CRLF with suggestion (:set ff=unix)
function! StatusLineFileFormat() abort
    let l:buf = exists('g:statusline_winid') ? winbufnr(g:statusline_winid) : bufnr('')
    let l:bt = getbufvar(l:buf, '&buftype')
    let l:ft = getbufvar(l:buf, '&filetype')
    if l:bt =~# '^\%(nofile\|terminal\|quickfix\|help\)$' || l:ft =~# '^\%(nerdtree\|tagbar\|startify\)$'
        return ''
    endif
    let l:ff = getbufvar(l:buf, '&fileformat')
    if l:ff ==# 'dos'
        return ' ⚠️ CRLF (:set ff=unix) '
    elseif l:ff ==# 'mac'
        return ' ⚠️ MAC-CR (:set ff=unix) '
    endif
    return ''
endfunction

" 5. Custom Statusline Formatter
function! CustomStatusLine(active) abort
    let l:buf = exists('g:statusline_winid') ? winbufnr(g:statusline_winid) : bufnr('')
    let l:ft = getbufvar(l:buf, '&filetype')
    let l:name = bufname(l:buf)
    let l:arrow = get(g:, 'powerline_arrow', 0)

    if l:ft ==# 'nerdtree' || l:name =~# 'NERD_tree'
        if l:arrow
            return a:active ? '%#StatusLineNERDTree# NERDTree %#StatusLineNERDTreeSep#%#StatusLineBase#%=' : '%#StatusLineNERDTreeNC# NERDTree %#StatusLineNERDTreeNCSep#%#StatusLineNC#%='
        else
            return a:active ? '%#StatusLineNERDTree# NERDTree %#StatusLineBase#%=' : '%#StatusLineNERDTreeNC# NERDTree %#StatusLineNC#%='
        endif
    endif
    if l:ft ==# 'tagbar'
        if l:arrow
            return a:active ? '%#StatusLineNERDTree# Tagbar %#StatusLineNERDTreeSep#%#StatusLineBase#%=' : '%#StatusLineNERDTreeNC# Tagbar %#StatusLineNERDTreeNCSep#%#StatusLineNC#%='
        else
            return a:active ? '%#StatusLineNERDTree# Tagbar %#StatusLineBase#%=' : '%#StatusLineNERDTreeNC# Tagbar %#StatusLineNC#%='
        endif
    endif

    if !a:active
        let l:s = l:arrow ? '%#StatusLineNCFile# %<%t%m%r %#StatusLineNCFileSep#' : '%#StatusLineNCFile# %<%t%m%r '
        let l:s .= '%#StatusLineNC#%='
        let l:s .= '%#StatusLineWarn#%{StatusLineFileFormat()}'
        let l:s .= '%#StatusLineNC# %{&filetype !=# "" ? &filetype : "txt"} '
        let l:s .= ' Ln %l/%L, Col %-2c '
        return l:s
    endif

    let l:s = l:arrow ? '%#StatusLineFileActive# %<%t%m%r %#StatusLineFileSep#' : '%#StatusLineFileActive# %<%t%m%r '
    let l:s .= '%#StatusLineBase#%='
    let l:s .= '%#StatusLineWarn#%{StatusLineFileFormat()}'
    let l:s .= '%#StatusLineSearch#%{StatusLineSearchCount()}'
    let l:s .= '%#StatusLineVisual#%{StatusLineVisualStats()}'
    let l:s .= '%#StatusLineInfo# %{&filetype !=# "" ? &filetype : "txt"} '
    let l:s .= '%#StatusLinePos# Ln %l/%L, Col %-2c '
    return l:s
endfunction

set statusline=%!CustomStatusLine(1)
set fillchars+=vert:│

function! s:UpdateStatusLine(active) abort
    let l:arrow = get(g:, 'powerline_arrow', 0)
    if &filetype ==# 'nerdtree' || bufname('') =~# 'NERD_tree'
        if l:arrow
            let &l:statusline = a:active ? '%#StatusLineNERDTree# NERDTree %#StatusLineNERDTreeSep#%#StatusLineBase#%=' : '%#StatusLineNERDTreeNC# NERDTree %#StatusLineNERDTreeNCSep#%#StatusLineNC#%='
        else
            let &l:statusline = a:active ? '%#StatusLineNERDTree# NERDTree %#StatusLineBase#%=' : '%#StatusLineNERDTreeNC# NERDTree %#StatusLineNC#%='
        endif
    elseif &filetype ==# 'tagbar'
        if l:arrow
            let &l:statusline = a:active ? '%#StatusLineNERDTree# Tagbar %#StatusLineNERDTreeSep#%#StatusLineBase#%=' : '%#StatusLineNERDTreeNC# Tagbar %#StatusLineNERDTreeNCSep#%#StatusLineNC#%='
        else
            let &l:statusline = a:active ? '%#StatusLineNERDTree# Tagbar %#StatusLineBase#%=' : '%#StatusLineNERDTreeNC# Tagbar %#StatusLineNC#%='
        endif
    else
        let &l:statusline = '%!CustomStatusLine(' . a:active . ')'
    endif
endfunction

augroup StatusLineFocus
    autocmd!
    autocmd WinEnter,BufEnter * call s:UpdateStatusLine(1)
    autocmd WinLeave * call s:UpdateStatusLine(0)
augroup END

" 6. Statusline Palette (Powerline Khaki & Slate Theme)
highlight StatusLineFileActive  cterm=none ctermfg=234 ctermbg=137 guifg=#232323 guibg=#af875f gui=none
highlight StatusLineFileSep     cterm=none ctermfg=137 ctermbg=234 guifg=#af875f guibg=#1e1e1e gui=none

highlight StatusLineNCFile      cterm=none ctermfg=244 ctermbg=237 guifg=#808080 guibg=#333842 gui=none
highlight StatusLineNCFileSep   cterm=none ctermfg=237 ctermbg=234 guifg=#333842 guibg=#1e1e1e gui=none

highlight StatusLineBase        cterm=none ctermfg=244 ctermbg=234 guifg=#5c6370 guibg=#1e1e1e gui=none
highlight StatusLineWarn        cterm=none ctermfg=white ctermbg=167 guifg=#ffffff guibg=#e06c75 gui=none
highlight StatusLineSearch      cterm=none ctermfg=186 ctermbg=234 guifg=#e5c07b guibg=#1e1e1e gui=none
highlight StatusLineVisual      cterm=none ctermfg=234 ctermbg=75  guifg=#232323 guibg=#61afef gui=none
highlight StatusLineInfo        cterm=none ctermfg=248 ctermbg=234 guifg=#abb2bf guibg=#1e1e1e gui=none
highlight StatusLinePos         cterm=none ctermfg=250 ctermbg=234 guifg=#d0d0d0 guibg=#1e1e1e gui=none

highlight StatusLineNERDTree    cterm=none ctermfg=234 ctermbg=137 guifg=#232323 guibg=#af875f gui=none
highlight StatusLineNERDTreeSep cterm=none ctermfg=137 ctermbg=234 guifg=#af875f guibg=#1e1e1e gui=none
highlight StatusLineNERDTreeNC  cterm=none ctermfg=244 ctermbg=237 guifg=#808080 guibg=#333842 gui=none
highlight StatusLineNERDTreeNCSep cterm=none ctermfg=237 ctermbg=234 guifg=#333842 guibg=#1e1e1e gui=none

highlight StatusLine           cterm=none ctermfg=250 ctermbg=234 guifg=#abb2bf guibg=#1e1e1e gui=none
highlight StatusLineNC         cterm=none ctermfg=243 ctermbg=234 guifg=#5c6370 guibg=#1e1e1e gui=none
highlight VertSplit            ctermbg=none ctermfg=238 guibg=NONE guifg=#444444
highlight StatusLineTerm       ctermfg=253 ctermbg=28  guifg=#dadada guibg=#2a6634 gui=none
highlight StatusLineTermNC     ctermfg=248 ctermbg=236 guifg=#a8a8a8 guibg=#303030
