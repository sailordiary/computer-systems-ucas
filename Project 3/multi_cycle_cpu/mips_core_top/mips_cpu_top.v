/* =========================================
* Top module for MIPS cores in the FPGA
* evaluation platform
*
* Author: Yisong Chang (changyisong@ict.ac.cn)
* Date: 19/03/2017
* Version: v0.0.1
*===========================================
*/

`timescale 1 ps / 1 ps

module mips_cpu_top (

`ifndef MIPS_CPU_SIM
	//AXI AR Channel
    input  [13:0]	mips_cpu_axi_if_araddr,
    output			mips_cpu_axi_if_arready,
    input			mips_cpu_axi_if_arvalid,

	//AXI AW Channel
    input  [13:0]	mips_cpu_axi_if_awaddr,
    output			mips_cpu_axi_if_awready,
    input			mips_cpu_axi_if_awvalid,

	//AXI B Channel
    input			mips_cpu_axi_if_bready,
    output [1:0]	mips_cpu_axi_if_bresp,
    output			mips_cpu_axi_if_bvalid,

	//AXI R Channel
    output [31:0]	mips_cpu_axi_if_rdata,
    input			mips_cpu_axi_if_rready,
    output [1:0]	mips_cpu_axi_if_rresp,
    output			mips_cpu_axi_if_rvalid,

	//AXI W Channel
    input  [31:0]	mips_cpu_axi_if_wdata,
    output			mips_cpu_axi_if_wready,
    input  [3:0]	mips_cpu_axi_if_wstrb,
    input			mips_cpu_axi_if_wvalid,
`endif
	input			mips_cpu_clk,
    input			mips_cpu_reset
);

//AXI Lite IF ports to distributed memory
wire [10:0]		axi_lite_mem_addr;
wire [31:0]		axi_lite_mem_wdata;
wire			axi_lite_mem_wren;
wire			axi_lite_mem_rden;
wire [31:0]		axi_lite_mem_rdata;

//MIPS CPU ports to distributed memory
wire [31:0]		mips_mem_addr;
wire			mips_mem_wren;
wire			mips_mem_rden;
wire [31:0]		mips_mem_wdata;
wire [31:0]		mips_mem_rdata;

//read arbitration signal
wire			mips_mem_rd;
wire			axi_lite_mem_rd;

//Distributed memory ports
wire [10:0]		Waddr;
wire [31:0]		Raddr1;
wire [10:0]		Raddr2;
wire			Wren;
wire			Rden2;
wire [31:0]		Wdata;
wire [31:0]		Rdata1;
wire [31:0]		Rdata2;

//Synchronized reset signal generated from AXI Lite IF
wire			mips_rst;

`ifndef MIPS_CPU_SIM
  //AXI Lite Interface Module
  //Receving memory read/write requests from ARM CPU cores
  axi_lite_if 	u_axi_lite_slave (
	  .S_AXI_ACLK		(mips_cpu_clk),
	  .S_AXI_ARESETN	(~mips_cpu_reset),
	  
	  .S_AXI_ARADDR		(mips_cpu_axi_if_araddr),
	  .S_AXI_ARREADY	(mips_cpu_axi_if_arready),
	  .S_AXI_ARVALID	(mips_cpu_axi_if_arvalid),
	  
	  .S_AXI_AWADDR		(mips_cpu_axi_if_awaddr),
	  .S_AXI_AWREADY	(mips_cpu_axi_if_awready),
	  .S_AXI_AWVALID	(mips_cpu_axi_if_awvalid),
	  
	  .S_AXI_BREADY		(mips_cpu_axi_if_bready),
	  .S_AXI_BRESP		(mips_cpu_axi_if_bresp),
	  .S_AXI_BVALID		(mips_cpu_axi_if_bvalid),
	  
	  .S_AXI_RDATA		(mips_cpu_axi_if_rdata),
	  .S_AXI_RREADY		(mips_cpu_axi_if_rready),
	  .S_AXI_RRESP		(mips_cpu_axi_if_rresp),
	  .S_AXI_RVALID		(mips_cpu_axi_if_rvalid),
	  
	  .S_AXI_WDATA		(mips_cpu_axi_if_wdata),
	  .S_AXI_WREADY		(mips_cpu_axi_if_wready),
	  .S_AXI_WSTRB		(mips_cpu_axi_if_wstrb),
	  .S_AXI_WVALID		(mips_cpu_axi_if_wvalid),
	  
	  .Address			(axi_lite_mem_addr),
	  .MemRead			(axi_lite_mem_rden),
	  .MemWrite			(axi_lite_mem_wren),
	  .Read_data		(axi_lite_mem_rdata),
	  .Write_data		(axi_lite_mem_wdata),
	  
	  .mips_rst			(mips_rst)
  );
`else
  assign axi_lite_mem_addr = 'd0;
  assign axi_lite_mem_rden = 'd0;
  assign axi_lite_mem_wren = 'd0;
  assign axi_lite_mem_wdata = 'd0;
  assign mips_rst = mips_cpu_reset;
`endif

//MIPS CPU cores
  mips_cpu	u_mips_cpu (	
	  .clk			(mips_cpu_clk),
	  .rst			(mips_rst),

	  .PC			(Raddr1),
	  .Instruction	(Rdata1),

	  .Address		(mips_mem_addr),
	  .MemWrite		(mips_mem_wren),
	  .Write_data	(mips_mem_wdata),
	  
	  .MemRead		(mips_mem_rden),
	  .Read_data	(mips_mem_rdata)
  );

/*
 * ============================================================== 
 * Memory read arbitration between AXI Lite IF and MIPS CPU
 * ==============================================================
 */

  //AXI Lite IF can read distributed memory only when MIPS CPU has no memory operations
  //if contention occurs, return 0xFFFFFFFF to Read_data port of AXI Lite IF
  assign mips_mem_rd = mips_mem_rden & (~mips_rst);
  assign axi_lite_mem_rd = axi_lite_mem_rden & (mips_rst | (~mips_mem_rden));
  
  assign Rden2 = mips_mem_rd | axi_lite_mem_rd;

  assign axi_lite_mem_rdata = ({32{axi_lite_mem_rd}} & Rdata2) | ({32{~axi_lite_mem_rd}});

  assign mips_mem_rdata = {32{mips_mem_rd}} & Rdata2;

  assign Raddr2 = ({11{mips_mem_rd}} & mips_mem_addr[12:2]) | ({11{axi_lite_mem_rd}} & axi_lite_mem_addr);

/*
 * ==============================================================
 * Memory write arbitration between AXI Lite IF and MIPS CPU
 * ==============================================================
 */
  //AXI Lite IF only generates memory write requests before MIPS CPU is running
  assign Wren = mips_mem_wren | axi_lite_mem_wren;

  assign Wdata = ({32{mips_mem_wren}} & mips_mem_wdata) | ({32{axi_lite_mem_wren}} & axi_lite_mem_wdata);
  assign Waddr = ({11{mips_mem_wren}} & mips_mem_addr[12:2]) | ({11{axi_lite_mem_wren}} & axi_lite_mem_addr);

  //Distributed memory module used as main memory of MIPS CPU
  ideal_mem 		u_ideal_mem (
	  .clk			(mips_cpu_clk),
	  
	  .Waddr		(Waddr),
	  .Raddr1		(Raddr1[12:2]),
	  .Raddr2		(Raddr2),

	  .Wren			(Wren),
	  .Rden1		(1'b1),
	  .Rden2		(Rden2),

	  .Wdata		(Wdata),
	  .Rdata1		(Rdata1),
	  .Rdata2		(Rdata2)
  );

endmodule

