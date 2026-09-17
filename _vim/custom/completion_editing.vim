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

    if (_Ent ==# '_Ent')
        return "\<space>\<left>"
    elseif (cursor_before ==# '(' && cursor ==# ')')
        return "\<C-3>\<esc>A;\<esc>O"
    elseif (cursor_before ==# '{' && cursor ==# '}')
        return "\<C-3>\<esc>O"
    elseif (_begin ==# 'begin')
        return "\<space>\<bs>\<C-3>end\<esc>O"
    elseif (line =~ '^\s*case.*)')
        return "\<C-3>endcase\<esc>O"
    elseif ((line =~ '`ifdef') || (line =~ '`ifndef'))
        return "\<esc>$bveyA\<C-3>`endif // \<esc>p==O"
    elseif (pumvisible())
        return "\<space>\<bs>"
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

" Smart Multi-line Comment / Uncomment
function! Comment() range abort
    let ft = &filetype
    let is_c_like = (ft ==# 'verilog_systemverilog' || ft ==# 'c' || ft ==# 'fortran' || ft ==# 'systemC' || ft ==# 'lisa')
    for lnum in range(a:firstline, a:lastline)
        let line = getline(lnum)
        if is_c_like
            if line =~ '^\s*//'
                let line = substitute(line, '^\(\s*\)//\?', '\1', '')
            else
                let line = substitute(line, '^\(\s*\)', '\1//', '')
            endif
        else
            if line =~ '^\s*#'
                let line = substitute(line, '^\(\s*\)#\?', '\1', '')
            else
                let line = substitute(line, '^\(\s*\)', '\1#', '')
            endif
        endif
        call setline(lnum, line)
    endfor
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
