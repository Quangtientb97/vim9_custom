"   sv_assert_Ent                        
"   sv_assert_Ent                        
"   sv_case_Ent                          
"   sv_covergroup_Ent                    
"   sv_disable_fork_Ent                  
"   sv_dump_wave_Ent                     
"   sv_func_compare_array                
"   sv_func_compare_data                 
"   sv_func_has_substr                   
"   sv_guardian_Ent                      
"   sv_ifndef_Ent                        
"   sv_randomize_Ent                     
"   sv_sva_module_Ent                    
"   sv_task_thread_Ent                   
"   sv_timeout_Ent                       
"   sv_typedef_enum_Ent                  
"   sv_write_file_Ent                    
"   uvm_body_Ent                         
"   uvm_build_phase_Ent                  
"   uvm_check_phase_Ent                  
"   uvm_common_macros_Ent                
"   uvm_config_db_get_Ent                
"   uvm_connect_phase_Ent                
"   uvm_end_of_elaboration_phase_Ent     
"   uvm_extract_phase_Ent                
"   uvm_final_phase_Ent                  
"   uvm_info_Ent                         
"   uvm_info_psprintf_Ent                
"   uvm_new_component_Ent                
"   uvm_new_object_Ent                   
"   uvm_report_phase_Ent                 
"   uvm_run_phase_Ent                    
"   uvm_sequence_Ent                     
"   uvm_start_of_simualation_phase_Ent   


"--------------------------------------------------------------------+
" Template                                                           |
"--------------------------------------------------------------------+
"inorea sv_example_Ent <esc>:set formatoptions-=cro<cr>i
"            \<cr>
"            \<esc>=:set formatoptions+=cro<cr>/__f\w*<cr>

"--------------------------------------------------------------------+
inorea sv_timeformat_Ent <esc>:set formatoptions-=cro<cr>i
            \$timeformat(-9, 2, "ns", 10);
            \<esc>=:set formatoptions+=cro<cr>/__f\w*<cr>

inorea uvm_build_phase_Ent <esc>:set formatoptions-=cro<cr>i
            \// Build phase<cr>
            \virtual function void build_phase(uvm_phase phase);<cr>
            \`uvm_info(`gfn, "build_phase() start ...", UVM_LOW);<cr>
            \super.build_phase(phase);<cr>
            \endfunction<cr>
            \<esc>=:set formatoptions+=cro<cr>/__f\w*<cr>

inorea uvm_connect_phase_Ent virtual function void connect_phase(uvm_phase phase);<cr>
            \`uvm_info(`gfn, "connect_phase() start ...", UVM_LOW)<cr>
            \super.connect_phase(phase);<cr>
            \endfunction<esc>

inorea uvm_end_of_elaboration_phase_Ent virtual function void end_of_elaboration_phase(uvm_phase phase);<cr>
            \`uvm_info(`gfn, "end_of_elaboration_phase() start ...", UVM_LOW)<cr>
            \super.end_of_elaboration_phase(phase);<cr>
            \endfunction<esc>

inorea uvm_start_of_simualation_phase_Ent virtual function void start_of_simualation_phase(uvm_phase phase);<cr>
            \`uvm_info(`gfn, "start_of_simualation_phase() start ...", UVM_LOW)<cr>
            \super.start_of_simualation_phase(phase);<cr>
            \endfunction<esc>

inorea uvm_extract_phase_Ent virtual function void extract_phase(uvm_phase phase);<cr>
            \`uvm_info(`gfn, "extract_phase() start ...", UVM_LOW)<cr>
            \super.extract_phase(phase);<cr>
            \endfunction<esc>

inorea uvm_check_phase_Ent virtual function void check_phase(uvm_phase phase);<cr>
            \`uvm_info(`gfn, "check_phase() start ...", UVM_LOW)<cr>
            \super.check_phase(phase);<cr>
            \endfunction<esc>

inorea uvm_report_phase_Ent virtual function void report_phase(uvm_phase phase);<cr>
            \`uvm_info(`gfn, "report_phase() start ...", UVM_LOW)<cr>
            \super.report_phase(phase);<cr>
            \endfunction<esc>

inorea uvm_final_phase_Ent virtual function void final_phase(uvm_phase phase);<cr>
            \`uvm_info(`gfn, "final_phase() start ...", UVM_LOW)<cr>
            \super.final_phase(phase);<cr>
            \endfunction<esc>

inorea uvm_body_Ent <esc>:set formatoptions-=cro<cr>i
            \// body()<cr>
            \//     NOTE: Do not call super.body if this class <cr>
            \//           extends directly from uvm_sequence<cr>
            \virtual task body();<cr>
            \`uvm_info(`gfn, "body() start ...", UVM_LOW)<cr>
            \//super.body();<cr>
            \endtask<cr>
            \<esc>=:set formatoptions+=cro<cr>/__f\w*<cr>

