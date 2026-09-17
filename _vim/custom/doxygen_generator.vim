"=============================================================================
" Custom Module: doxygen_generator.vim
" Description: Intelligent Doxygen Comment Generator for SystemVerilog, Verilog & C/C++
"   - Commands: :Dox, :DoxAuthor, :DoxBlock
"   - Intelligently parses:
"       * SystemVerilog/Verilog: module, interface, task, function, class
"       * Extracts ports (input, output, inout), parameters (#(...)), arguments
"       * Does NOT generate fake @return for modules/tasks
"       * C/C++: functions, structs, classes, return types
"=============================================================================

if exists('g:loaded_custom_doxygen_generator')
    finish
endif
let g:loaded_custom_doxygen_generator = 1

let g:doxygen_author = get(g:, 'doxygen_author', 'tian')

function! s:StripComments(str) abort
    let l:s = substitute(a:str, '//.*$', '', '')
    let l:s = substitute(l:s, '/\*.\{-}\*/', '', 'g')
    return l:s
endfunction

function! DoxGenerate() abort
    let l:start_lnum = line('.')
    let l:indent = matchstr(getline(l:start_lnum), '^\s*')

    " Scan forward up to 40 lines to capture the full signature / header
    let l:raw = ''
    let l:lnum = l:start_lnum
    while l:lnum <= line('$') && l:lnum <= l:start_lnum + 40
        let l:line = getline(l:lnum)
        let l:clean = s:StripComments(l:line)
        let l:raw .= ' ' . l:clean
        if l:clean =~# ');' || (l:clean =~# ';' && l:raw !~# '(') || l:clean =~# '{$'
            break
        endif
        let l:lnum += 1
    endwhile

    let l:doc = []
    call add(l:doc, l:indent . '/**')

    " Case 1: SystemVerilog / Verilog module
    if l:raw =~# '\<module\>\s\+\k\+'
        let l:name = matchstr(l:raw, '\<module\>\s\+\zs\k\+\ze')
        call add(l:doc, l:indent . ' * @brief ' . l:name)

        " Parse parameters: #( ... )
        let l:param_chunk = matchstr(l:raw, '#\s*(\zs\_.\{-}\ze)\s*(')
        if !empty(l:param_chunk)
            call add(l:doc, l:indent . ' *')
            for l:it in split(l:param_chunk, ',')
                let l:pname = matchstr(l:it, '\<parameter\>\_.\{-}\zs\k\+\ze\s*=')
                if empty(l:pname)
                    let l:pname = matchstr(l:it, '\k\+\ze\s*=')
                endif
                if !empty(l:pname)
                    call add(l:doc, l:indent . printf(' * @param[param] %-12s Parameter', l:pname))
                endif
            endfor
        endif

        " Parse ports: ( ... );
        let l:ports_chunk = matchstr(l:raw, ')\s*(\zs\_.\{-}\ze)\s*;')
        if empty(l:ports_chunk)
            let l:ports_chunk = matchstr(l:raw, '(\zs\_.\{-}\ze)\s*;')
        endif
        if !empty(l:ports_chunk)
            let l:ports = []
            for l:it in split(l:ports_chunk, ',')
                let l:dir = matchstr(l:it, '\<\(input\|output\|inout\|ref\)\>')
                let l:pname = matchstr(l:it, '\k\+\ze\s*$')
                if !empty(l:pname)
                    if l:dir ==# 'output'
                        let l:tag = '@param[out]'
                    elseif l:dir ==# 'inout' || l:dir ==# 'ref'
                        let l:tag = '@param[in,out]'
                    elseif l:dir ==# 'input'
                        let l:tag = '@param[in]'
                    else
                        let l:tag = '@param'
                    endif
                    call add(l:ports, printf(' * %-15s %s', l:tag, l:pname))
                endif
            endfor
            if !empty(l:ports)
                call add(l:doc, l:indent . ' *')
                for l:p in l:ports
                    call add(l:doc, l:indent . l:p)
                endfor
            endif
        endif

    " Case 2: SystemVerilog interface
    elseif l:raw =~# '\<interface\>\s\+\k\+'
        let l:name = matchstr(l:raw, '\<interface\>\s\+\zs\k\+\ze')
        call add(l:doc, l:indent . ' * @brief Interface ' . l:name)

    " Case 3: SystemVerilog class
    elseif l:raw =~# '\<class\>\s\+\k\+'
        let l:name = matchstr(l:raw, '\<class\>\s\+\zs\k\+\ze')
        call add(l:doc, l:indent . ' * @brief Class ' . l:name)

    " Case 4: SystemVerilog task
    elseif l:raw =~# '\<task\>\s\+'
        let l:name = matchstr(l:raw, '\<task\>\s\+\%(\k\+::\)*\zs\k\+\ze')
        call add(l:doc, l:indent . ' * @brief ' . l:name)

        let l:args_chunk = matchstr(l:raw, '(\zs\_.\{-}\ze)')
        if !empty(l:args_chunk)
            call add(l:doc, l:indent . ' *')
            for l:it in split(l:args_chunk, ',')
                let l:dir = matchstr(l:it, '\<\(input\|output\|inout\|ref\)\>')
                let l:pname = matchstr(l:it, '\k\+\ze\s*$')
                if !empty(l:pname)
                    let l:tag = l:dir ==# 'output' ? '@param[out]' : (l:dir ==# 'inout' || l:dir ==# 'ref' ? '@param[in,out]' : '@param[in]')
                    call add(l:doc, l:indent . printf(' * %-15s %s', l:tag, l:pname))
                endif
            endfor
        endif

    " Case 5: SystemVerilog / C / C++ function
    elseif l:raw =~# '\<function\>\s\+' || (l:raw =~# '(' && l:raw !~# '^\s*#')
        let l:is_sv = l:raw =~# '\<function\>'
        if l:is_sv
            let l:name = matchstr(l:raw, '\<function\>\s\+\%(\k\+\s\+\)*\zs\k\+\ze\s*(')
            if empty(l:name)
                let l:name = matchstr(l:raw, '\<function\>\s\+\zs\k\+\ze')
            endif
            let l:ret = matchstr(l:raw, '\<function\>\s\+\zs\k\+\ze\s\+' . l:name)
        else
            " C/C++ function
            let l:name = matchstr(l:raw, '\zs\k\+\ze\s*(')
            let l:ret = matchstr(l:raw, '^\s*\%(static\s\+\|inline\s\+\|virtual\s\+\)*\zs\k\+\ze\s\+' . l:name)
        endif

        call add(l:doc, l:indent . ' * @brief ' . (!empty(l:name) ? l:name : ''))

        " Parse parameters
        let l:args_chunk = matchstr(l:raw, '(\zs\_.\{-}\ze)')
        if !empty(l:args_chunk)
            let l:params = []
            for l:it in split(l:args_chunk, ',')
                let l:dir = matchstr(l:it, '\<\(input\|output\|inout\|ref\)\>')
                let l:pname = matchstr(l:it, '\k\+\ze\s*\%(=[^,]*\)\?$')
                if !empty(l:pname) && l:pname !=# 'void'
                    if !empty(l:dir)
                        let l:tag = l:dir ==# 'output' ? '@param[out]' : (l:dir ==# 'inout' || l:dir ==# 'ref' ? '@param[in,out]' : '@param[in]')
                    else
                        let l:tag = '@param'
                    endif
                    call add(l:params, printf(' * %-15s %s', l:tag, l:pname))
                endif
            endfor
            if !empty(l:params)
                call add(l:doc, l:indent . ' *')
                for l:p in l:params
                    call add(l:doc, l:indent . l:p)
                endfor
            endif
        endif

        " Return value (only if not void)
        if !empty(l:ret) && l:ret !=# 'void'
            call add(l:doc, l:indent . ' * @return         ' . l:ret)
        endif

    else
        " Generic fallback docblock
        call add(l:doc, l:indent . ' * @brief ')
    endif

    call add(l:doc, l:indent . ' */')

    " Insert lines above current declaration
    call append(l:start_lnum - 1, l:doc)
    " Place cursor on the @brief line
    call cursor(l:start_lnum + 1, col('$'))
endfunction

function! DoxAuthorGenerate() abort
    let l:filename = expand('%:t')
    if empty(l:filename)
        let l:filename = 'module_or_file'
    endif
    let l:date = strftime('%Y-%m-%d')
    let l:doc = [
        \ '/**',
        \ ' * @file    ' . l:filename,
        \ ' * @brief   ',
        \ ' * @author  ' . g:doxygen_author,
        \ ' * @date    ' . l:date,
        \ ' */',
    \ ]
    call append(0, l:doc)
    call cursor(3, col('$'))
endfunction

function! DoxBlockGenerate() abort
    let l:indent = matchstr(getline('.'), '^\s*')
    let l:doc = [
        \ l:indent . '/**',
        \ l:indent . ' * @name    ',
        \ l:indent . ' * @{',
        \ l:indent . ' */',
        \ l:indent . '/* @} */',
    \ ]
    call append(line('.') - 1, l:doc)
    call cursor(line('.') - 3, col('$'))
endfunction

" Commands
command! -nargs=0 Dox       call DoxGenerate()
command! -nargs=0 DoxAuthor call DoxAuthorGenerate()
command! -nargs=0 DoxBlock  call DoxBlockGenerate()
