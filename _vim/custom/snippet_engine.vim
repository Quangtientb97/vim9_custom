"=============================================================================
" Plugin: snippet_engine.vim
" Description: Clean, Lightweight Zero-Dependency Snippet Engine for Vim
"   - 100% compatible with Vim 7.4+ and Vim 8/9+
"   - Eliminates formatoptions-=cro hacks, manual <esc>, and broken autoindent
"   - Direct atomic buffer insertion with base-indent preservation
"   - Dynamic variable replacement: ${FILENAME}, ${DATETIME}, ${AUTHOR}, ${GUARD}, etc.
"   - Modern placeholders: ${1:default}, $1, and backward-compatible __f_xxx / _fill
"   - Seamless placeholder navigation (<C-j> / <C-2> / <C-k>) with high-contrast Select mode
"   - Buffer-local, leak-free snippet definitions for all filetypes
"   - Built-in interactive snippet explorer (:SnippetList)
"=============================================================================

if exists('g:loaded_snippet_engine')
    finish
endif
let g:loaded_snippet_engine = 1

"-----------------------------------------------------------------------------
" 1. Global Configuration & Defaults
"-----------------------------------------------------------------------------
let g:snippet_author = get(g:, 'snippet_author', 'Tian')
let g:snippet_email  = get(g:, 'snippet_email',  'tientq@coasia.com')

" Internal storage: s:snippets[filetype][trigger_Ent] = { body: [...], desc: '...', ft: '...' }
let s:snippets = {
    \ '_global': {}
\ }

"-----------------------------------------------------------------------------
" 2. Compatibility Helpers (Vim 7.4 Support)
"-----------------------------------------------------------------------------
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

function! s:CompareNum(a, b) abort
    let l:na = str2nr(a:a)
    let l:nb = str2nr(a:b)
    return l:na == l:nb ? 0 : (l:na > l:nb ? 1 : -1)
endfunction

"-----------------------------------------------------------------------------
" 3. Dynamic Variable Resolution
"-----------------------------------------------------------------------------
function! s:ResolveVariables(line) abort
    let l:line   = a:line
    let l:fname  = expand('%:t')
    let l:fbase  = expand('%:t:r')
    let l:fext   = expand('%:e')
    let l:author = get(g:, 'snippet_author', 'Tian')
    let l:email  = get(g:, 'snippet_email',  'tientq@coasia.com')
    let l:dt     = strftime('%Y-%m-%d %H:%M:%S')
    let l:date   = strftime('%Y-%m-%d')
    let l:time   = strftime('%H:%M:%S')
    let l:year   = strftime('%Y')
    let l:guard  = '__' . toupper(substitute(l:fname, '\.', '_', 'g')) . '__'

    let l:line = substitute(l:line, '\V${FILENAME}', l:fname, 'g')
    let l:line = substitute(l:line, '\V$FILENAME',   l:fname, 'g')
    let l:line = substitute(l:line, '\V${FILEBASE}', l:fbase, 'g')
    let l:line = substitute(l:line, '\V$FILEBASE',   l:fbase, 'g')
    let l:line = substitute(l:line, '\V${EXT}',      l:fext,  'g')
    let l:line = substitute(l:line, '\V$EXT',        l:fext,  'g')
    let l:line = substitute(l:line, '\V${AUTHOR}',   l:author,'g')
    let l:line = substitute(l:line, '\V$AUTHOR',     l:author,'g')
    let l:line = substitute(l:line, '\V${EMAIL}',    l:email, 'g')
    let l:line = substitute(l:line, '\V$EMAIL',      l:email, 'g')
    let l:line = substitute(l:line, '\V${DATETIME}', l:dt,    'g')
    let l:line = substitute(l:line, '\V$DATETIME',   l:dt,    'g')
    let l:line = substitute(l:line, '\V${DATE}',     l:date,  'g')
    let l:line = substitute(l:line, '\V$DATE',       l:date,  'g')
    let l:line = substitute(l:line, '\V${TIME}',     l:time,  'g')
    let l:line = substitute(l:line, '\V$TIME',       l:time,  'g')
    let l:line = substitute(l:line, '\V${YEAR}',     l:year,  'g')
    let l:line = substitute(l:line, '\V$YEAR',       l:year,  'g')
    let l:line = substitute(l:line, '\V${GUARD}',    l:guard, 'g')
    let l:line = substitute(l:line, '\V$GUARD',      l:guard, 'g')
    return l:line
endfunction

