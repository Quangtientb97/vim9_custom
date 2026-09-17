"=============================================================================
" Custom Fuzzy Finder (Fuzzbox/Fuzzyy) Configuration for Vim 9+
" Written in 100% native Vim9 script with Zero external dependencies
"=============================================================================

if !has('vim9script') || v:version < 900
    finish
endif

" 1. Fuzzbox / Fuzzyy Options
let g:fuzzbox_respect_gitignore = 1
let g:fuzzbox_include_hidden = 0

" 2. Key Mappings
" Ctrl-P: Instant file finder (classic & intuitive)
nnoremap <silent> <C-p> :FuzzyFiles<CR>

" <leader>f prefix shortcuts
nnoremap <silent> <leader>ff :FuzzyFiles<CR>
nnoremap <silent> <leader>fg :FuzzyGrep<CR>
nnoremap <silent> <leader>fb :FuzzyBuffers<CR>
nnoremap <silent> <leader>fm :FuzzyMru<CR>
nnoremap <silent> <leader>fl :FuzzyInBuffer<CR>
nnoremap <silent> <leader>ft :FuzzyTags<CR>

" 'sf' shortcut under 's' prefix
nnoremap <silent> sf :FuzzyFiles<CR>

" 3. Register into Which-Key menu if available
if exists('g:which_key_map_root')
    let g:which_key_map_root['f'] = {
        \ 'name': '+fuzzy-find (Vim9)',
        \ 'f': [':FuzzyFiles',    'find-files (<C-p>)'],
        \ 'g': [':FuzzyGrep',     'live-grep (ripgrep)'],
        \ 'b': [':FuzzyBuffers',  'find-buffers'],
        \ 'm': [':FuzzyMru',      'recent-files (MRU)'],
        \ 'l': [':FuzzyInBuffer', 'search-in-buffer'],
        \ 't': [':FuzzyTags',     'find-tags'],
    \ }
endif

if exists('g:which_key_map_s')
    let g:which_key_map_s['f'] = [':FuzzyFiles', 'find-files (<C-p>)']
endif