inorea uvm_new_object_Ent function new(string name="");<cr>
			\super.new(name);<cr>
			\endfunction <esc>O<esc>:/__f_<cr>ggn

inorea uvm_new_component_Ent function new(string name="", uvm_component parent);<cr>
			\super.new(name, parent);<cr>
			\endfunction <esc>O<esc>:/__f_<cr>ggn

inorea uvm_info_Ent uvm_info(`gfn, "__f", UVM_LOW)<esc>:/__f<cr>ggn

inorea uvm_info_psprintf_Ent uvm_info(`gfn, $psprintf("__f", __f), UVM_LOW)<esc>:/__f<cr>ggn

inorea module <esc>:let g:auto_complete=0<cr>
            \imodule();<cr>endmodule<esc>:let g:auto_complete=1<cr>kA<left><left><left>

inorea class <esc>:let g:auto_complete=0<cr>
            \iclass;<cr>endclass<esc>:let g:auto_complete=1<cr>kA<left>

inorea uvm_config_db_get_Ent if (uvm_config_db#(__f_type)::get(__f_contxt, "__f_inst_name", "__f_field_name", __f_value)) begin<cr>
			\`uvm_info(`gn, {`gfn, ".__f_field_name has been found in ConfigDB."}, UVM_LOW)<cr>
			\end else `uvm_fatal(`gfn, {`gfn, ".__f_field_name cannot be found in ConfigDB!"})<esc>/__f_\w*<cr>

inorea uvm_config_db_set_Ent uvm_config_db#(__f_type)::set(__f_contxt,<cr>
            \"__f_inst_name", "__f_field_name", __f_value);<esc>/__f_\w*<cr>

inorea sv_ifndef_Ent `ifndef __<c-r>=toupper(expand("%:t:r"))."_".toupper(expand("%:e"))<cr>__<cr>
			\`define __<c-r>=toupper(expand("%:t:r"))."_".toupper(expand("%:e"))<cr>__<cr><cr>
			\`endif /* __<c-r>=toupper(expand("%:t:r"))."_".toupper(expand("%:e"))<cr>__ */<esc><up> 

inorea sv_case_Ent case (__f_expression)<cr>
			\__f_value1: begin<cr>
			\// TBD<cr><bs><bs><bs>
			\end<cr>
			\__f_value2: begin<cr>
			\// TBD<cr><bs><bs><bs>
			\end<cr>
			\default: begin<cr>
			\// code executed if expression does not match any value<cr><bs><bs><bs>
			\end<cr>
			\endcase<cr><esc><esc>:/__f_\w*<cr>ggn

inorea sv_typedef_enum_Ent typedef enum __f_type {<cr>
			\__f_STATE_A,<cr>
			\__f_STATE_B,<cr>
			\__f_STATE_C<cr>
			\} __f_state_type;<cr><esc>:/__f_\w*<cr>ggn

inorea sv_covergroup_Ent covergroup __f_cvg_name @(posedge clk iff resetn);<cr>
			\option.per_instance = 1  ;<cr>
    		\option.goal         = 100;<cr>
    		\__f_cp0_name: coverpoint __f_variable {<cr>
    		\//bins b0_to_b1 = (0 => 1);<cr>
    		\bins b1_to_b0 = (1 => 0);<cr><bs><bs><bs>
    		\};<cr>
    		\__f_cp1_name: coverpoint __f_variable {<cr>
    		\//bins b0_to_b1 = (0 => 1);<cr>
    		\bins b1_to_b0 = (1 => 0);<cr><bs><bs><bs>
    		\};<cr>
			\endgroup<cr>
            \<cr>
            \__f_cvg_name cg0 = new();<esc>:/__f_\w*<cr>ggn

inorea sv_randomize_Ent !randomize(__f_var)<esc>0iif (<esc>$a with {<cr>
			\// TBD ;<cr><bs><bs><bs>
			\}) `uvm_warning("[RANDOMIZE FAILED]", "Randomization failed");<esc>:/__f_\w*<cr>ggn

