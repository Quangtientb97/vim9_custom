"=============================================================================
" SystemC & C++ Snippets
"=============================================================================
call snippet_engine#add('sc_module_Ent', [
            \ '#include <systemc.h>',
            \ '',
            \ 'SC_MODULE(${1:module_name}) {',
            \ '    // Ports',
            \ '    sc_in<bool>  ${2:clk};',
            \ '    sc_in<bool>  ${3:rst_n};',
            \ '',
            \ '    // Process methods',
            \ '    void ${4:process_name}();',
            \ '',
            \ '    SC_CTOR(${1:module_name}) {',
            \ '        SC_METHOD(${4:process_name});',
            \ '        sensitive << ${2:clk}.pos();',
            \ '        dont_initialize();',
            \ '    }',
            \ '};',
            \ ], { 'filetype': 'systemC', 'desc': 'SystemC SC_MODULE template' })

call snippet_engine#add('sc_ctor_Ent', [
            \ 'SC_CTOR(${1:module_name}) {',
            \ '    ${0}',
            \ '}',
            \ ], { 'filetype': 'systemC', 'desc': 'SystemC constructor block' })

call snippet_engine#add('sc_method_Ent', [
            \ 'SC_METHOD(${1:method_name});',
            \ 'sensitive << ${2:clk}.pos();',
            \ 'dont_initialize();${0}',
            \ ], { 'filetype': 'systemC', 'desc': 'SystemC SC_METHOD registration' })

call snippet_engine#add('sc_thread_Ent', [
            \ 'SC_THREAD(${1:thread_name});',
            \ 'sensitive << ${2:clk}.pos();${0}',
            \ ], { 'filetype': 'systemC', 'desc': 'SystemC SC_THREAD registration' })
