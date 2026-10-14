"=============================================================================
" Plugin: source_popup.vim
" Description: Floating Popup Source Code & Type Definition Inspector for Vim
"   - Displays type definitions (struct, union, enum, class, typedef, #define,
"     functions, SV modules/interfaces/tasks, Python classes/defs) in a syntax-
"     highlighted floating popup window at cursor.
"   - Key Mappings:
"       Normal mode: 'gp' or 'sp' -> inspect symbol under cursor
"       Visual mode: 'gp' or 'sp' -> inspect selected symbol
"   - Interactive Controls inside Popup:
"       <Esc>, 'q', <C-c> : Dismiss popup
"       <CR>, 'o', 'gd'   : Jump directly to definition in source file
"       'j' / 'k', Arrows : Scroll popup content up / down
"       <C-d> / <C-u>     : Page scroll down / up
"       Any other key     : Closes popup and executes key in Vim
"   - User Commands:
"       :ShowDef [symbol]
"       :ShowSourcePopup [symbol]
"=============================================================================

if !hlexists('CustomPopup')
    highlight CustomPopup       ctermfg=254 ctermbg=238 guifg=#e4e4e4 guibg=#2b313c
endif
if !hlexists('CustomPopupBorder')
    highlight CustomPopupBorder ctermfg=75  ctermbg=238 guifg=#5fafff guibg=#2b313c
endif

let s:active_def_popup_id = 0

"-----------------------------------------------------------------------------
" 1. Helper Functions
"-----------------------------------------------------------------------------
function! s:CountBraces(str) abort
    return [count(a:str, '{'), count(a:str, '}')]
endfunction

function! s:ExtractDocComments(lines, start_idx) abort
    let l:cur = a:start_idx - 1
    if l:cur < 0
        return a:start_idx
    endif
    let l:prev_line = a:lines[l:cur]
    if l:prev_line !~# '\v^\s*(\*|/\*|//)' && l:prev_line !~# '\*/\s*$'
        return a:start_idx
    endif
    let l:min_idx = max([0, a:start_idx - 6])
    let l:res = a:start_idx
    while l:cur >= l:min_idx
        let l:line = a:lines[l:cur]
        if l:line =~# '\v^\s*(/\*|//)'
            let l:res = l:cur
            break
        elseif l:line =~# '\v^\s*\*|^\s*\*/'
            let l:res = l:cur
            let l:cur -= 1
        else
            break
        endif
    endwhile
    return l:res
endfunction

function! s:DetectFileType(filepath) abort
    let l:ext = fnamemodify(a:filepath, ':e')
    if l:ext =~# '^\%(c\|h\)$'
        return 'c'
    elseif l:ext =~# '^\%(cpp\|cc\|cxx\|hpp\|hh\|hxx\)$'
        return 'cpp'
    elseif l:ext =~# '^\%(sv\|svh\|v\|vh\|svp\|vp\)$'
        return 'verilog_systemverilog'
    elseif l:ext ==# 'py'
        return 'python'
    elseif l:ext ==# 'vim'
        return 'vim'
    elseif l:ext =~# '^\%(sh\|bash\)$'
        return 'sh'
    endif
    return ''
endfunction

