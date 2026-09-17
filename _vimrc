"-----------------------------------------------------------------------------
" 1. General & Performance Settings
"-----------------------------------------------------------------------------
set nocompatible
scriptencoding utf-8

set encoding=UTF-8
set completeopt=menuone
silent! set completeopt+=noinsert,noselect
set backspace=indent,eol,start
set foldmethod=marker
set guifont=Consolas:h11
set laststatus=2
set linebreak
set noswapfile
set nowrap
set noshowcmd
set number
set numberwidth=6
set scrolloff=3
set smarttab
set mouse=niv
set t_Co=256
set tabstop=4
set shiftwidth=4
set expandtab
set hlsearch
set diffopt+=iwhite
set matchpairs+=<:>
set visualbell
set t_vb=
set pumheight=8
silent! set shortmess+=c
set complete=.,w,b,k
set lazyredraw
set ttyfast
set updatetime=1000
set ttimeout
set ttimeoutlen=50
set maxmempattern=2000000

" Vim 9+ optimizations (Smooth scrolling, No bell sound/flash, Fast log quickfix filter, Smart diff, Splitkeep)
if exists('&smoothscroll')
    set smoothscroll
endif
if exists('&belloff')
    set belloff=all
endif
if exists(':packadd')
    silent! packadd cfilter
endif
if exists('&splitkeep')
    set splitkeep=screen
endif
if has('patch-9.0.0240')
    set diffopt+=linematch:60
endif

" Terminal Alt keycode mapping (makes Alt/Meta keys work in terminal Vim)
if !has('gui_running')
    silent! execute "set <M-j>=\<Esc>j"
    silent! execute "set <M-k>=\<Esc>k"
    silent! execute "set <M-Down>=\<Esc>[1;3B"
    silent! execute "set <M-Up>=\<Esc>[1;3A"
endif

" Upward recursive tag searching (searches current dir up to root)
set tags=./tags;,tags;

if &diff
    syntax off
endif

colorscheme desert
syntax enable
filetype plugin indent on

" Statusline Powerline Arrow (1 = arrow glyph , 0 = clean flat block fallback)
let g:powerline_arrow = 0

" Determine the directory containing _vimrc and associated runtime directory
let s:vim_custom_root = expand('<sfile>:p:h')
let s:vim_runtime = s:vim_custom_root . '/_vim'

" Exclusively use _vim instead of default ~/.vim:
" Remove default ~/.vim and ~/.vim/after from runtimepath, then prepend and append _vim
set runtimepath-=~/.vim
set runtimepath-=~/.vim/after
execute 'set runtimepath^=' . fnameescape(s:vim_runtime)
execute 'set runtimepath+=' . fnameescape(s:vim_runtime . '/after')

"-----------------------------------------------------------------------------
" 2. Plugin Management (vim-plug)
"-----------------------------------------------------------------------------
let s:plug_file = s:vim_runtime . '/autoload/plug.vim'
if filereadable(s:plug_file)
    execute 'source ' . fnameescape(s:plug_file)
endif

" Rainbow Brackets Configuration (Bracket Pair Colorization)
let g:rainbow_active = 0
let g:rainbow_conf = {
\   'guifgs': ['#e4e4e4', '#5fafff', '#ff87d7', '#87d787', '#ffaf5f', '#af87ff'],
\   'ctermfgs': [254, 75, 212, 114, 215, 141],
\   'operators': '',
\   'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/'],
\   'separately': {
\       '*': {},
\       'nerdtree': 0,
\       'log': 0,
\       'logfile': 0,
\   }
\}

let g:matchup_surround_enabled = 1
" Prevent vim-matchup from ever mapping 'cs%' (which intercepts/delays 'c')
nmap <Plug>(DisableMatchupCS) <plug>(matchup-cs%)

