// -*- text -*-
`timescale 1 ns / 1 ps

module mt32_init (
  input         clk,
  input         reset,
  input         init,
  input  [31:0] seed,
  output  [9:0] waddr,
  output        wen,
  output [31:0] wdata,
  output        is_init,
  output        done
);

////////////////////////////////////////
reg   [1:0] st_reg;
reg  [31:0] seed_reg;
reg  [11:0] addr_count_reg;
wire        cry;

//<table>
//entityname: mt32_init_tbl
//hdltype: verilog
//in: st_reg
//in: init
//in: cry
//out: st_next
//out: reg_en
//out: addr_ctrl
//out: done
//#
//#              |      seed  addr init
//#state init cry|state regen ctrl done
//   -    1    - |  1     1    11   0
//   1    0    0 |  1     1    01   0
//   1    0    1 |  0     1    11   1
//</table>

////////////////////////////////////////
//// state register
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1)
    st_reg <= 1'b0;
  else if (init == 1'b1)
    st_reg <= 1'b1;
  else if (st_reg == 1'b1 && cry == 1'b0)
    st_reg <= 1'b1;
  else if (st_reg == 1'b1 && cry == 1'b1)
    st_reg <= 1'b0;
end

assign is_init = st_reg;

////////////////////////////////////////
//// counter
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1)
    addr_count_reg <= 12'b0;
  else if (init == 1'b1)
    addr_count_reg <= 10'b0;
  else if (st_reg == 1'b1 && cry == 1'b0)
    addr_count_reg <= addr_count_reg + 12'b1;
  else if (st_reg == 1'b1 && cry == 1'b1)
    addr_count_reg <= 12'b0;
end

assign cry = (addr_count_reg == 12'd2492);

////////////////////////////////////////
//// multiplier
localparam [31:0] SEED_INT   = 32'd1812433253;
localparam [31:0] SEED_H = SEED_INT[31:16];
localparam [31:0] SEED_L = SEED_INT[15:0];

wire [31:0] seed_reg_t = seed_reg ^ {30'b0, seed_reg[31:30]};
wire [15:0] mult_lhs;
wire [15:0] mult_rhs;
reg  [31:0] mult_out_reg;
wire  [1:0] mult_op = addr_count_reg[1:0];

assign {mult_lhs, mult_rhs} = (mult_op == 2'b00 ? {SEED_L, seed_reg_t[15:0]} :
			       mult_op == 2'b01 ? {SEED_L, seed_reg_t[31:16]} :
						  {SEED_H, seed_reg_t[15:0]});

always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1)
    mult_out_reg <= 32'b0;
  else
    mult_out_reg <= mult_lhs * mult_rhs;
end

////////////////////////////////////////
reg  [31:0] acc_reg;

always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1)
    acc_reg <= 32'b0;
  else if (mult_op == 2'b00)
    acc_reg <= addr_count_reg[11:2] + 10'b1;
  else if (mult_op == 2'b01)
    acc_reg <= acc_reg + mult_out_reg;
  else if (mult_op == 2'b10)
    acc_reg <= acc_reg + {mult_out_reg[15:0], 16'b0};
end

////////////////////////////////////////
//// seed reg
always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1)
    seed_reg <= 32'b0;
  else if (init == 1'b1)
    seed_reg <= seed;
  else if (mult_op == 2'b11)
    seed_reg <= acc_reg + {mult_out_reg[15:0], 16'b0};
end

assign wdata = seed_reg;

////////////////////////////////////////
reg        wen_reg;
reg        done_reg;

always @ (posedge clk, posedge reset)
begin
  if (reset == 1'b1) begin
    wen_reg   <= 1'b0;
    done_reg  <= 1'b0;
  end else begin
    wen_reg   <= (addr_count_reg[1:0] == 2'b11) | init;
    done_reg  <= cry;
  end
end

assign waddr = addr_count_reg[11:2];
assign wen   = wen_reg;
assign done  = done_reg;

endmodule
