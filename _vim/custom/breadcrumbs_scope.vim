"=============================================================================
" Plugin: breadcrumbs_scope.vim
" Description: VS Code-like Breadcrumbs / Scope Detection on StatusLine
"   - CurrentScope() function used in statusline
"=============================================================================

function! CurrentScope() abort
    if &filetype =~# '^\%(nerdtree\|tagbar\|terminal\|log\|logfile\)$' || line('$') > 5000
        return ''
    endif
    let l:save_pos = exists('*getcurpos') ? getcurpos() : getpos('.')
    let l:cur_lnum = l:save_pos[1]

    let l:crumbs = []
    let l:proc_lnum = 0

    " 1. Check for Procedural block (SystemVerilog / Verilog: always_ff, always_comb, always_latch, always, initial, final)
    if &filetype =~# '^\%(verilog\|systemverilog\)$' || expand('%:e') =~# '^\%(v\|sv\|svh\|vh\)$' || &filetype ==# ''
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
                endif
            else
                " Single statement or header without begin
                let l:semi_lnum = search(';', 'cnW')
                if l:semi_lnum >= l:cur_lnum
                    let l:is_inside_proc = 1
                endif
            endif

            if l:is_inside_proc
                call add(l:crumbs, l:proc_name)
            else
                let l:proc_lnum = 0
            endif
        endif
    endif

    " 2. Search backwards for routine / container scopes (task, function, module, class, interface, package, def)
    let l:search_start_lnum = (l:proc_lnum > 1) ? (l:proc_lnum - 1) : l:cur_lnum
    call cursor(l:search_start_lnum, col([l:search_start_lnum, '$']))

    let l:is_python = (&filetype ==# 'python' || (&filetype ==# '' && expand('%:e') ==# 'py'))
    let l:py_max_indent = -1

    let l:search_pat = '^\s*\%(async\s\+\|virtual\s\+\|static\s\+\|protected\s\+\|local\s\+\|extern\s\+\|pure\s\+virtual\s\+\)*\%(module\|class\|interface\|package\|def\|task\|function\)\>'
    let l:name_pat = '\zs\%(\k\+\%(\s*#\s*([^)]*)\)\?::\)*\k\+\ze\s*\%([;(]\|$\)'

    let l:depth = 0
    while l:depth < 10
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
                break
            endif

            " Check end of block
            let l:encloses = 0
            if l:type =~# '^\%(module\|task\|function\|interface\|package\)$' || (l:type ==# 'class' && !l:is_python)
                let l:end_pat = '^\s*end' . l:type . '\>'
                call cursor(l:lnum, 1)
                let l:end_lnum = search(l:end_pat, 'nW')
                if l:end_lnum >= l:cur_lnum
                    let l:encloses = 1
                endif
            elseif l:is_python && (l:type ==# 'def' || l:type ==# 'class')
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
            endif

            if l:encloses
                let l:item = '[' . l:type . ': ' . l:name . ']'
                call insert(l:crumbs, l:item, 0)
                if l:is_python && (l:type ==# 'def' || l:type ==# 'class')
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

        if l:lnum <= 1
            break
        endif
        call cursor(l:lnum - 1, col([l:lnum - 1, '$']))
    endwhile

    call setpos('.', l:save_pos)
    return join(l:crumbs, ' > ')
endfunction

function! BreadcrumbScope() abort
    let l:s = CurrentScope()
    return empty(l:s) ? '' : ' › ' . l:s
endfunction