let s:plugged_dir = s:vim_runtime . '/plugged'
silent! call plug#begin(s:plugged_dir)
    execute 'Plug ' . string(s:plugged_dir . '/verilog_systemverilog.vim')
    execute 'Plug ' . string(s:plugged_dir . '/nerdtree')
    execute 'Plug ' . string(s:plugged_dir . '/vim-easy-align')
    execute 'Plug ' . string(s:plugged_dir . '/vim-matchup')
    execute 'Plug ' . string(s:plugged_dir . '/tagbar') . ', ' . string({'on': 'TagbarToggle'})
    execute 'Plug ' . string(s:plugged_dir . '/vim-gitgutter')
    execute 'Plug ' . string(s:plugged_dir . '/rainbow')
    execute 'Plug ' . string(s:plugged_dir . '/vim-which-key')
    execute 'Plug ' . string(s:plugged_dir . '/vim-startify')
    execute 'Plug ' . string(s:plugged_dir . '/vim-fugitive')
    if v:version >= 900 && has('patch-9.0.0000')
        execute 'Plug ' . string(s:plugged_dir . '/fuzzyy')
    endif
call plug#end()

"-----------------------------------------------------------------------------
" 3. UI, Highlighting & Colors
"-----------------------------------------------------------------------------
set cursorline

" CursorLine & Numbers
highlight CursorLine        cterm=none ctermbg=238 guibg=#444444 gui=none
highlight CursorLineNr      cterm=none ctermfg=blue ctermbg=none guifg=#5fafff guibg=NONE gui=none
highlight LineNr            ctermfg=245 ctermbg=none guifg=#8a8a8a guibg=NONE
highlight Visual            cterm=underline ctermfg=none ctermbg=238 guibg=#444444 gui=underline
highlight Cursor            ctermfg=white ctermbg=white guifg=#ffffff guibg=#ffffff
" End of Buffer (~) & NonText: Clean background matching editor (fixes gray bar in Vim 9)
highlight NonText           ctermfg=240 ctermbg=none guifg=#585858 guibg=NONE
highlight EndOfBuffer       ctermfg=240 ctermbg=none guifg=#585858 guibg=NONE

" Popup Menu Completion
highlight Pmenu      ctermfg=DarkGray ctermbg=233 guifg=#808080 guibg=#121212
highlight PmenuSel   ctermfg=blue     ctermbg=233 guifg=#5fafff guibg=#121212
highlight Search     ctermfg=black    cterm=underline ctermbg=185 guifg=#000000 guibg=#d7d75f gui=underline
silent! highlight CurSearch  cterm=bold ctermfg=232 ctermbg=214 guifg=#1c1c1c guibg=#ffaf00 gui=bold
highlight PmenuThumb ctermfg=245      ctermbg=245 guifg=#8a8a8a guibg=#8a8a8a
highlight PmenuSbar  ctermfg=240      ctermbg=240 guifg=#585858 guibg=#585858

" Diff Highlights
highlight DiffAdd    ctermfg=176  ctermbg=none cterm=underline guifg=#d787d7 guibg=NONE gui=underline
highlight DiffChange ctermfg=176  ctermbg=none cterm=underline guifg=#d787d7 guibg=NONE gui=underline
highlight DiffDelete ctermfg=blue ctermbg=none guifg=#5fafff guibg=NONE
highlight DiffText   ctermfg=215  ctermbg=none guifg=#ffaf5f guibg=NONE

" NERDTree Config & Highlights
let g:NERDTreeStatusline = '%#StatusLineNERDTreeNC# NERDTree %='
let g:NERDTreeWinSize = 27
let g:stt_tree = 1
let g:NERDTreeIgnore = ['\.o$', '\.a$', '\.so$', '\.d$', '\.vpd$', '\.fsdb$', '\.vcd$', '\~$', '\.git$']

