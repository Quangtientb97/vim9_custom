let s:dict_file = expand('<sfile>:p:h:h:h') . '/dict/asm.dict'
if filereadable(s:dict_file)
    execute 'setlocal dictionary+=' . fnameescape(s:dict_file)
endif

syntax clear

syn keyword asm_keyword adc adcs add addcc addeq addge addgt addle addls addlt addne addpl adds and andcc andeq andgt containedin=ALLBUT, asm_comment 
syn keyword asm_keyword andhi andle andls andne ands andsne asr asrcs asrs b bcc bcs beq bfi bge bgt bhi bic biceq bicge containedin=ALLBUT, asm_comment 
syn keyword asm_keyword bichi biclt bicne bl ble bleq bls blt blx bmi bne bpl bx bxeq bxls bxne c cbnz cbz clz cmn cmnmi containedin=ALLBUT, asm_comment 
syn keyword asm_keyword cmp cmpcs cmpeq cmphi cmpne cmppl cpsie dsb eor eoreq eorne isb it itt ldm ldmdb ldmeq ldmib ldr containedin=ALLBUT, asm_comment 
syn keyword asm_keyword ldrb ldrbeq ldrbne ldrcc ldrd ldreq ldrge ldrgt ldrh ldrheq ldrhi ldrhlt ldrhne ldrle ldrls ldrlt containedin=ALLBUT, asm_comment 
syn keyword asm_keyword ldrne ldrsh lsl lslcc lslcs lsleq lslgt lslle lslls lslne lsls lsr lsrcc lsreq lsrhi lsrls lsrne containedin=ALLBUT, asm_comment 
syn keyword asm_keyword lsrs lsrseq mcr mcrr mla mls mov movcc movcs moveq movge movgt movhi movle movls movlt movmi movne containedin=ALLBUT, asm_comment 
syn keyword asm_keyword movpl movs movt movtle movtne movw movwle movwne mrc mrrc mul mvn mvncc mvncs mvneq mvnhi mvnlt containedin=ALLBUT, asm_comment 
syn keyword asm_keyword mvnne mvns mvnseq mvnsne nop orr orrcc orrcs orreq orrge orrgt orrle orrne orrs orrseq orrsne pop containedin=ALLBUT, asm_comment 
syn keyword asm_keyword popcc popeq popge popgt pophi pople popls popne push rev rrx rrxs rsb rsbeq rsbge rsbgt rsble rsblt containedin=ALLBUT, asm_comment 
syn keyword asm_keyword rsbmi rsbne rsbs rsbsgt rsc rscs sbc sbcs sdiv smull stm stmfd stmia stmib str strb strbls strbne containedin=ALLBUT, asm_comment 
syn keyword asm_keyword strcc strd streq strge strgt strh strheq strhi strhlt strhne strls strlt strmi strne strpl sub subcs containedin=ALLBUT, asm_comment 
syn keyword asm_keyword subeq subgt suble subne subs subseq svc teq teqeq teqne tst ubfx udiv udiveq umlal umull uxtah uxtb containedin=ALLBUT, asm_comment 
syn keyword asm_keyword uxtbne uxth vmov vmsr wfi bs ret
syn keyword asm_keyword mrs msr adr dc csel containedin=ALLBUT,asm_comment

