`timescale 1 ns / 1 ps

module synchro
  #(
  parameter          INITIALIZE = "LOGIC0"
  )

  (
  input  wire        async,
  input  wire        clk,
  output wire        sync
  );

  //******************************************************************//
  // Synchronizer.                                                    //
  //******************************************************************//

  wire        temp;

  generate
    if (INITIALIZE == "LOGIC1")
    begin : use_fdp
      FDP fda (.Q(temp),.D(async),.C(clk),.PRE(1'b0));
      FDP fdb (.Q(sync),.D(temp),.C(clk),.PRE(1'b0));
    end
    else
    begin : use_fdc
      FDC fda (.Q(temp),.D(async),.C(clk),.CLR(1'b0));
      FDC fdb (.Q(sync),.D(temp),.C(clk),.CLR(1'b0));
    end
  endgenerate

  // synthesis attribute ASYNC_REG of fda is "TRUE";
  // synthesis attribute ASYNC_REG of fdb is "TRUE";
  // synthesis attribute HU_SET of fda is "SYNC";
  // synthesis attribute HU_SET of fdb is "SYNC";
  // synthesis attribute RLOC of fda is "X0Y0";
  // synthesis attribute RLOC of fdb is "X0Y0";

  //******************************************************************//
  //                                                                  //
  //******************************************************************//

endmodule