"-----------------------------------------------------------------------------
" 4. Snippet Registration API
"-----------------------------------------------------------------------------
" SnippetAdd(trigger, body, [opts])
"   - trigger: string, e.g. 'sv_case_Ent' or 'py_env_Ent'
"   - body: List of strings OR multiline string
"   - opts: { 'filetype': '...', 'desc': '...' }
function! snippet_engine#add(trigger, body, ...) abort
    let l:opts = a:0 > 0 ? a:1 : {}
    let l:ft   = get(l:opts, 'filetype', '_global')
    let l:desc = get(l:opts, 'desc', '')

    if !has_key(s:snippets, l:ft)
        let s:snippets[l:ft] = {}
    endif

    let l:lines = type(a:body) == 3 ? copy(a:body) : split(a:body, "\n")
    let l:data = {
        \ 'body': l:lines,
        \ 'desc': l:desc,
        \ 'ft':   l:ft,
    \ }

    " STRICT: Normalize trigger to always end with _Ent
    let l:trig_ent = a:trigger =~# '_Ent$' ? a:trigger : a:trigger . '_Ent'
    let s:snippets[l:ft][l:trig_ent] = l:data

endfunction

" Global alias for clean script definitions
function! SnippetAdd(trigger, body, ...) abort
    let l:opts = a:0 > 0 ? a:1 : {}
    call snippet_engine#add(a:trigger, a:body, l:opts)
endfunction

" Base directories
let s:custom_dir      = expand('<sfile>:p:h')
let s:snipet_base_dir = expand('<sfile>:p:h:h') . '/snipet'

" Cache tracking loaded snippet files per filetype
let s:loaded_filetypes = {}

function! snippet_engine#load_filetype(ft) abort
    if empty(a:ft) || get(s:loaded_filetypes, a:ft, 0)
        return
    endif
    let s:loaded_filetypes[a:ft] = 1

    let l:single = s:snipet_base_dir . '/' . a:ft . '.vim'
    if filereadable(l:single)
        execute 'source ' . fnameescape(l:single)
    else
        let l:root = s:snipet_base_dir . '/' . a:ft
        if isdirectory(l:root)
            for l:f in glob(l:root . '/*.vim', 1, 1)
                execute 'source ' . fnameescape(l:f)
            endfor
        endif
    endif
endfunction

function! snippet_engine#load_all() abort
    if isdirectory(s:snipet_base_dir)
        for l:f in glob(s:snipet_base_dir . '/*.vim', 1, 1)
            let l:ft = fnamemodify(l:f, ':t:r')
            call snippet_engine#load_filetype(l:ft)
        endfor
    endif
endfunction

" Check if snippet exists for current filetype or global (normalizes to _Ent)
function! snippet_engine#has(trigger) abort
    let l:ft = &filetype
    if !empty(l:ft) && !get(s:loaded_filetypes, l:ft, 0)
        call snippet_engine#load_filetype(l:ft)
    endif
    let l:t  = a:trigger =~# '_Ent$' ? a:trigger : a:trigger . '_Ent'
    if has_key(s:snippets, l:ft) && has_key(s:snippets[l:ft], l:t)
        return 1
    endif
    if has_key(s:snippets, '_global') && has_key(s:snippets['_global'], l:t)
        return 1
    endif
    if exists('b:custom_snippets') && has_key(b:custom_snippets, l:t)
        return 1
    endif
    return 0
endfunction

" Helper: fetch snippet data (normalizes to _Ent)
function! s:GetSnippet(trigger) abort
    let l:ft = &filetype
    if !empty(l:ft) && !get(s:loaded_filetypes, l:ft, 0)
        call snippet_engine#load_filetype(l:ft)
    endif
    let l:t  = a:trigger =~# '_Ent$' ? a:trigger : a:trigger . '_Ent'
    if exists('b:custom_snippets') && has_key(b:custom_snippets, l:t)
        return b:custom_snippets[l:t]
    endif
    if has_key(s:snippets, l:ft) && has_key(s:snippets[l:ft], l:t)
        return s:snippets[l:ft][l:t]
    endif
    if has_key(s:snippets, '_global') && has_key(s:snippets['_global'], l:t)
        return s:snippets['_global'][l:t]
    endif
    return {}
endfunction

