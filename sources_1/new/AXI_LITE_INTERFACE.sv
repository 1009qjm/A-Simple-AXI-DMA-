`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/10 15:08:51
// Design Name: 
// Module Name: AXI_Lite_Interface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

interface AXI4_LITE (input logic ACLK,input logic ARESETn);
//写地址通道
logic AWVALID;
logic [31:0]AWADDR; 
logic [2:0]AWPROT; 
logic AWREADY;
//写数据通道
logic WVALID;
logic [31:0] WDATA; 
logic [3:0] WSTRB;
logic WREADY;
//写响应通道
logic BREADY;
logic BVALID;
logic [1:0] BRESP;
//读地址通道
logic ARVALID;
logic [31:0] ARADDR; 
logic [2:0] ARPROT; 
logic ARREADY;
//读数据通道
logic RREADY;
logic RVALID;
logic [31:0] RDATA; 
logic [1:0] RRESP;
modport  MASTER (
input ACLK,ARESETn,AWREADY,WREADY,BVALID,BRESP,ARREADY,RVALID,RDATA,RRESP,
output AWVALID,AWADDR,AWPROT,WVALID,WDATA,WSTRB,BREADY,ARVALID,ARADDR,ARPROT,RREADY
); 
modport SLAVE (
output AWREADY,WREADY,BVALID,BRESP,ARREADY,RVALID,RDATA,RRESP,
input ACLK,ARESETn,AWVALID,AWADDR,AWPROT,WVALID,WDATA,WSTRB,BREADY,ARVALID,ARADDR,ARPROT,RREADY
);
endinterface 