"-----------------------------------------------------------------------------
" 2. Definition Search & Extraction in File Lines
"-----------------------------------------------------------------------------
function! s:SearchInLines(lines, symbol, filepath) abort
    let l:sym = a:symbol
    let l:nlines = len(a:lines)
    if l:nlines == 0
        return {}
    endif

    " Fallback prototype placeholder if encountered before full definition
    let l:proto_res = {}

    " 1. Typedef struct / union / enum ending with: } <symbol>;
    " e.g. '} granule_config_t;' or '} granule_config_t, *granule_config_p;'
    let l:pat_typedef_close = '\v\}\s*([A-Za-z0-9_]+\s*,\s*)*<' . l:sym . '>\s*;'
    for l:i in range(0, l:nlines - 1)
        if a:lines[l:i] =~# l:pat_typedef_close
            let l:end_idx = l:i
            let l:brace_count = 1
            let l:start_idx = l:i
            for l:j in range(l:i - 1, max([0, l:i - 120]), -1)
                let l:line = a:lines[l:j]
                let [l:open_cnt, l:close_cnt] = s:CountBraces(l:line)
                let l:brace_count += (l:close_cnt - l:open_cnt)
                if l:brace_count <= 0 && l:line =~# '\v<typedef>\s+(struct|union|enum)>'
                    let l:start_idx = l:j
                    break
                elseif l:brace_count <= 0 && l:line =~# '{'
                    if l:j > 0 && a:lines[l:j - 1] =~# '\v<typedef>\s+(struct|union|enum)>'
                        let l:start_idx = l:j - 1
                    else
                        let l:start_idx = l:j
                    endif
                    break
                endif
            endfor
            let l:doc_start = s:ExtractDocComments(a:lines, l:start_idx)
            return {
                \ 'symbol': l:sym,
                \ 'filepath': a:filepath,
                \ 'def_line': l:start_idx + 1,
                \ 'start_line': l:doc_start + 1,
                \ 'end_line': l:end_idx + 1,
                \ 'lines': a:lines[l:doc_start : l:end_idx],
            \ }
        endif
    endfor

    " 2. Named struct / union / enum / class:
    " e.g. 'struct granule_config {' or 'class uvm_sequence_item'
    let l:pat_struct_open = '\v^\s*(typedef\s+)?(struct|union|enum|class)\s+<' . l:sym . '>'
    for l:i in range(0, l:nlines - 1)
        let l:line = a:lines[l:i]
        if l:line =~# l:pat_struct_open
            let l:start_idx = l:i
            " Check if forward declaration ending with ';' without '{'
            if l:line =~# ';\s*$' && l:line !~# '{'
                if empty(l:proto_res)
                    let l:proto_res = {
                        \ 'symbol': l:sym,
                        \ 'filepath': a:filepath,
                        \ 'def_line': l:start_idx + 1,
                        \ 'start_line': l:start_idx + 1,
                        \ 'end_line': l:start_idx + 1,
                        \ 'lines': a:lines[l:start_idx : l:start_idx],
                        \ 'is_prototype': 1,
                    \ }
                endif
                continue
            endif

            " SystemVerilog class
            if l:line =~# '\v^\s*class\s+'
                let l:end_idx = min([l:nlines - 1, l:i + 45])
                for l:j in range(l:i + 1, min([l:nlines - 1, l:i + 60]))
                    if a:lines[l:j] =~# '\v^\s*endclass\b'
                        let l:end_idx = l:j
                        break
                    endif
                endfor
                let l:doc_start = s:ExtractDocComments(a:lines, l:start_idx)
                return {
                    \ 'symbol': l:sym,
                    \ 'filepath': a:filepath,
                    \ 'def_line': l:start_idx + 1,
                    \ 'start_line': l:doc_start + 1,
                    \ 'end_line': l:end_idx + 1,
                    \ 'lines': a:lines[l:doc_start : l:end_idx],
                \ }
            endif

            " C/C++ struct/union/enum with braces
            let l:brace_count = 0
            let l:found_open = 0
            let l:end_idx = min([l:nlines - 1, l:i + 45])
            for l:j in range(l:i, min([l:nlines - 1, l:i + 100]))
                let l:cur = a:lines[l:j]
                let [l:open_cnt, l:close_cnt] = s:CountBraces(l:cur)
                if l:open_cnt > 0 | let l:found_open = 1 | endif
                let l:brace_count += (l:open_cnt - l:close_cnt)
                if l:found_open && l:brace_count <= 0
                    let l:end_idx = l:j
                    break
                endif
            endfor
            let l:doc_start = s:ExtractDocComments(a:lines, l:start_idx)
            return {
                \ 'symbol': l:sym,
                \ 'filepath': a:filepath,
                \ 'def_line': l:start_idx + 1,
                \ 'start_line': l:doc_start + 1,
                \ 'end_line': l:end_idx + 1,
                \ 'lines': a:lines[l:doc_start : l:end_idx],
            \ }
        endif
    endfor

    " 3. Single-line typedef:
    " e.g. 'typedef uint64_t granule_size_t;' or 'typedef void (*callback_t)(int);'
    let l:pat_typedef_single = '\v^\s*typedef\s+[^;]*<' . l:sym . '>\s*;'
    for l:i in range(0, l:nlines - 1)
        if a:lines[l:i] =~# l:pat_typedef_single
            let l:doc_start = s:ExtractDocComments(a:lines, l:i)
            return {
                \ 'symbol': l:sym,
                \ 'filepath': a:filepath,
                \ 'def_line': l:i + 1,
                \ 'start_line': l:doc_start + 1,
                \ 'end_line': l:i + 1,
                \ 'lines': a:lines[l:doc_start : l:i],
            \ }
        endif
    endfor

    " 4. Macro definition:
    " e.g. '#define MMU_PAGE_POOL_SIZE ...' or '`define RESET_CYCLES ...'
    let l:pat_define = '\v^\s*(#|`)define\s+<' . l:sym . '>'
    for l:i in range(0, l:nlines - 1)
        if a:lines[l:i] =~# l:pat_define
            let l:start_idx = l:i
            let l:end_idx = l:i
            while l:end_idx < l:nlines - 1 && a:lines[l:end_idx] =~# '\\\s*$'
                let l:end_idx += 1
            endwhile
            let l:doc_start = s:ExtractDocComments(a:lines, l:start_idx)
            return {
                \ 'symbol': l:sym,
                \ 'filepath': a:filepath,
                \ 'def_line': l:start_idx + 1,
                \ 'start_line': l:doc_start + 1,
                \ 'end_line': l:end_idx + 1,
                \ 'lines': a:lines[l:doc_start : l:end_idx],
            \ }
        endif
    endfor

    " 5. SystemVerilog module / interface / package:
    let l:pat_sv_block = '\v^\s*(module|interface|package)\s+<' . l:sym . '>'
    for l:i in range(0, l:nlines - 1)
        if a:lines[l:i] =~# l:pat_sv_block
            let l:start_idx = l:i
            let l:end_idx = min([l:nlines - 1, l:i + 35])
            let l:block_type = matchstr(a:lines[l:i], '\v(module|interface|package)')
            for l:j in range(l:i + 1, min([l:nlines - 1, l:i + 60]))
                if a:lines[l:j] =~# '\v^\s*end' . l:block_type . '\b'
                    let l:end_idx = l:j
                    break
                endif
            endfor
            let l:doc_start = s:ExtractDocComments(a:lines, l:start_idx)
            return {
                \ 'symbol': l:sym,
                \ 'filepath': a:filepath,
                \ 'def_line': l:start_idx + 1,
                \ 'start_line': l:doc_start + 1,
                \ 'end_line': l:end_idx + 1,
                \ 'lines': a:lines[l:doc_start : l:end_idx],
            \ }
        endif
    endfor

    " 6. SystemVerilog task / function:
    let l:pat_sv_sub = '\v^\s*(task|function)\s+.*<' . l:sym . '>'
    for l:i in range(0, l:nlines - 1)
        if a:lines[l:i] =~# l:pat_sv_sub
            let l:start_idx = l:i
            let l:end_idx = min([l:nlines - 1, l:i + 30])
            let l:sub_type = matchstr(a:lines[l:i], '\v(task|function)')
            for l:j in range(l:i + 1, min([l:nlines - 1, l:i + 50]))
                if a:lines[l:j] =~# '\v^\s*end' . l:sub_type . '\b'
                    let l:end_idx = l:j
                    break
                endif
            endfor
            let l:doc_start = s:ExtractDocComments(a:lines, l:start_idx)
            return {
                \ 'symbol': l:sym,
                \ 'filepath': a:filepath,
                \ 'def_line': l:start_idx + 1,
                \ 'start_line': l:doc_start + 1,
                \ 'end_line': l:end_idx + 1,
                \ 'lines': a:lines[l:doc_start : l:end_idx],
            \ }
        endif
    endfor

    " 7. Python class / def:
    let l:pat_py = '\v^\s*(class|def)\s+<' . l:sym . '>'
    for l:i in range(0, l:nlines - 1)
        if a:lines[l:i] =~# l:pat_py
            let l:start_idx = l:i
            let l:base_indent = len(matchstr(a:lines[l:i], '^\s*'))
            let l:end_idx = l:i
            for l:j in range(l:i + 1, min([l:nlines - 1, l:i + 35]))
                let l:trimmed = substitute(a:lines[l:j], '^\s*\|\s*$', '', 'g')
                if empty(l:trimmed)
                    let l:end_idx = l:j
                    continue
                endif
                let l:cur_indent = len(matchstr(a:lines[l:j], '^\s*'))
                if l:cur_indent > l:base_indent
                    let l:end_idx = l:j
                else
                    break
                endif
            endfor
            let l:doc_start = s:ExtractDocComments(a:lines, l:start_idx)
            return {
                \ 'symbol': l:sym,
                \ 'filepath': a:filepath,
                \ 'def_line': l:start_idx + 1,
                \ 'start_line': l:doc_start + 1,
                \ 'end_line': l:end_idx + 1,
                \ 'lines': a:lines[l:doc_start : l:end_idx],
            \ }
        endif
    endfor

    " 8. C/C++ Function definition or prototype:
    let l:pat_c_func = '\v^\s*(static\s+|extern\s+|inline\s+|virtual\s+)*([A-Za-z0-9_*&]+\s+)+[*&]*<' . l:sym . '>\s*\('
    for l:i in range(0, l:nlines - 1)
        if a:lines[l:i] =~# l:pat_c_func
            let l:start_idx = l:i
            let l:has_brace = 0
            let l:end_idx = l:i
            for l:j in range(l:i, min([l:nlines - 1, l:i + 15]))
                if a:lines[l:j] =~# '{'
                    let l:has_brace = 1
                    let l:start_brace = l:j
                    break
                elseif a:lines[l:j] =~# ';\s*$'
                    let l:end_idx = l:j
                    break
                endif
            endfor
            if l:has_brace
                let l:brace_count = 0
                let l:end_idx = min([l:nlines - 1, l:start_brace + 40])
                for l:j in range(l:start_brace, min([l:nlines - 1, l:start_brace + 80]))
                    let [l:open_cnt, l:close_cnt] = s:CountBraces(a:lines[l:j])
                    let l:brace_count += (l:open_cnt - l:close_cnt)
                    if l:brace_count <= 0
                        let l:end_idx = l:j
                        break
                    endif
                endfor
                let l:doc_start = s:ExtractDocComments(a:lines, l:start_idx)
                return {
                    \ 'symbol': l:sym,
                    \ 'filepath': a:filepath,
                    \ 'def_line': l:start_idx + 1,
                    \ 'start_line': l:doc_start + 1,
                    \ 'end_line': l:end_idx + 1,
                    \ 'lines': a:lines[l:doc_start : l:end_idx],
                \ }
            else
                " Prototype declaration: save as candidate, continue searching for full body
                if empty(l:proto_res)
                    let l:doc_start = s:ExtractDocComments(a:lines, l:start_idx)
                    let l:proto_res = {
                        \ 'symbol': l:sym,
                        \ 'filepath': a:filepath,
                        \ 'def_line': l:start_idx + 1,
                        \ 'start_line': l:doc_start + 1,
                        \ 'end_line': l:end_idx + 1,
                        \ 'lines': a:lines[l:doc_start : l:end_idx],
                        \ 'is_prototype': 1,
                    \ }
                endif
            endif
        endif
    endfor

    " 9. Enum member:
    " e.g. 'MMU_GRANULE_4KB = 0,'
    let l:pat_enum_member = '\v^\s*<' . l:sym . '>\s*(\=|,|\})'
    for l:i in range(0, l:nlines - 1)
        if a:lines[l:i] =~# l:pat_enum_member
            let l:found_enum = 0
            let l:start_idx = l:i
            for l:j in range(l:i, max([0, l:i - 40]), -1)
                if a:lines[l:j] =~# '\v<enum>'
                    let l:found_enum = 1
                    let l:start_idx = l:j
                    break
                endif
            endfor
            if l:found_enum
                let l:end_idx = min([l:nlines - 1, l:i + 20])
                for l:j in range(l:i, min([l:nlines - 1, l:i + 40]))
                    if a:lines[l:j] =~# '\v\}\s*([A-Za-z0-9_]+\s*)*;'
                        let l:end_idx = l:j
                        break
                    endif
                endfor
                let l:doc_start = s:ExtractDocComments(a:lines, l:start_idx)
                return {
                    \ 'symbol': l:sym,
                    \ 'filepath': a:filepath,
                    \ 'def_line': l:start_idx + 1,
                    \ 'start_line': l:doc_start + 1,
                    \ 'end_line': l:end_idx + 1,
                    \ 'lines': a:lines[l:doc_start : l:end_idx],
                \ }
            endif
        endif
    endfor

    " 10. Variable / Constant declaration:
    " e.g. 'static granule_config_t g_granule_cfg;'
    let l:pat_var = '\v^\s*(static\s+|extern\s+|const\s+|volatile\s+)+.*<' . l:sym . '>\s*(\[[^\]]*\])?\s*(\=.*)?;'
    for l:i in range(0, l:nlines - 1)
        if a:lines[l:i] =~# l:pat_var
            let l:doc_start = s:ExtractDocComments(a:lines, l:i)
            return {
                \ 'symbol': l:sym,
                \ 'filepath': a:filepath,
                \ 'def_line': l:i + 1,
                \ 'start_line': l:doc_start + 1,
                \ 'end_line': l:i + 1,
                \ 'lines': a:lines[l:doc_start : l:i],
            \ }
        endif
    endfor

    " 11. Struct member / field declaration:
    " e.g. 'uint64_t block_l2_size;' inside a struct
    let l:pat_field = '\v^\s*([A-Za-z0-9_*&]+\s+)+<' . l:sym . '>\s*(\[[^\]]*\])?\s*(\=.*)?;\s*(/\*.*\*/|//.*)?$'
    for l:i in range(0, l:nlines - 1)
        if a:lines[l:i] =~# l:pat_field
            let l:doc_start = s:ExtractDocComments(a:lines, l:i)
            return {
                \ 'symbol': l:sym,
                \ 'filepath': a:filepath,
                \ 'def_line': l:i + 1,
                \ 'start_line': l:doc_start + 1,
                \ 'end_line': l:i + 1,
                \ 'lines': a:lines[l:doc_start : l:i],
            \ }
        endif
    endfor

    if !empty(l:proto_res)
        return l:proto_res
    endif

    return {}