"-----------------------------------------------------------------------------
" 5. Trigger Detection (Hook for <CR> in Snipet())
"-----------------------------------------------------------------------------
function! snippet_engine#check_word_before_cursor() abort
    let l:c = col('.')
    let l:line = getline('.')
    if l:c <= 1 && mode() =~# '^[iR]'
        return ''
    endif
    let l:pre = mode() =~# '^[iR]' ? (l:c > 1 ? l:line[0 : l:c - 2] : '') : l:line[0 : l:c - 1]
    let l:word = matchstr(l:pre, '[_a-zA-Z0-9]\+$')
    " STRICT: Must end with _Ent to be identified as a snippet trigger
    if empty(l:word) || l:word !~# '_Ent$'
        return ''
    endif
    if snippet_engine#has(l:word)
        return l:word
    endif
    return ''
endfunction

"-----------------------------------------------------------------------------
" 6. Snippet Expansion Engine (Direct Buffer Insertion)
"-----------------------------------------------------------------------------
function! snippet_engine#expand(trigger) abort
    let l:cur_line_nr = line('.')
    let l:line_str    = getline(l:cur_line_nr)
    let l:cur_col     = col('.')

    let l:entry = s:GetSnippet(a:trigger)
    if empty(l:entry)
        return 0
    endif

    " 1. Strip trigger word from current line
    let l:pat = '\V' . a:trigger . '\$'
    let l:head = l:cur_col > 0 ? l:line_str[0 : l:cur_col - 1] : ''
    if l:head =~# l:pat
        let l:pre_text = substitute(l:head, l:pat, '', '')
        let l:post_text = l:line_str[l:cur_col : ]
    else
        let l:idx = strridx(l:line_str, a:trigger)
        if l:idx >= 0
            let l:pre_text = l:idx > 0 ? l:line_str[0 : l:idx - 1] : ''
            let l:post_text = l:line_str[l:idx + len(a:trigger) : ]
        else
            let l:pre_text = l:line_str
            let l:post_text = ''
        endif
    endif
    let l:base_indent = matchstr(l:pre_text, '^\s*')

    " 2. Process snippet lines and placeholders
    let l:raw_lines = copy(l:entry.body)
    if empty(l:raw_lines)
        return 0
    endif

    let l:final_lines = []
    let l:placeholders = {}
    let l:auto_idx = 100

    for l:i in range(len(l:raw_lines))
        let l:raw = s:ResolveVariables(l:raw_lines[l:i])

        " Merge first line with pre_text, indent subsequent lines
        if l:i == 0
            let l:current_line = l:pre_text . l:raw
        else
            let l:current_line = l:base_indent . l:raw
        endif

        " Parse placeholders: ${N:default}, ${N}, $N, __f_xxx, _fill
        let l:scan_col = 0
        while 1
            let l:m = s:MatchStrPos(l:current_line, '\${\(\d\+\)\%(:\([^}]*\)\)\?}\|\$\(\d\+\)\|__f\w*\|_fill', l:scan_col)
            if empty(l:m[0]) || l:m[1] == -1
                break
            endif

            let l:full      = l:m[0]
            let l:start_idx = l:m[1]
            let l:end_idx   = l:m[2]
            let l:ph_idx    = 0
            let l:ph_val    = ''

            if l:full =~# '^\${'
                let l:parts  = matchlist(l:full, '^\${\(\d\+\)\%(:\([^}]*\)\)\?}$')
                let l:ph_idx = str2nr(l:parts[1])
                let l:ph_val = len(l:parts) > 2 ? l:parts[2] : ''
            elseif l:full =~# '^\$'
                let l:parts  = matchlist(l:full, '^\$\(\d\+\)$')
                let l:ph_idx = str2nr(l:parts[1])
                let l:ph_val = ''
            else
                " __f or _fill legacy placeholder
                let l:ph_idx = l:auto_idx
                let l:auto_idx += 1
                let l:ph_val = l:full
            endif

            " Replace placeholder with default value in the line text
            let l:prefix = l:start_idx > 0 ? l:current_line[0 : l:start_idx - 1] : ''
            let l:suffix = l:current_line[l:end_idx : ]
            let l:current_line = l:prefix . l:ph_val . l:suffix

            if !has_key(l:placeholders, l:ph_idx)
                let l:placeholders[l:ph_idx] = []
            endif
            call add(l:placeholders[l:ph_idx], [l:i, len(l:prefix) + 1, len(l:ph_val)])

            let l:scan_col = len(l:prefix) + len(l:ph_val)
        endwhile

        call add(l:final_lines, l:current_line)
    endfor

    " Attach any text after trigger to the last line
    let l:final_lines[-1] .= l:post_text

    " 3. Write directly into the buffer (Atomic, zero autoindent/formatoptions side effects!)
    call setline(l:cur_line_nr, l:final_lines[0])
    if len(l:final_lines) > 1
        call append(l:cur_line_nr, l:final_lines[1 : ])
    endif

    " 4. Initialize buffer placeholder queue
    let b:snippet_placeholders = []
    let b:snippet_history      = []

    let l:sorted_keys = sort(keys(l:placeholders), 's:CompareNum')
    for l:k in l:sorted_keys
        if l:k != '0'
            for l:p in l:placeholders[l:k]
                call add(b:snippet_placeholders, [l:cur_line_nr + l:p[0], l:p[1], l:p[2]])
            endfor
        endif
    endfor

    " Add $0 (exit point) at the end if present
    if has_key(l:placeholders, '0')
        for l:p in l:placeholders['0']
            call add(b:snippet_placeholders, [l:cur_line_nr + l:p[0], l:p[1], l:p[2]])
        endfor
    endif

    " 5. Jump to first placeholder
    call snippet_engine#jump_next()
    return 1
