// -*- text -*-
`timescale 1ns/1ps

module mt_tdpram # (
  parameter integer D_WIDTH = 18,
  parameter integer A_WIDTH = 14
) (
  input                clk0,
  input  [A_WIDTH-1:0] addr0,
  input                en0,
  input                wen0,
  input  [D_WIDTH-1:0] wdata0,
  output [D_WIDTH-1:0] rdata0,

  input                clk1,
  input  [A_WIDTH-1:0] addr1,
  input                en1,
  input                wen1,
  input  [D_WIDTH-1:0] wdata1,
  output [D_WIDTH-1:0] rdata1
);

////////////////////////////////////////////////////////////

reg  [D_WIDTH-1:0] mem [2**A_WIDTH-1:0] /* synthesis syn_ramstyle="no_rw_check,area" */; 
reg  [D_WIDTH-1:0] rdata0_reg;
reg  [D_WIDTH-1:0] rdata1_reg;

always @(posedge clk0)
begin
  if (en0) begin
    rdata0_reg <= mem[addr0];
    if (wen0)
      mem[addr0] <= wdata0;
  end
end

assign rdata0 = rdata0_reg;

always @(posedge clk1)
begin   
  if (en1) begin
    rdata1_reg <= mem[addr1];
    if (wen1)
      mem[addr1] <= wdata1;
  end
end

assign rdata1 = rdata1_reg;

endmodule

/*
mt_tdpram # (
  .D_WIDTH (18),
  .A_WIDTH (14)) mem0 (
  .clk0   (clk0),
  .addr0  (addr0),
  .en0    (en0),
  .wen0   (wen0),
  .wdata0 (wdata0),
  .rdata0 (rdata0),

  .clk1   (clk1),
  .addr1  (addr1),
  .en1    (en1),
  .wen1   (wen1),
  .wdata1 (wdata1),
  .rdata1 (rdata1)
);
*/
