`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/10 12:04:26
// Design Name: 
// Module Name: AXI4_Slave
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
//`include"E:\\rtl_project\\DDR_Model\\DDR_Model.srcs\\sources_1\\new\\AXI_Interface.sv"

module AXI4_Slave(
AXI4_FULL.SLAVE s_axi4
    );
parameter N = 1024;
//内存建模
logic [31:0] MEM [0:N-1];
logic [31:0] RD_BASE_ADDR;
logic [31:0] RD_CNT;
logic [31:0] RD_LEN;
logic [31:0] RD_DATA;
logic [31:0] RD_ADDR;
logic [31:0] WR_BASE_ADDR;
logic [31:0] WR_CNT;
logic [31:0] WR_LEN;
logic [31:0] WR_DATA;
logic [31:0] WR_ADDR;
//初始化
initial begin
    foreach(MEM[i])
        MEM[i]=i;
end
//从机响应主机发起的读请求
//************************************读地址通道*****************************************
//s_axi4.ARID
//s_axi4.ARADDR
always_ff@(posedge s_axi4.ACLK,negedge s_axi4.ARESETn)
if(~s_axi4.ARESETn)
    RD_BASE_ADDR<=0;
else if(s_axi4.ARVALID&&s_axi4.ARREADY)
    RD_BASE_ADDR<=s_axi4.ARADDR;
//s_axi4.ARLEN 
always_ff@(posedge s_axi4.ACLK,negedge s_axi4.ARESETn)
if(~s_axi4.ARESETn)
    RD_LEN<=0;
else if(s_axi4.ARREADY&&s_axi4.ARVALID)
    RD_LEN<=s_axi4.ARLEN+1;
//s_axi4.ARSIZE
//ARBURST
//ARLOCK
//ARCACHE
//ARPROT
//ARQOS
//ARUSER
//ARVALID
//ARREADY
always_ff@(posedge s_axi4.ACLK,negedge s_axi4.ARESETn)
if(~s_axi4.ARESETn)
    s_axi4.ARREADY<=0;
else if(s_axi4.ARVALID&&~s_axi4.ARREADY)
    s_axi4.ARREADY<=1;
else if(s_axi4.ARVALID&&s_axi4.ARREADY)           //握手完成
    s_axi4.ARREADY<=0;
//**************************************读数据通道*********************************************
assign s_axi4.RID=0;
assign s_axi4.RRESP=2'b00;
assign s_axi4.RUSER=0;
//RVALID
always_ff@(posedge s_axi4.ACLK,negedge s_axi4.ARESETn)
if(~s_axi4.ARESETn)
    s_axi4.RVALID<=0;
else if(s_axi4.ARREADY&&s_axi4.ARVALID)            //读地址通道完成即开始传输数据
    s_axi4.RVALID<=1;
else if(s_axi4.RREADY&&s_axi4.RVALID&&s_axi4.RLAST)
    s_axi4.RVALID<=0;
//RD_ADDR
assign RD_ADDR=RD_BASE_ADDR+RD_CNT;
//RDATA
always_comb
if(s_axi4.RVALID&&s_axi4.RREADY)
    s_axi4.RDATA=MEM[RD_ADDR];
else
    s_axi4.RDATA=0;
//RD_CNT
always_ff@(posedge s_axi4.ACLK,negedge s_axi4.ARESETn)
if(~s_axi4.ARESETn)
    RD_CNT<=0;
else if(s_axi4.ARVALID&&s_axi4.ARREADY)
    RD_CNT<=0;
else if(s_axi4.RVALID&&s_axi4.RREADY)
    RD_CNT<=RD_CNT+1;
//RLAST
always_ff@(posedge s_axi4.ACLK,negedge s_axi4.ARESETn)
if(~s_axi4.ARESETn)
    s_axi4.RLAST<=0;
else if(s_axi4.RREADY&&s_axi4.RVALID&&RD_CNT==RD_LEN-2)         //倒数第二个数据传输完成
    s_axi4.RLAST<=1;
else if(s_axi4.RREADY&&s_axi4.RVALID&&s_axi4.RLAST)             //最后一个数据传输完成
    s_axi4.RLAST<=0;
//*******************************************************写地址通道************************************************************
//AWADDR
always_ff@(posedge s_axi4.ACLK,negedge s_axi4.ARESETn)
if(~s_axi4.ARESETn)
    WR_BASE_ADDR<=0;
else if(s_axi4.AWVALID&&s_axi4.AWREADY) 
    WR_BASE_ADDR<=s_axi4.AWADDR;
//AWLEN
always_ff@(posedge s_axi4.ACLK,negedge s_axi4.ARESETn)
if(~s_axi4.ARESETn)
    WR_LEN<=0;
else if(s_axi4.AWVALID&&s_axi4.AWREADY)
    WR_LEN<=s_axi4.AWLEN+1;
//AWID
//AWSIZE
//AWBURST
//AWLOCK
//AWCACHE
//AWPROT
//AWQOS
//AWUSER
//AWREADY
always_ff@(posedge s_axi4.ACLK,negedge s_axi4.ARESETn)
if(~s_axi4.ARESETn)
   s_axi4.AWREADY<=0;
else if(~s_axi4.AWREADY&&s_axi4.AWVALID)
   s_axi4.AWREADY<=1;
else if(s_axi4.AWVALID&&s_axi4.AWREADY)
   s_axi4.AWREADY<=0;
//************************************************写数据通道******************************************
//WREADY
always_ff@(posedge s_axi4.ACLK,negedge s_axi4.ARESETn)
if(~s_axi4.ARESETn)
    s_axi4.WREADY<=0;
else if(s_axi4.AWREADY&&s_axi4.AWVALID)
    s_axi4.WREADY<=1;
else if(s_axi4.WVALID&&s_axi4.WREADY&&s_axi4.WLAST)
    s_axi4.WREADY<=0;
//WR_CNT
always_ff@(posedge s_axi4.ACLK,negedge s_axi4.ARESETn)
if(~s_axi4.ARESETn)
    WR_CNT<=0;
else if(s_axi4.AWREADY&&s_axi4.AWVALID)
    WR_CNT<=0;
else if(s_axi4.WVALID&&s_axi4.WREADY)
    WR_CNT<=WR_CNT+1;
//WR_ADDR
assign WR_ADDR=WR_BASE_ADDR+WR_CNT;
//WDATA
always_ff@(posedge s_axi4.ACLK)
if(s_axi4.WVALID&&s_axi4.WREADY)
    MEM[WR_ADDR]<=s_axi4.WDATA;
//*************************************************写应答通道***********************************************
assign s_axi4.BID=0;
assign s_axi4.BRESP=2'b00;
assign s_axi4.BUSER=0;
//BVALID
always_ff@(posedge s_axi4.ACLK,negedge s_axi4.ARESETn)
if(~s_axi4.ARESETn)
    s_axi4.BVALID<=0;
else if(s_axi4.WREADY&&s_axi4.WVALID&&s_axi4.WLAST)         //最后一个数据传输完成
    s_axi4.BVALID<=1;
else if(s_axi4.BVALID&&s_axi4.BREADY)
    s_axi4.BVALID<=0;
endmodule