endfunction

"-----------------------------------------------------------------------------
" 3. Multi-File Search Pipeline
"-----------------------------------------------------------------------------
function! s:FindIncludeFiles(lines, cur_dir) abort
    let l:inc_files = []
    for l:line in a:lines
        " C/C++: #include "header.h"
        let l:m = matchlist(l:line, '\v^\s*#\s*include\s*["<]([^">]+)[">]')
        if empty(l:m)
            " Verilog/SystemVerilog: `include "header.svh"
            let l:m = matchlist(l:line, '\v^\s*`\s*include\s*["<]([^">]+)[">]')
        endif
        if !empty(l:m) && !empty(l:m[1])
            let l:name = l:m[1]
            let l:candidates = [
                \ a:cur_dir . '/' . l:name,
                \ a:cur_dir . '/include/' . l:name,
                \ a:cur_dir . '/../include/' . l:name,
                \ a:cur_dir . '/inc/' . l:name,
                \ a:cur_dir . '/../inc/' . l:name,
            \ ]
            let l:found_inc = 0
            for l:c in l:candidates
                let l:full = fnamemodify(l:c, ':p')
                if filereadable(l:full) && index(l:inc_files, l:full) == -1
                    call add(l:inc_files, l:full)
                    let l:found_inc = 1
                    break
                endif
            endfor
            if !l:found_inc
                for l:pat in [
                    \ a:cur_dir . '/../../drivers/**/' . l:name,
                    \ a:cur_dir . '/../drivers/**/' . l:name,
                    \ a:cur_dir . '/../../include/**/' . l:name,
                    \ a:cur_dir . '/../include/**/' . l:name,
                    \ a:cur_dir . '/../../inc/**/' . l:name,
                    \ a:cur_dir . '/../inc/**/' . l:name,
                \ ]
                    let l:globbed = glob(l:pat, 0, 1)
                    if !empty(l:globbed)
                        let l:found_path = fnamemodify(l:globbed[0], ':p')
                        if filereadable(l:found_path) && index(l:inc_files, l:found_path) == -1
                            call add(l:inc_files, l:found_path)
                            break
                        endif
                    endif
                endfor
            endif
        endif
    endfor
    return l:inc_files
