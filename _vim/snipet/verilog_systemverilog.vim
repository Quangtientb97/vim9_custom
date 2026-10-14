"=============================================================================
" SystemVerilog Language Snippets
"=============================================================================
call snippet_engine#add('sv_timeformat_Ent', [
            \ '$timeformat(-9, 2, "ns", 10);',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'Set default $timeformat' })

call snippet_engine#add('module_Ent', [
            \ 'module ${1:module_name} (',
            \ '    ${2:// ports}',
            \ ');',
            \ '    ${0}',
            \ 'endmodule',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'SystemVerilog module' })

call snippet_engine#add('sv_module_Ent', [
            \ 'module ${1:module_name} (',
            \ '    ${2:// ports}',
            \ ');',
            \ '    ${0}',
            \ 'endmodule',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'SystemVerilog module' })

call snippet_engine#add('class_Ent', [
            \ 'class ${1:class_name};',
            \ '    ${0}',
            \ 'endclass',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'SystemVerilog class' })

call snippet_engine#add('sv_class_Ent', [
            \ 'class ${1:class_name};',
            \ '    ${0}',
            \ 'endclass',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'SystemVerilog class' })

call snippet_engine#add('sv_ifndef_Ent', [
            \ '`ifndef ${GUARD}',
            \ '`define ${GUARD}',
            \ '',
            \ '${0}',
            \ '',
            \ '`endif /* ${GUARD} */',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'Include guard macro' })

call snippet_engine#add('sv_case_Ent', [
            \ 'case (${1:expression})',
            \ '    ${2:val1}: begin',
            \ '        ${3:// TBD}',
            \ '    end',
            \ '    ${4:val2}: begin',
            \ '        ${5:// TBD}',
            \ '    end',
            \ '    default: begin',
            \ '        ${6:// default code}',
            \ '    end',
            \ 'endcase',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'SystemVerilog case statement' })

call snippet_engine#add('sv_typedef_enum_Ent', [
            \ 'typedef enum ${1:logic [1:0]} {',
            \ '    ${2:STATE_A},',
            \ '    ${3:STATE_B},',
            \ '    ${4:STATE_C}',
            \ '} ${5:state_e};${0}',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'SystemVerilog typedef enum' })

call snippet_engine#add('sv_covergroup_Ent', [
            \ 'covergroup ${1:cg_name} @(posedge ${2:clk} iff ${3:resetn});',
            \ '    option.per_instance = 1;',
            \ '    option.goal         = 100;',
            \ '    ${4:cp0}: coverpoint ${5:variable} {',
            \ '        bins ${6:b0} = {0};',
            \ '        bins ${7:b1} = {1};',
            \ '    }',
            \ 'endgroup',
            \ '',
            \ '${1:cg_name} ${1:cg_name}_inst = new();${0}',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'SystemVerilog covergroup' })

call snippet_engine#add('sv_randomize_Ent', [
            \ 'if (!${1:var}.randomize() with {',
            \ '    ${2:// constraints}',
            \ '}) begin',
            \ '    `uvm_warning("[RANDOMIZE FAILED]", "Randomization failed for ${1:var}");',
            \ 'end',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'Randomize with error check' })

call snippet_engine#add('sv_sva_module_Ent', [
            \ '`ifndef ${GUARD}',
            \ '`define ${GUARD}',
            \ '',
            \ 'module ${1:checker_name} (',
            \ '    input logic ${2:clk},',
            \ '    input logic ${3:resetn}',
            \ ');',
            \ '',
            \ '    // ---------------------------------------------------------------',
            \ '    // Property',
            \ '    // ---------------------------------------------------------------',
            \ '    property ${4:p_req_ack};',
            \ '        @(posedge ${2:clk}) disable iff (!${3:resetn})',
            \ '        ${5:req} |-> ##[1:3] ${6:ack};',
            \ '    endproperty',
            \ '',
            \ '    // ---------------------------------------------------------------',
            \ '    // Assertion',
            \ '    // ---------------------------------------------------------------',
            \ '    assert_${4:p_req_ack}: assert property (${4:p_req_ack})',
            \ '        else `uvm_error("${1:checker_name}", "Assertion ${4:p_req_ack} failed!");',
            \ '',
            \ 'endmodule',
            \ '`endif /* ${GUARD} */',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'SystemVerilog SVA Checker module' })

call snippet_engine#add('sv_write_file_Ent', [
            \ 'begin',
            \ '    string filename = "${1:output.txt}";',
            \ '    int handle_file = $fopen(filename, "${2:a+}"); // append',
            \ '    if (handle_file == 0) begin',
            \ '        `uvm_fatal("FILE_OPEN", $sformatf("Error opening file %s", filename));',
            \ '    end',
            \ '    $fwrite(handle_file, "[%0t] %s\n", $time, "${3:helloworld}");',
            \ '    $fclose(handle_file);',
            \ 'end',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'File open, write and close block' })

