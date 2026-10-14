"=============================================================================
" Plugin: breadcrumbs_scope.vim
" Description: VS Code-like Breadcrumbs / Scope Detection on StatusLine
"   - CurrentScope() function used in statusline
"   - Optimized with block-range caching and filetype early-exit
"=============================================================================

let g:breadcrumbs_scope_enabled = get(g:, 'breadcrumbs_scope_enabled', 1)

function! ToggleBreadcrumbs() abort
    let g:breadcrumbs_scope_enabled = !get(g:, 'breadcrumbs_scope_enabled', 1)
    echo 'Breadcrumbs scope: ' . (g:breadcrumbs_scope_enabled ? 'ON' : 'OFF')
endfunction
command! ToggleBreadcrumbs call ToggleBreadcrumbs()

function! CurrentScope() abort
    if !get(g:, 'breadcrumbs_scope_enabled', 1)
        return ''
    endif

    " 1. Fast exit for unsupported filetypes or huge files
    let l:ft = &filetype
    let l:ext = expand('%:e')
    let l:is_sv = (l:ft =~# '^\%(verilog\|systemverilog\)$' || l:ext =~# '^\%(v\|sv\|svh\|vh\)$')
    let l:is_py = (l:ft ==# 'python' || l:ext ==# 'py')

    if (!l:is_sv && !l:is_py) || line('$') > 8000
        return ''
    endif

    let l:cur_lnum = line('.')
    let l:tick = b:changedtick

    " 2. Range Cache check: if cursor is within cached scope range, return instantly in O(1)
    if exists('b:cached_scope_tick') && b:cached_scope_tick == l:tick
        if exists('b:cached_scope_range')
            if l:cur_lnum >= b:cached_scope_range[0] && l:cur_lnum <= b:cached_scope_range[1]
                return b:cached_scope_result
            endif
        elseif exists('b:cached_scope_lnum') && b:cached_scope_lnum == l:cur_lnum
            return b:cached_scope_result
        endif
    endif

    let l:save_pos = exists('*getcurpos') ? getcurpos() : getpos('.')
    let l:crumbs = []
    let l:proc_lnum = 0
    let l:scope_start = 1
    let l:scope_end = line('$')

    " 3. Check for Procedural block (SystemVerilog / Verilog: always_ff, always_comb, always_latch, always, initial, final)
    if l:is_sv
        call cursor(l:cur_lnum, col([l:cur_lnum, '$']))
        let l:proc_lnum = search('^\s*\%(always_ff\|always_comb\|always_latch\|always\|initial\|final\)\>', 'bcnW')
        if l:proc_lnum > 0
            let l:proc_line = getline(l:proc_lnum)
            let l:proc_type = matchstr(l:proc_line, '^\s*\zs\%(always_ff\|always_comb\|always_latch\|always\|initial\|final\)\>')

            " Check if it encloses cur_lnum
            call cursor(l:proc_lnum, 1)
            let l:begin_lnum = search('\<begin\>', 'cnW', min([l:proc_lnum + 10, l:cur_lnum]))
            let l:is_inside_proc = 0
            let l:proc_name = l:proc_type

            if l:begin_lnum > 0 && l:begin_lnum <= l:cur_lnum
                let l:label = matchstr(getline(l:begin_lnum), '\<begin\>\s*:\s*\zs\k\+')
                if !empty(l:label)
                    let l:proc_name = l:proc_type . ':' . l:label
                endif
                call cursor(l:begin_lnum, col([l:begin_lnum, '$']))
                let l:end_lnum = searchpair('\<begin\>', '', '\<end\>', 'nW', '', 0, 100)
                if l:end_lnum >= l:cur_lnum
                    let l:is_inside_proc = 1
                    let l:scope_start = max([l:scope_start, l:begin_lnum])
                    let l:scope_end = min([l:scope_end, l:end_lnum])
                endif
            else
                " Single statement or header without begin
                let l:semi_lnum = search(';', 'cnW')
                if l:semi_lnum >= l:cur_lnum
                    let l:is_inside_proc = 1
                    let l:scope_start = max([l:scope_start, l:proc_lnum])
                    let l:scope_end = min([l:scope_end, l:semi_lnum])
                endif
            endif

            if l:is_inside_proc
                call add(l:crumbs, l:proc_name)
            else
                let l:proc_lnum = 0
            endif
        endif
    endif

    " 4. Search backwards for routine / container scopes (task, function, module, class, interface, package, def)
    let l:search_start_lnum = (l:proc_lnum > 1) ? (l:proc_lnum - 1) : l:cur_lnum
    call cursor(l:search_start_lnum, col([l:search_start_lnum, '$']))

    let l:py_max_indent = -1
    let l:search_pat = '^\s*\%(async\s\+\|virtual\s\+\|static\s\+\|protected\s\+\|local\s\+\|extern\s\+\|pure\s\+virtual\s\+\)*\%(module\|class\|interface\|package\|def\|task\|function\)\>'
    let l:name_pat = '\zs\%(\k\+\%(\s*#\s*([^)]*)\)\?::\)*\k\+\ze\s*\%([;(]\|$\)'

    let l:depth = 0
    let l:found_enclosing = 0
    let l:seen_routine = 0

    while l:depth < 8
        let l:depth += 1
        let l:lnum = search(l:search_pat, 'bcnW')
        if l:lnum == 0
            break
        endif
        let l:line = getline(l:lnum)
        let l:type = matchstr(l:line, '\<\%(module\|class\|interface\|package\|def\|task\|function\)\>')

        " Extract name (supports Class::Method and parameterized scopes)
        if l:type =~# '^\%(task\|function\)$'
            let l:name = matchstr(l:line, l:name_pat)
            let l:seen_routine = 1
        elseif l:type =~# '^\%(module\|class\|interface\|package\|def\)$'
            let l:name = matchstr(l:line, '\<' . l:type . '\>\s\+\zs\k\+')
        else
            let l:name = ''
        endif

        if !empty(l:name) && !empty(l:type)
            " Check if this is an extern declaration (ends with semicolon, no body)
            let l:is_extern = (l:line =~# '^\s*\%(.*\s\+\)\=extern\s\+' || l:line =~# '^\s*pure\s\+virtual\s\+')
            if l:is_extern
                call cursor(l:lnum, 1)
                let l:semi_lnum = search(';', 'cnW')
                if l:semi_lnum == 0 | let l:semi_lnum = l:lnum | endif
                if l:cur_lnum > l:semi_lnum
                    if l:lnum <= 1 | break | endif
                    call cursor(l:lnum - 1, col([l:lnum - 1, '$']))
                    continue
                endif
                call insert(l:crumbs, '[' . l:type . ': ' . l:name . ']', 0)
                let l:scope_start = max([l:scope_start, l:lnum])
                let l:scope_end = min([l:scope_end, l:semi_lnum])
                let l:found_enclosing = 1
                break
            endif

            " Check end of block
            let l:encloses = 0
            if l:type =~# '^\%(module\|task\|function\|interface\|package\)$' || (l:type ==# 'class' && !l:is_py)
                let l:end_pat = '^\s*end' . l:type . '\>'
                call cursor(l:lnum, 1)
                let l:end_lnum = search(l:end_pat, 'nW')
                if l:end_lnum >= l:cur_lnum
                    let l:encloses = 1
                    let l:scope_start = max([l:scope_start, l:lnum])
                    let l:scope_end = min([l:scope_end, l:end_lnum])
                endif
            elseif l:is_py && (l:type ==# 'def' || l:type ==# 'class')
                let l:def_indent = indent(l:lnum)
                if l:py_max_indent < 0 || l:def_indent < l:py_max_indent
                    if l:cur_lnum == l:lnum
                        let l:encloses = 1
                    elseif l:cur_lnum > l:lnum
                        let l:closer_pat = (l:def_indent == 0) ? '^[^ \t#]' : '^\%( \{0,' . l:def_indent . '}\|\t\{0,' . (l:def_indent / max([1, &tabstop])) . '}\)[^ \t#]'
                        call cursor(l:lnum + 1, 1)
                        let l:closed_lnum = search(l:closer_pat, 'cnW', l:cur_lnum)
                        if l:closed_lnum == 0
                            let l:cur_line = getline(l:cur_lnum)
                            if l:cur_line =~# '^\s*$' || l:cur_line =~# '^\s*#'
                                let l:next_nb = nextnonblank(l:cur_lnum)
                                if (l:next_nb > 0 && indent(l:next_nb) <= l:def_indent) || (l:next_nb == 0 && l:cur_lnum > prevnonblank(l:cur_lnum) + 1)
                                    let l:encloses = 0
                                else
                                    let l:encloses = 1
                                endif
                            else
                                let l:encloses = 1
                            endif
                        endif
                    endif
                endif
                if l:encloses
                    let l:scope_start = max([l:scope_start, l:lnum])
                    call cursor(l:cur_lnum, 1)
                    let l:closer_pat = (l:def_indent == 0) ? '^[^ \t#]' : '^\%( \{0,' . l:def_indent . '}\|\t\{0,' . (l:def_indent / max([1, &tabstop])) . '}\)[^ \t#]'
                    let l:next_closer = search(l:closer_pat, 'nW')
                    if l:next_closer > l:cur_lnum
                        let l:scope_end = min([l:scope_end, l:next_closer - 1])
                    endif
                endif
            endif

            if l:encloses
                let l:found_enclosing = 1
                let l:item = '[' . l:type . ': ' . l:name . ']'
                call insert(l:crumbs, l:item, 0)
                if l:is_py && (l:type ==# 'def' || l:type ==# 'class')
                    let l:py_max_indent = l:def_indent
                    if l:def_indent == 0
                        break
                    endif
                endif
                " Outer container reached, finish hierarchy
                if l:type =~# '^\%(module\|package\|interface\)$'
                    break
                endif
            endif
        endif

        " Optimization for SV: once routine (task/function) is seen, only search for containers
        if l:is_sv && l:seen_routine
            let l:search_pat = '^\s*\%(virtual\s\+\|static\s\+\)*\%(module\|class\|interface\|package\)\>'
        endif

        if l:lnum <= 1
            break
        endif
        call cursor(l:lnum - 1, col([l:lnum - 1, '$']))
    endwhile

    call setpos('.', l:save_pos)
    let l:result = join(l:crumbs, ' > ')

    " Save cache with range and line
    let b:cached_scope_tick = l:tick
    let b:cached_scope_result = l:result
    let b:cached_scope_lnum = l:cur_lnum
    if l:found_enclosing || l:proc_lnum > 0
        let b:cached_scope_range = [l:scope_start, l:scope_end]
    else
        let b:cached_scope_range = [l:cur_lnum, l:cur_lnum]
    endif

    return l:result
endfunction

function! BreadcrumbScope() abort
    let l:s = CurrentScope()
    return empty(l:s) ? '' : ' › ' . l:s
endfunction