endfunction

function! s:IsSourceFile(filepath) abort
    return a:filepath =~# '\v\.(c|cpp|cc|cxx|sv|v)$'
endfunction

function! s:SortTagsBySourcePriority(t1, t2) abort
    let l:s1 = s:IsSourceFile(get(a:t1, 'filename', ''))
    let l:s2 = s:IsSourceFile(get(a:t2, 'filename', ''))
    if l:s1 && !l:s2
        return -1
    elseif !l:s1 && l:s2
        return 1
    endif
    return 0
endfunction

function! s:FindCompanionFiles(filepath) abort
    let l:res = []
    let l:root = fnamemodify(a:filepath, ':r')
    let l:ext = fnamemodify(a:filepath, ':e')
    let l:dir = fnamemodify(a:filepath, ':h')
    let l:stem = fnamemodify(a:filepath, ':t:r')
    let l:parent = fnamemodify(l:dir, ':h')

    if l:ext =~# '^\%(c\|cpp\|cc\|cxx\)$'
        for l:h_ext in ['h', 'hpp', 'hh', 'hxx']
            let l:candidate = l:root . '.' . l:h_ext
            if filereadable(l:candidate) && index(l:res, l:candidate) == -1
                call add(l:res, l:candidate)
            endif
            for l:inc_dir in ['include', 'inc', '../include', '../inc']
                let l:cand = fnamemodify(l:dir . '/' . l:inc_dir . '/' . l:stem . '.' . l:h_ext, ':p')
                if filereadable(l:cand) && index(l:res, l:cand) == -1
                    call add(l:res, l:cand)
                endif
            endfor
        endfor
    elseif l:ext =~# '^\%(h\|hpp\|hh\|hxx\)$'
        for l:c_ext in ['c', 'cpp', 'cc', 'cxx']
            let l:candidate = l:root . '.' . l:c_ext
            if filereadable(l:candidate) && index(l:res, l:candidate) == -1
                call add(l:res, l:candidate)
            endif
            let l:subdirs = [
                \ l:parent . '/' . l:stem . '/' . l:stem . '.' . l:c_ext,
                \ l:parent . '/src/' . l:stem . '.' . l:c_ext,
                \ l:parent . '/source/' . l:stem . '.' . l:c_ext,
                \ l:parent . '/' . l:stem . '.' . l:c_ext,
                \ l:dir . '/../' . l:stem . '/' . l:stem . '.' . l:c_ext,
                \ l:dir . '/../src/' . l:stem . '.' . l:c_ext,
                \ l:dir . '/../drivers/' . l:stem . '/' . l:stem . '.' . l:c_ext,
                \ l:dir . '/../../drivers/' . l:stem . '/' . l:stem . '.' . l:c_ext,
                \ l:parent . '/drivers/' . l:stem . '/' . l:stem . '.' . l:c_ext,
            \ ]
            for l:c in l:subdirs
                let l:c_full = fnamemodify(l:c, ':p')
                if filereadable(l:c_full) && index(l:res, l:c_full) == -1
                    call add(l:res, l:c_full)
                endif
            endfor
            let l:module_dirs = [
                \ l:dir,
                \ l:parent . '/' . l:stem,
                \ l:dir . '/../' . l:stem,
                \ l:parent . '/src',
            \ ]
            for l:md in l:module_dirs
                let l:md_full = fnamemodify(l:md, ':p')
                if isdirectory(l:md_full)
                    for l:mf in glob(l:md_full . '/*.' . l:c_ext, 0, 1)
                        let l:mf_full = fnamemodify(l:mf, ':p')
                        if filereadable(l:mf_full) && index(l:res, l:mf_full) == -1
                            call add(l:res, l:mf_full)
                        endif
                    endfor
                endif
            endfor
        endfor
    elseif l:ext =~# '^\%(sv\|v\|vp\|svp\)$'
        for l:sv_ext in ['svh', 'vh']
            let l:candidate = l:root . '.' . l:sv_ext
            if filereadable(l:candidate) && index(l:res, l:candidate) == -1
                call add(l:res, l:candidate)
            endif
        endfor
    elseif l:ext =~# '^\%(svh\|vh\)$'
        for l:sv_ext in ['sv', 'v']
            let l:candidate = l:root . '.' . l:sv_ext
            if filereadable(l:candidate) && index(l:res, l:candidate) == -1
                call add(l:res, l:candidate)
            endif
        endfor
    endif
    return l:res
