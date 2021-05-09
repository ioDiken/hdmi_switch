/**
 * A simple macro header file for commonly used test macros.
 */

 `ifndef _test_macros_vh_
 `define _test_macros_vh_

`define ASSERT_EQ(desc, sig1, sig2) \
        if (sig1 !== sig2) begin \
            $display("ASSERT_EQ Failed[%s] in %m:\n\tsig1(%h) != sig2(%h)", desc, sig1, sig2); \
            $finish; \
        end

`define EXPECT_EQ(desc, sig1, sig2) \
        if (sig1 !== sig2) begin \
            $display("EXPECT_EQ Failed[%s] in %m:\n\tsig1(%h) != sig2(%h)", desc, sig1, sig2); \
        end

`endif // _test_macros_vh_