highlight NERDTreeOpenable        ctermfg=250  guifg=#bcbcbc
highlight NERDTreeClosable        ctermfg=250  guifg=#bcbcbc
highlight NERDTreeDir             ctermfg=blue guifg=#5fafff
highlight NERDTreeDirSlash        ctermfg=248  guifg=#a8a8a8
highlight NERDTreeHelpKey         ctermfg=248  guifg=#a8a8a8
highlight NERDTreeFile            ctermfg=248  guifg=#a8a8a8
highlight NERDTreeLinkTarget      ctermfg=blue guifg=#5fafff cterm=underline gui=underline
highlight NERDTreeLinkDir         ctermfg=13   guifg=#ff55ff
highlight NERDTreeLinkFile        ctermfg=139  guifg=#af87af
highlight NERDTreeExecFile        ctermfg=248  guifg=#a8a8a8
highlight NERDTreeCWD             ctermfg=176  guifg=#d787d7
highlight NERDTreeup              ctermfg=248  guifg=#a8a8a8
highlight NERDTreeHelp            ctermfg=248  guifg=#a8a8a8
highlight NERDTreeBookmark        ctermfg=gray guifg=#808080
highlight NERDTreeBookmarksLeader ctermfg=233  guifg=#121212
highlight NERDTreeBookmarksHeader ctermfg=gray guifg=#808080
highlight NERDTreeBookmarkName    ctermfg=215  guifg=#ffaf5f

" Bracket & Error Highlights
highlight Folded          ctermbg=242 ctermfg=234 guibg=#6c6c6c guifg=#1c1c1c
highlight MatchParen      cterm=none  ctermbg=brown ctermfg=white guibg=#8b4513 guifg=#ffffff gui=none
highlight ErrorMsg        ctermfg=001 ctermbg=white cterm=reverse guifg=#ffffff guibg=#d70000
highlight WordUnderCursor cterm=underline ctermbg=237 guibg=#3a3a3a gui=underline

" Default Syntax Highlights
highlight Comment    ctermfg=107      guifg=#6A9955
highlight Normal     ctermfg=252      guifg=#d0d0d0
highlight Special    ctermfg=13       guifg=#ff55ff
highlight SpecialKey ctermfg=darkblue guifg=#005faf
highlight Type       ctermfg=blue     guifg=#5fafff
highlight Identifier ctermfg=blue     guifg=#5fafff
highlight Directory  ctermfg=blue     guifg=#5fafff
highlight netrwExe   ctermfg=gray     guifg=#808080
highlight String     ctermfg=215      guifg=#ffaf5f
highlight PreProc    ctermfg=13       guifg=#ff55ff

" Floating Popup Windows (Vim 8.2+) - VS Code dark slate background
highlight CustomPopup       ctermfg=254 ctermbg=238 guifg=#e4e4e4 guibg=#2b313c
highlight CustomPopupBorder ctermfg=75  ctermbg=238 guifg=#5fafff guibg=#2b313c

"-----------------------------------------------------------------------------
" 4. Custom Plugins & Modules (_vim/custom/*.vim)
"-----------------------------------------------------------------------------
let s:custom_dir = s:vim_runtime . '/custom'

let s:custom_modules = [
    \ 'engineering_tools.vim',
    \ 'bottom_terminal.vim',
    \ 'breadcrumbs_scope.vim',
    \ 'statusline.vim',
    \ 'cursor_highlight.vim',
    \ 'completion_editing.vim',
    \ 'easy_align_helper.vim',
    \ 'surround.vim',
    \ 'doxygen_generator.vim',
    \ 'splitjoin.vim',
    \ 'git_diff.vim',
    \ 'which_key.vim',
    \ 'verilog_align.vim',
    \ 'large_file.vim',
\]

if v:version >= 900 && has('patch-9.0.0000')
    let s:custom_modules += ['fuzzyy.vim']
endif

for s:mod in s:custom_modules
    let s:mod_path = s:custom_dir . '/' . s:mod
    if filereadable(s:mod_path)
        execute 'source ' . fnameescape(s:mod_path)
    endif
endfor

"-----------------------------------------------------------------------------
" 5. Key Mappings & Shortcuts
"-----------------------------------------------------------------------------
" Exit & Save
nnoremap <silent> <F1> :call CloseCurrentFileAndTerminal()<cr>
inoremap <silent> <F1> <esc>:call CloseCurrentFileAndTerminal()<cr>
vnoremap <silent> <F1> <esc>:call CloseCurrentFileAndTerminal()<cr>
if has('terminal')
    tnoremap <silent> <F1> <C-\><C-n>:call CloseCurrentFileAndTerminal()<cr>
endif
nnoremap ss :w!<cr><esc>:echohl Search \| echo expand('%:t') . ' is saved' \| echohl None<cr>

