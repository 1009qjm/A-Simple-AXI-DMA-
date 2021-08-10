`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/10 18:22:07
// Design Name: 
// Module Name: AXIS_INTERFACE
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
interface AXIS #(DATA_WIDTH=32) (input logic ACLK,input logic ARESETn);
logic TREADY;
logic TVALID;
logic TLAST;
logic [DATA_WIDTH/8-1:0] TSTRB;
logic [DATA_WIDTH:0] TDATA;
logic TUSER;

modport MASTER (
input TREADY,ACLK,ARESETn,
output TVALID,TLAST,TSTRB,TDATA,TUSER
);

modport SLAVE (
input TVALID,TLAST,TSTRB,TDATA,TUSER,ACLK,ARESETn,
output TREADY
);

endinterface