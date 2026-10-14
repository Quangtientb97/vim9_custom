"=============================================================================
" Python Snippets
"=============================================================================
call snippet_engine#add('py_env_Ent', [
            \ '#!/usr/bin/python3',
            \ '#----------------------------------------------------------------------',
            \ '#  File name     : ${FILENAME}',
            \ '#  Function      : <empty>',
            \ '#  Author        : ${AUTHOR}',
            \ '#  Email         : ${EMAIL}',
            \ '#  Created time  : ${DATETIME}',
            \ '#----------------------------------------------------------------------',
            \ 'import re, os, argparse',
            \ 'import sys',
            \ 'for _p in ["/home/tientq/tiandir/python", "/mnt/users/tientq/tiandir/python"]:',
            \ '    if os.path.exists(_p) and _p not in sys.path:',
            \ '        sys.path.append(_p)',
            \ '        sys.path.append(f"{_p}/pylib")',
            \ 'import tian',
            \ 'from   tian           import this_file, this_dir',
            \ '',
            \ '# --------------------------------------------------------------------+',
            \ '# Function declare                                                    |',
            \ '# --------------------------------------------------------------------+',
            \ 'def get_args():',
            \ '    parser = argparse.ArgumentParser(description="${1:File description}")',
            \ '    # Add arguments',
            \ '    parser.add_argument("-f", "--file", type=str, required=True, help="input file link")',
            \ '    parser.add_argument(      "--on"  , action="store_true", required=False, help="boolean variable take True/False")',
            \ '    return parser.parse_args()',
            \ '',
            \ '# --------------------------------------------------------------------+',
            \ '# main                                                                |',
            \ '# --------------------------------------------------------------------+',
            \ 'def main() -> int:',
            \ '    args = get_args()',
            \ '    print("Start...")',
            \ '    ${2}',
            \ '    return 0',
            \ '',
            \ '# --------------------------------------------------------------------+',
            \ '# Script entry point                                                  |',
            \ '# --------------------------------------------------------------------+',
            \ 'if __name__ == "__main__":',
            \ '    tian.time.start()',
            \ '    rc = main()',
            \ '    print(f"Command: ''python3 {'' ''.join(sys.argv)}''")',
            \ '    tian.time.end()',
            \ '    sys.exit(rc)',
            \ ], { 'filetype': 'python', 'desc': 'Standard Python script template' })

call snippet_engine#add('py_parallel_Ent', [
            \ 'from concurrent.futures import ThreadPoolExecutor',
            \ 'with ThreadPoolExecutor() as executor:',
            \ '    # Create sheets in parallel',
            \ '    executor.map(lambda ${1:register}: ${2:create_reg_sheet(workexcel, register)}, ${3:registers})',
            \ ], { 'filetype': 'python', 'desc': 'Parallel ThreadPoolExecutor block' })

call snippet_engine#add('py_help_Ent', [
            \ 'if (tian.argv.get_argument_by_prefix("-h")) or (len(sys.argv) == 1):',
            \ '    fd = os.path.dirname(__file__)',
            \ '    tian.run(f"cat {fd}/README")',
            \ '    ${0}',
            \ ], { 'filetype': 'python', 'desc': 'Display README on -h argument' })

call snippet_engine#add('py_try_Ent', [
            \ 'try:',
            \ '    ${1:pass}',
            \ 'except Exception as e:',
            \ '    print("Error:", e)',
            \ '    ${0}',
            \ ], { 'filetype': 'python', 'desc': 'Try-except block' })

call snippet_engine#add('py_excel_Ent', [
            \ 'tian.excel.create_excel_file("${1:filename.xlsx}")',
            \ 'workexcel = tian.excel("${1:filename.xlsx}")',
            \ 'workbook  = tian.wb',
            \ '#workexcel.create_sheet("Summary")',
            \ '#workexcel.remove_sheet("Sheet")',
            \ '${0}',
            \ ], { 'filetype': 'python', 'desc': 'Tian Excel helper initialization' })

call snippet_engine#add('py_tqdm_Ent', [
            \ 'from tqdm import tqdm',
            \ 'pbar = tqdm(${1:items}, bar_format="{n_fmt}/{total_fmt} | {desc}")',
            \ 'pbar.set_description("${2:Processing...}")',
            \ 'for ${3:item} in pbar:',
            \ '    ${0}',
            \ ], { 'filetype': 'python', 'desc': 'Tqdm progress bar loop' })