" Select All
nnoremap <C-a> ggVG
inoremap <C-a> <esc>ggVG
vnoremap <C-a> <esc>ggVG

" Preserve Clipboard on Visual Paste (VS Code style: paste over selection without losing register)
xnoremap <expr> p 'pgv"' . v:register . 'y'
xnoremap <expr> P 'Pgv"' . v:register . 'y'

" Navigation & Motion
nnoremap - Gzz
" nnoremap s <esc> (managed by which_key.vim for interactive tool popup)
nnoremap <nowait> c <esc>cw
nnoremap <F5> <esc>:e!<cr>:echo "Successfully reload file!"<cr>

" Indentation & Visual Alignment
nnoremap > >>
nnoremap < <<
nnoremap = ==
vnoremap > >gv
vnoremap < <gv

" Move Line / Visual Block Up & Down (VS Code: Alt+Up / Alt+Down or Alt+j / Alt+k)
nnoremap <silent> <M-j> :m .+1<cr>==
nnoremap <silent> <M-k> :m .-2<cr>==
inoremap <silent> <M-j> <esc>:m .+1<cr>==gi
inoremap <silent> <M-k> <esc>:m .-2<cr>==gi
vnoremap <silent> <M-j> :m '>+1<cr>gv=gv
vnoremap <silent> <M-k> :m '<-2<cr>gv=gv

nnoremap <silent> <A-j> :m .+1<cr>==
nnoremap <silent> <A-k> :m .-2<cr>==
inoremap <silent> <A-j> <esc>:m .+1<cr>==gi
inoremap <silent> <A-k> <esc>:m .-2<cr>==gi
vnoremap <silent> <A-j> :m '>+1<cr>gv=gv
vnoremap <silent> <A-k> :m '<-2<cr>gv=gv

nnoremap <silent> <M-Down> :m .+1<cr>==
nnoremap <silent> <M-Up>   :m .-2<cr>==
inoremap <silent> <M-Down> <esc>:m .+1<cr>==gi
inoremap <silent> <M-Up>   <esc>:m .-2<cr>==gi
vnoremap <silent> <M-Down> :m '>+1<cr>gv=gv
vnoremap <silent> <M-Up>   :m '<-2<cr>gv=gv

nnoremap <silent> <A-Down> :m .+1<cr>==
nnoremap <silent> <A-Up>   :m .-2<cr>==
inoremap <silent> <A-Down> <esc>:m .+1<cr>==gi
inoremap <silent> <A-Up>   <esc>:m .-2<cr>==gi
vnoremap <silent> <A-Down> :m '>+1<cr>gv=gv
vnoremap <silent> <A-Up>   :m '<-2<cr>gv=gv

" Quick Search & Replace
nnoremap <C-h> :%s///g<left><left><left>
vnoremap <C-h> :s///g<left><left><left>
nnoremap / :%s///gn<left><left><left><left>
nnoremap n nzz

" Scrolling & Movement
nnoremap <space> 10jzz
vnoremap <space> 10jzz
vnoremap <tab> <esc><C-w>w

nnoremap <C-Right> z5l
nnoremap <C-Left>  z5h
nnoremap <C-Down>  5jzz
nnoremap <C-Up>    5kzz

nnoremap J 10j
nnoremap K 10k
vnoremap J 10jzz
vnoremap K 10kzz

