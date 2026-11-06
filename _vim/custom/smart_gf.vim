"=============================================================================
" Plugin/Module: smart_gf.vim
" Description: Smart 'gf' to jump directly to file and line number
" Compatible with: Vim 7.4+ and Vim 8/9+
" Supports: <file>,line | "file", line | (file, line) | file:line | file(line)
"           file,line|col | file:line:col
" Keybinding:
"   - 'gf': Jump directly to file (and line) in current window
"=============================================================================

if exists('g:loaded_smart_gf')
    finish
endif
let g:loaded_smart_gf = 1

" Ensure comma and space are not treated as part of filename for built-in <cfile>
set isfname-=,
set isfname-=32
set isfname-=\ 

" Fallback for Vim 7.4 builds that do not have matchstrpos() (added in 7.4.1685)
function! s:MatchStrPos(expr, pat, start) abort
    if exists('*matchstrpos')
        return matchstrpos(a:expr, a:pat, a:start)
    endif
    let l:s = match(a:expr, a:pat, a:start)
    if l:s == -1
        return ['', -1, -1]
    endif
    let l:e = matchend(a:expr, a:pat, a:start)
    let l:str = a:expr[l:s : l:e - 1]
    return [l:str, l:s, l:e]
endfunction

function! s:ParseLocation(line, col) abort
    " Suffix matches: ,line|col | :line:col | (line, col) | line 75 | @ 75
    let l:pat = '\%(' .
        \ '<\([^> \t]\+\)>' . '\|' .
        \ '["'']\([^"'' \t]\+\)["'']' . '\|' .
        \ '(\([a-zA-Z0-9_.~/-]\+\.[a-zA-Z0-9_]\+\|[a-zA-Z0-9_.~/-]\+/[a-zA-Z0-9_.-]\+\))' . '\|' .
        \ '\([a-zA-Z0-9_.~/-]\+\.[a-zA-Z0-9_]\+\|[a-zA-Z0-9_.~/-]\+/[a-zA-Z0-9_.-]\+\)' .
        \ '\)' .
        \ '\%(,\s*line\s\+\|\s\+line\s\+\|:\s*\|\s*,\s*\|\s*(\s*\|\s*@\s*\)\?\s*\(\d\+\)\?\%([:|]\s*\(\d\+\)\|?\)\?)\?'

    let l:start = 0
    let l:candidates = []
    while 1
        let l:pos = s:MatchStrPos(a:line, l:pat, l:start)
        if l:pos[0] ==# '' || l:pos[1] == -1
            break
        endif
        let l:m_str = l:pos[0]
        let l:m_start = l:pos[1] + 1
        let l:m_end = l:pos[2]
        let l:start = l:m_end

        let l:list = matchlist(l:m_str, l:pat)
        if !empty(l:list)
            let l:fname = ''
            for l:idx in [1, 2, 3, 4]
                if l:list[l:idx] !=# ''
                    let l:fname = l:list[l:idx]
                    break
                endif
            endfor
            let l:lnum = l:list[5]
            let l:cnum = l:list[6]

            " Check if fname itself has trailing ',75|2' or ',75' or ':75' or ':75:2'
            let l:sub = matchlist(l:fname, '^\(.\{-}\)\%(,\s*line\s\+\|\s\+line\s\+\|:\s*\|\s*,\s*\|\s*(\s*\|\s*@\s*\)\s*\(\d\+\)\%([:|]\s*\(\d\+\)\|?\)\?)\?$')
            if !empty(l:sub)
                let l:fname = l:sub[1]
                if empty(l:lnum)
                    let l:lnum = l:sub[2]
                endif
                if empty(l:cnum)
                    let l:cnum = l:sub[3]
                endif
            endif

            if l:fname !=# ''
                call add(l:candidates, [l:m_start, l:m_end, l:fname, l:lnum, l:cnum])
            endif
        endif
    endwhile

    for l:cand in l:candidates
        let [l:c_start, l:c_end, l:f, l:l, l:c] = l:cand
        if a:col >= l:c_start && a:col <= l:c_end
            return [l:f, l:l, l:c]
        endif
    endfor
    return []
