`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/10 17:50:21
// Design Name: 
// Module Name: AXI_DMA
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


module AXI_DMA(
AXI4_FULL.MASTER axi_full,                                  //MM
AXI4_LITE.SLAVE s_axilite,                              //LITE
AXIS.MASTER m_axis,                                     //STREAM
AXIS.SLAVE s_axis                                       //STREAM
    );
parameter DEPTH = 1024;
//DMA<--->MM,读
logic [31:0] rd_base_addr;
logic [31:0] rd_base_addr_r;                       //读起始地址
logic [31:0] rd_total_len;
logic [31:0] rd_total_len_r;                       //需要传输的字的个数,字为单位,可大于256
logic [31:0] rd_len;                             //当前突发传输长度
logic [31:0] rd_cnt;                             //一次传输内的计数
logic rd_continue;                               //是否继续突发读
logic [31:0] rd_transfer_num;                    //共需要多少次突发传输
logic [31:0] rd_transfer_cnt;                    //当前完成的突发读的次数
//DMA<--->,写
logic [31:0] wr_base_addr;
logic [31:0] wr_base_addr_r;                       //写起始地址
logic [31:0] wr_total_len;
logic [31:0] wr_total_len_r;                       //需要传输的总次数，可以大于256
logic [31:0] wr_len;                             //当前突发传输长度
logic [31:0] wr_cnt;                             //一次传输内的计数
logic wr_continue;                               //是否继续发起突发写
logic [31:0] wr_transfer_num;                    //共需要多少次突发传输
logic [31:0] wr_transfer_cnt;                    //当前完成的传输事务次数
logic start;
logic [31:0] start_r;
logic [31:0] start_r_ff;
logic writeback;                                 //写回数据标志
logic done;
logic [31:0] done_r;
//DMA<--->STREAM,发送数据
logic [31:0] send_cnt;
//DMA<--->STREAM,接受数据
logic [31:0] recv_cnt;
//缓冲区
logic [31:0] tx_buffer [0:DEPTH-1];               
logic [31:0] rx_buffer [0:DEPTH-1];
logic [31:0] tx_buffer_cnt;                   //记录tx_buffer内数据个数
logic [31:0] rx_buffer_cnt;                   //记录rx_buffer内数据个数
//
// initial begin
//     rd_base_addr=0;
//     wr_base_addr=512;
//     rd_total_len=255;
//     wr_total_len=255;
// end

// initial begin
//     start=0;
//     #100
//     start=1;
//     #10
//     start=0;
// end

//writeback
always_ff@(posedge s_axis.ACLK,negedge s_axis.ARESETn)
if(~s_axis.ARESETn)
    writeback<=0;
else if(s_axis.TREADY&&s_axis.TVALID&&s_axis.TLAST)
    writeback<=1;
else
    writeback<=0;
//rd_continue
always_ff@(posedge axi_full.ACLK,negedge axi_full.ARESETn)
if(~axi_full.ARESETn)
    rd_continue<=0;
else if(axi_full.RVALID&&axi_full.RREADY&&axi_full.RLAST)
begin
    if(rd_transfer_cnt<rd_transfer_num-1)
        rd_continue<=1;
    else
        rd_continue<=0;
end
else
    rd_continue<=0;
//wr_continue
always_ff@(posedge axi_full.ACLK,negedge axi_full.ARESETn)
if(~axi_full.ARESETn)
    wr_continue<=0;
else if(axi_full.BVALID&&axi_full.BREADY)
begin
    if(wr_transfer_cnt<wr_transfer_num-1)
        wr_continue<=1;
    else
        wr_continue<=0;
end
else
    wr_continue<=0;
//rd_transfer_cnt
always_ff@(posedge axi_full.ACLK,negedge axi_full.ARESETn)
if(~axi_full.ARESETn)
    rd_transfer_cnt<=0;
else if(start)
    rd_transfer_cnt<=0;
else if(axi_full.RVALID&&axi_full.RREADY&&axi_full.RLAST)    //完成一次读操作
    rd_transfer_cnt<=rd_transfer_cnt+1;
//wr_transfer_cnt
always_ff@(posedge axi_full.ACLK,negedge axi_full.ARESETn)
if(~axi_full.ARESETn)
    wr_transfer_cnt<=0;
else if(start)
    wr_transfer_cnt<=0;
else if(axi_full.BVALID&&axi_full.BREADY)                   //完成一次写操作
    wr_transfer_cnt<=wr_transfer_cnt+1;
//rd_transfer_num
always_ff@(posedge axi_full.ACLK,negedge axi_full.ARESETn)
if(~axi_full.ARESETn)
    rd_transfer_num<=0;
else if(start)
begin
    if(rd_total_len[7:0]==8'd0)
        rd_transfer_num<=rd_total_len[31:8];
    else
        rd_transfer_num<=rd_total_len[31:8]+1;                               //最后一次传输长度为rd_len[7:0]+1
end
//wr_transfer_num
always_ff@(posedge axi_full.ACLK,negedge axi_full.ARESETn)
if(~axi_full.ARESETn)
    wr_transfer_num<=0;
else if(start)
begin
    if(wr_total_len[7:0]==8'd0)
        wr_transfer_num<=wr_total_len[31:8];
    else
        wr_transfer_num<=wr_total_len[31:8]+1;
end    
//最大突发传输长度为256，可能需要分多次进行传输
//读数据
//*************************************************读地址通道*************************************************
//rd_len
always_comb
if(rd_transfer_cnt<rd_transfer_num-1)
    rd_len=8'd255;
else
    rd_len=rd_total_len[7:0];
//ARVALID
always_ff@(posedge axi_full.ACLK,negedge axi_full.ARESETn)
if(~axi_full.ARESETn)
    axi_full.ARVALID<=0;
else if(start||rd_continue)
    axi_full.ARVALID<=1;
else if(axi_full.ARVALID&&axi_full.ARREADY)
    axi_full.ARVALID<=0;
//ARADDR
always_ff@(posedge axi_full.ACLK,negedge axi_full.ARESETn)
if(~axi_full.ARESETn)
    axi_full.ARADDR<=0;
else if(start||rd_continue)
    axi_full.ARADDR<=rd_base_addr+rd_transfer_cnt*256;
//ARLEN
always_ff@(posedge axi_full.ACLK,negedge axi_full.ARESETn)
if(~axi_full.ARESETn)
    axi_full.ARLEN<=0;
else if(start||rd_continue)
    axi_full.ARLEN<=rd_len;               //实际长度-1
//ARSIZE
assign axi_full.ARSIZE=4'b0010;            
//ARBURST
assign axi_full.ARBURST=2'b01;
//ARID
assign axi_full.ARID=0;
//ARPROT
assign axi_full.ARPROT=3'b000;
//ARQOS
assign axi_full.ARQOS=4'b0000;
//ARCACHE
assign axi_full.ARCACHE=4'b0011;
//ARLOCK
assign axi_full.ARLOCK=1'b0;
//ARUSER
assign axi_full.ARUSER=0;
//**********************************************读数据通道***************************************************
//RID
assign axi_full.RID=0;
//RREADY
always_ff@(posedge axi_full.ACLK,negedge axi_full.ARESETn)
if(~axi_full.ARESETn)
    axi_full.RREADY<=0;
else if(axi_full.ARVALID&&axi_full.ARREADY)
    axi_full.RREADY<=1;
else if(axi_full.RREADY&&axi_full.RVALID&&axi_full.RLAST)
    axi_full.RREADY<=0;
//RDATA寄存
always_ff@(posedge axi_full.ACLK)
if(axi_full.RVALID&&axi_full.RREADY)
    tx_buffer[tx_buffer_cnt]<=axi_full.RDATA;
//rd_cnt
always_ff@(posedge axi_full.ACLK,negedge axi_full.ARESETn)
if(~axi_full.ARESETn)
    rd_cnt<=0;
else if(axi_full.ARVALID&&axi_full.ARREADY)
    rd_cnt<=0;
else if(axi_full.RVALID&&axi_full.RREADY)
    rd_cnt<=rd_cnt+1;
//tx_buffer_cnt
always_ff@(posedge axi_full.ACLK,negedge axi_full.ARESETn)
if(~axi_full.ARESETn)
    tx_buffer_cnt<=0;
else if(start)
    tx_buffer_cnt<=0;
else if(axi_full.RVALID&&axi_full.RREADY)
    tx_buffer_cnt<=tx_buffer_cnt+1;
//写数据
//************************************************************写地址通道***********************************************************
//wr_len
always_comb
if(wr_transfer_cnt<wr_transfer_num-1)
    wr_len=8'd255;
else
    wr_len=wr_total_len[7:0];
//AWVALID
always_ff@(posedge axi_full.ACLK,negedge axi_full.ARESETn)
if(~axi_full.ARESETn)
    axi_full.AWVALID<=0;
else if(writeback||wr_continue)
    axi_full.AWVALID<=1;
else if(axi_full.AWVALID&&axi_full.AWREADY)
    axi_full.AWVALID<=0;
//AWADDR
always_ff@(posedge axi_full.ACLK,negedge axi_full.ARESETn)
if(~axi_full.ARESETn)
    axi_full.AWADDR<=0;
else if(writeback||wr_continue)
    axi_full.AWADDR<=wr_base_addr+wr_transfer_cnt*256;                      //?
//AWLEN
always_ff@(posedge axi_full.ACLK,negedge axi_full.ARESETn)
if(~axi_full.ARESETn)
    axi_full.AWLEN<=0;
else if(writeback||wr_continue)
    axi_full.AWLEN<=wr_len;
//AWID
assign axi_full.AWID=0;
//AWSIZE
assign axi_full.AWSIZE=4'b0010;
//AWBURST
assign axi_full.AWBURST=2'b01;
//AWLOCK
assign axi_full.AWLOCK=1'b0;
//AWCACHE
assign axi_full.AWCACHE=4'b0011;
//AWPROT
assign axi_full.AWPROT=0;
//AWQOS
assign axi_full.AWQOS=0;
//AWUSER
assign axi_full.AWUSER=0;
//***********************************************************写数据通道***********************************************************
//wr_cnt
always_ff@(posedge axi_full.ACLK,negedge axi_full.ARESETn)
if(~axi_full.ARESETn)
    wr_cnt<=0;
else if(axi_full.AWVALID&&axi_full.AWREADY)
    wr_cnt<=0;
else if(axi_full.WVALID&&axi_full.WREADY)
if(axi_full.WLAST)
    wr_cnt<=0;
else
    wr_cnt<=wr_cnt+1;
//WVALID
always_ff@(posedge axi_full.ACLK,negedge axi_full.ARESETn)
if(~axi_full.ARESETn)
    axi_full.WVALID<=0;
else if(axi_full.AWVALID&&axi_full.AWREADY)
    axi_full.WVALID<=1;
else if(axi_full.WVALID&&axi_full.WREADY&&axi_full.WLAST)
    axi_full.WVALID<=0;
//WLAST
always_ff@(posedge axi_full.ACLK,negedge axi_full.ARESETn)
if(~axi_full.ARESETn)
    axi_full.WLAST<=0;
else if(axi_full.WVALID&&axi_full.WREADY&&wr_cnt==wr_len-1)
    axi_full.WLAST<=1;
else if(axi_full.WVALID&&axi_full.WREADY&&axi_full.WLAST)
    axi_full.WLAST<=0;
//WDATA
always_comb
if(axi_full.WVALID&&axi_full.WREADY)
    axi_full.WDATA=rx_buffer[rx_buffer_cnt];
else
    axi_full.WDATA=0;
//rx_buffer_cnt
always_ff@(posedge axi_full.ACLK,negedge axi_full.ARESETn)
if(~axi_full.ARESETn)
    rx_buffer_cnt<=0;
else if(writeback)
    rx_buffer_cnt<=0;
else if(axi_full.WVALID&&axi_full.WREADY)                                      //
    rx_buffer_cnt<=rx_buffer_cnt+1;
//
assign axi_full.WSTRB=4'b1111;
assign axi_full.WUSER=0;
//***********************************************************写应答通道***********************************************************
//BREADY
always_ff@(posedge axi_full.ACLK,negedge axi_full.ARESETn)
if(~axi_full.ARESETn)
    axi_full.BREADY<=0;
else if(axi_full.AWVALID&&axi_full.AWREADY)
    axi_full.BREADY<=1;
else if(axi_full.BVALID&&axi_full.BREADY)
    axi_full.BREADY<=0;

//**********************************************AXIS MASTER,DMA向设备写入**********************************************
//TLAST
always_ff@(posedge m_axis.ACLK,negedge m_axis.ARESETn)
if(~m_axis.ARESETn)
    m_axis.TLAST<=0;
else if(m_axis.TVALID&&m_axis.TREADY&&send_cnt==rd_total_len-1)
    m_axis.TLAST<=1;
else
    m_axis.TLAST<=0;
//TVALID
always_ff@(posedge m_axis.ACLK,negedge m_axis.ARESETn)
if(~m_axis.ARESETn)
    m_axis.TVALID<=0;
else if(send_cnt+1<tx_buffer_cnt)                   //只要buffer有数据就拉高
    m_axis.TVALID<=1;
else if(m_axis.TVALID&&m_axis.TREADY&&m_axis.TLAST||(send_cnt+1>=tx_buffer_cnt))
    m_axis.TVALID<=0;
//TUSER
assign m_axis.TUSER=0;
//TSTRB
assign m_axis.TSTRB=4'b1111;
//TDATA
always_comb
if(m_axis.TVALID&&m_axis.TREADY)
    m_axis.TDATA=tx_buffer[send_cnt];
else
    m_axis.TDATA=0;
//send_cnt
always_ff@(posedge m_axis.ACLK,negedge m_axis.ARESETn)
if(~m_axis.ARESETn)
    send_cnt<=0;
else if(start)
    send_cnt<=0;
else if(m_axis.TVALID&&m_axis.TREADY)             //成功发送一个数据
if(m_axis.TLAST)
    send_cnt<=0;
else
    send_cnt<=send_cnt+1;
//*******************************************************AXIS SLAVE,DMA接收来自设备的数据*******************************************************
//TREADY
always_ff@(posedge s_axis.ACLK,negedge s_axis.ARESETn)
if(~s_axis.ARESETn)
    s_axis.TREADY<=0;
else if(start)
    s_axis.TREADY<=1;
else if(s_axis.TREADY&&s_axis.TVALID&&s_axis.TLAST)
    s_axis.TREADY<=0;
//缓存数据
always_ff@(posedge s_axis.ACLK)
if(s_axis.TVALID&&s_axis.TREADY)
    rx_buffer[recv_cnt]<=s_axis.TDATA;
//recv_cnt
always_ff@(posedge s_axis.ACLK,negedge s_axis.ARESETn)
if(~s_axis.ARESETn)
    recv_cnt<=0;
else if(start)
    recv_cnt<=0;
else if(s_axis.TVALID&&s_axis.TREADY)
    recv_cnt<=recv_cnt+1;
//***********************************************************AXI LITE,配置寄存器*************************************************************
//写寄存器
/*
rd_base_addr         0
rd_total_len         4
wr_base_addr         8
wr_total_len         12
start                16
done                 20
*/
//写地址通道
//AWREADY
always_ff@(posedge s_axilite.ACLK,negedge s_axilite.ARESETn)
if(~s_axilite.ARESETn)
    s_axilite.AWREADY<=0;
else if(s_axilite.AWVALID&&s_axilite.WVALID&&~s_axilite.AWREADY)
    s_axilite.AWREADY<=1;
else if(s_axilite.AWVALID&&s_axilite.AWREADY)
    s_axilite.AWREADY<=0;
//************************************************写数据通道************************************************
//WREADY
always_ff@(posedge s_axilite.ACLK,negedge s_axilite.ARESETn)
if(~s_axilite.ARESETn)
    s_axilite.WREADY<=0;
else if(s_axilite.AWVALID&&s_axilite.WVALID&&~s_axilite.WREADY)
    s_axilite.WREADY<=1;
else if(s_axilite.WVALID&&s_axilite.WREADY)
    s_axilite.WREADY<=0;
//将数据写入寄存器
always_ff@(posedge s_axilite.ACLK)
if(s_axilite.WVALID&&s_axilite.AWVALID&&s_axilite.AWREADY&&s_axilite.WREADY)
begin
    case(s_axilite.AWADDR[4:2])
        3'd0:rd_base_addr_r<=s_axilite.WDATA;
        3'd1:rd_total_len_r<=s_axilite.WDATA;
        3'd2:wr_base_addr_r<=s_axilite.WDATA;
        3'd3:wr_total_len_r<=s_axilite.WDATA;
        3'd4:start_r<=s_axilite.WDATA;
        3'd5:done_r<=s_axilite.WDATA;
        default:;
    endcase
end
//**************************************************写响应通道********************************************
//BVALID
always_ff@(posedge s_axilite.ACLK,negedge s_axilite.ARESETn)
if(~s_axilite.ARESETn)
    s_axilite.BVALID<=0;
else if(s_axilite.WVALID&&s_axilite.WREADY)
    s_axilite.BVALID<=1;
else if(s_axilite.BVALID&&s_axilite.BREADY)
    s_axilite.BVALID<=0;
//BRESP
assign s_axilite.BRESP=2'b00;
//***********************************************AXI LITE读地址通道***************************************
//ARREADY
always_ff@(posedge s_axilite.ACLK,negedge s_axilite.ARESETn)
if(~s_axilite.ARESETn)
    s_axilite.ARREADY<=0;
else if(s_axilite.ARVALID&&~s_axilite.ARREADY)
    s_axilite.ARREADY<=1;
else if(s_axilite.ARREADY&&s_axilite.ARVALID)
    s_axilite.ARREADY<=0;
//****************************************************读数据通道***********************************************
//RVALID
always_ff@(posedge s_axilite.ACLK,s_axilite.ARESETn)
if(~s_axilite.ARESETn)
    s_axilite.RVALID<=0;
else if(s_axilite.ARVALID&&s_axilite.ARREADY)
    s_axilite.RVALID<=1;
else if(s_axilite.RVALID&&s_axilite.RREADY)
    s_axilite.RVALID<=0;
//RDATA
always_ff@(posedge s_axilite.ACLK)
if(s_axilite.ARVALID&&s_axilite.ARREADY)
begin
    case(s_axilite.ARADDR[4:2])
        3'd0:s_axilite.RDATA<=rd_base_addr_r;
        3'd1:s_axilite.RDATA<=rd_total_len_r;
        3'd2:s_axilite.RDATA<=wr_base_addr_r;
        3'd3:s_axilite.RDATA<=wr_total_len_r;
        3'd4:s_axilite.RDATA<=start_r;
        3'd5:s_axilite.RDATA<=done_r;
        default:;
    endcase
end
//RRESP
assign RRESP=2'b00;
//start_r_ff
always_ff@(posedge s_axilite.ACLK)
    start_r_ff<=start_r;
//start
assign start=start_r[0]&&(~start_r_ff[0]);
//done
assign done=(rx_buffer_cnt==wr_total_len)?1:0;
//
assign rd_base_addr=rd_base_addr_r;
assign rd_total_len=rd_total_len_r;
assign wr_base_addr=wr_base_addr_r;
assign wr_total_len=wr_total_len_r;
//done_r
always_ff@(posedge s_axilite.ACLK,negedge s_axilite.ARESETn)
if(~s_axilite.ARESETn)
    done_r<=32'd0;
else if(start)
    done_r<=32'd0;
else if(done)
    done_r<=32'd1;
endmodule