endfunction

"-----------------------------------------------------------------------------
" 7. Placeholder Navigation (<C-j> / <C-2> / <C-k>)
"-----------------------------------------------------------------------------
function! snippet_engine#jump_next() abort
    if !exists('b:snippet_placeholders') || empty(b:snippet_placeholders)
        " Fallback: search forward for __f_xxx or _fill without polluting search register
        let l:pos = searchpos('\${\d\+\%(:[^}]*\)\?}\|\$\d\+\|__f\w*\|_fill', 'W')
        if l:pos[0] > 0
            call cursor(l:pos[0], l:pos[1])
            return 1
        endif
        echo "[Snippet] All placeholders completed"
        return 0
    endif

    let l:target = remove(b:snippet_placeholders, 0)
    if !exists('b:snippet_history')
        let b:snippet_history = []
    endif
    call add(b:snippet_history, l:target)

    let l:lnum = l:target[0]
    let l:col  = l:target[1]

    call cursor(l:lnum, l:col)
    return 1
endfunction

function! snippet_engine#jump_prev() abort
    if !exists('b:snippet_history') || len(b:snippet_history) < 2
        echo "[Snippet] Already at first placeholder"
        return 0
    endif

    " Move current back to placeholders queue
    let l:current = remove(b:snippet_history, -1)
    call insert(b:snippet_placeholders, l:current, 0)

    " Pop previous
    let l:prev = remove(b:snippet_history, -1)
    call insert(b:snippet_placeholders, l:prev, 0)

    return snippet_engine#jump_next()
endfunction

"-----------------------------------------------------------------------------
" 8. Interactive Snippet Explorer (:SnippetList)
"-----------------------------------------------------------------------------
function! snippet_engine#list_filter(winid, key) abort
    if a:key ==# "\<CR>" || a:key ==# ' '
        let l:line = line('.', a:winid)
        let l:text = getbufline(winbufnr(a:winid), l:line)[0]
        call popup_close(a:winid, l:line)
        let l:trig = matchstr(l:text, '^\s*\zs\k\+\ze')
        if !empty(l:trig) && snippet_engine#has(l:trig)
            " Insert trigger and expand into current buffer
            call feedkeys("i" . l:trig . "\<CR>", 'n')
        endif
        return 1
    elseif a:key ==# "\<Esc>" || a:key ==# 'q'
        call popup_close(a:winid, -1)
        return 1
    endif
    return popup_filter_menu(a:winid, a:key)
endfunction

function! snippet_engine#list(...) abort
    let l:ft = a:0 > 0 && !empty(a:1) ? a:1 : &filetype
    if empty(l:ft) || l:ft ==# 'all'
        call snippet_engine#load_all()
    else
        call snippet_engine#load_filetype(l:ft)
    endif
    let l:list = []

    " Collect filetype snippets
    if has_key(s:snippets, l:ft)
        for [k, v] in items(s:snippets[l:ft])
            call add(l:list, printf('%-32s [%s] %s', k, l:ft, v.desc))
        endfor
    endif

    " Collect global snippets
    if has_key(s:snippets, '_global')
        for [k, v] in items(s:snippets['_global'])
            call add(l:list, printf('%-32s [_global] %s', k, v.desc))
        endfor
    endif

    if empty(l:list)
        echo printf('[Snippet] No snippets found for filetype "%s"', l:ft)
        return
    endif

    call sort(l:list)
    let l:header = [
        \ printf('=== Available Snippets for "%s" (%d total) ===', l:ft, len(l:list)),
        \ 'Trigger                          Type       Description (Press Enter to insert)',
        \ repeat('-', 78),
    \ ]
    let l:content = l:header + l:list

    if exists('*popup_create')
        call popup_create(l:content, {
            \ 'title': ' Snippets (' . l:ft . ') ',
            \ 'border': [1, 1, 1, 1],
            \ 'padding': [0, 1, 0, 1],
            \ 'close': 'button',
            \ 'moved': 'any',
            \ 'filter': function('snippet_engine#list_filter'),
            \ 'highlight': 'CustomPopup',
            \ 'borderhighlight': ['CustomPopupBorder'],
        \ })
    else
        echo join(l:content, "\n")
    endif