endfunction

function! s:LinearScanTagfiles(symbol) abort
    let l:tags = []
    if !exists('*tagfiles')
        return l:tags
    endif
    let l:pat_tag = '^' . a:symbol . "\t"
    for l:tf in tagfiles()
        if filereadable(l:tf)
            for l:tline in readfile(l:tf)
                if l:tline =~# l:pat_tag
                    let l:parts = split(l:tline, "\t")
                    if len(l:parts) >= 2
                        let l:tf_dir = fnamemodify(l:tf, ':h')
                        let l:target_rel = l:parts[1]
                        let l:target_full = fnamemodify(l:tf_dir . '/' . l:target_rel, ':p')
                        if filereadable(l:target_full)
                            call add(l:tags, {'filename': l:target_full})
                        endif
                    endif
                endif
            endfor
        endif
    endfor
    return l:tags
endfunction

function! s:FindDefinition(symbol, cur_bufnr) abort
    let l:sym = a:symbol
    let l:cur_file = expand('#' . a:cur_bufnr . ':p')
    if empty(l:cur_file)
        let l:cur_file = expand('%:p')
    endif
    let l:cur_dir = fnamemodify(l:cur_file, ':h')

    let l:proto_fallback = {}
    let l:checked_files = {}

    " 1. Search in current buffer first
    let l:cur_lines = getbufline(a:cur_bufnr, 1, '$')
    let l:res = s:SearchInLines(l:cur_lines, l:sym, l:cur_file)
    if !empty(l:res)
        if !get(l:res, 'is_prototype', 0)
            return l:res
        endif
        let l:proto_fallback = l:res
    endif

    if !empty(l:cur_file)
        let l:checked_files[l:cur_file] = 1
    endif

    " 2. Search companion header/source files (e.g. .c for .h, or .h for .c)
    let l:companion_files = s:FindCompanionFiles(l:cur_file)
    for l:comp in l:companion_files
        if has_key(l:checked_files, l:comp) || !filereadable(l:comp)
            continue
        endif
        let l:checked_files[l:comp] = 1
        let l:lines = readfile(l:comp)
        let l:res = s:SearchInLines(l:lines, l:sym, l:comp)
        if !empty(l:res)
            if !get(l:res, 'is_prototype', 0)
                return l:res
            elseif empty(l:proto_fallback)
                let l:proto_fallback = l:res
            endif
        endif
    endfor

    " 3. Search included files: ALWAYS prioritize companion source files (.c, .cpp) before headers (.h)
    let l:inc_files = s:FindIncludeFiles(l:cur_lines, l:cur_dir)
    for l:inc in l:inc_files
        " Prioritize companion source files (.c, .cpp) FIRST
        let l:companion_sources = s:FindCompanionFiles(l:inc)
        for l:c_src in l:companion_sources
            if !has_key(l:checked_files, l:c_src) && filereadable(l:c_src)
                let l:checked_files[l:c_src] = 1
                let l:c_lines = readfile(l:c_src)
                let l:c_res = s:SearchInLines(l:c_lines, l:sym, l:c_src)
                if !empty(l:c_res)
                    if !get(l:c_res, 'is_prototype', 0)
                        return l:c_res
                    elseif empty(l:proto_fallback)
                        let l:proto_fallback = l:c_res
                    endif
                endif
            endif
        endfor

        " Then search the included header file itself (.h, .hpp)
        if !has_key(l:checked_files, l:inc) && filereadable(l:inc)
            let l:checked_files[l:inc] = 1
            let l:lines = readfile(l:inc)
            let l:res = s:SearchInLines(l:lines, l:sym, l:inc)
            if !empty(l:res)
                if !get(l:res, 'is_prototype', 0)
                    return l:res
                elseif empty(l:proto_fallback)
                    let l:proto_fallback = l:res
                endif
            endif
        endif
    endfor

    " 4. Search other open buffers in Vim (prioritizing source files)
    let l:open_src_buffers = []
    let l:open_hdr_buffers = []
    for l:b in range(1, bufnr('$'))
        if buflisted(l:b) && l:b != a:cur_bufnr
            let l:b_file = expand('#' . l:b . ':p')
            if !empty(l:b_file) && !has_key(l:checked_files, l:b_file)
                if s:IsSourceFile(l:b_file)
                    call add(l:open_src_buffers, [l:b, l:b_file])
                else
                    call add(l:open_hdr_buffers, [l:b, l:b_file])
                endif
            endif
        endif
    endfor
    for [l:b, l:b_file] in (l:open_src_buffers + l:open_hdr_buffers)
        let l:checked_files[l:b_file] = 1
        let l:b_lines = getbufline(l:b, 1, '$')
        let l:res = s:SearchInLines(l:b_lines, l:sym, l:b_file)
        if !empty(l:res)
            if !get(l:res, 'is_prototype', 0)
                return l:res
            elseif empty(l:proto_fallback)
                let l:proto_fallback = l:res
            endif
        endif
    endfor

    " 5. Search source files in directory and project driver trees
    if !empty(l:cur_dir) && isdirectory(l:cur_dir)
        " 5a. Check .c source files in current directory first
        for l:df in glob(l:cur_dir . '/*.{c,cpp}', 0, 1)
            if !has_key(l:checked_files, l:df) && filereadable(l:df)
                let l:checked_files[l:df] = 1
                let l:res = s:SearchInLines(readfile(l:df), l:sym, l:df)
                if !empty(l:res)
                    if !get(l:res, 'is_prototype', 0)
                        return l:res
                    elseif empty(l:proto_fallback)
                        let l:proto_fallback = l:res
                    endif
                endif
            endif
        endfor

        " 5b. Check modular driver source trees (e.g. drivers/*/*.c or src/*.c)
        for l:drv_pat in [
            \ l:cur_dir . '/../../drivers/*/*.c',
            \ l:cur_dir . '/../drivers/*/*.c',
            \ l:cur_dir . '/../../src/*.c',
            \ l:cur_dir . '/../src/*.c',
        \ ]
            for l:drv_c in glob(l:drv_pat, 0, 1)
                let l:drv_full = fnamemodify(l:drv_c, ':p')
                if !has_key(l:checked_files, l:drv_full) && filereadable(l:drv_full)
                    let l:checked_files[l:drv_full] = 1
                    let l:res = s:SearchInLines(readfile(l:drv_full), l:sym, l:drv_full)
                    if !empty(l:res)
                        if !get(l:res, 'is_prototype', 0)
                            return l:res
                        elseif empty(l:proto_fallback)
                            let l:proto_fallback = l:res
                        endif
                    endif
                endif
            endfor
        endfor

        " 5c. Check header files in current directory
        let l:dir_headers = glob(l:cur_dir . '/*.{h,hpp,svh,inc}', 0, 1)
        for l:dh in l:dir_headers
            if !has_key(l:checked_files, l:dh) && filereadable(l:dh)
                let l:checked_files[l:dh] = 1
                let l:lines = readfile(l:dh)
                let l:res = s:SearchInLines(l:lines, l:sym, l:dh)
                if !empty(l:res)
                    if !get(l:res, 'is_prototype', 0)
                        return l:res
                    elseif empty(l:proto_fallback)
                        let l:proto_fallback = l:res
                    endif
                endif
            endif
        endfor
    endif

    " 6. Taglist fallback if tags exist
    let l:tags = []
    if exists('*taglist')
        try
            let l:tags = taglist('^' . escape(l:sym, '\^$*[]~') . '$')
        catch /^Vim\%((\a\+)\)\=:E432/
            let l:tags = s:LinearScanTagfiles(l:sym)
        catch
            let l:tags = s:LinearScanTagfiles(l:sym)
        endtry

        if empty(l:tags)
            let l:tags = s:LinearScanTagfiles(l:sym)
        endif

        " Prioritize .c / .cpp source files before .h header files in tag search
        call sort(l:tags, function('s:SortTagsBySourcePriority'))

        let l:all_tagfiles = exists('*tagfiles') ? tagfiles() : []
        for l:t in l:tags
            let l:raw_path = get(l:t, 'filename', '')
            if empty(l:raw_path)
                continue
            endif
            let l:t_file = ''
            if filereadable(l:raw_path)
                let l:t_file = fnamemodify(l:raw_path, ':p')
            else
                for l:tf in l:all_tagfiles
                    let l:cand = fnamemodify(fnamemodify(l:tf, ':h') . '/' . l:raw_path, ':p')
                    if filereadable(l:cand)
                        let l:t_file = l:cand
                        break
                    endif
                endfor
            endif

            if !empty(l:t_file) && filereadable(l:t_file) && !has_key(l:checked_files, l:t_file)
                let l:checked_files[l:t_file] = 1
                let l:t_lines = readfile(l:t_file)
                let l:res = s:SearchInLines(l:t_lines, l:sym, l:t_file)
                if !empty(l:res)
                    if !get(l:res, 'is_prototype', 0)
                        return l:res
                    elseif empty(l:proto_fallback)
                        let l:proto_fallback = l:res
                    endif
                endif
            endif
        endfor
    endif

    if !empty(l:proto_fallback)
        return l:proto_fallback
    endif

    return {}
