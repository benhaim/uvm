
module dut_wrapper();         

    ///////////////////////////////////
    //
    //        AXI DUMMY MEMORY
    //
    //  this memory was briefly composed to allow
    //  communication via the AXI bus. the flows
    //  used here should not be considered correct
    //  ane wehe based on online examples
    //
    //  memory size determined by the defines from
    //  the top TB.
    //
    reg dut_clock; // driven by the Palladium

    logic /*output*/   [`AXI_ADDR_W-1:0]     AWADDR;        
    logic /*output*/   [`AXI_DATA_W-1:0]     WDATA;
    logic /*output*/   [`AXI_ADDR_W-1:0]     ARADDR;
    logic /*input*/    [`AXI_DATA_W-1:0]     RDATA;
    logic /*output*/                         AWREADY,WREADY,ARREADY;
    logic /*input*/                          AWVALID,WVALID,ARVALID;
    
    // "memory" model for AXI demo
    localparam MEM_SIZE = 2 ** `AXI_ADDR_W;
    logic [`AXI_DATA_W-1:0] mem[MEM_SIZE];
    logic [`AXI_ADDR_W-1:0] address;
    
    // AXI write
    always @ (posedge dut_clock) begin
        AWREADY = (AWVALID) ? 1'b1 : 1'b0;
        WREADY  = (WVALID)  ? 1'b1 : 1'b0;
        if (AWVALID) address = AWADDR;
        if (WVALID) mem[address] = WDATA;
    end
    
    // AXI read
    always @ (posedge dut_clock) begin
        ARREADY = (ARVALID) ? 1'b1 : 1'b0;
        RDATA = mem[ARADDR];
    end


    ////////////////////////////////
    //
    //  the below I/F is to ease Ran's
    //  work of copy-past, as those ports
    //  are already in the TB (commented).
    //
    logic [31:0] host_axim_Ar_Addr       ;
    logic [1:0]  host_axim_Ar_Burst      ;
    logic [3:0]  host_axim_Ar_Cache      ;
    logic [8:0]  host_axim_Ar_Id         ;
    logic [3:0]  host_axim_Ar_Len        ;
    logic [1:0]  host_axim_Ar_Lock       ;
    logic [2:0]  host_axim_Ar_Prot       ;
    logic        host_axim_Ar_Ready      ;
    logic [2:0]  host_axim_Ar_Size       ;
    logic        host_axim_Ar_Valid      ;
    logic [31:0] host_axim_Aw_Addr       ;
    logic [1:0]  host_axim_Aw_Burst      ;
    logic [3:0]  host_axim_Aw_Cache      ;
    logic [8:0]  host_axim_Aw_Id         ;
    logic [3:0]  host_axim_Aw_Len        ;
    logic [1:0]  host_axim_Aw_Lock       ;
    logic [2:0]  host_axim_Aw_Prot       ;
    logic        host_axim_Aw_Ready      ;
    logic [2:0]  host_axim_Aw_Size       ;
    logic        host_axim_Aw_Valid      ;
    logic [8:0]  host_axim_B_Id          ;
    logic        host_axim_B_Ready       ;
    logic [1:0]  host_axim_B_Resp        ;
    logic        host_axim_B_Valid       ;
    logic [63:0] host_axim_R_Data        ;
    logic [8:0]  host_axim_R_Id          ;
    logic        host_axim_R_Last        ;
    logic        host_axim_R_Ready       ;
    logic [1:0]  host_axim_R_Resp        ;
    logic        host_axim_R_Valid       ;
    logic [63:0] host_axim_W_Data        ;
    logic [8:0]  host_axim_W_Id          ;
    logic        host_axim_W_Last        ;
    logic        host_axim_W_Ready       ;
    logic [7:0]  host_axim_W_Strb        ;
    logic        host_axim_W_Valid       ;
       
endmodule