call snippet_engine#add('sv_disable_fork_Ent', [
            \ 'fork begin // isolate child processes',
            \ '    fork',
            \ '        begin',
            \ '            ${1:// Process 1}',
            \ '        end',
            \ '        begin',
            \ '            ${2:// Process 2}',
            \ '        end',
            \ '    join_any',
            \ '    disable fork;',
            \ 'end join',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'Fork-join_any with disable fork' })

call snippet_engine#add('sv_timeout_Ent', [
            \ 'fork begin',
            \ '    fork',
            \ '        begin',
            \ '            #${1:10_000us};',
            \ '            `uvm_error("TIMEOUT", "Timeout occurred!");',
            \ '        end',
            \ '        begin',
            \ '            ${2:// Process to monitor}',
            \ '        end',
            \ '    join_any',
            \ '    disable fork;',
            \ 'end join',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'Timeout watchdog with fork' })

call snippet_engine#add('sv_dump_wave_Ent', [
            \ '// Option compile:    -loadpli1 debpli:novas_pli_boot -assert +access+rwc',
            \ '// Option simulation: -assert +fsdb+parallel=on +fsdb+sva_success',
            \ 'initial begin',
            \ '    $fsdbDumpfile("${1:top.fsdb}");',
            \ '    $fsdbDumpvars(0, ${2:top}, "+all");',
            \ '    $fsdbDumpSVA(0, ${2:top});',
            \ 'end',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'FSDB waveform dumping block' })

call snippet_engine#add('sv_task_thread_Ent', [
            \ 'task thread_${1:name}();',
            \ '    fork',
            \ '        begin',
            \ '            ${0:// TBD}',
            \ '        end',
            \ '    join_none',
            \ 'endtask',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'Non-blocking thread task (fork join_none)' })

call snippet_engine#add('sv_assert_Ent', [
            \ 'assert (${1:condition}) begin',
            \ '    $display("[%0t] [ASSERT PASSED] ${1:condition}", $time);',
            \ 'end else begin',
            \ '    `uvm_error(`gfn, "[ASSERT FAILED] ${1:condition}");',
            \ 'end',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'Immediate assertion with pass/fail' })

call snippet_engine#add('sv_clkgen_Ent', [
            \ '`define CLK_GEN(${1:CLOCK_HIER}, ${2:PERIOD}) \',
            \ 'always begin \',
            \ '    real period = ${2:PERIOD}; \',
            \ '    #(period/2) ${1:CLOCK_HIER} = !${1:CLOCK_HIER}; \',
            \ 'end',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'Clock generator macro' })

call snippet_engine#add('sv_interface_Ent', [
            \ 'interface ${1:if_name} (input logic ${2:clk}, input logic ${3:resetn});',
            \ '    ${0}',
            \ 'endinterface',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'SystemVerilog interface' })

call snippet_engine#add('sv_template_Ent', [
            \ '//----------------------------------------------------------------------',
            \ '//  File name     : ${FILENAME}',
            \ '//  Function      : <empty>',
            \ '//  Author        : ${AUTHOR}',
            \ '//  Email         : ${EMAIL}',
            \ '//  Created time  : ${DATETIME}',
            \ '//----------------------------------------------------------------------',
            \ '`ifndef ${GUARD}',
            \ '`define ${GUARD}',
            \ '',
            \ '${0}',
            \ '',
            \ '`endif /* ${GUARD} */',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'SystemVerilog file header template' })

call snippet_engine#add('sv_task_Ent', [
            \ 'task ${1:task_name}();',
            \ '    ${0}',
            \ 'endtask',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'SystemVerilog task' })

call snippet_engine#add('sv_func_Ent', [
            \ 'function void ${1:func_name}();',
            \ '    ${0}',
            \ 'endfunction',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'SystemVerilog void function' })

"=============================================================================
" UVM (Universal Verification Methodology) Snippets
"=============================================================================
call snippet_engine#add('uvm_build_phase_Ent', [
            \ '// Build phase',
            \ 'virtual function void build_phase(uvm_phase phase);',
            \ '    `uvm_info(`gfn, "build_phase() start ...", UVM_LOW);',
            \ '    super.build_phase(phase);',
            \ '    ${0}',
            \ 'endfunction',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM build_phase' })

