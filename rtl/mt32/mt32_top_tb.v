// -*- text -*-
`timescale 1 ns / 1 ps

module mt32_top_tb;

reg         clk;
reg         reset;
reg         init;
reg  [31:0] seed;
wire [31:0] dout;
wire        dout_en;
reg         update;

parameter STEP = 100;
parameter DLY  = 1;

mt32_top c0 (
  .clk     (clk),
  .reset   (reset),
  .init    (init),
  .seed    (seed),
  .dout    (dout),
  .dout_en (dout_en),
  .update  (update)
);

////////////////////////////////////////
always
begin
  clk = 1'b0; #(STEP/2);
  clk = 1'b1; #(STEP/2);
end

initial
begin
  reset = 1'b1; #(STEP*5);
  forever begin
    reset = 1'b0; #(STEP * 10000000);
  end
end

////////////////////////////////////////
initial
begin
  #(STEP/2 + DLY);
  {init, seed, update} = {1'b0, 32'h0000_0000, 1'b0}; #(STEP*10);
  //
  {init, seed, update} = {1'b1, 32'h9a28_e153, 1'b0}; #(STEP*1);
  //{init, seed, update} = {1'b1, 32'h0000_0000, 1'b0}; #(STEP*1);
  // wait until init done
  {init, seed, update} = {1'b0, 32'h0000_0000, 1'b0}; #(STEP*2500);
  //
  {init, seed, update} = {1'b0, 32'h0000_0000, 1'b1}; #(STEP*1);
  {init, seed, update} = {1'b0, 32'h0000_0000, 1'b0}; #(STEP*5);
  {init, seed, update} = {1'b0, 32'h0000_0000, 1'b1}; #(STEP*2);
  {init, seed, update} = {1'b0, 32'h0000_0000, 1'b0}; #(STEP*5);
  {init, seed, update} = {1'b0, 32'h0000_0000, 1'b1}; #(STEP*3);
  {init, seed, update} = {1'b0, 32'h0000_0000, 1'b0}; #(STEP*5);
  {init, seed, update} = {1'b0, 32'h0000_0000, 1'b1}; #(STEP*994);
  {init, seed, update} = {1'b0, 32'h0000_0000, 1'b0}; #(STEP*100);
end

////////////////////////////////////////
//// dump
integer fid0;
initial fid0 = $fopen("dump_init_state.txt");
always @ (posedge clk)
begin
  if (c0.init0.wen == 1'b1)
    $fwrite(fid0, "%08x\n", c0.init0.wdata);
end

integer fid1;
initial fid1 = $fopen("dump_1000output.txt");
always @ (posedge clk)
begin
  if (dout_en == 1'b1 && update == 1'b1)
    $fwrite(fid1, "%08x\n", dout);
end


endmodule