endfunction

command! -nargs=? SnippetList call snippet_engine#list(<f-args>)
command! -nargs=? Snippets    call snippet_engine#list(<f-args>)

"-----------------------------------------------------------------------------
" 9. Key Mappings & Shortcuts
"-----------------------------------------------------------------------------
" Placeholder navigation: <C-j> (next), <C-k> (prev), and <C-2> (backward-compatible)
inoremap <silent> <C-j> <Esc>:call snippet_engine#jump_next()<CR>
snoremap <silent> <C-j> <Esc>:call snippet_engine#jump_next()<CR>
nnoremap <silent> <C-j> :call snippet_engine#jump_next()<CR>

inoremap <silent> <C-2> <Esc>:call snippet_engine#jump_next()<CR>
snoremap <silent> <C-2> <Esc>:call snippet_engine#jump_next()<CR>
nnoremap <silent> <C-2> :call snippet_engine#jump_next()<CR>

inoremap <silent> <C-k> <Esc>:call snippet_engine#jump_prev()<CR>
snoremap <silent> <C-k> <Esc>:call snippet_engine#jump_prev()<CR>
nnoremap <silent> <C-k> :call snippet_engine#jump_prev()<CR>

"-----------------------------------------------------------------------------
" 10. Code Suggestions & Floating Preview for Snippets
"-----------------------------------------------------------------------------
let s:preview_win = -1

function! snippet_engine#get_snippet(trigger) abort
    return s:GetSnippet(a:trigger)
endfunction

function! snippet_engine#format_preview(body) abort
    let l:lines = []
    for l:l in a:body
        " Clean placeholder syntax ${1:default} -> default, $1 -> '', $0 -> ''
        let l:clean = substitute(l:l, '\${\d\+:\([^}]\+\)}', '\1', 'g')
        let l:clean = substitute(l:clean, '\$\d\+', '', 'g')
        call add(l:lines, l:clean)
    endfor
    return l:lines
endfunction

function! snippet_engine#get_preview_win() abort
    return s:preview_win
endfunction

function! snippet_engine#show_preview(word, ...) abort
    if !exists('*popup_create')
        return -1
    endif

    let l:word = a:word
    if empty(l:word) || !snippet_engine#has(l:word)
        call snippet_engine#close_preview()
        return -1
    endif

    let l:entry = s:GetSnippet(l:word)
    if empty(l:entry) || empty(get(l:entry, 'body', []))
        call snippet_engine#close_preview()
        return -1
    endif

    let l:title = printf(' Snippet Code: %s ', l:word)
    let l:desc  = empty(l:entry.desc) ? '' : printf('// Description: %s', l:entry.desc)
    let l:body_lines = snippet_engine#format_preview(l:entry.body)

    let l:preview_content = []
    if !empty(l:desc)
        call add(l:preview_content, l:desc)
        call add(l:preview_content, '// ' . repeat('-', 40))
    endif
    call extend(l:preview_content, l:body_lines)

    let l:pum_row = a:0 > 0 ? a:1 : 1
    let l:pum_col = a:0 > 1 ? a:2 : 1
    let l:pum_w   = a:0 > 2 ? a:3 : 20

    let l:max_w = 65
    let l:max_h = 16

    let l:target_col = l:pum_col + l:pum_w + 1
    if (l:target_col + l:max_w) > &columns
        let l:target_col = max([1, l:pum_col - l:max_w - 2])
    endif

    let l:target_row = max([1, l:pum_row])

    if s:preview_win != -1 && popup_getpos(s:preview_win) != {}
        call popup_settext(s:preview_win, l:preview_content)
        call popup_setoptions(s:preview_win, {
            \ 'title': l:title,
            \ 'line': l:target_row,
            \ 'col': l:target_col,
        \ })
    else
        let s:preview_win = popup_create(l:preview_content, {
            \ 'title': l:title,
            \ 'line': l:target_row,
            \ 'col': l:target_col,
            \ 'minwidth': 35,
            \ 'maxwidth': l:max_w,
            \ 'maxheight': l:max_h,
            \ 'border': [1, 1, 1, 1],
            \ 'padding': [0, 1, 0, 1],
            \ 'highlight': 'CustomPopup',
            \ 'borderhighlight': ['CustomPopupBorder'],
            \ 'zindex': 300,
        \ })
    endif

    " Apply syntax highlighting to the popup buffer matching the snippet filetype
    let l:ft = get(l:entry, 'ft', &filetype)
    if !empty(l:ft) && s:preview_win != -1
        call s:ApplyPopupSyntax(s:preview_win, l:ft)
    endif
    return s:preview_win
