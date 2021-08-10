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
AXIS axis1(.ACLK(ACLK),.ARESETn(ARESETn));
AXIS axis2(.ACLK(ACLK),.ARESETn(ARESETn));

AXI_DMA U(
.axi_full(axi4),
.m_axis(axis1),
.s_axis(axis2)
);

AXI4_Slave S(.s_axi4(axi4));

AXI_FIFO D(
.m_axis(axis2),
.s_axis(axis1));
endmodule
