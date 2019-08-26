class top_env extends uvm_env;

  `uvm_component_utils(top_env)

  extern function new(string name, uvm_component parent);

    virtual task run_phase(uvm_phase phase);

		uvm_test_done.raise_objection(this);
    
        `uvm_info("mok","start",UVM_LOW);
        super.run_phase(phase);
        #5000ns;
        uvm_hdl_force("top_tb.dut_i.some_bit",1'bz);
        `uvm_info("mok","po",UVM_LOW);
        #5000ns;
        uvm_hdl_release("top_tb.dut_i.some_bit");
        `uvm_info("mok","po",UVM_LOW);
        #5000ns;
        uvm_hdl_force("top_tb.dut_i.some_bit",1'bz);
        `uvm_info("mok","po",UVM_LOW);
        #5000ns;
        uvm_hdl_release("top_tb.dut_i.some_bit");
        `uvm_info("mok","po",UVM_LOW);
        #5000ns;
        `uvm_info("mok","done",UVM_LOW);

		uvm_test_done.drop_objection(this);
    
    endtask : run_phase

endclass : top_env
