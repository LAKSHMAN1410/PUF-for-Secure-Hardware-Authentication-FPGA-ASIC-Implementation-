(* DONT_TOUCH = "true" *)
module ArbiterCell(
    input path_a_sig,   // Signal from the first path
    input path_b_sig,   // Signal from the second path, acts as the clock
    output reg response_bit
);
    always @(posedge path_b_sig)
        response_bit <= path_a_sig;
endmodule

//======================================================================
// Module: Mux2to1
// Function: A standard 2-to-1 multiplexer.
//======================================================================
(* DONT_TOUCH = "true" *)
module Mux2to1(
    input  InputA,
    input  InputB,
    input  Select,
    output OutputMux
);
    assign OutputMux = (~Select & InputA) | (Select & InputB);
endmodule

//======================================================================
// Module: Demux1to2
// Function: A standard 1-to-2 demultiplexer.
//======================================================================
(* DONT_TOUCH = "true" *)
module Demux1to2(
    input  InputDemux,
    input  Select,
    output OutputY,
    output OutputZ
);
    assign OutputY = (~Select) & InputDemux;
    assign OutputZ = Select & InputDemux;
endmodule

//======================================================================
// Module: ArbiterStage
// Function: A single stage of a classic arbiter PUF. It has two
// cross-coupled multiplexers controlled by a challenge bit.
//======================================================================
(* DONT_TOUCH = "true" *)
module ArbiterStage(
    input  PathTopIn,
    input  PathBottomIn,
    input  ChallengeBit,
    output PathTopOut,
    output PathBottomOut
);
    (* DONT_TOUCH = "true" *)
    Mux2to1 mux_top (
        .InputA(PathTopIn),
        .InputB(PathBottomIn),
        .Select(ChallengeBit),
        .OutputMux(PathTopOut)
    );

    (* DONT_TOUCH = "true" *)
    Mux2to1 mux_bottom (
        .InputA(PathBottomIn),
        .InputB(PathTopIn),
        .Select(ChallengeBit),
        .OutputMux(PathBottomOut)
    );
endmodule

//======================================================================
// Module: DualDemuxStage
// Function: A block containing two 1-to-2 demultiplexers.
//======================================================================
(* DONT_TOUCH = "true" *)
module DualDemuxStage(
    input  InputX,
    input  InputY,
    input  Select,
    output OutputE,
    output OutputF,
    output OutputG,
    output OutputH
);
    (* DONT_TOUCH = "true" *)
    Demux1to2 demux1 (InputX, Select, OutputE, OutputF);

    (* DONT_TOUCH = "true" *)
    Demux1to2 demux2 (InputY, Select, OutputG, OutputH);
endmodule

//======================================================================
// Module: ArbiterPUF_Chain
// Function: An 8-stage arbiter PUF chain. A trigger starts a race
// down two paths, with challenge bits determining the route.
//======================================================================
(* DONT_TOUCH = "true" *)
module ArbiterPUF_Chain(
    input      Trigger,
    input [7:0] Challenge,
    output     Response
);
    wire [15:0] path_signals;

    (* DONT_TOUCH = "true" *) ArbiterStage s1(Trigger, Trigger, Challenge[0], path_signals[0], path_signals[1]);
    (* DONT_TOUCH = "true" *) ArbiterStage s2(path_signals[0], path_signals[1], Challenge[1], path_signals[2], path_signals[3]);
    (* DONT_TOUCH = "true" *) ArbiterStage s3(path_signals[2], path_signals[3], Challenge[2], path_signals[4], path_signals[5]);
    (* DONT_TOUCH = "true" *) ArbiterStage s4(path_signals[4], path_signals[5], Challenge[3], path_signals[6], path_signals[7]);
    (* DONT_TOUCH = "true" *) ArbiterStage s5(path_signals[6], path_signals[7], Challenge[4], path_signals[8], path_signals[9]);
    (* DONT_TOUCH = "true" *) ArbiterStage s6(path_signals[8], path_signals[9], Challenge[5], path_signals[10], path_signals[11]);
    (* DONT_TOUCH = "true" *) ArbiterStage s7(path_signals[10], path_signals[11], Challenge[6], path_signals[12], path_signals[13]);
    (* DONT_TOUCH = "true" *) ArbiterStage s8(path_signals[12], path_signals[13], Challenge[7], path_signals[14], path_signals[15]);

    (* DONT_TOUCH = "true" *)
    ArbiterCell arbiter (
        .path_a_sig(path_signals[14]),
        .path_b_sig(path_signals[15]),
        .response_bit(Response)
    );
endmodule

