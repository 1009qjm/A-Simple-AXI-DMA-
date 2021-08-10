`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/10 10:40:29
// Design Name: 
// Module Name: AXI_Interface
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

interface AXI4_FULL #(DATA_WIDTH = 32)(input logic ACLK,input logic ARESETn);
//全局信号
//写地址通道信号
logic AWVALID;
logic [31:0] AWADDR;
logic [7:0] AWLEN;
logic AWID;
logic [2:0] AWSIZE;
logic [1:0] AWBURST;
logic AWLOCK;
logic [3:0]AWCACHE;
logic [2:0]AWPROT;
logic [3:0]AWQOS;
logic AWUSER;
logic AWREADY;
//写数据通道
logic WVALID;
logic WLAST;
logic [DATA_WIDTH-1:0]WDATA;
logic [DATA_WIDTH/8-1:0]WSTRB;
logic WUSER;
logic WREADY;
//写应答通道
logic BREADY;
logic BID;
logic [1:0] BRESP;
logic BUSER;
logic BVALID;
//读地址通道
logic ARID;
logic [31:0] ARADDR;
logic [7:0] ARLEN;
logic [2:0] ARSIZE;
logic [1:0] ARBURST;
logic [1:0] ARLOCK;
logic [3:0] ARCACHE;
logic [2:0] ARPROT;
logic [3:0] ARQOS;
logic ARUSER;
logic ARVALID;
logic ARREADY;
//读数据通道
logic RREADY;
logic RID;
logic [DATA_WIDTH-1:0] RDATA;
logic [1:0] RRESP;
logic RLAST;
logic RUSER;
logic RVALID;
//modport
//master
modport MASTER
(
input ACLK,
input ARESETn,
//写地址通道信号
output AWVALID,
output AWADDR,
output AWLEN,
output AWID,
output AWSIZE,
output AWBURST,
output AWLOCK,
output AWCACHE,
output AWPROT,
output AWQOS,
output AWUSER,
input AWREADY,
//写数据通道
output WVALID,
output WLAST,
output WDATA,
output WSTRB,
output WUSER,
input WREADY,
//写应答通道
output BREADY,
input BID,
input BRESP,
input BUSER,
input BVALID,
//读地址通道
output ARID,
output ARADDR,
output ARLEN,
output ARSIZE,
output ARBURST,
output ARLOCK,
output ARCACHE,
output ARPROT,
output ARQOS,
output ARUSER,
output ARVALID,
input ARREADY,
//读数据通道
output RREADY,
input RID,
input RDATA,
input RRESP,
input RLAST,
input RUSER,
input RVALID          
);
//slave
modport SLAVE
(
input ACLK,
input ARESETn,
//写地址通道信号
input AWVALID,
input AWADDR,
input AWLEN,
input AWID,
input AWSIZE,
input AWBURST,
input AWLOCK,
input AWCACHE,
input AWPROT,
input AWQOS,
input AWUSER,
output AWREADY,
//写数据通道
input WVALID,
input WLAST,
input WDATA,
input WSTRB,
input WUSER,
output WREADY,
//写应答通道
input BREADY,
output BID,
output BRESP,
output BUSER,
output BVALID,
//读地址通道
input ARID,
input ARADDR,
input ARLEN,
input ARSIZE,
input ARBURST,
input ARLOCK,
input ARCACHE,
input ARPROT,
input ARQOS,
input ARUSER,
input ARVALID,
output ARREADY,
//读数据通道
input RREADY,
output RID,
output RDATA,
output RRESP,
output RLAST,
output RUSER,
output RVALID          
);

endinterface



