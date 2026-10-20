#!/usr/bin/env bash
# =============================================================================
# Automated Test Runner for Vim Custom Environment
# Usage:
#   ./run_tests.sh          # Run all test suites
#   ./run_tests.sh indent   # Run SystemVerilog indentation tests
#   ./run_tests.sh make     # Run Makefile syntax tests
#   ./run_tests.sh sanity   # Run Vimrc sanity & configuration tests
#   ./run_tests.sh eng      # Run Engineering utilities (ConvertBase, QuickCalc, ShowAscii)
#   ./run_tests.sh snip     # Run Snippet Engine & Template Expansions
#   ./run_tests.sh edit     # Run Advanced Editing (Verilog Align, SplitJoin, Surround, Dox)
#   ./run_tests.sh status   # Run Statusline & Large File Optimization tests
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIM_CUSTOM_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
VIMRC="${VIM_CUSTOM_DIR}/_vimrc"

# Color definitions
GREEN="\033[0;32m"
RED="\033[0;31m"
CYAN="\033[0;36m"
BOLD="\033[1m"
NC="\033[0m"

VIM_BIN="${VIM_BIN:-$(which vim 2>/dev/null || which nvim 2>/dev/null)}"

if [ -z "${VIM_BIN}" ]; then
    echo -e "${RED}[ERROR] No vim binary found in PATH!${NC}"
    exit 1
fi

run_suite() {
    local suite_name="$1"
    local suite_file="$2"

    echo ""
    echo -e "${CYAN}${BOLD}>>> Running Suite: ${suite_name}...${NC}"
    
    if "${VIM_BIN}" --cmd "let g:testing_mode = 1" -u "${VIMRC}" -S "${suite_file}"; then
        echo -e "${GREEN}${BOLD}✔ [PASSED] ${suite_name}${NC}"
        return 0
    else
        echo -e "${RED}${BOLD}✘ [FAILED] ${suite_name}${NC}"
        return 1
    fi
}

TARGET="${1:-all}"
FAILED=0
PASSED=0

echo -e "${BOLD}=====================================================================${NC}"
echo -e "${BOLD}  Vim Automated Regression Test Suite${NC}"
echo -e "  Vim Binary: ${VIM_BIN} ($("${VIM_BIN}" --version | head -n 1))"
echo -e "  Vimrc Path: ${VIMRC}"
echo -e "${BOLD}=====================================================================${NC}"

if [ "${TARGET}" = "all" ] || [ "${TARGET}" = "indent" ]; then
    if run_suite "SystemVerilog Indentation" "${SCRIPT_DIR}/test_indent_sv.vim"; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi
fi

if [ "${TARGET}" = "all" ] || [ "${TARGET}" = "make" ]; then
    if run_suite "Makefile Syntax Highlighting" "${SCRIPT_DIR}/test_syntax_make.vim"; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi
fi

if [ "${TARGET}" = "all" ] || [ "${TARGET}" = "sanity" ]; then
    if run_suite "Vimrc Configuration & Sanity" "${SCRIPT_DIR}/test_config_sanity.vim"; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi
fi

if [ "${TARGET}" = "all" ] || [ "${TARGET}" = "eng" ]; then
    if run_suite "Engineering Utilities (ConvertBase, QuickCalc, ShowAscii)" "${SCRIPT_DIR}/test_engineering_tools.vim"; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi
fi

if [ "${TARGET}" = "all" ] || [ "${TARGET}" = "snip" ]; then
    if run_suite "Snippet Engine & Templates" "${SCRIPT_DIR}/test_snippet_engine.vim"; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi
fi

if [ "${TARGET}" = "all" ] || [ "${TARGET}" = "edit" ]; then
    if run_suite "Advanced Editing Operations (Align, SplitJoin, Surround, Dox)" "${SCRIPT_DIR}/test_editing_ops.vim"; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi
fi

if [ "${TARGET}" = "all" ] || [ "${TARGET}" = "status" ]; then
    if run_suite "Statusline & Large File Optimization" "${SCRIPT_DIR}/test_statusline_largefile.vim"; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi
fi

echo ""
echo -e "${BOLD}=====================================================================${NC}"
echo -e "${BOLD}FINAL TEST RESULTS SUMMARY:${NC}"
echo -e "  Suites Passed: ${GREEN}${PASSED}${NC}"
echo -e "  Suites Failed: ${RED}${FAILED}${NC}"
echo -e "${BOLD}=====================================================================${NC}"

if [ "${FAILED}" -gt 0 ]; then
    exit 1
else
    echo -e "${GREEN}${BOLD}ALL TEST SUITES COMPLETED SUCCESSFULLY!${NC}"
    exit 0
fi
