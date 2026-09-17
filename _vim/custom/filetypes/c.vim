"=============================================================================
" C Language Syntax & Dictionary Configuration
"=============================================================================
execute "setlocal dictionary+=" . expand("<sfile>:p")

syn match C_braket 	        "[=*,;(){}]"                  containedin=ALLBUT,cComment,C_string,cComment,C_not
syn region  C_String      start=+"+ skip=+\\"+ end=+"+    
"syn match C_string 	        "\".*\""                      containedin=ALLBUT,cComment
"syn match C_string 	        "<[a-zA-Z0-9.][a-zA-Z0-9.]*>" containedin=ALLBUT,cComment
syn match C_constant 	    "\s[A-Z][A-Z][A-Z]\w*"        containedin=ALLBUT,C_braket,cComment,Comment,C_string,cComment,C_funtion
syn match C_constant 	    "\s[A-Z][0-9][A-Z]\w*"        containedin=ALLBUT,C_braket,cComment,Comment,C_string,cComment,C_funtion
syn match C_constant 	    "__[A-Z][A-Z][A-Z]\w*"        containedin=ALLBUT,C_braket,cComment,Comment,C_string,cComment,C_funtion
syn match C_constant 	    "[(=][A-Z][A-Z][A-Z]\w*"      containedin=ALLBUT,cComment,Comment,C_string,cComment
syn match C_funtion 		"\s\w*("                      containedin=ALLBUT,C_braket,cComment,C_condition,C_string,cComment
syn match C_funtion 		"[(,=]\w*("                   containedin=ALLBUT,C_braket,cComment,C_condition,C_string,cComment
syn match C_funtion 		"*\w*("                       containedin=ALLBUT,C_braket,cComment,C_condition,C_string,cComment
syn match C_funtion 		"\s\w*\s*("                   containedin=ALLBUT,C_braket,cComment,C_condition,C_string,cComment
syn match C_funtion 		"uint\d*"                     containedin=ALLBUT,C_braket,cComment,C_condition,C_string,cComment
syn match C_addr 			"[&|]"                        containedin=ALLBUT,C_braket,cComment
syn match C_not 			"!\w\w*"                      containedin=ALLBUT,C_braket,cComment
syn match C_not 			"#ifndef"                     containedin=ALLBUT,C_braket,cComment
syn match C_not 			"!="                          containedin=ALLBUT,C_braket,cComment
syn match C_not 			"\\[nr]"                      containedin=ALLBUT,C_braket,cComment
syn match C_not 			"%\d*[dxsf]"                  containedin=ALLBUT,C_braket,cComment
syn match C_not 			"%lx"                         containedin=ALLBUT,C_braket,cComment
syn match C_not 			"\~\w*"                       containedin=ALLBUT,C_braket,cComment
syn match C_index 		    "\[\w*\]"                     containedin=ALLBUT,C_braket,cComment
syn match C_include 		"#\w*"                        containedin=ALLBUT,C_braket,cComment
syn match C_number 		    "0b[01]*"                     containedin=ALLBUT,cComment
syn match C_property 	    "->\w\w*"                     containedin=ALLBUT,cComment
syn match C_struct 	        "\.\w*"                       containedin=ALLBUT,cComment
syn keyword C_condition     if else return do while for   containedin=ALLBUT,C_braket,cComment,C_include,C_string,cComment
syn keyword C_void          void                          containedin=ALLBUT,C_braket,cComment,C_include,C_string,cComment


syn match C_type 		"\su\d\d*\s" 	containedin=ALL,cComment
syn match C_type 		"\Wu\d\d*\W" 	containedin=ALL,cComment,C_braket
syn match C_type 		"\su\d\d*\s" 	containedin=ALL,cComment

syn match Ccomment 		"//.*" 	containedin=ALL


highlight C_constant  ctermfg=13"cyan
highlight C_type      ctermfg=blue
highlight C_funtion   ctermfg=blue
highlight C_addr      ctermfg=red
highlight C_not       ctermfg=42
highlight C_index     ctermfg=42
highlight C_condition ctermfg=176"139
highlight C_include   ctermfg=139
highlight C_number    ctermfg=brown
highlight C_void      ctermfg=yellow
highlight C_property  ctermfg=215
highlight C_string    ctermfg=215
highlight C_struct    ctermfg=215
highlight Statement   ctermfg=139
highlight Normal      ctermfg=254

set dictionary+=~/gen_aarch32_reg/cpu.c

