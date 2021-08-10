`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/10 22:21:25
// Design Name: 
// Module Name: AXI_FIFO
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


module AXI_FIFO(
AXIS.MASTER m_axis,
AXIS.SLAVE s_axis
    );

always_ff@(posedge m_axis.ACLK)
begin
    m_axis.TVALID<=s_axis.TVALID;
    m_axis.TLAST<=s_axis.TLAST;
    m_axis.TDATA<=s_axis.TDATA;
    m_axis.TSTRB<=s_axis.TSTRB;
    m_axis.TUSER<=s_axis.TUSER;
    s_axis.TREADY<=m_axis.TREADY;
end
// logic TREADY;
// logic TVALID;
// logic TLAST;
// logic [DATA_WIDTH/8-1:0] TSTRB;
// logic [DATA_WIDTH:0] TDATA;
// logic TUSER;
endmodule
