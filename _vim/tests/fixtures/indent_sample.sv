// SystemVerilog Indentation Test Sample
class sample_test extends uvm_test;
    `uvm_component_utils(sample_test)

    extern virtual function bit is_target_block(uvm_reg_block blk);
    extern virtual function void get_matched_blocks(ref uvm_reg_block matched[$]);
    extern task non_secure_access(register_wrapper_c reg_wrapper);
    extern task ws_rns_rs(register_wrapper_c reg_wrapper);
    extern task addr_write(output uvm_status_e status, input logic [31:0] addr, logic [31:0] wdata,
                           secure_mode_t secure = SFRTEST_SECURE_MODE);
    extern task addr_read(output uvm_status_e status, input logic [31:0] addr,
                          output logic [31:0] rdata,
                          input secure_mode_t secure = SFRTEST_SECURE_MODE);

    pure virtual function void pure_func();

    function new(string name = "sample_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task automatic do_work();
        int counter = 0;
        if (counter == 0) begin
            reset_task();
            check_status();
        end
    endtask
endclass

function bit sample_test::is_target_block(uvm_reg_block blk);
    return 1;
endfunction

task sample_test::non_secure_access(register_wrapper_c reg_wrapper);
    uvm_reg_bus_op rw_op;
    foreach (matched_blocks[idx]) begin
        if ($test$plusargs("RESET_2")) begin
            reset_task();
            check_reset_value();
        end
    end
endtask

task sample_test::addr_write(output uvm_status_e status, input logic [31:0] addr, logic [31:0] wdata,
                             secure_mode_t secure = SFRTEST_SECURE_MODE);
    uvm_reg_map map = get_reg_map();
    if (map == null) begin
        status = UVM_NOT_OK;
        return;
    end
    status = UVM_IS_OK;
endtask
