class some_test extends uvm_test;

	`uvm_component_utils(some_test)
    
    function new(input string name, input uvm_component parent=null);
        super.new(name,parent);
    endfunction
 
    top_env ve;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase); 
        ve = top_env::type_id::create("ve", this);
    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase); 
        while (1) ;
    endtask : run_phase


endclass :  some_test
