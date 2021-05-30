`timescale 1 ns / 1 ps

module debnce
  (
  input  wire        sync,
  input  wire        clk,
  output reg         debnced = 1'b0
  );

  //******************************************************************//
  // Implement debouncing.                                            //
  //******************************************************************//

  reg         [15:0] ctr;
  reg                dly;
  wire               sat;

  reg                sync_q;
  reg                transition;

  wire block_out;
  SRL16E #(.INIT(16'h0)) blockout_0 (
    .Q(block_out),
    .A0(1'b1),
    .A1(1'b1),
    .A2(1'b1),
    .A3(1'b1),
    .CE(1'b1),
    .CLK(clk),
    .D(1'b1)
  );

  always @ (posedge clk) begin
    sync_q <= sync;
    transition <= block_out & (sync_q ^ sync);
  end

  reg cntr_en;
  always @ (posedge clk) begin
    if(transition)
      cntr_en <= 1'b1;
    else if(sat)
      cntr_en <= 1'b0;
  end


`ifdef SIMULATION
  initial begin
    ctr = 16'b0;
  end

  parameter SATISFY = 16'hff;
`else
  parameter SATISFY = 16'hffff;
`endif

  assign sat = (ctr == SATISFY);

  always @(posedge clk)
  begin
    if(transition)
      ctr <= 1'b0;
    else if(cntr_en)
      ctr <= ctr + 1;
  end

  always @ (posedge clk) begin
    debnced <= sat;
  end 

endmodule