syn keyword asm_keyword ADC ADCS ADD ADDCC ADDEQ ADDGE ADDGT ADDLE ADDLS ADDLT ADDNE ADDPL ADDS AND ANDCC ANDEQ ANDGT containedin=ALLBUT,asm_comment 
syn keyword asm_keyword ANDHI ANDLE ANDLS ANDNE ANDS ANDSNE ASR ASRCS ASRS B BCC BCS BEQ BFI BGE BGT BHI BIC BICEQ BICGE containedin=ALLBUT,asm_comment 
syn keyword asm_keyword BICHI BICLT BICNE BL BLE BLEQ BLS BLT BLX BMI BNE BPL BX BXEQ BXLS BXNE C CBNZ CBZ CLZ CMN CMNMI containedin=ALLBUT,asm_comment 
syn keyword asm_keyword CMP CMPCS CMPEQ CMPHI CMPNE CMPPL CPSIE DSB EOR EOREQ EORNE ISB IT ITT LDM LDMDB LDMEQ LDMIB LDR containedin=ALLBUT,asm_comment 
syn keyword asm_keyword LDRB LDRBEQ LDRBNE LDRCC LDRD LDREQ LDRGE LDRGT LDRH LDRHEQ LDRHI LDRHLT LDRHNE LDRLE LDRLS LDRLT containedin=ALLBUT,asm_comment 
syn keyword asm_keyword LDRNE LDRSH LSL LSLCC LSLCS LSLEQ LSLGT LSLLE LSLLS LSLNE LSLS LSR LSRCC LSREQ LSRHI LSRLS LSRNE containedin=ALLBUT,asm_comment 
syn keyword asm_keyword LSRS LSRSEQ MCR MCRR MLA MLS MOV MOVCC MOVCS MOVEQ MOVGE MOVGT MOVHI MOVLE MOVLS MOVLT MOVMI MOVNE containedin=ALLBUT,asm_comment 
syn keyword asm_keyword MOVPL MOVS MOVT MOVTLE MOVTNE MOVW MOVWLE MOVWNE MRC MRRC MUL MVN MVNCC MVNCS MVNEQ MVNHI MVNLT containedin=ALLBUT,asm_comment 
syn keyword asm_keyword MVNNE MVNS MVNSEQ MVNSNE NOP ORR ORRCC ORRCS ORREQ ORRGE ORRGT ORRLE ORRNE ORRS ORRSEQ ORRSNE POP containedin=ALLBUT,asm_comment 
syn keyword asm_keyword POPCC POPEQ POPGE POPGT POPHI POPLE POPLS POPNE PUSH REV RRX RRXS RSB RSBEQ RSBGE RSBGT RSBLE RSBLT containedin=ALLBUT,asm_comment 
syn keyword asm_keyword RSBMI RSBNE RSBS RSBSGT RSC RSCS SBC SBCS SDIV SMULL STM STMFD STMIA STMIB STR STRB STRBLS STRBNE containedin=ALLBUT,asm_comment 
syn keyword asm_keyword STRCC STRD STREQ STRGE STRGT STRH STRHEQ STRHI STRHLT STRHNE STRLS STRLT STRMI STRNE STRPL SUB SUBCS containedin=ALLBUT,asm_comment 
syn keyword asm_keyword SUBEQ SUBGT SUBLE SUBNE SUBS SUBSEQ SVC TEQ TEQEQ TEQNE TST UBFX UDIV UDIVEQ UMLAL UMULL UXTAH UXTB containedin=ALLBUT,asm_comment 
syn keyword asm_keyword UXTBNE UXTH VMOV VMSR WFI BS RET

syn match asm_block      "^\w\+:"
syn match asm_num        "\s[0-9a-zA-Z]\+\s"
syn match asm_num        "^[0-9a-zA-Z]\+\s"
syn match asm_num        "\s0x[0-9a-fA-F]\+$"
syn match asm_comment    ";.*"
syn match asm_comment    "//.*"
syn match asm_type_data  "\.\w\+"
syn match asm_in_braket  "{[^}]*}"
syn match asm_in_braket  "\[[^\]]*\]"
syn match asm_function   "<[^>]*>"
syn match asm_constant   "#-\?\w\+"
syn region asm_string    start=+"+ skip=+\\"+ end=+"+
syn match asm_string     "%\w\+"
syn match asm_string     "=\w\+"
syn match asm_constant   "\<[A-Z_][A-Z0-9_]\{2,}\>"
syn match asm_num        "\<[xw][0-9]\+\>"

highlight   asm_num         ctermfg=75  guifg=#569cd6
highlight   asm_comment     ctermfg=107 guifg=#6a9955
highlight   asm_type_data   ctermfg=13  guifg=#9170cb
highlight   asm_addr        ctermfg=250 guifg=#bcbcbc
highlight   asm_in_braket   ctermfg=42  guifg=#00d787
highlight   asm_function    ctermfg=139 guifg=#af87af
highlight   Normal          ctermfg=252 guifg=#d0d0d0
highlight   asm_keyword     ctermfg=130 guifg=#af5f00
highlight   asm_constant    cterm=none ctermfg=13 gui=none guifg=#9170cb
highlight! link Constant    asm_constant
highlight   asm_block       ctermfg=79  guifg=#4ec9b0
highlight   asm_string      ctermfg=215 guifg=#ffaf5f

" Load snippets from snipet/asm/
if exists('*snippet_engine#load_filetype')
    call snippet_engine#load_filetype('asm')
endif