endfunction

"-----------------------------------------------------------------------------
" 4. Floating Popup Window Display & Filter
"-----------------------------------------------------------------------------
function! s:OnPopupClosed(winid, result) abort
    let s:active_def_popup_id = 0
endfunction

function! s:IsEditorWindow(winnr) abort
    let l:buf = winbufnr(a:winnr)
    let l:ft = getbufvar(l:buf, '&filetype')
    let l:bt = getbufvar(l:buf, '&buftype')
    if l:ft =~# '^\%(nerdtree\|tagbar\|qf\|startify\)$'
        return 0
    endif
    if l:bt =~# '^\%(terminal\|nofile\|quickfix\|prompt\)$'
        return 0
    endif
    return 1
endfunction

function! s:OpenInRightPanel(filepath, line) abort
    let l:target_file = fnamemodify(a:filepath, ':p')
    let l:target_line = a:line
    let l:orig_win = winnr()

    " Check if there is an existing editor window to the right
    wincmd l
    let l:right_win = winnr()

    if l:right_win != l:orig_win && s:IsEditorWindow(l:right_win)
        " Use existing editor window to the right
    else
        execute l:orig_win . 'wincmd w'
        wincmd h
        let l:left_win = winnr()
        execute l:orig_win . 'wincmd w'

        if l:left_win != l:orig_win && s:IsEditorWindow(l:left_win)
            " Current window is already the right panel
        else
            " Single editor window: split vertically to the right
            rightbelow vsplit
        endif
    endif

    if expand('%:p') !=# l:target_file
        execute 'edit ' . fnameescape(l:target_file)
    endif
    execute l:target_line
    normal! zz
    echohl Directory | echo l:target_file . ':' . l:target_line | echohl None
