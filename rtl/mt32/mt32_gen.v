// -*- text -*-
`timescale 1 ns / 1 ps

module mt32_gen (
  input         clk,
  input         reset,
  input         init,
  output [31:0] dout,
  output        dout_en,
  input         update,
  output  [9:0] raddr0,
  output  [9:0] raddr1,
  output        ren,
  input  [31:0] rdata0,
  input  [31:0] rdata1,
  output  [9:0] waddr,
  output        wen,
  output [31:0] wdata
);


reg   [2:0] st_reg;
reg   [9:0] raddr0_reg;
reg   [9:0] raddr1_reg;
reg   [9:0] waddr_reg;
wire        raddr0_cry;
wire        raddr1_cry;
wire        waddr_cry;
reg  [31:0] d0_reg;
reg  [31:0] d1_reg;
reg  [31:0] dm_reg;

//<table>
//entityname: mt32_gen_tbl
//hdltype: verilog
//in: st_reg
//in: init
//in: update
//out: st_next
//out: raddr_ctrl
//out: ren
//out: d0_reg_en
//out: d1_reg_en
//out: waddr_ctrl
//out: wen
//#
//#                 |      raddr     d0    d1    waddr
//#state init update|state ctrl  ren regen regen ctrl  wen
//  ---    1    -   | 001   11    0    0     0    11    0
//#
//  001    0    -   | 010   01    1    0     0    00    0  #read D0
//  010    0    -   | 011   01    1    1     0    00    0  #read D1,DM0
//  011    0    -   | 100   01    1    1     1    00    0  #read D2,DM1
//  100    0    -   | 101   01    1    1     1    00    0  #read D3,DM2
//#
//  101    0    0   | 101   00    0    0     0    00    0
//  101    0    1   | 101   01    1    1     1    01    1
//</table>

////////////////////////////////////////
//// state register
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1)
    st_reg <= 3'd0;
  else if (init == 1'b1)
    st_reg <= 3'd1;
  else if (st_reg == 3'd1)
    st_reg <= 3'd2;
  else if (st_reg == 3'd2)
    st_reg <= 3'd3;
  else if (st_reg == 3'd3)
    st_reg <= 3'd4;
  else if (st_reg == 3'd4)
    st_reg <= 3'd5;
end

////////////////////////////////////////
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    raddr0_reg <= 10'd0;
    raddr1_reg <= 10'd0;
  end else if (init == 1'b1) begin
    raddr0_reg <= 10'd0;
    raddr1_reg <= 10'd396;
  end else if (st_reg == 3'd1 || st_reg == 3'd2 || st_reg == 3'd3 || st_reg == 3'd4) begin
    raddr0_reg <= raddr0_reg + 10'd1;
    raddr1_reg <= raddr1_reg + 10'd1;
  end else if (st_reg == 3'd5 && update == 1) begin
    raddr0_reg <= (raddr0_cry == 1'b1 ? 10'd0 : raddr0_reg + 10'd1);
    raddr1_reg <= (raddr1_cry == 1'b1 ? 10'd0 : raddr1_reg + 10'd1);
  end
end

assign raddr0 = raddr0_reg;
assign raddr1 = raddr1_reg;
assign ren = (st_reg == 3'd1 || st_reg == 3'd2 || st_reg == 3'd3 || st_reg == 3'd4) |
       	     (st_reg == 3'd5 && update == 1'b1);
assign raddr0_cry = (raddr0_reg == 10'd623);
assign raddr1_cry = (raddr1_reg == 10'd623);

////////////////////////////////////////
//// registers
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    d0_reg <= 32'b0;
    d1_reg <= 32'b0;
    dm_reg <= 32'b0;
  end else if (st_reg == 3'd2) begin
    d0_reg <= rdata0;
  end else if (st_reg == 3'd3) begin
    d1_reg <= rdata0;
    dm_reg <= rdata1;
  end else if (st_reg == 3'd4) begin
    d0_reg <= d1_reg;
    d1_reg <= rdata0;
    dm_reg <= rdata1;
  end else if (st_reg == 3'd5 && update == 1'b1) begin
    d0_reg <= d1_reg;
    d1_reg <= rdata0;
    dm_reg <= rdata1;
  end
end

////////////////////////////////////////
//// generator
localparam [31:0] UPPER_MASK = 32'h80000000;
localparam [31:0] LOWER_MASK = 32'h7fffffff;
localparam [31:0] MATRIX_A   = 32'h9908b0df;

wire [31:0] gen_y = (d0_reg & UPPER_MASK) | (d1_reg & LOWER_MASK);
wire [31:0] gen_s = dm_reg ^ {1'b0, gen_y[31:1]} ^ (gen_y[0] == 1'b0 ? 32'b0 : MATRIX_A);

////////////////////////////////////////
//// write address, data
reg  [31:0] wdata_reg;
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    waddr_reg <= 10'd0;
    wdata_reg <= 32'b0;
  end else begin
    if (init == 1'b1)
      waddr_reg <= 10'd0;
    else if (st_reg == 3'd4)
      wdata_reg <= gen_s;
    else if (st_reg == 3'd5 && update == 1'b1) begin
      waddr_reg <= (waddr_cry == 1'b1 ? 10'd0 : waddr_reg + 10'd1);
      wdata_reg <= gen_s;
    end
  end
end

assign waddr_cry = (waddr_reg == 10'd623);
assign waddr = waddr_reg;
assign wen = (st_reg == 3'd5 && update == 1'b1);
assign wdata = wdata_reg;

////////////////////////////////////////
//// dout
wire [31:0] y0 = wdata_reg ^ {11'b0, wdata_reg[31:11]};
wire [31:0] y1 = y0 ^ ({y0[24:0], 7'b0} & 32'h9d2c5680);
wire [31:0] y2 = y1 ^ ({y1[16:0], 15'b0} & 32'hefc60000);
assign dout    = y2 ^ {18'b0, y2[31:18]};

assign dout_en = (st_reg == 3'd5);

endmodule