endfunction

function! s:ResolveFile(raw_file) abort
    let l:target = a:raw_file
    let l:target = substitute(l:target, '^file:\/\/', '', '')
    let l:target = substitute(l:target, '^[<"''(\[]\+\|[>"'')\],:;]\+$', '', 'g')
    let l:target = substitute(l:target, '^\.\.\.\/', '', '')
    let l:target = expand(l:target)

    if l:target ==# ''
        return ''
    endif
    if filereadable(l:target)
        return l:target
    endif
    let l:cur_dir = expand('%:p:h')
    if l:cur_dir !=# '' && filereadable(l:cur_dir . '/' . l:target)
        return l:cur_dir . '/' . l:target
    endif
    let l:found = findfile(l:target, &path)
    if l:found !=# ''
        return l:found
    endif
    let l:git_dir = finddir('.git', (l:cur_dir !=# '' ? l:cur_dir : '.') . ';')
    if l:git_dir !=# ''
        let l:git_root = fnamemodify(l:git_dir, ':h')
        if l:git_root !=# '' && filereadable(l:git_root . '/' . l:target)
            return l:git_root . '/' . l:target
        endif
    endif
    let l:base = fnamemodify(l:target, ':t')
    let l:found_base = findfile(l:base, &path)
    if l:found_base !=# ''
        return l:found_base
    endif
    return ''
endfunction

function! s:GotoFile() abort
    let l:line = getline('.')
    let l:col = col('.')
    let l:loc = s:ParseLocation(l:line, l:col)

    let l:raw_file = ''
    let l:lnum = 0
    let l:cnum = 0

    if !empty(l:loc) && !empty(l:loc[0])
        let l:raw_file = l:loc[0]
        let l:lnum = empty(l:loc[1]) ? 0 : str2nr(l:loc[1])
        let l:cnum = empty(l:loc[2]) ? 0 : str2nr(l:loc[2])
    else
        let l:raw_file = expand('<cfile>')
        let l:lnum = v:count
    endif

    " Safety check: strip any lingering line/column suffix from raw_file
    let l:sub = matchlist(l:raw_file, '^\(.\{-}\)\%(,\s*line\s\+\|\s\+line\s\+\|:\s*\|\s*,\s*\|\s*(\s*\|\s*@\s*\)\s*\(\d\+\)\%([:|]\s*\(\d\+\)\|?\)\?)\?$')
    if !empty(l:sub)
        let l:raw_file = l:sub[1]
        if l:lnum == 0 && !empty(l:sub[2])
            let l:lnum = str2nr(l:sub[2])
        endif
        if l:cnum == 0 && !empty(l:sub[3])
            let l:cnum = str2nr(l:sub[3])
        endif
    endif

    if v:count > 0 && l:lnum == 0
        let l:lnum = v:count
    endif

    let l:resolved = s:ResolveFile(l:raw_file)
    if empty(l:resolved)
        echohl WarningMsg | echo "File not found: " . l:raw_file | echohl None
        return
    endif

    let l:cmd = 'edit'
    if l:lnum > 0
        let l:cmd .= ' +' . l:lnum
    endif
    let l:cmd .= ' ' . fnameescape(l:resolved)

    try
        execute l:cmd
        if l:cnum > 0
            execute 'normal! ' . l:cnum . '|'
        endif
        if l:lnum > 0
            normal! zz
        endif
    catch /^Vim\%((\a\+)\)\=:E37/
        execute 'split ' . (l:lnum > 0 ? '+' . l:lnum . ' ' : '') . fnameescape(l:resolved)
        if l:cnum > 0
            execute 'normal! ' . l:cnum . '|'
        endif
        if l:lnum > 0
            normal! zz
        endif
    catch
        echohl ErrorMsg | echo "Cannot open: " . l:resolved | echohl None
    endtry
endfunction

nnoremap <silent> gf :call <SID>GotoFile()<CR>