inorea sv_sva_module_Ent <esc>:set formatoptions-=cro<cr>
            \i`ifndef __<c-r>=substitute(toupper(expand('%:t')), '\.', '_', 'g')<cr>__<cr>
            \`define __<c-r>=substitute(toupper(expand('%:t')), '\.', '_', 'g')<cr>__<cr>
            \module __f_module_name_chk(<cr>
            \    clk,<cr>
            \    resetn<cr>
            \);<cr>
            \
            \    // ---------------------------------------------------------------<cr>
            \    // parameter                                                      <cr>
            \    // ---------------------------------------------------------------<cr>
            \<cr>
            \<cr>
            \    // ---------------------------------------------------------------<cr>
            \    // Input/output                                                   <cr>
            \    // ---------------------------------------------------------------<cr>
            \<cr>
            \<cr>
            \    // ---------------------------------------------------------------<cr>
            \    // Property                                                       <cr>
            \    // ---------------------------------------------------------------<cr>
            \    // property REQ_ACK_CHK(req, ack);<cr>
            \    //    @(posedge clk) req -> ##3 ack;<cr>
            \    // endproperty<cr>
            \<cr>
            \    // ---------------------------------------------------------------<cr>
            \    // SVA                                                            <cr>
            \    // ---------------------------------------------------------------<cr>
            \    // ASSERT_REQ_ACK_CHK: assert property (REQ_ACK_CHK(req, ack))<cr>
            \    // else $error("ASSERT_REQ_ACK_CHK Fail!");<cr>
            \<cr>
            \endmodule<cr>
            \`endif /* __<c-r>=substitute(toupper(expand('%:t')), '\.', '_', 'g')<cr>__<cr>
            \<esc>:set formatoptions+=cro<cr>ggVG=:/__f\w*<cr>

inorea sv_write_file_Ent <esc>:set formatoptions-=cro<cr>i
            \begin<cr>
            \string filename     = "__filename.txt";<cr>
            \int    handle_file  = $fopen(filename, "a+");   // append (if not exist, create new)<cr>
            \//int    handle_file  = $fopen(filename, "w");  // create and overwrite<cr>
            \<cr>
            \if (handle_file == 0) begin<cr>
            \    `uvm_log_fatal($psprintf("Error opening file '%s' for writing", filename))<cr>
            \end<cr>
            \$fwrite(handle_file, "[%t] helloworld!\n", $time);<cr>
            \$fclose(handle_file);<cr>
            \end<cr><esc>
            \<esc>:set formatoptions+=cro<cr>ggVG=:/__f\w*<cr>

inorea sv_disable_fork_Ent <esc>:set formatoptions-=cro<cr>i
            \fork begin // isolate the following code as a single child process<cr>
            \fork  <cr>
            \begin<cr>
            \// Process1<cr>
            \end<cr>
            \begin<cr>
            \// Process2<cr>
            \end<cr>
            \join_any <cr>
            \disable fork;<cr>
            \end join <cr>
            \<esc>:set formatoptions+=cro<cr>