" Word Search & Replace Under Cursor
nnoremap *     evby<esc>:%s/\<<C-R>=escape(@",'/\')<cr>\>//gn<cr>0n
nnoremap <C-f> evby<esc>:%s/\<<C-R>=escape(@",'/\')<cr>\>//g<left><left>
nnoremap #     evby<esc>:%s/\<<C-R>=escape(@",'/\')<cr>\>//g<left><left>
vnoremap *     y/\V<C-R>=escape(@",'/\')<cr><cr>

" Command Mode & Utility
nnoremap vi  <esc>:vi
nnoremap :Vi <esc>:vi
nnoremap g/  <esc>:g/
nnoremap sm  <esc>:set modifiable<cr>
nnoremap <silent> sa :call ShowAscii(0)<cr>
vnoremap <silent> sa :<C-u>call ShowAscii(1)<cr>
nnoremap <silent> sb :call ConvertBase(0)<cr>
vnoremap <silent> sb :<C-u>call ConvertBase(1)<cr>
nnoremap <silent> sc :call QuickCalc(0)<cr>
vnoremap <silent> sc :<C-u>call QuickCalc(1)<cr>
nnoremap <silent> sg :call ToggleGitDiff()<cr>
nnoremap <silent> gd :call ToggleGitDiff()<cr>
nnoremap <silent> sh :<c-u>WhichKey '\'<CR>
vnoremap <silent> sh :<c-u>WhichKeyVisual '\'<CR>
nnoremap <C-w>v <C-w>v<C-w>w
nnoremap tn :tabnew<cr>:E<cr>
nnoremap <tab> <C-w>w
nnoremap <C-g> :echo expand('%:p')<cr>

" Line Append Shortcuts
nnoremap <C-@> <esc>A
inoremap <C-@> <esc>A
nnoremap <C-space> <esc>A
inoremap <C-space> <esc>A

" Safe delete cancels
nnoremap dj <esc>
nnoremap dk <esc>

" Wrap toggle
nnoremap sw :set wrap!<cr>

" Doxygen Generator Configuration
let g:doxygen_author = "tian"

" Startify Configuration (Dashboard)
let g:startify_change_to_dir = 0
let g:startify_fortune_use_unicode = 1

" Plugin Toggles
nnoremap <F3> :call ToggleNERDTree()<cr>
nnoremap <F4> :NERDTreeToggle<cr>:TagbarToggle<cr>:echo "Run TagBar!"<cr><C-w>w

" Terminal Drawer Toggle (VS Code Ctrl+` / F12)
nnoremap <silent> <F12> :call ToggleBottomTerminal()<cr>
inoremap <silent> <F12> <esc>:call ToggleBottomTerminal()<cr>
if has('terminal')
    tnoremap <silent> <F12> <C-w>:call ToggleBottomTerminal()<cr>
endif

" Commenting Shortcut (Ctrl + /)
nnoremap <silent> <C-_> :call Comment()<cr>
vnoremap <silent> <C-_> :call Comment()<cr>

" Header Comment Divider (F7)
nnoremap <silent> <F7> :call AddMinus()<cr>

" Folding Shortcut
nnoremap zf :call Fold()<cr>

" Delete Pair (<BS> / <C-h>)
inoremap <expr> <BS> RemovePair()
imap <C-h> <BS>

" Super Tab & Popup Navigation
imap <expr> <tab> Supertab()
inoremap <F10> <tab>
inoremap <expr> <up>   pumvisible() ? "\<C-p>" : "\<Up>"
inoremap <expr> <down> pumvisible() ? "\<C-n>" : "\<Down>"

" Snippet Triggers
imap <C-2> <space><esc>/_fill<cr><left><right><esc>
imap <expr> <nowait> <cr> Snipet()
inoremap <nowait> <C-3> <cr>
inoremap <s-tab> <esc>:setlocal iskeyword+=.<cr>a<C-n><C-p>

" Auto-Pairing in Insert Mode
inoremap <expr> ( ((getline('.')[col('.')-8 : col('.')-2]) ==# 'display') ? "(\"@ %0t [tian] \", $time);<esc>9hi"   :
            \ ((getline('.')[col('.')-4 : col('.')-2]) ==# 'new'    )     ? "();\<left>\<left>"                   :
            \ ((getline('.')[col('.')-7 : col('.')-2]) ==# 'create' )     ? "();\<left>\<left>"                   :
            \ ((getline('.')[col('.')-1])              =~ '\K')           ? "("                                   :
            \ ((getline('.')[col('.')-1])              =~ '\d')           ? "("                                   :
            \ "()\<left>"

inoremap <expr> { ((getline('.')[col('.')-1]) =~ '\K') ? "{" :
            \ ((getline('.')[col('.')-1]) =~ '\d') ? "{" :
            \ "{}\<left>"

inoremap <expr> [ ((getline('.')[col('.')-1]) =~ '\K') ? "[" :
            \ ((getline('.')[col('.')-1]) =~ '\d') ? "[" :
            \ "[]\<left>"

inoremap <expr> " ((getline('.')[col('.')-1]) ==# '"') ? "\"<del>" :
            \ ((getline('.')[col('.')-1]) =~ '[a-zA-Z0-9_]') ? "\"" :
            \ "\"\"\<left>"

inoremap <expr> ) (getline('.')[col('.')-1] ==# ')') ? ")\<del>" : ")"
inoremap <expr> } (getline('.')[col('.')-1] ==# '}') ? "}\<del>" : "}"
inoremap <expr> ] (getline('.')[col('.')-1] ==# ']') ? "]\<del>" : "]"

"-----------------------------------------------------------------------------
" 6. Autocommand Groups (Optimized & Cleanly Scoped)
"-----------------------------------------------------------------------------
augroup VimrcCore
    autocmd!
    " Remember cursor position
    autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

    " Startup Layout: Empty vi -> NERDTree on left, Startify on right; File vi -> NERDTree on left, File on right
    autocmd VimEnter * nested if !argc() | Startify | NERDTree | else | NERDTree | wincmd p | endif
    autocmd VimEnter * silent! nunmap cs%
    autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

    " CursorLine & timeout management in Insert mode
    autocmd InsertEnter * set nocul | set timeoutlen=0
    autocmd InsertLeave * set cul   | set timeoutlen=1000 | setlocal iskeyword-=.

    " Auto-completion trigger
    autocmd InsertCharPre * if get(g:, 'auto_complete', 1) == 1 | call AutoComplete() | endif

    " Auto-highlight word under cursor (VS Code Document Highlight)
    autocmd CursorHold,CursorHoldI * silent! call HighlightCursorWord()
    autocmd WinLeave,BufLeave * silent! call ClearCursorWordHighlight()

    " Terminal custom statusline
    if exists('##TerminalOpen')
        autocmd TerminalOpen * setlocal statusline=%#StatusLineTerm#\ [TERMINAL]\ %{bufname('%')}%=\ [F12:\ Toggle]\ 
    endif
augroup END

augroup VimrcFiletypes
    autocmd!
    autocmd BufRead,BufNewFile *            setlocal modifiable
    autocmd BufRead,BufNewFile *.jj2        setfiletype jinja2
    execute 'autocmd BufRead,BufNewFile *.log setlocal nomodifiable | setfiletype logfile | silent! source ' . fnameescape(s:custom_dir . '/filetypes/logfile.vim')
    autocmd BufRead,BufNewFile Makefile*,*.make,*.mconf setfiletype make
    autocmd BufRead,BufNewFile *.lst,*.S,*tarmac* setfiletype asm
    autocmd BufRead,BufNewFile *.f,*.h,*.c  setfiletype c
    autocmd BufRead,BufNewFile vcode.f,*autorun setfiletype tcsh
    autocmd BufRead,BufNewFile *.cc,*.cpp   setfiletype systemC
    autocmd BufRead,BufNewFile *.note       setfiletype note
    autocmd BufRead,BufNewFile *.help       setfiletype help
    autocmd BufRead,BufNewFile *.upf        setfiletype upf
    autocmd BufRead,BufNewFile *.v,*.vh,*.vp,*.sv,*.svi,*.svh,*.svp,*.sva set filetype=verilog_systemverilog
    autocmd BufRead,BufNewFile *.lisa       setfiletype lisa
    autocmd BufRead,BufNewFile *.md,*.markdown setfiletype markdown
augroup END

augroup VimrcFileTypeSettings
    autocmd!
    autocmd FileType verilog,systemverilog set filetype=verilog_systemverilog
    execute 'autocmd FileType logfile    silent! source ' . fnameescape(s:custom_dir . '/filetypes/logfile.vim')
    execute 'autocmd FileType help       silent! source ' . fnameescape(s:custom_dir . '/filetypes/help.vim')
    execute 'autocmd FileType asm        silent! source ' . fnameescape(s:custom_dir . '/filetypes/asm.vim')
    execute 'autocmd FileType c          silent! source ' . fnameescape(s:custom_dir . '/filetypes/c.vim')
    execute 'autocmd FileType csh,tcsh   silent! source ' . fnameescape(s:custom_dir . '/filetypes/csh.vim')
    execute 'autocmd FileType tcl        silent! source ' . fnameescape(s:custom_dir . '/filetypes/tcl.vim')
    execute 'autocmd FileType jinja2     silent! source ' . fnameescape(s:custom_dir . '/filetypes/jinja2.vim')
    execute 'autocmd FileType make       silent! source ' . fnameescape(s:custom_dir . '/filetypes/make.vim')
    execute 'autocmd FileType note       silent! source ' . fnameescape(s:custom_dir . '/filetypes/note.vim')
    execute 'autocmd FileType markdown   silent! source ' . fnameescape(s:custom_dir . '/filetypes/markdown.vim')
    execute 'autocmd FileType upf        silent! source ' . fnameescape(s:custom_dir . '/filetypes/upf.vim')
    execute 'autocmd FileType python     silent! source ' . fnameescape(s:custom_dir . '/filetypes/python.vim')
    execute 'autocmd FileType systemC    silent! source ' . fnameescape(s:custom_dir . '/filetypes/systemC.vim')
    execute 'autocmd FileType lisa       silent! source ' . fnameescape(s:custom_dir . '/filetypes/lisa.vim')
    execute 'autocmd FileType verilog_systemverilog silent! source ' . fnameescape(s:custom_dir . '/filetypes/verilog_systemverilog.vim')
    execute 'autocmd FileType xml        silent! source ' . fnameescape(s:custom_dir . '/filetypes/xml.vim')

    autocmd FileType startify
                \ setlocal cursorline

    autocmd FileType nerdtree
                \ nnoremap <buffer> J 10j
                \ | nnoremap <buffer> K 10k
                \ | highlight! NERDTreeCWD ctermfg=176 guifg=#d787d7
                \ | highlight! NERDTreeDir ctermfg=blue guifg=#5fafff

    autocmd FileType netrw
                \ nnoremap <buffer> J 10j
                \ | nnoremap <buffer> K 10k
                \ | nnoremap <buffer> ma %
                \ | nnoremap <buffer> md D
                \ | nnoremap <buffer> u gg7j<cr>

    autocmd FileType tagbar
                \ nnoremap <buffer> <F1> :q!<cr>
                \ | nnoremap <buffer> <space> 10j

    autocmd FileType *
                \ setlocal iskeyword=48-57,_,64
                \ | setlocal iskeyword-=-
augroup END

" Python specific window split on open
augroup VimrcPythonSplit
    autocmd!
    autocmd VimEnter *.py
                \ vsplit ~/tiandir/python/tian/auto_complete.py
                \ | wincmd H
                \ | wincmd L
                \ | NERDTreeClose
                \ | vertical resize 80
                \ | setlocal ft=python
                \ | wincmd h
augroup END

"-----------------------------------------------------------------------------
" 7. User Commands & Plugin Configurations
"-----------------------------------------------------------------------------
command! Compile !clear; python3 ~/tiandir/python/precomp.py %
execute 'command! GoVim   vsplit ' . fnameescape(s:plugged_dir) . ' | wincmd H | wincmd L | NERDTreeClose'
execute 'command! GoCustom vsplit ' . fnameescape(s:custom_dir) . ' | wincmd H | wincmd L | NERDTreeClose'
command! E       e %:h
command! GoPy    vsplit ~/tiandir/python/tian/auto_complete.py
            \ | wincmd H
            \ | wincmd L
            \ | NERDTreeClose
            \ | vertical resize 80
            \ | wincmd h
command! Term    call ToggleBottomTerminal()
command! Ascii   call ShowAscii(0)
command! Rainbow call rainbow_main#toggle()
nnoremap <silent> srb :call rainbow_main#toggle()<cr>

" Tagbar configuration for SystemVerilog
let g:tagbar_type_verilog_systemverilog = {
    \ 'ctagstype' : 'systemverilog',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'c:class',
        \ 'i:interface',
        \ 'f:function',
        \ 'v:variables',
        \ 'd:define',
        \ 'm:module',
        \ 't:task',
    \ ]
\ }

" vim: set filetype=vim foldmethod=marker :