//======================================================================
// Module: ComplexPUF_Chain
// Function: A more complex PUF structure involving mux and demux
// stages, controlled by a challenge and a select bit.
//======================================================================
(* DONT_TOUCH = "true" *)
module ComplexPUF_Chain(
    input      Trigger,
    input [7:0] Challenge,
    input      Select,
    output     Response
);
    wire [23:0] w;

    (* DONT_TOUCH = "true" *) ArbiterStage s1(Trigger, Trigger, Challenge[0], w[0], w[1]);
    (* DONT_TOUCH = "true" *) ArbiterStage s2(w[0], w[1], Challenge[1], w[2], w[3]);
    (* DONT_TOUCH = "true" *) DualDemuxStage ds1(w[2], w[3], Select, w[4], w[5], w[6], w[7]);
    (* DONT_TOUCH = "true" *) ArbiterStage s3(w[4], w[6], Challenge[2], w[8], w[9]);
    (* DONT_TOUCH = "true" *) ArbiterStage s4(w[8], w[9], Challenge[3], w[10], w[11]);
    (* DONT_TOUCH = "true" *) Mux2to1 m1(w[10], w[5], Select, w[12]);
    (* DONT_TOUCH = "true" *) Mux2to1 m2(w[11], w[7], Select, w[13]);
    (* DONT_TOUCH = "true" *) ArbiterStage s5(w[12], w[13], Challenge[4], w[14], w[15]);
    (* DONT_TOUCH = "true" *) ArbiterStage s6(w[14], w[15], Challenge[5], w[16], w[17]);
    (* DONT_TOUCH = "true" *) Mux2to1 m3(w[16], w[5], Select, w[18]);
    (* DONT_TOUCH = "true" *) Mux2to1 m4(w[17], w[7], Select, w[19]);
    (* DONT_TOUCH = "true" *) ArbiterStage s7(w[18], w[19], Challenge[6], w[20], w[21]);
    (* DONT_TOUCH = "true" *) ArbiterStage s8(w[20], w[21], Challenge[7], w[22], w[23]);
   
    (* DONT_TOUCH = "true" *)
    ArbiterCell arbiter (
        .path_a_sig(w[22]),
        .path_b_sig(w[23]),
        .response_bit(Response)
    );
endmodule

//======================================================================
// Module: XOR_PUF
// Function: Combines multiple PUF chains and XORs their outputs
// to produce a single, more robust response bit.
//======================================================================
(* DONT_TOUCH = "true" *)
module XOR_PUF(
    input      Trigger,
    input [7:0] Challenge,
    output     FinalResponse
);
    wire [7:0] puf_bits;

    (* DONT_TOUCH = "true" *) ArbiterPUF_Chain puf1 (Trigger, Challenge, puf_bits[0]);
    (* DONT_TOUCH = "true" *) ComplexPUF_Chain puf2 (Trigger, Challenge, 1'b0, puf_bits[1]);
    (* DONT_TOUCH = "true" *) ArbiterPUF_Chain puf3 (Trigger, Challenge, puf_bits[2]);
    (* DONT_TOUCH = "true" *) ComplexPUF_Chain puf4 (Trigger, Challenge, 1'b1, puf_bits[3]);
    (* DONT_TOUCH = "true" *) ArbiterPUF_Chain puf5 (Trigger, Challenge, puf_bits[4]);
    (* DONT_TOUCH = "true" *) ComplexPUF_Chain puf6 (Trigger, Challenge, 1'b0, puf_bits[5]);
    (* DONT_TOUCH = "true" *) ArbiterPUF_Chain puf7 (Trigger, Challenge, puf_bits[6]);
    (* DONT_TOUCH = "true" *) ComplexPUF_Chain puf8 (Trigger, Challenge, 1'b1, puf_bits[7]);

    // XOR all response bits together for the final 1-bit output
    assign FinalResponse = ^puf_bits;
endmodule

//======================================================================
// Module: Debouncer (Corrected)
// Function: Cleans up noisy button signals.
//======================================================================
module Debouncer (
    input  wire clk,
    input  wire noisy_in,
    output wire debounced_out
);
    parameter COUNTER_MAX = 100000; // Debounce for 1ms @ 100MHz clock
    reg [16:0] count = 0;
    reg registered_in = 1'b0;

    always @(posedge clk) begin
        if (noisy_in != registered_in) begin
            count <= count + 1;
            if (count >= COUNTER_MAX) begin
                registered_in <= noisy_in;
            end
        end else begin
            count <= 0;
        end
    end
    assign debounced_out = registered_in;
endmodule

//======================================================================
// Module: Basys3_XOR_PUF_Top (TOP LEVEL)
// Function: Connects the PUF to the Basys 3 board's I/O.
//======================================================================
module Basys3_XOR_PUF_Top(
    input clk,          // Basys 3 100MHz clock
    input [7:0] sw,     // Switches for challenge
    input btnC,         // Center button for trigger
    output [0:0] led    // LED for response
);
    wire debounced_btn;
    reg  debounced_btn_dly = 1'b0;
    wire trigger_pulse;

    // Instantiate the button debouncer for a clean trigger signal
    Debouncer btn_debounce_inst (
        .clk(clk),
        .noisy_in(btnC),
        .debounced_out(debounced_btn)
    );

    // Create a single-cycle pulse on the rising edge of the button press
    always @(posedge clk) begin
        debounced_btn_dly <= debounced_btn;
    end
    assign trigger_pulse = debounced_btn & ~debounced_btn_dly;

    // Instantiate the main PUF logic
    XOR_PUF puf_inst (
        .Trigger(trigger_pulse),
        .Challenge(sw),
        .FinalResponse(led[0])
    );
endmodule