inorea sv_timeout_Ent <esc>:set formatoptions-=cro<cr>i
            \fork begin <cr>
            \fork  <cr>
            \begin<cr>
            \#10_000us;<cr>
            \`uvm_error("TIMEOUT", "Timeout!")<cr>
            \end<cr>
            \begin<cr>
            \// User define<cr>
            \end<cr>
            \join_any <cr>
            \disable fork;<cr>
            \end join <cr>
            \<esc>:set formatoptions+=cro<cr>

inorea uvm_sequence_Ent <esc>:set formatoptions-=cro<cr>i
            \class __f_class_name extends __f_class_parent;<cr>
            \`uvm_object_utils(__f_class_name)<cr>
            \<cr>
            \function new(string name="");<cr>
            \super.new(name);<cr>
            \endfunction<cr>
            \<cr>
            \// Method<cr>
            \<cr>
            \task body();<cr>
            \// ---------------------------------------------------------------------+<cr>
            \// Thread                                                               \|<cr>
            \// ---------------------------------------------------------------------+<cr>
            \<cr>
            \// ---------------------------------------------------------------------+<cr>
            \// Main sequence                                                        \|<cr>
            \// ---------------------------------------------------------------------+<cr>
            \<cr>
            \endtask<cr>
            \<cr>
            \endclass<cr>
            \<esc>:set formatoptions+=cro<cr>/__f\w*<cr>

inorea sv_dump_wave_Ent <esc>:set formatoptions-=cro<cr>a
            \//  dump_fsdb.tcl<cr>
            \//     \| call fsdbDumpfile all.fsdb<cr>
            \//     \| call fsdbDumpvars 0 top +all<cr>
            \//     \| call fsdbDumpSVA  0 top<cr>
            \//     \| run<cr>
            \//     \| exit<cr>
            \//  dump_shm.tcl<cr>
            \//     \| database -open shm_all -into all.shm -default -event<cr>
	        \//     \| probe -create -unpacked 65536 -database shm_all -all -dynamic -memories -depth all top<cr>
            \//     \| run<cr>
            \//     \| exit<cr>
            \//  Option compile<cr>
            \//     \| -loadpli1 debpli:novas_pli_boot<cr>
            \//     \| -assert<cr>
            \//     \| +access+rwc<cr>
            \//  Option simulation<cr>
            \//     \| -input dump_fsdb.tcl<cr>
            \//     \| -input dump_shm.tcl<cr>
            \//     \| -assert<cr>
            \//     \| +fsdb+parallel=on<cr>
            \//     \| +fsdb+sva_success<cr>
            \//  Environment variablecr>
            \//     \| setenv      VERDI_HOME      /tools/synopsys/verdi/O-2018.09-SP2-11<cr>
            \//     \| setenv      PATH            ${VERDI_HOME}/bin:$PATH<cr>
            \//     \| setenv      LD_LIBRARY_PATH ${VERDI_HOME}/PLI/IUS/linux64:$LD_LIBRARY_PATH<cr>
            \initial begin<cr>
			\$fsdbDumpfile("top.fsdb");<cr>
			\$fsdbDumpvars(0, top, "+all");<cr>
			\$fsdbDumpSVA (0, top);<cr>
			\end<cr><esc>
            \<esc>:set formatoptions+=cro<cr>/__f\w*<cr>

"            \//     \| setenv      LD_LIBRARY_PATH ${VERDI_HOME}/share/PLI/IUS/linux64/boot/:${VERDI_HOME}/PLI/IUS/linux64:$LD_LIBRARY_PATH<cr>

inorea sv_task_thread_Ent <esc>:set formatoptions-=cro<cr>i
            \task thread___f();<cr>
            \fork <cr>
            \begin<cr>
            \// TBD<cr>
            \end<cr>
            \join_none<cr>
            \endtask<cr>
            \<esc>:set formatoptions+=cro<cr>/__f\w*<cr>

inorea sv_assert_Ent <esc>:set formatoptions-=cro<cr>i
            \assert(__f_condition) $display("[__f_condition] Assertion passed");<cr>
            \else `uvm_error(`gtn, "[__f_condition] Assertion failed")<cr>
            \<esc>:set formatoptions+=cro<cr>/__f\w*<cr>

inorea uvm_run_phase_Ent <esc>:set formatoptions-=cro<cr>i
            \virtual task run_phase(uvm_phase phase);<cr>
			\`uvm_info(`gfn, "run_phase() start ...", UVM_LOW)<cr>
			\super.run_phase(phase);<cr>
            \//phase.raise_objection(this);<cr>
            \<cr>
            \//phase.drop_objection(this);<cr>
			\endtask<esc><up><esc>
            \<esc>:set formatoptions+=cro<cr>/__f\w*<cr>

inorea uvm_do_with_Ent `uvm_do_with(trans, {Addr == addr; Data == data;});<esc>

inorea uvm_do_sequence_item_Ent <esc>:set formatoptions-=cro<cr>i
            \// Property<cr>
            \// REQ                req;<cr>
            \// RSP                rsp;<cr>
            \`uvm_create(req);<cr>
            \req.cfg = cfg;<cr>
            \if (!req.randomize() with {direction == READ;}) begin<cr>
            \`uvm_fatal("body", "Transaction randomize error.")<cr>
            \end<cr>
            \`uvm_send(req);<cr>
            \<esc>=:set formatoptions+=cro<cr>/__f\w*<cr>

inorea uvm_component_Ent <esc>:set formatoptions-=cro<cr>i
            \// Class: __f_class_name<cr>
            \//<cr>
            \class __f_class_name extends uvm_component;<cr>
            \<cr>
            \// Properties<cr>
            \<cr>
            \// Factory<cr>
            \`uvm_component_utils(__f_class_name)<cr>
            \<cr>
            \function new(string name = "", uvm_component parent);<cr>
            \super.new(name, parent);<cr>
            \endfunction <cr>
            \<cr>
            \// Build phase<cr>
            \virtual function void build_phase(uvm_phase phase);<cr>
            \`uvm_info(`gfn, "build_phase() start ...", UVM_LOW);<cr>
            \super.build_phase(phase);<cr>
            \endfunction<cr>
            \<cr>
            \// Connect phase<cr>
            \virtual function void connect_phase(uvm_phase phase);<cr>
            \super.connect_phase(phase);<cr>
            \`uvm_info(`gfn, "connect_phase() start ...", UVM_LOW)<cr>
            \endfunction<cr>
            \<cr>
            \// Run phase<cr>
            \extern virtual task run_phase(uvm_phase phase);<cr>
            \<cr>
            \endclass<cr>
            \<cr>
            \// Run phase<cr>
            \// <cr>
            \task __f_class_name::run_phase(uvm_phase phase);<cr>
            \super.run_phase(phase);<cr>
            \//phase.raise_objection(this);<cr>
            \`uvm_info(`gfn, "run_phase() start ...", UVM_LOW)<cr>
            \// TODO<cr>
            \<cr>
            \//phase.drop_objection(this);<cr>
            \endtask<cr>
            \<cr>
            \<esc>=:set formatoptions+=cro<cr>/__f\w*<cr>

