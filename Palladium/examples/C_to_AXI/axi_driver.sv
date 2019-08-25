`timescale 1ns/1ns

interface axi_master_driver_if();

    ///////////////////////////////
    //
    //      AXI partial I/F
    //
    // those are the ports to be connected by force
    // in the TB. this is actually the host AXI I/F
    //
    logic                                    CLK;
    // AXI write address bus ------------------------------------------
    logic /*output*/   [`AXI_ID_W-1:0]       AWID;
    logic /*output*/   [`AXI_ADDR_W-1:0]     AWADDR;
    logic /*output*/   [ 3:0]                AWLEN;   //burst length is 1 + (0 - 15)
    logic /*output*/   [ 2:0]                AWSIZE;  //size of each transfer in burst
    logic /*output*/   [ 1:0]                AWBURST; //for bursts>1, accept only incr burst=01
    logic /*output*/   [ 1:0]                AWLOCK;  //only normal access supported axs_awlock=00
    logic /*output*/   [ 3:0]                AWCACHE; 
    logic /*output*/   [ 2:0]                AWPROT;
    logic /*output*/                         AWVALID; //master addr valid
    logic /*input*/                          AWREADY; //slave ready to accept
    // AXI write data bus ---------------------------------------------
    logic /*output*/   [`AXI_ID_W-1:0]       WID;
    logic /*output*/   [`AXI_DATA_W-1:0]     WDATA;
    logic /*output*/   [`AXI_NUMBYTES-1:0]   WSTRB;   //1 strobe per byte
    logic /*output*/                         WLAST;   //last transfer in burst
    logic /*output*/                         WVALID;  //master data valid
    logic /*input*/                          WREADY;  //slave ready to accept
    // AXI write response bus -------------------------------------
    logic /*input*/  [`AXI_ID_W-1:0]         BID;
    logic /*input*/  [ 1:0]                  BRESP;
    logic /*input*/                          BVALID;
    logic /*output*/                         BREADY;
    // AXI read address bus ---------------------------------------
    logic /*output*/   [`AXI_ID_W-1:0]       ARID;
    logic /*output*/   [`AXI_ADDR_W-1:0]     ARADDR;
    logic /*output*/   [ 3:0]                ARLEN;   //burst length - 1 to 16
    logic /*output*/   [ 2:0]                ARSIZE;  //size of each transfer in burst
    logic /*output*/   [ 1:0]                ARBURST; //for bursts>1, accept only incr burst=01
    logic /*output*/   [ 1:0]                ARLOCK;  //only normal access supported axs_awlock=00
    logic /*output*/   [ 3:0]                ARCACHE; 
    logic /*output*/   [ 2:0]                ARPROT;
    logic /*output*/                         ARVALID; //master addr valid
    logic /*input*/                          ARREADY; //slave ready to accept
    // AXI read data bus ------------------------------------------
    logic /*input*/  [`AXI_ID_W-1:0]         RID;
    logic /*input*/  [`AXI_DATA_W-1:0]       RDATA;
    logic /*input*/  [ 1:0]                  RRESP;
    logic /*input*/                          RLAST;   //last transfer in burst
    logic /*input*/                          RVALID;  //slave data valid
    logic /*output*/                         RREADY;  //master ready to accept

    ///////////////////////////////
    //
    //      C functions call
    //
    // those are the functions definitions
    // to be executed in C code
    //
    import "DPI-C" function void      set_axi_read_data         (int RDATA);
    import "DPI-C" function string    get_next_axi_command_op   (input int cmd_cnt);
    import "DPI-C" function int       get_next_axi_command_addr (input int cmd_cnt);
    import "DPI-C" function int       get_next_axi_command_data (input int cmd_cnt);


 
    ///////////////////////////////
    //
    //     AXI clock by Palladium
    //
    // the AXI_FREQ_MHZ define is defined in the top tb
    reg axi_clock;
    initial axi_clock = 0;
    initial forever axi_clock = #((500000/`AXI_FREQ_MHZ)*1ns) ~axi_clock;
    // connect the AXI clock to the generated clock
    assign CLK = axi_clock;

 
    ///////////////////////////////
    //
    //     MAIN Flow
    //
    //  the counter and debug message are for debug perpuses
    //  and has no functional meaning
    //
    //  the case statemnt can be extended to include more commands
    //  if needed, like burst write or read, value on a GPIO, or 
    //  any other external functionality desired to be simulated
    //  by the Palladium TB under FW command.
    //
    reg [256:0] debug_message;
    int command_counter;
    initial command_counter = 0;
    initial forever begin
        string command;
        int axi_id = 2;
        //$display("AXI_DRIVER: @%0t: execute command %0d",$time,command_counter);
        debug_message = {"cmd ",48+command_counter};
        @(posedge axi_clock);
        command = get_next_axi_command_op(command_counter);
        //$display("AXI_DRIVER: command - ",command);
        case (command)
            "init":     axi_init();
            "write":    begin
                            axi_set_write_addr(axi_id,get_next_axi_command_addr(command_counter),0,1);
                            axi_set_write_data(axi_id,get_next_axi_command_data(command_counter),4,1);
                        end
            "read":     axi_set_read_addr(axi_id,get_next_axi_command_addr(command_counter),0,1);
            //"null":     $display("AXI_DRIVER: null");
            "done":     $display("AXI_DRIVER: done");
        endcase
        command_counter++;
    end

    task axi_init();
        $display("AXI_DRIVER: axi_init");
        debug_message = {"init"};
        // axi waddr bus
        AWID       =  {`AXI_ID_W{1'b0}};
        AWADDR     =  {`AXI_ADDR_W{1'b0}};
        AWLEN      =  4'h0;
        AWSIZE     =  3'h0;
        AWBURST    =  2'h0; 
        AWLOCK     =  2'h0; 
        AWCACHE    =  4'h0; 
        AWPROT     =  3'h0;
        AWVALID    =  1'b0;
        // axi wdata bus
        WID        = {`AXI_ID_W{1'b0}};
        WDATA      = 32'h0;
        WSTRB      = 4'h0;
        WLAST      = 1'b0;
        WVALID     = 1'b0;
        // axi raddr bus
        ARID       =  {`AXI_ID_W{1'b0}};
        ARADDR     =  {`AXI_ADDR_W{1'b0}};
        ARLEN      =  4'h0;
        ARSIZE     =  3'h0;
        ARBURST    =  2'h0; 
        ARLOCK     =  2'h0; 
        ARCACHE    =  4'h0; 
        ARPROT     =  3'h0;
        ARVALID    =  1'b0;
        // axi rdata bus
        RREADY     =  1'b0;
    endtask

    task axi_set_write_addr(
       input  [`AXI_ID_W-1:0] id,
       input  [`AXI_ADDR_W-1:0] addr,
       input  [ 3:0] alen,
       input  [ 2:0] asiz
    );
        $display("AXI_DRIVER: axi write addr 0x%x",addr);
        debug_message = {"write addr"};
        @(posedge axi_clock);
        AWID     = id;
        AWADDR   = addr;
        AWLEN    = alen;
        AWSIZE   = asiz;
        AWBURST  = 2'h1; // incrementing address burst
        AWLOCK   = 2'h0; // normal access
        AWCACHE  = 4'h0; 
        AWPROT   = 3'h2; // normal, non-secure data access
        AWVALID  = 1'b1;
        wait (AWREADY);
        @(posedge axi_clock);
        AWVALID = 1'b0;
    endtask
    
    task axi_set_write_data(
       input  [`AXI_ID_W-1:0] twid,
       input  [32:0] twdata,
       input  [ 3:0] twstrb,
       input         twlast
    );
        $display("AXI_DRIVER: axi write data 0x%x",twdata);
        debug_message = {"write data"};
        @(posedge axi_clock);
        WID    = twid;
        WDATA  = twdata;
        WSTRB  = twstrb;
        WLAST  = twlast;
        WVALID = 1'b1;
        #1 wait (WREADY);
        @(posedge axi_clock);
        WVALID = 1'b0;
        WLAST  = 1'b0;
    endtask         
          
    task axi_set_read_addr(
       input  [`AXI_ID_W-1:0] id,
       input  [`AXI_ADDR_W-1:0] addr,
       input  [ 3:0] alen,
       input  [ 2:0] asiz
    );
        $display("AXI_DRIVER: axi read addr 0x%x",addr);
        debug_message = {"read addr"};
        @(posedge axi_clock);
        ARID     = id;
        ARADDR   = addr;
        ARLEN    = alen;
        ARSIZE   = asiz;
        ARBURST  = 2'h1; // incrementing address burst
        ARLOCK   = 2'h0; // normal access
        ARCACHE  = 4'h0; 
        ARPROT   = 3'h2; // normal, non-secure data access
        ARVALID  = 1'b1;
        wait (ARREADY);
        @(posedge axi_clock);
        ARVALID = 1'b0;
        $display("AXI_DRIVER: read data 0x%x",RDATA);
        set_axi_read_data(RDATA);
    endtask

endinterface

