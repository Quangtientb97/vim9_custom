"=============================================================================
" Plugin: which_key.vim
" Description: Which-Key Interactive Shortcut Popup Guide for Vim
"   - Displays floating popup with available keys when pausing on prefix
"   - 's' prefix: Tools, quick save, base converter, calculator, etc.
"   - 'sh' / '<Leader>': Full interactive cheatsheet menu
"=============================================================================

silent! runtime! plugin/which_key.vim
if !exists(':WhichKey')
    " Plugin not installed or not loaded
    finish
endif

" 1. Which-Key Behavior & Visual Settings
let g:which_key_use_floating_win = exists('*popup_create') || exists('*nvim_open_win')
let g:which_key_centered = 1
let g:which_key_sep = '→'
let g:which_key_hspace = 4
let g:which_key_sort_horizontal = 0
let g:which_key_display_names = {
    \ '<CR>': '↵',
    \ '<TAB>': '⇆',
    \ '<Space>': '␣',
\ }

" 2. Highlight Styling (Matches custom dark slate & gold theme)
highlight default link WhichKey          Special
highlight default link WhichKeySeperator DiffAdded
highlight default link WhichKeyGroup     Keyword
highlight default link WhichKeyDesc      Identifier
highlight default link WhichKeyFloating  CustomPopup

" 3. Register Dictionary for 's' (Engineering Tools & Quick Actions)
let g:which_key_map_s = {
    \ 'name': '+tools/shortcuts',
    \ 'a': [':call ShowAscii(0)',           'show-ascii-info'],
    \ 'b': [':call ConvertBase(0)',         'convert-base (hex/dec/bin)'],
    \ 'c': [':call QuickCalc(0)',           'quick-calculator'],
    \ 'h': [':WhichKey "\\"',               'which-key-menu (full)'],
    \ 'm': [':set modifiable',              'set-modifiable'],
    \ 's': [':w!',                          'quick-save (:w!)'],
    \ 'w': [':set wrap!',                   'toggle-line-wrap'],
    \ 'n': [':SnippetList',                 'list-snippets (:SnippetList)'],
    \ 'g': [':call ToggleGitDiff()',        'git-diff-toggle (gd/sg)'],
    \ 'p': [':call ShowSourcePopup()',       'source-popup-def (sp/gp)'],
    \ 't': [':ContextToggle',                'toggle-sticky-context (st)'],
    \ 'd': {
    \     'name': '+doxygen',
    \     'x': [':Dox',       'doxygen-comment (:Dox)'],
    \     'a': [':DoxAuthor', 'doxygen-author-header (:DoxAuthor)'],
    \     'b': [':DoxBlock',  'doxygen-block (:DoxBlock)'],
    \ },
    \ 'r': {
    \     'name': '+rainbow',
    \     'b': [':call rainbow_main#toggle()', 'toggle-rainbow-brackets'],
    \ },
\ }

let g:which_key_map_s_vis = {
    \ 'name': '+tools/shortcuts',
    \ 'a': [':<C-u>call ShowAscii(1)',        'show-ascii-info'],
    \ 'b': [':<C-u>call ConvertBase(1)',      'convert-base (hex/dec/bin)'],
    \ 'c': [':<C-u>call QuickCalc(1)',        'quick-calculator'],
    \ 'h': [':WhichKeyVisual "\\"',           'which-key-menu (full)'],
    \ 's': [':w!',                            'quick-save (:w!)'],
    \ 'p': [':<C-u>call ShowSourcePopupVisual()', 'source-popup-def (sp/gp)'],
\ }

call which_key#register('s', 'g:which_key_map_s', 'n')
call which_key#register('s', 'g:which_key_map_s_vis', 'v')

" 4. Register Root Dictionary (Full Editor Cheatsheet on 'sh' or <Leader>)
let g:which_key_map_root = {
    \ 'name': '+which-key-menu',
    \ 's': g:which_key_map_s,
    \ 't': {
    \     'name': '+tab/align',
    \     'n': [':tabnew | :E', 'new-tab-explorer'],
    \     'a': [':EasyAlign //<left>', 'easy-align-custom'],
    \     'p': [':AP', 'align-ports/signals (:AP)'],
    \ },
    \ '_':     [':call EasyAlignUnderCursor()',        'align-under-cursor (_)'],
    \ 'd':     { 'name': '+delete', 's': 'delete-matching-pair (ds on bracket/quote)' },
    \ 'g':     { 'name': '+git/splitjoin', 'd': [':call ToggleGitDiff()', 'git-diff-toggle (gd)'], 'p': [':call ShowSourcePopup()', 'source-popup-def (gp)'], 's': 'split-multiline (gs)', 'j': 'join-singleline (gj)' },
    \ 'S':     [':Startify',                           'startify-dashboard'],
    \ '<F1>':  [':call CloseCurrentFileAndTerminal()', 'close-file/terminal'],
    \ '<F3>':  [':call ToggleNERDTree()',              'nerdtree-toggle'],
    \ '<F4>':  [':NERDTreeToggle | :TagbarToggle',     'nerdtree+tagbar'],
    \ '<F5>':  [':e!',                                 'reload-current-file'],
    \ '<F7>':  [':call BlockComment()',                'generate-block-comment'],
    \ '<F12>': [':call ToggleBottomTerminal()',        'bottom-terminal-drawer'],
\ }

call which_key#register('\', 'g:which_key_map_root')

" 5. Keybindings
" When pausing on 's' in Normal mode, show the tools popup
nnoremap <silent> s :<c-u>WhichKey 's'<CR>
" (Note: In Visual mode, 's' is mapped to vim-surround)

" 'sh' / <Leader> toggles the full interactive menu
nnoremap <silent> sh :<c-u>WhichKey '\'<CR>
vnoremap <silent> sh :<c-u>WhichKeyVisual '\'<CR>
nnoremap <silent> <leader> :<c-u>WhichKey '\'<CR>
vnoremap <silent> <leader> :<c-u>WhichKeyVisual '\'<CR>

" Convenient user command aliases
command! -bang WK WhichKey<bang> '\'