call snippet_engine#add('uvm_connect_phase_Ent', [
            \ 'virtual function void connect_phase(uvm_phase phase);',
            \ '    `uvm_info(`gfn, "connect_phase() start ...", UVM_LOW);',
            \ '    super.connect_phase(phase);',
            \ '    ${0}',
            \ 'endfunction',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM connect_phase' })

call snippet_engine#add('uvm_end_of_elaboration_phase_Ent', [
            \ 'virtual function void end_of_elaboration_phase(uvm_phase phase);',
            \ '    `uvm_info(`gfn, "end_of_elaboration_phase() start ...", UVM_LOW);',
            \ '    super.end_of_elaboration_phase(phase);',
            \ '    ${0}',
            \ 'endfunction',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM end_of_elaboration_phase' })

call snippet_engine#add('uvm_start_of_simulation_phase_Ent', [
            \ 'virtual function void start_of_simulation_phase(uvm_phase phase);',
            \ '    `uvm_info(`gfn, "start_of_simulation_phase() start ...", UVM_LOW);',
            \ '    super.start_of_simulation_phase(phase);',
            \ '    ${0}',
            \ 'endfunction',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM start_of_simulation_phase' })

call snippet_engine#add('uvm_start_of_simualation_phase_Ent', [
            \ 'virtual function void start_of_simulation_phase(uvm_phase phase);',
            \ '    `uvm_info(`gfn, "start_of_simulation_phase() start ...", UVM_LOW);',
            \ '    super.start_of_simulation_phase(phase);',
            \ '    ${0}',
            \ 'endfunction',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM start_of_simulation_phase' })

call snippet_engine#add('uvm_extract_phase_Ent', [
            \ 'virtual function void extract_phase(uvm_phase phase);',
            \ '    `uvm_info(`gfn, "extract_phase() start ...", UVM_LOW);',
            \ '    super.extract_phase(phase);',
            \ '    ${0}',
            \ 'endfunction',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM extract_phase' })

call snippet_engine#add('uvm_check_phase_Ent', [
            \ 'virtual function void check_phase(uvm_phase phase);',
            \ '    `uvm_info(`gfn, "check_phase() start ...", UVM_LOW);',
            \ '    super.check_phase(phase);',
            \ '    ${0}',
            \ 'endfunction',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM check_phase' })

call snippet_engine#add('uvm_report_phase_Ent', [
            \ 'virtual function void report_phase(uvm_phase phase);',
            \ '    `uvm_info(`gfn, "report_phase() start ...", UVM_LOW);',
            \ '    super.report_phase(phase);',
            \ '    ${0}',
            \ 'endfunction',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM report_phase' })

call snippet_engine#add('uvm_final_phase_Ent', [
            \ 'virtual function void final_phase(uvm_phase phase);',
            \ '    `uvm_info(`gfn, "final_phase() start ...", UVM_LOW);',
            \ '    super.final_phase(phase);',
            \ '    ${0}',
            \ 'endfunction',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM final_phase' })

call snippet_engine#add('uvm_run_phase_Ent', [
            \ 'virtual task run_phase(uvm_phase phase);',
            \ '    `uvm_info(`gfn, "run_phase() start ...", UVM_LOW);',
            \ '    super.run_phase(phase);',
            \ '    // phase.raise_objection(this);',
            \ '    ${0}',
            \ '    // phase.drop_objection(this);',
            \ 'endtask',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM run_phase task' })

call snippet_engine#add('uvm_body_Ent', [
            \ '// body()',
            \ '//     NOTE: Do not call super.body if this class',
            \ '//           extends directly from uvm_sequence',
            \ 'virtual task body();',
            \ '    `uvm_info(`gfn, "body() start ...", UVM_LOW);',
            \ '    // super.body();',
            \ '    ${0}',
            \ 'endtask',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM sequence body task' })

call snippet_engine#add('uvm_new_object_Ent', [
            \ 'function new(string name = "");',
            \ '    super.new(name);',
            \ '    ${0}',
            \ 'endfunction',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM object constructor' })

call snippet_engine#add('uvm_new_component_Ent', [
            \ 'function new(string name = "", uvm_component parent);',
            \ '    super.new(name, parent);',
            \ '    ${0}',
            \ 'endfunction',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM component constructor' })