endfunction

function! s:PopupFilter(winid, key) abort
    " Dismiss popup (q, Esc, Ctrl-C, x, or p)
    if a:key ==# 'q' || a:key ==# "\<Esc>" || a:key ==# "\<C-c>" || a:key ==# 'x' || a:key ==# 'p'
        call popup_close(a:winid)
        return 1
    " Jump to definition in right panel
    elseif a:key ==# "\<CR>" || a:key ==# 'o' || a:key ==# 'gd'
        let l:meta = getwinvar(a:winid, 'def_meta', {})
        call popup_close(a:winid)
        if !empty(l:meta) && has_key(l:meta, 'file') && has_key(l:meta, 'line')
            call s:OpenInRightPanel(l:meta.file, l:meta.line)
        endif
        return 1
    " Scroll Down 1 line
    elseif a:key ==# 'j' || a:key ==# "\<Down>" || a:key ==# "\<ScrollWheelDown>"
        let l:pos = popup_getpos(a:winid)
        let l:firstline = get(l:pos, 'firstline', 1)
        let l:totallines = line('$', a:winid)
        if l:firstline < l:totallines
            call popup_setoptions(a:winid, {'firstline': l:firstline + 1})
        endif
        return 1
    " Scroll Up 1 line
    elseif a:key ==# 'k' || a:key ==# "\<Up>" || a:key ==# "\<ScrollWheelUp>"
        let l:pos = popup_getpos(a:winid)
        let l:firstline = get(l:pos, 'firstline', 1)
        if l:firstline > 1
            call popup_setoptions(a:winid, {'firstline': l:firstline - 1})
        endif
        return 1
    " Half page down
    elseif a:key ==# 'd' || a:key ==# "\<C-d>" || a:key ==# "\<PageDown>"
        let l:pos = popup_getpos(a:winid)
        let l:firstline = get(l:pos, 'firstline', 1)
        let l:totallines = line('$', a:winid)
        let l:step = max([1, get(l:pos, 'height', 10) / 2])
        call popup_setoptions(a:winid, {'firstline': min([l:firstline + l:step, l:totallines])})
        return 1
    " Half page up
    elseif a:key ==# 'u' || a:key ==# "\<C-u>" || a:key ==# "\<PageUp>"
        let l:pos = popup_getpos(a:winid)
        let l:firstline = get(l:pos, 'firstline', 1)
        let l:step = max([1, get(l:pos, 'height', 10) / 2])
        call popup_setoptions(a:winid, {'firstline': max([1, l:firstline - l:step])})
        return 1
    " Full page down
    elseif a:key ==# "\<C-f>" || a:key ==# ' '
        let l:pos = popup_getpos(a:winid)
        let l:firstline = get(l:pos, 'firstline', 1)
        let l:totallines = line('$', a:winid)
        let l:step = max([1, get(l:pos, 'height', 10) - 2])
        call popup_setoptions(a:winid, {'firstline': min([l:firstline + l:step, l:totallines])})
        return 1
    " Full page up
    elseif a:key ==# "\<C-b>"
        let l:pos = popup_getpos(a:winid)
        let l:firstline = get(l:pos, 'firstline', 1)
        let l:step = max([1, get(l:pos, 'height', 10) - 2])
        call popup_setoptions(a:winid, {'firstline': max([1, l:firstline - l:step])})
        return 1
    " Jump to top of popup
    elseif a:key ==# 'g' || a:key ==# "\<Home>"
        call popup_setoptions(a:winid, {'firstline': 1})
        return 1
    " Jump to bottom of popup
    elseif a:key ==# 'G' || a:key ==# "\<End>"
        let l:totallines = line('$', a:winid)
        call popup_setoptions(a:winid, {'firstline': l:totallines})
        return 1
    endif

    " Hold popup: do NOT close on idle events, mouse movement, or other keys
    return 1
endfunction

