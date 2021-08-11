`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/10 20:39:45
// Design Name: 
// Module Name: test_tb
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


module test_tb;
logic ACLK;
logic ARESETn;
logic [31:0] wr_data;
logic [31:0] wr_addr;
logic wren;
logic wr_done;
logic rden;
logic rd_done;
logic [31:0] rd_addr;
logic [31:0] rd_data;

initial begin
    wren=0;
    wr_data=0;
    wr_addr=0;
    //写rd_base_addr
    #100
    wren=1;
    wr_data=0;
    wr_addr=0;
    #10
    wren=0;
    //写rd_total_len
    #100
    wren=1;
    wr_data=299;
    wr_addr=4;
    #10
    wren=0;
    //写wr_base_addr
    #100
    wren=1;
    wr_data=512;
    wr_addr=8;
    #10
    wren=0;
    //写wr_total_len
    #100
    wren=1;
    wr_data=299;
    wr_addr=12;
    #10
    wren=0;
    //置start=0
    #100
    wren=1;
    wr_data=0;
    wr_addr=16;
    #10
    wren=0;
    //置start=1
    #100
    wren=1;
    wr_data=1;
    wr_addr=16;
    #10
    wren=0;
end

initial begin
    rden=0;
    rd_addr=20;
    #8000
    rden=1;
    #10
    rden=0;
end

initial begin
    ACLK=0;
    forever begin
        #5 ACLK=~ACLK;
    end
end
initial begin
    ARESETn=0;
    #20
    ARESETn=1;
end

AXI4_FULL axi4(.ACLK(ACLK),.ARESETn(ARESETn));
AXI4_LITE axilite(.ACLK(ACLK),.ARESETn(ARESETn));
AXIS axis1(.ACLK(ACLK),.ARESETn(ARESETn));
AXIS axis2(.ACLK(ACLK),.ARESETn(ARESETn));

AXI_DMA U(
.axi_full(axi4),
.s_axilite(axilite),
.m_axis(axis1),
.s_axis(axis2)
);

AXI4_Slave S(.s_axi4(axi4));

AXI_Lite_Mater M(
.m_axilite(axilite),
.wr_data(wr_data),
.wr_addr(wr_addr),
.wren(wren),
.wr_done(wr_done),
.rden(rden),
.rd_done(rd_done),
.rd_addr(rd_addr),
.rd_data(rd_data)
);

AXI_FIFO D(
.m_axis(axis2),
.s_axis(axis1));
endmodule