" get and upper the file name
" <c-r>=substitute(toupper(expand('%:t')), '\.', '_', 'g')
inorea c_template_c_Ent /* Includes ------------------------------------------------------------------*/<cr>
            \#include <stdio.h><cr>
            \#include "tprintf.h"<cr>
            \<cr>
            \/* Private typedef -----------------------------------------------------------*/<cr>
            \<cr>
            \/* Private define ------------------------------------------------------------*/<cr>
            \<cr>
            \/* Private macro -------------------------------------------------------------*/<cr>
            \<cr>
            \/* Private variables ---------------------------------------------------------*/<cr>
            \unsigned int err_code;<cr>
            \<cr>
            \/* external variables --------------------------------------------------------*/<cr>
            \<cr>
            \/* Private function prototypes -----------------------------------------------*/<cr>
            \<cr>
            \/* Exported functions --------------------------------------------------------*/<cr>
            \int main(void){<cr>
            \/* User start */<cr>
            \<cr>
            \/* End simulation */<cr>
            \tube_end_sim();<cr>
            \}<cr><esc><esc>ggVG=/User start<cr>

inorea c_template_h_Ent #ifndef __<c-r>=substitute(toupper(expand('%:t')), '\.', '_', 'g')<cr>__<cr>
            \#define __<c-r>=substitute(toupper(expand('%:t')), '\.', '_', 'g')<cr>__<cr>
            \<cr>
            \/* Includes ------------------------------------------------------------------*/<cr> 
            \<cr>
            \/* Private typedef -----------------------------------------------------------*/<cr>
            \<cr>
            \/* Private define ------------------------------------------------------------*/<cr>
            \<cr>
            \/* Private macro -------------------------------------------------------------*/<cr>
            \<cr>
            \/* Private variables ---------------------------------------------------------*/<cr>
            \<cr>
            \/* external variables --------------------------------------------------------*/<cr>
            \<cr>
            \/* Private function prototypes -----------------------------------------------*/<cr>
            \<cr>
            \/* Exported functions --------------------------------------------------------*/<cr>
            \<cr>
            \#endif /* __<c-r>=substitute(toupper(expand('%:t')), '\.', '_', 'g')<cr>__ */<esc>

inorea c_include_Ent #include <stdio.h><cr>
            \#include <stdint.h><cr>
            \#include <string.h><cr>

inorea c_macro_Ent <esc>:set formatoptions-=cro<cr>i
            \#include <stdio.h><cr>
            \#include <stdint.h><cr>
            \#define WRITE32(addr, data) (*((volatile uint32_t *)(addr)) = (data))<cr>
            \#define READ32(addr) (*((volatile uint32_t *)(addr)))<cr>
            \<cr>
            \#define READ_FUNC(reg_name)                                \<cr>
            \static inline uint64_t read_##reg_name(void) {         \<cr>
            \uint64_t value;                                    \<cr>
            \asm volatile("mrs %0, "#reg_name : "=r" (value));  \<cr>
            \return value;                                      \<cr>
            \} <cr>
            \<cr>
            \#define WRITE_FUNC(reg_name)                                            \<cr>
            \static inline void write_##reg_name(uint64_t value) {               \<cr>
            \asm volatile("msr "#reg_name", %0" : : "r" (value) : "memory"); \<cr>
            \}<cr>
            \<esc>=:set formatoptions+=cro<cr>

finish
"=============================================================================
" Dictionary Keywords (used for <C-n>/<C-x><C-k> autocomplete)
"=============================================================================
auto double int struct
break else long switch
case enum register typedef
char extern return union
continue for signed void
do if static while
default goto sizeof volatile
const float short unsigned printf while
long short char

uint32_t uint8_t uint16_t uint64_t
int32_t int8_t int16_t int64_t
csv_low
csv_none csv_sim_end

BIT0_SET 
BIT1_SET 
BIT2_SET 
BIT3_SET 
BIT4_SET 
BIT5_SET 
BIT6_SET 
BIT7_SET 
BIT8_SET 
BIT9_SET 
BIT10_SET
BIT11_SET
BIT12_SET
BIT13_SET
BIT14_SET
BIT15_SET
BIT16_SET
BIT17_SET
BIT18_SET
BIT19_SET
BIT20_SET
BIT21_SET
BIT22_SET
BIT23_SET
BIT24_SET
BIT25_SET
BIT26_SET
BIT27_SET
BIT28_SET
BIT29_SET
BIT30_SET
BIT31_SET
         
BIT0_CLR 
BIT1_CLR 
BIT2_CLR 
BIT3_CLR 
BIT4_CLR 
BIT5_CLR 
BIT6_CLR 
BIT7_CLR 
BIT8_CLR 
BIT9_CLR 
BIT10_CLR
BIT11_CLR
BIT12_CLR
BIT13_CLR
BIT14_CLR
BIT15_CLR
BIT16_CLR
BIT17_CLR
BIT18_CLR
BIT19_CLR
BIT20_CLR
BIT21_CLR
BIT22_CLR
BIT23_CLR
BIT24_CLR
BIT25_CLR
BIT26_CLR
BIT27_CLR
BIT28_CLR
BIT29_CLR
BIT30_CLR
BIT31_CLR
