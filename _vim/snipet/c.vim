"=============================================================================
" C Language Snippets
"=============================================================================
call snippet_engine#add('c_template_c_Ent', [
            \ '/* Includes ------------------------------------------------------------------*/',
            \ '#include <stdio.h>',
            \ '#include <stdint.h>',
            \ '#include "tprintf.h"',
            \ '',
            \ '/* Private typedef -----------------------------------------------------------*/',
            \ '',
            \ '/* Private define ------------------------------------------------------------*/',
            \ '',
            \ '/* Private macro -------------------------------------------------------------*/',
            \ '',
            \ '/* Private variables ---------------------------------------------------------*/',
            \ 'unsigned int err_code;',
            \ '',
            \ '/* external variables --------------------------------------------------------*/',
            \ '',
            \ '/* Private function prototypes -----------------------------------------------*/',
            \ '',
            \ '/* Exported functions --------------------------------------------------------*/',
            \ 'int main(void) {',
            \ '    /* User start */',
            \ '    ${0}',
            \ '    /* End simulation */',
            \ '    tube_end_sim();',
            \ '    return 0;',
            \ '}',
            \ ], { 'filetype': 'c', 'desc': 'Standard C simulation file template' })

call snippet_engine#add('c_template_h_Ent', [
            \ '#ifndef ${GUARD}',
            \ '#define ${GUARD}',
            \ '',
            \ '/* Includes ------------------------------------------------------------------*/',
            \ '#include <stdint.h>',
            \ '',
            \ '/* Exported types ------------------------------------------------------------*/',
            \ '',
            \ '/* Exported constants --------------------------------------------------------*/',
            \ '',
            \ '/* Exported macro ------------------------------------------------------------*/',
            \ '',
            \ '/* Exported functions --------------------------------------------------------*/',
            \ '${0}',
            \ '',
            \ '#endif /* ${GUARD} */',
            \ ], { 'filetype': 'c', 'desc': 'Standard C header file template' })

call snippet_engine#add('c_include_Ent', [
            \ '#include <stdio.h>',
            \ '#include <stdint.h>',
            \ '#include <stdbool.h>',
            \ '#include <string.h>',
            \ '${0}',
            \ ], { 'filetype': 'c', 'desc': 'Standard C library includes' })

call snippet_engine#add('c_macro_Ent', [
            \ '#include <stdio.h>',
            \ '#include <stdint.h>',
            \ '#define WRITE32(addr, data) (*((volatile uint32_t *)(addr)) = (data))',
            \ '#define READ32(addr)         (*((volatile uint32_t *)(addr)))',
            \ '',
            \ '#define READ_FUNC(reg_name)                                \\',
            \ 'static inline uint64_t read_##reg_name(void) {             \\',
            \ '    uint64_t value;                                         \\',
            \ '    asm volatile("mrs %0, "#reg_name : "=r" (value));       \\',
            \ '    return value;                                           \\',
            \ '}',
            \ '',
            \ '#define WRITE_FUNC(reg_name)                                                \\',
            \ 'static inline void write_##reg_name(uint64_t value) {                       \\',
            \ '    asm volatile("msr "#reg_name", %0" : : "r" (value) : "memory");         \\',
            \ '}',
            \ ], { 'filetype': 'c', 'desc': 'MMIO and system register read/write macros' })

call snippet_engine#add('c_main_Ent', [
            \ '#include <stdio.h>',
            \ '#include <stdint.h>',
            \ '',
            \ 'int main(int argc, char *argv[]) {',
            \ '    ${0}',
            \ '    return 0;',
            \ '}',
            \ ], { 'filetype': 'c', 'desc': 'Standard main function' })

call snippet_engine#add('c_for_Ent', [
            \ 'for (uint32_t ${1:i} = 0; ${1:i} < ${2:count}; ${1:i}++) {',
            \ '    ${0}',
            \ '}',
            \ ], { 'filetype': 'c', 'desc': 'For loop' })

call snippet_engine#add('c_func_Ent', [
            \ '${1:void} ${2:func_name}(${3:void}) {',
            \ '    ${0}',
            \ '}',
            \ ], { 'filetype': 'c', 'desc': 'Function definition' })
