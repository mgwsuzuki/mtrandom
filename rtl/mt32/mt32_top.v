// -*- text -*-
`timescale 1 ns / 1 ps

module mt32_top (
  input         clk,
  input         reset,
  input         init,
  input  [31:0] seed,
  output [31:0] dout,
  output        dout_en,
  input         update
);


wire  [9:0] gen_raddr0;
wire  [9:0] gen_raddr1;
wire        gen_ren;
wire [31:0] gen_rdata0;
wire [31:0] gen_rdata1;

wire  [9:0] mem_waddr0;
wire        mem_wen0;
wire [31:0] mem_wdata0;

wire  [9:0] init_waddr;
wire        init_wen;
wire [31:0] init_wdata;
wire        init_done;
wire        init_is_init;

wire  [9:0] gen_waddr;
wire        gen_wen;
wire [31:0] gen_wdata;

////////////////////////////////////////
assign mem_waddr0 = (init_is_init == 1'b1 ? init_waddr : gen_waddr);
assign mem_wen0   = (init_is_init == 1'b1 ? init_wen   : gen_wen);
assign mem_wdata0 = (init_is_init == 1'b1 ? init_wdata : gen_wdata);

mt32_mem mem0 (
  .clk    (clk),
  .reset  (reset),

  .raddr0 (gen_raddr0),
  .ren0   (gen_ren),
  .rdata0 (gen_rdata0),

  .raddr1 (gen_raddr1),
  .ren1   (gen_ren),
  .rdata1 (gen_rdata1),

  .waddr0 (mem_waddr0),
  .wen0   (mem_wen0),
  .wdata0 (mem_wdata0)
);

mt32_init init0 (
  .clk     (clk),
  .reset   (reset),
  .init    (init),
  .seed    (seed),
  .waddr   (init_waddr),
  .wen     (init_wen),
  .wdata   (init_wdata),
  .is_init (init_is_init),
  .done    (init_done)
);

mt32_gen gen0 (
  .clk     (clk),
  .reset   (reset),
  .init    (init_done),
  .dout    (dout),
  .dout_en (dout_en),
  .update  (update),
  .raddr0  (gen_raddr0),
  .raddr1  (gen_raddr1),
  .ren     (gen_ren),
  .rdata0  (gen_rdata0),
  .rdata1  (gen_rdata1),
  .waddr   (gen_waddr),
  .wen     (gen_wen),
  .wdata   (gen_wdata)
);

endmodule