endfunction

function! snippet_engine#on_complete_changed() abort
    if !exists('*popup_create') || mode() !~# '^[iR]'
        return
    endif

    let l:item = get(v:event, 'completed_item', {})
    let l:word = get(l:item, 'word', '')

    if empty(l:word) || !snippet_engine#has(l:word)
        call snippet_engine#close_preview()
        return
    endif

    let l:pum_row = get(v:event, 'row', 1)
    let l:pum_col = get(v:event, 'col', 1)
    let l:pum_w   = get(v:event, 'width', 20)

    call snippet_engine#show_preview(l:word, l:pum_row, l:pum_col, l:pum_w)
endfunction

function! s:ApplyPopupSyntax(winid, ft) abort
    if !exists('*win_execute') || a:winid == -1
        return
    endif
    let l:custom_ft = s:custom_dir . '/filetypes/' . a:ft . '.vim'
    call win_execute(a:winid, 'setlocal filetype=' . fnameescape(a:ft) . ' syntax=' . fnameescape(a:ft))
    if filereadable(l:custom_ft)
        call win_execute(a:winid, 'source ' . fnameescape(l:custom_ft))
    endif
endfunction

function! snippet_engine#close_preview() abort
    if s:preview_win != -1
        if exists('*popup_close') && popup_getpos(s:preview_win) != {}
            call popup_close(s:preview_win)
        endif
        let s:preview_win = -1
    endif
endfunction

" Completefunc provider (<C-x><C-u>) for snippets with descriptions and code preview
function! snippet_engine#complete(findstart, base) abort
    if a:findstart
        let l:line = getline('.')
        let l:start = col('.') - 1
        while l:start > 0 && l:line[l:start - 1] =~# '\k'
            let l:start -= 1
        endwhile
        return l:start
    else
        let l:ft = &filetype
        if empty(l:ft)
            return []
        endif
        call snippet_engine#load_filetype(l:ft)
        let l:matches = []

        let l:snips = {}
        if has_key(s:snippets, l:ft)
            call extend(l:snips, s:snippets[l:ft])
        endif
        if has_key(s:snippets, '_global')
            call extend(l:snips, s:snippets['_global'])
        endif
        if exists('b:custom_snippets')
            call extend(l:snips, b:custom_snippets)
        endif

        for [k, v] in items(l:snips)
            if empty(a:base) || k =~? '^' . a:base || k =~? a:base
                let l:preview = join(snippet_engine#format_preview(v.body[0:8]), "\n")
                if len(v.body) > 9
                    let l:preview .= "\n..."
                endif
                call add(l:matches, {
                    \ 'word': k,
                    \ 'abbr': k,
                    \ 'menu': '[snip] ' . v.desc,
                    \ 'info': l:preview,
                    \ 'dup': 1,
                    \ 'icase': 1,
                \ })
            endif
        endfor
        return l:matches
    endif
endfunction

"-----------------------------------------------------------------------------
" 11. Automatic Snippet Loader & Autocommands
"-----------------------------------------------------------------------------
augroup SnippetEngineLoader
    autocmd!
    autocmd FileType * call snippet_engine#load_filetype(expand('<amatch>'))
    autocmd FileType * setlocal completefunc=snippet_engine#complete
    if exists('##CompleteChanged')
        autocmd CompleteChanged * call snippet_engine#on_complete_changed()
    endif
    if exists('##CompleteDone')
        autocmd CompleteDone * call snippet_engine#close_preview()
    endif
    autocmd InsertLeave * call snippet_engine#close_preview()
augroup END
