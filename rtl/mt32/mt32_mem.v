// -*- text -*-
`timescale 1 ns / 1 ps

module mt32_mem (
  input         clk,
  input         reset,

  input   [9:0] raddr0,
  input         ren0,
  output [31:0] rdata0,

  input   [9:0] raddr1,
  input         ren1,
  output [31:0] rdata1,

  input   [9:0] waddr0,
  input         wen0,
  input  [31:0] wdata0
);

mt_tdpram # (
  .D_WIDTH (32),
  .A_WIDTH (10)) mem0 (
  .clk0   (clk),
  .addr0  (raddr0),
  .en0    (ren0),
  .wen0   (1'b0),
  .wdata0 (32'b0),
  .rdata0 (rdata0),

  .clk1   (clk),
  .addr1  (waddr0),
  .en1    (wen0),
  .wen1   (wen0),
  .wdata1 (wdata0),
  .rdata1 ()
);

mt_tdpram # (
  .D_WIDTH (32),
  .A_WIDTH (10)) mem1 (
  .clk0   (clk),
  .addr0  (raddr1),
  .en0    (ren1),
  .wen0   (1'b0),
  .wdata0 (32'b0),
  .rdata0 (rdata1),

  .clk1   (clk),
  .addr1  (waddr0),
  .en1    (wen0),
  .wen1   (wen0),
  .wdata1 (wdata0),
  .rdata1 ()
);

endmodule