inorea sv_clkgen_Ent <esc>:set formatoptions-=cro<cr>i
            \`define CLK_GEN(CLOCK_HIER, PERIOD) \<cr>
            \always begin \<cr>
            \real period = PERIOD; \<cr>
            \#(period/2) CLOCK_HIER = !CLOCK_HIER; \<cr>
            \end<cr>
            \<esc>=:set formatoptions+=cro<cr>/__f\w*<cr>

inorea uvm_object_Ent class __f_class_name extends uvm_object;<cr>
			\`uvm_object_utils_begin(__f_class_name)<cr>
			\`uvm_object_utils_end<cr>
			\<cr>
			\// Func: new()<cr><bs><bs><bs>
            \function new(string name="");<cr>
			\super.new(name);<cr>
			\endfunction: new<cr>
			\<cr>
			\endclass<esc>:/__f<cr>ggn

inorea uvm_analysis_imp_decl_Ent <esc>:set formatoptions-=cro<cr>i
            \`uvm_analysis_imp_decl(__f_port_name) // outside the class;<cr>
            \// Analysis implementation<cr>
            \uvm_analysis_imp__f_port_name #(<uvm_trans>, <this_type>) <port_name>;<cr>
            \<cr>
            \// new<cr>
            \<port_name> = new("<port_name>", this);<cr>
            \<cr>
            \// Implement port function: write()<cr>
            \virtual function void write__f_port_name(<uvm_trans> trans);<cr>
            \endfunction<cr>
            \<esc>=:set formatoptions+=cro<cr>/__f\w*<cr>

inorea sv_interface_Ent <esc>:set formatoptions-=cro<cr>i
            \interface apb_if(input pclk);<cr>
            \logic penable;<cr>
            \logic [31:0] paddr;<cr>
            \endinterface<cr>
            \<esc>=:set formatoptions+=cro<cr>/__f\w*<cr>

inorea sv_template_Ent <esc>:set formatoptions-=cro<cr>i
            \//----------------------------------------------------------------------<cr>
            \//  File name     : <esc>:r!basename %<cr>i<bs><esc>o
            \//  Function      : <empty><cr>
            \//  Author        : Tian<cr>
            \//  Email         : tientq@coasia.com<cr>
            \//  Created time  : <esc>:r !date '+\%Y-\%m-\%d \%H:\%M:\%S'<cr>i<bs><esc>o
            \//----------------------------------------------------------------------<cr>
            \`ifndef __<c-r>=toupper(expand("%:t:r"))."_".toupper(expand("%:e"))<cr>__<cr>
			\`define __<c-r>=toupper(expand("%:t:r"))."_".toupper(expand("%:e"))<cr>__<cr><cr>
			\`endif /* __<c-r>=toupper(expand("%:t:r"))."_".toupper(expand("%:e"))<cr>__ */<esc>
            \<esc>=:set formatoptions+=cro<cr>

inorea sv_task_Ent <esc>:set formatoptions-=cro<cr>i
            \task __f_task_name();<cr>
            \endtask<cr>
            \<esc>=:set formatoptions+=cro<cr>/__f\w*<cr>

inorea sv_func_Ent <esc>:set formatoptions-=cro<cr>i
            \function void __f_func_name();<cr>
            \endfunction<cr>
            \<esc>=:set formatoptions+=cro<cr>/__f\w*<cr>

inorea uvm_raise_objection_Ent <esc>:set formatoptions-=cro<cr>i
            \phase.raise_objection(this);<cr>
            \phase.drop_objection(this);<cr>
            \<esc>=:set formatoptions+=cro<cr>/__f\w*<cr>

inorea uvm_create_Ent <esc>:set formatoptions-=cro<cr>i
            \//`uvm_create_on(__seq, __seqr);<cr>
            \`uvm_create(__seq_item);<cr>
            \assert(__seq_item.randomize());<cr>
            \`uvm_send(__seq_item);<cr>
            \<esc>=:set formatoptions+=cro<cr>/__f\w*<cr>
inorea uvm_get_factory_Ent uvm_coreservice_t::get().get_factory()
