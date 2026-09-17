#!/bin/csh -f
# Environment setup for Custom Vim Configuration (csh / tcsh)
# Usage:
#   source /path/to/vim_custom/vim_env.csh

set script_path = ""

# Method 1: Linux /proc file descriptor check when sourced
if ( -d /proc/$$/fd ) then
    set sp = `\ls -l /proc/$$/fd | sed -n 's/.*-> //p' | grep 'vim_env.*\.csh' | tail -1`
    if ( "$sp" != "" ) set script_path = "$sp"
endif

# Method 2: Check if current directory or known locations have _vimrc
if ( "$script_path" == "" ) then
    if ( -f "$cwd/_vimrc" && -f "$cwd/vim_env.csh" ) then
        set script_path = "$cwd/vim_env.csh"
    else if ( -f "$cwd/vim_custom/_vimrc" && -f "$cwd/vim_custom/vim_env.csh" ) then
        set script_path = "$cwd/vim_custom/vim_env.csh"
    endif
endif

# Method 3: Resolve directory without triggering cd/ls aliases
if ( "$script_path" != "" && -f "$script_path" ) then
    if ( "$script_path:h" == "$script_path" ) then
        setenv VIM_CUSTOM_DIR `readlink -f "$cwd"`
    else
        setenv VIM_CUSTOM_DIR `readlink -f "$script_path:h"`
    endif
else
    # Fallback to current directory or standard path
    if ( -f "$cwd/_vimrc" ) then
        setenv VIM_CUSTOM_DIR `readlink -f "$cwd"`
    else if ( -f "$cwd/vim_custom/_vimrc" ) then
        setenv VIM_CUSTOM_DIR `readlink -f "$cwd/vim_custom"`
    else
        setenv VIM_CUSTOM_DIR "$cwd"
    endif
endif

setenv VIMINIT "source $VIM_CUSTOM_DIR/_vimrc"

# Aliases for automatic application (vim, vi, vic)
if ( -x "$HOME/.local/vim9/bin/vim" ) then
    alias vim "$HOME/.local/vim9/bin/vim -u $VIM_CUSTOM_DIR/_vimrc"
    alias vi  "$HOME/.local/vim9/bin/vim -u $VIM_CUSTOM_DIR/_vimrc"
else
    alias vim "vim -u $VIM_CUSTOM_DIR/_vimrc"
    alias vi  "vim -u $VIM_CUSTOM_DIR/_vimrc"
endif
alias vic "vim -u $VIM_CUSTOM_DIR/_vimrc"

echo "[VIM_ENV] Custom Vim environment loaded from: $VIM_CUSTOM_DIR"
echo "[VIM_ENV] VIMINIT set to: $VIMINIT"
