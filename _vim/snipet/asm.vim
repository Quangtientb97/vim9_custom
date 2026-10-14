"=============================================================================
" Assembly (ARM / AArch64 / AArch32) Snippets
"=============================================================================
call snippet_engine#add('asm_func_read_Ent', [
            \ '.global read_${1:func_name}',
            \ '.type read_${1:func_name}, "function"',
            \ 'read_${1:func_name}:',
            \ '    mrs x0, ${2:CNTFRQ_EL0}',
            \ '    ret',
            \ ], { 'filetype': 'asm', 'desc': 'ARM64 read system register function' })

call snippet_engine#add('asm_func_write_Ent', [
            \ '.global write_${1:func_name}',
            \ '.type write_${1:func_name}, "function"',
            \ 'write_${1:func_name}:',
            \ '    msr ${2:CNTFRQ_EL0}, x0',
            \ '    ret',
            \ ], { 'filetype': 'asm', 'desc': 'ARM64 write system register function' })

call snippet_engine#add('asm_macro_func_read_Ent', [
            \ '.macro READ_FUNC sysreg',
            \ '.global read_\sysreg',
            \ '.type read_\sysreg, "function"',
            \ 'read_\sysreg:',
            \ '    mrs x0, \sysreg',
            \ '    ret',
            \ '.endm',
            \ ], { 'filetype': 'asm', 'desc': 'ARM64 macro read function' })

call snippet_engine#add('asm_macro_func_write_Ent', [
            \ '.macro WRITE_FUNC sysreg',
            \ '.global write_\sysreg',
            \ '.type write_\sysreg, "function"',
            \ 'write_\sysreg:',
            \ '    mrs \sysreg, x0',
            \ '    ret',
            \ '.endm',
            \ ], { 'filetype': 'asm', 'desc': 'ARM64 macro write function' })

call snippet_engine#add('asm_print_func_aa32_Ent', [
            \ 'print_string:',
            \ '    mov r1, #${1:0x13000000}  // TUBE address',
            \ '1:',
            \ '    ldrb r2, [r0], #1    // Load byte from string and increment pointer',
            \ '    cmp r2, #0           // Check for null terminator',
            \ '    beq done             // If null, return',
            \ '    strb r2, [r1]        // Store byte to TUBE',
            \ '    b 1f                 // Repeat',
            \ '2:',
            \ '    bx lr                // Return',
            \ 'el_message:',
            \ '    .asciz "${2:This is EL = \n}"',
            \ ], { 'filetype': 'asm', 'desc': 'AArch32 print string via TUBE' })