call snippet_engine#add('uvm_info_Ent', [
            \ '`uvm_info(`gfn, "${1:message}", ${2:UVM_LOW});${0}',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM `uvm_info macro' })

call snippet_engine#add('uvm_info_psprintf_Ent', [
            \ '`uvm_info(`gfn, $sformatf("${1:format_str}", ${2:args}), ${3:UVM_LOW});${0}',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM `uvm_info with $sformatf' })

call snippet_engine#add('uvm_config_db_get_Ent', [
            \ 'if (uvm_config_db#(${1:type})::get(${2:this}, "${3:inst_name}", "${4:field_name}", ${5:val})) begin',
            \ '    `uvm_info(`gfn, {`gfn, ".${4:field_name} has been found in ConfigDB."}, UVM_LOW);',
            \ 'end else begin',
            \ '    `uvm_fatal(`gfn, {`gfn, ".${4:field_name} cannot be found in ConfigDB!"});',
            \ 'end',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM config_db get with check' })

call snippet_engine#add('uvm_config_db_set_Ent', [
            \ 'uvm_config_db#(${1:type})::set(${2:this}, "${3:inst_name}", "${4:field_name}", ${5:val});${0}',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM config_db set' })

call snippet_engine#add('uvm_sequence_Ent', [
            \ 'class ${1:seq_name} extends ${2:uvm_sequence};',
            \ '    `uvm_object_utils(${1:seq_name})',
            \ '',
            \ '    function new(string name = "${1:seq_name}");',
            \ '        super.new(name);',
            \ '    endfunction',
            \ '',
            \ '    virtual task body();',
            \ '        `uvm_info(`gfn, "body() start ...", UVM_LOW);',
            \ '        ${0}',
            \ '    endtask',
            \ 'endclass',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM sequence class definition' })

call snippet_engine#add('uvm_do_with_Ent', [
            \ '`uvm_do_with(${1:req}, { ${2:Addr == addr; Data == data;} });${0}',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM `uvm_do_with macro' })

call snippet_engine#add('uvm_do_sequence_item_Ent', [
            \ '`uvm_create(${1:req});',
            \ 'if (!${1:req}.randomize() with { ${2:direction == READ;} }) begin',
            \ '    `uvm_fatal(`gfn, "Transaction randomize error");',
            \ 'end',
            \ '`uvm_send(${1:req});',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'Manual uvm_create, randomize, and uvm_send' })

call snippet_engine#add('uvm_component_Ent', [
            \ '// Class: ${1:comp_name}',
            \ 'class ${1:comp_name} extends ${2:uvm_component};',
            \ '    `uvm_component_utils(${1:comp_name})',
            \ '',
            \ '    function new(string name = "${1:comp_name}", uvm_component parent = null);',
            \ '        super.new(name, parent);',
            \ '    endfunction',
            \ '',
            \ '    virtual function void build_phase(uvm_phase phase);',
            \ '        `uvm_info(`gfn, "build_phase() start ...", UVM_LOW);',
            \ '        super.build_phase(phase);',
            \ '    endfunction',
            \ '',
            \ '    virtual function void connect_phase(uvm_phase phase);',
            \ '        super.connect_phase(phase);',
            \ '        `uvm_info(`gfn, "connect_phase() start ...", UVM_LOW);',
            \ '    endfunction',
            \ '',
            \ '    virtual task run_phase(uvm_phase phase);',
            \ '        `uvm_info(`gfn, "run_phase() start ...", UVM_LOW);',
            \ '        super.run_phase(phase);',
            \ '        ${0}',
            \ '    endtask',
            \ 'endclass',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM component class template' })

call snippet_engine#add('uvm_object_Ent', [
            \ 'class ${1:obj_name} extends ${2:uvm_object};',
            \ '    `uvm_object_utils(${1:obj_name})',
            \ '',
            \ '    function new(string name = "${1:obj_name}");',
            \ '        super.new(name);',
            \ '    endfunction',
            \ '',
            \ '    ${0}',
            \ 'endclass',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM object class template' })

call snippet_engine#add('uvm_analysis_imp_decl_Ent', [
            \ '`uvm_analysis_imp_decl(_${1:port_name})',
            \ 'uvm_analysis_imp_${1:port_name} #(${2:trans_t}, ${3:this_type}) ${1:port_name}_imp;',
            \ '',
            \ 'virtual function void write_${1:port_name}(${2:trans_t} trans);',
            \ '    ${0}',
            \ 'endfunction',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM analysis imp declaration' })

call snippet_engine#add('uvm_raise_objection_Ent', [
            \ 'phase.raise_objection(this);',
            \ '${0}',
            \ 'phase.drop_objection(this);',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM raise/drop objection block' })

call snippet_engine#add('uvm_create_Ent', [
            \ '`uvm_create(${1:seq_item});',
            \ 'assert(${1:seq_item}.randomize());',
            \ '`uvm_send(${1:seq_item});${0}',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'UVM create, randomize, and send' })

call snippet_engine#add('uvm_get_factory_Ent', [
            \ 'uvm_coreservice_t::get().get_factory();${0}',
            \ ], { 'filetype': 'verilog_systemverilog', 'desc': 'Get UVM factory instance' })