function! s:DisplayPopup(res) abort
    if !has('popupwin')
        " Fallback if popupwin is not available
        echo '=== ' . a:res.symbol . ' [' . a:res.filepath . ':' . a:res.def_line . '] ==='
        for l:l in a:res.lines
            echo l:l
        endfor
        return
    endif

    " Close any existing definition popup
    if exists('s:active_def_popup_id') && s:active_def_popup_id > 0
        silent! call popup_close(s:active_def_popup_id)
        let s:active_def_popup_id = 0
    endif

    let l:full_path = a:res.filepath . ':' . a:res.def_line
    let l:win_maxwidth = min([&columns - 4, 160])

    let l:hint = ' (q: close | <CR>: jump right) '
    let l:title = ' ' . a:res.symbol . ' [' . l:full_path . '] ' . l:hint
    if len(l:title) > l:win_maxwidth
        let l:hint = ' (q | <CR>) '
        let l:title = ' ' . a:res.symbol . ' [' . l:full_path . '] ' . l:hint
        if len(l:title) > l:win_maxwidth
            let l:title = ' ' . a:res.symbol . ' [' . l:full_path . '] '
        endif
    endif

    let l:max_len = max(map(copy(a:res.lines), 'len(v:val)'))
    let l:title_len = len(l:title)
    let l:content_width = max([l:max_len + 4, l:title_len + 4, 60])
    let l:width = min([l:content_width, l:win_maxwidth])

    let l:opts = {
        \ 'title': l:title,
        \ 'padding': [0, 1, 0, 1],
        \ 'border': [1, 1, 1, 1],
        \ 'borderchars': ['─', '│', '─', '│', '┌', '┐', '┘', '└'],
        \ 'highlight': 'CustomPopup',
        \ 'borderhighlight': ['CustomPopupBorder'],
        \ 'maxheight': min([&lines - 6, 30]),
        \ 'maxwidth': l:win_maxwidth,
        \ 'minwidth': min([l:width, l:win_maxwidth]),
        \ 'wrap': 0,
        \ 'close': 'click',
        \ 'filter': function('s:PopupFilter'),
        \ 'callback': function('s:OnPopupClosed'),
        \ 'mapping': 0,
    \ }

    let l:winid = popup_atcursor(a:res.lines, l:opts)
    if l:winid <= 0
        return
    endif

    let s:active_def_popup_id = l:winid
    call setwinvar(l:winid, 'def_meta', {
        \ 'file': a:res.filepath,
        \ 'line': a:res.def_line,
    \ })

    " Apply syntax highlighting matching target file
    let l:ft = s:DetectFileType(a:res.filepath)
    if empty(l:ft)
        let l:ft = &filetype
    endif

    if !empty(l:ft)
        try
            call win_execute(l:winid, 'setlocal syntax=' . fnameescape(l:ft))
        catch
        endtry
    endif
    echohl Directory | echo a:res.symbol . ': ' . a:res.filepath . ':' . a:res.def_line | echohl None
endfunction

"-----------------------------------------------------------------------------
" 5. Public API & Entry Points
"-----------------------------------------------------------------------------
function! s:GetVisualSelection() abort
    let [l:line_start, l:column_start] = getpos("'<")[1:2]
    let [l:line_end, l:column_end] = getpos("'>")[1:2]
    let l:lines = getline(l:line_start, l:line_end)
    if empty(l:lines)
        return ''
    endif
    let l:lines[-1] = l:lines[-1][: l:column_end - 1]
    let l:lines[0] = l:lines[0][l:column_start - 1 :]
    return substitute(join(l:lines, "\n"), '^\s*\|\s*$', '', 'g')
endfunction

function! ShowSourcePopupVisual() abort
    return ShowSourcePopup(s:GetVisualSelection())
endfunction

function! ShowSourcePopup(...) abort
    " Toggle: If popup is already active and visible, pressing gp/sp closes it
    if exists('s:active_def_popup_id') && s:active_def_popup_id > 0
        let l:pos = popup_getpos(s:active_def_popup_id)
        if get(l:pos, 'visible', 0)
            call popup_close(s:active_def_popup_id)
            let s:active_def_popup_id = 0
            return
        endif
    endif

    let l:sym = ''
    if a:0 > 0 && !empty(a:1)
        let l:sym = a:1
    elseif mode() =~# '^[vV\x16]'
        let l:sym = s:GetVisualSelection()
    else
        let l:sym = expand('<cword>')
    endif

    if empty(l:sym)
        echohl WarningMsg | echo "ShowSourcePopup: No symbol under cursor" | echohl None
        return
    endif

    let l:cur_bufnr = bufnr('%')
    let l:res = s:FindDefinition(l:sym, l:cur_bufnr)

    if empty(l:res) || empty(l:res.lines)
        echohl WarningMsg | echo "Definition not found for: " . l:sym | echohl None
        return
    endif

    call s:DisplayPopup(l:res)
endfunction

function! s:CompleteSymbols(ArgLead, CmdLine, CursorPos) abort
    let l:candidates = []
    if exists('*taglist')
        try
            silent! let l:tag_matches = taglist('^' . escape(a:ArgLead, '\^$*[]~'))
            for l:t in l:tag_matches
                if index(l:candidates, l:t.name) == -1
                    call add(l:candidates, l:t.name)
                endif
                if len(l:candidates) >= 20
                    break
                endif
            endfor
        catch
        endtry
    endif
    return l:candidates
endfunction

" User commands
command! -nargs=? -complete=customlist,s:CompleteSymbols ShowDef call ShowSourcePopup(<f-args>)
command! -nargs=? -complete=customlist,s:CompleteSymbols ShowSourcePopup call ShowSourcePopup(<f-args>)

" Plug mappings
nnoremap <silent> <Plug>(source_popup)        :call ShowSourcePopup()<CR>
vnoremap <silent> <Plug>(source_popup_visual) :<C-u>call ShowSourcePopupVisual()<CR>

" Key mappings (Normal & Visual)
nmap <silent> gp *<Plug>(source_popup)
nnoremap <silent> sp :call ShowSourcePopup()<CR>
vnoremap <silent> gp :<C-u>call ShowSourcePopupVisual()<CR>
vnoremap <silent> sp :<C-u>call ShowSourcePopupVisual()<CR>

augroup SourcePopupCleanup
    autocmd!
    autocmd BufLeave,WinLeave * if exists('s:active_def_popup_id') && s:active_def_popup_id > 0 | silent! call popup_close(s:active_def_popup_id) | let s:active_def_popup_id = 0 | endif
augroup END
