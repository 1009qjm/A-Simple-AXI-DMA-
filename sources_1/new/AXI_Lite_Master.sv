`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/10 16:07:52
// Design Name: 
// Module Name: AXI_Lite_Mater
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

`include"E:\\rtl_project\\DDR_Model\\DDR_Model.srcs\\sources_1\\new\\AXI_Lite_Interface.sv"

module AXI_Lite_Mater(
AXI4_LITE.MASTER m_axilite,
input logic [31:0] wr_data,
input logic [31:0] wr_addr,
input logic wren,
output logic wr_done,
input logic rden,
output logic rd_done,
input logic [31:0] rd_addr,
output logic [31:0] rd_data
    );
//写地址通道
//AWVALID
always_ff@(posedge m_axilite.ACLK,negedge m_axilite.ARESETn)
if(~m_axilite.ARESETn)
    m_axilite.AWVALID<=0;
else if(wren)
    m_axilite.AWVALID<=1;
else if(m_axilite.AWVALID&&m_axilite.AWREADY)
    m_axilite.AWVALID<=0;
//AWADDR
always_ff@(posedge m_axilite.ACLK,negedge m_axilite.ARESETn)
if(~m_axilite.ARESETn)
    m_axilite.AWADDR<=0;
else if(wren)
    m_axilite.AWADDR<=wr_addr;
//AWPROT
assign m_axilite.AWPROT=0;
//写数据通道
//WVALID
always_ff@(posedge m_axilite.ACLK,negedge m_axilite.ARESETn)
if(~m_axilite.ARESETn)
    m_axilite.WVALID<=0;
else if(wren)
    m_axilite.WVALID<=1;
else if(m_axilite.WVALID&&m_axilite.WREADY)
    m_axilite.WVALID<=0;
//WSTRB
assign WSTRB=4'hf;
//WDATA
always_ff@(posedge m_axilite.ACLK,negedge m_axilite.ARESETn)
if(~m_axilite.ARESETn)
    m_axilite.WDATA<=0;
else if(wren)
    m_axilite.WDATA<=wr_data;
//写响应通道
//BREADY
always_ff@(posedge m_axilite.ACLK,negedge m_axilite.ARESETn)
if(~m_axilite.ARESETn)
    m_axilite.BREADY<=0;
else if(m_axilite.AWVALID&&m_axilite.AWREADY)
    m_axilite.BREADY<=1;
else if(m_axilite.BREADY&&m_axilite.BVALID&&m_axilite.BRESP==2'b00)
    m_axilite.BREADY<=0;
//wr_done
assign wr_done=(m_axilite.BVALID&&m_axilite.BREADY)?1:0;
//读数据
//读地址通道
//ARVALID
always_ff@(posedge m_axilite.ACLK,negedge m_axilite.ARESETn)
if(~m_axilite.ARESETn)
    m_axilite.ARVALID<=0;
else if(rden)
    m_axilite.ARVALID<=1;
else if(m_axilite.ARVALID&&m_axilite.ARREADY)
    m_axilite.ARVALID<=0;
//ARADDR
always_ff@(posedge m_axilite.ACLK,negedge m_axilite.ARESETn)
if(~m_axilite.ARESETn)
    m_axilite.ARADDR<=0;
else if(rden)
    m_axilite.ARADDR<=rd_addr;
//ARPROT
assign ARPROT=2'b00;
//读数据通道
//rready
always_ff@(posedge m_axilite.ACLK,negedge m_axilite.ARESETn)
if(~m_axilite.ARESETn)
    m_axilite.RREADY<=0;
else if(m_axilite.ARVALID&&m_axilite.ARREADY)
    m_axilite.RREADY<=1;
else if(m_axilite.RREADY&&m_axilite.RVALID)
    m_axilite.RREADY<=0;
//rd_data
always_ff@(posedge m_axilite.ACLK)
if(m_axilite.RVALID&&m_axilite.RREADY)
    rd_data<=m_axilite.RDATA;
//rd_done
always_ff@(posedge m_axilite.ACLK,negedge m_axilite.ARESETn)
if(~m_axilite.ARESETn)
    rd_done<=0;
else if(m_axilite.RVALID&&m_axilite.RREADY)
    rd_done<=1;
else
    rd_done<=0;
endmodule
