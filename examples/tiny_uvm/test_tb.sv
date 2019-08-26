module top_tb();

	`include "uvm_macros.svh"

	import uvm_pkg::*;

    dut dut_i();
   
    initial begin
        run_test();
    end

endmodule
