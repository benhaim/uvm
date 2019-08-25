`timescale 1ns/1ns

// this define is the freq of the AXI driver
// simulating the CEVA uC
`define AXI_FREQ_MHZ    400

// on the right, commented, are the values
// in Auto-Talks's NOC design
`define AXI_ID_W        4  // 8  // width of ID fields
`define AXI_ADDR_W      12 // 64 // address width
`define AXI_DATA_W      32 // 64 // data symbol width 
`define AXI_NUMBYTES    4  // 8  // number of bytes per word


////////////////////////////////////
//
//          NON-SYNTHEZABLE TB
//
//  this TB wraps both the DUT running on 
//  the Palladium, and the AXI driver, which
//  is not synthesable and actually only
//  runs on the server, and coonects them.
//
module top_tb();
    

    // set the timeformat for debug prints 
    initial $timeformat(-9, 2, " ns", 20);


    ////////////////////////////////
    //
    //  instanciate and connect the 
    //  AXI driver and the DUT with 
    //  the AXI dummy memory
    //
    axi_master_driver_if    axi_if();
    //
    dut_wrapper             dut_i();
    //
    initial force dut_i.AWADDR    =  axi_if.AWADDR;
    initial force dut_i.WDATA     =  axi_if.WDATA;
    initial force dut_i.ARADDR    =  axi_if.ARADDR;
    initial force dut_i.ARVALID   =  axi_if.ARVALID;
    initial force dut_i.WVALID    =  axi_if.WVALID;
    initial force dut_i.AWVALID   =  axi_if.AWVALID;
    //
    initial force axi_if.RDATA    =  dut_i.RDATA;
    initial force axi_if.AWREADY  =  dut_i.AWREADY;
    initial force axi_if.WREADY   =  dut_i.WREADY;
    initial force axi_if.ARREADY  =  dut_i.ARREADY;


    
    ////////////////////////////////
    //
    //  the below commented force are
    //  to ease Ran's work of copy-past, 
    //  as those ports exists in the 
    //  dut_wrapper module
    //  
    //
    //        // AXI read address bus ---------------------------------------
    //	/*input  [31:0] */  initial force dut_i.host_axim_Ar_Addr   = axi_if.ARADDR;
    //	/*input  [1:0]  */  initial force dut_i.host_axim_Ar_Burst  = axi_if.ARBURST;
    //	/*input  [3:0]  */  initial force dut_i.host_axim_Ar_Cache  = axi_if.ARCACHE;
    //	/*input  [8:0]  */  initial force dut_i.host_axim_Ar_Id     = axi_if.ARID;
    //	/*input  [3:0]  */  initial force dut_i.host_axim_Ar_Len    = axi_if.ARLEN;
    //	/*input  [1:0]  */  initial force dut_i.host_axim_Ar_Lock   = axi_if.ARLOCK;
    //	/*input  [2:0]  */  initial force dut_i.host_axim_Ar_Prot   = axi_if.ARPROT;
    //	/*output        */  initial force axi_if.ARREADY = dut_i.host_axim_Ar_Ready;
    //	/*input  [2:0]  */  initial force dut_i.host_axim_Ar_Size   = axi_if.ARSIZE;
    //	/*input         */  initial force dut_i.host_axim_Ar_Valid  = axi_if.ARVALID;
    //        // AXI write address bus ------------------------------------------
    //	/*input  [31:0] */  initial force dut_i.host_axim_Aw_Addr   = axi_if.AWADDR;
    //	/*input  [1:0]  */  initial force dut_i.host_axim_Aw_Burst  = axi_if.AWBURST;
    //	/*input  [3:0]  */  initial force dut_i.host_axim_Aw_Cache  = axi_if.AWCACHE;
    //	/*input  [8:0]  */  initial force dut_i.host_axim_Aw_Id     = axi_if.AWID;
    //	/*input  [3:0]  */  initial force dut_i.host_axim_Aw_Len    = axi_if.AWLEN;
    //	/*input  [1:0]  */  initial force dut_i.host_axim_Aw_Lock   = axi_if.AWLOCK;
    //	/*input  [2:0]  */  initial force dut_i.host_axim_Aw_Prot   = axi_if.AWPROT;
    //	/*output        */  initial force axi_if.AWREADY = dut_i.host_axim_Aw_Ready;
    //	/*input  [2:0]  */  initial force dut_i.host_axim_Aw_Size   = axi_if.AWSIZE;
    //	/*input         */  initial force dut_i.host_axim_Aw_Valid  = axi_if.AWVALID;
    //        // AXI write response bus -------------------------------------
    //	/*output [8:0]  */  initial force axi_if.BID    = dut_i.host_axim_B_Id;
    //	/*input         */  initial force dut_i.host_axim_B_Ready   = axi_if.BREADY;
    //	/*output [1:0]  */  initial force axi_if.BRESP  = dut_i.host_axim_B_Resp;
    //	/*output        */  initial force axi_if.BVALID = dut_i.host_axim_B_Valid;
    //        // AXI read data bus ------------------------------------------
    //	/*output [63:0] */  initial force axi_if.RDATA  = dut_i.host_axim_R_Data;
    //	/*output [8:0]  */  initial force axi_if.RID    = dut_i.host_axim_R_Id; 
    //	/*output        */  initial force axi_if.RLAST  = dut_i.host_axim_R_Last;  
    //	/*input         */  initial force dut_i.host_axim_R_Ready   = axi_if.RREADY;
    //	/*output [1:0]  */  initial force axi_if.RRESP  = dut_i.host_axim_R_Resp; 
    //	/*output        */  initial force axi_if.RVALID = dut_i.host_axim_R_Valid;
    //        // AXI write data bus ---------------------------------------------
    //	/*input  [63:0] */  initial force dut_i.host_axim_W_Data    = axi_if.WDATA;
    //	/*input  [8:0]  */  initial force dut_i.host_axim_W_Id      = axi_if.WID;
    //	/*input         */  initial force dut_i.host_axim_W_Last    = axi_if.WLAST; 
    //	/*output        */  initial force axi_if.WREADY = dut_i.host_axim_W_Ready; 
    //	/*input  [7:0]  */  initial force dut_i.host_axim_W_Strb    = axi_if.WSTRB;
    //	/*input         */  initial force dut_i.host_axim_W_Valid   = axi_if.WVALID;

endmodule
