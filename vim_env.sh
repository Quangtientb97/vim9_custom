#!/bin/bash
# Environment setup for Custom Vim Configuration (bash / zsh / sh)
# Usage:
#   source /path/to/vim_custom/vim_env.sh

# Resolve directory of this script
if [ -n "$BASH_SOURCE" ]; then
    VIM_CUSTOM_DIR="$(builtin cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
elif [ -n "$ZSH_VERSION" ]; then
    VIM_CUSTOM_DIR="$(builtin cd "$(dirname "${(%):-%x}")" >/dev/null 2>&1 && pwd -P)"
else
    VIM_CUSTOM_DIR="$(builtin cd "$(dirname "$0")" >/dev/null 2>&1 && pwd -P)"
fi

export VIM_CUSTOM_DIR
export VIMINIT="source $VIM_CUSTOM_DIR/_vimrc"

# Aliases for automatic application (vim, vi, vic)
if [ -x "$HOME/.local/vim9/bin/vim" ]; then
    alias vim="$HOME/.local/vim9/bin/vim -u $VIM_CUSTOM_DIR/_vimrc"
    alias vi="$HOME/.local/vim9/bin/vim -u $VIM_CUSTOM_DIR/_vimrc"
else
    alias vim="vim -u $VIM_CUSTOM_DIR/_vimrc"
    alias vi="vim -u $VIM_CUSTOM_DIR/_vimrc"
fi
alias vic="vim -u $VIM_CUSTOM_DIR/_vimrc"

echo "[VIM_ENV] Custom Vim environment loaded from: $VIM_CUSTOM_DIR"
echo "[VIM_ENV] VIMINIT set to: $VIMINIT"
