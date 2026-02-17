//==========================================================
// ArbiterCell: Basic latch-like arbiter element
//==========================================================
(* DONT_TOUCH = "true" *)
module ArbiterCell(
    input path_a_sig,
    input path_b_sig,
    output reg response_bit
);
    always @(posedge path_b_sig)
        response_bit <= path_a_sig;
endmodule

//==========================================================
// Mux2to1: 2-input Multiplexer
//==========================================================
(* DONT_TOUCH = "true" *)
module Mux2to1(
    input  InputA,
    input  InputB,
    input  Select,
    output OutputMux
);
    assign OutputMux = (~Select & InputA) | (Select & InputB);
endmodule

//==========================================================
// Demux1to2: 1-to-2 Demultiplexer
//==========================================================
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

//==========================================================
// ArbiterStage: A single stage in the Arbiter PUF chain
//==========================================================
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

//==========================================================
// DualDemuxStage: Two parallel demux stages for complexity
//==========================================================
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

//==========================================================
// ArbiterPUF_Chain: 8-stage simple Arbiter PUF
//==========================================================
(* DONT_TOUCH = "true" *)
module ArbiterPUF_Chain(
    input        Trigger,
    input  [7:0] Challenge,
    output       Response
);
    wire [15:0] path_signals;

    (* DONT_TOUCH = "true" *) ArbiterStage s1 (Trigger, Trigger, Challenge[0], path_signals[0], path_signals[1]);
    (* DONT_TOUCH = "true" *) ArbiterStage s2 (path_signals[0], path_signals[1], Challenge[1], path_signals[2], path_signals[3]);
    (* DONT_TOUCH = "true" *) ArbiterStage s3 (path_signals[2], path_signals[3], Challenge[2], path_signals[4], path_signals[5]);
    (* DONT_TOUCH = "true" *) ArbiterStage s4 (path_signals[4], path_signals[5], Challenge[3], path_signals[6], path_signals[7]);
    (* DONT_TOUCH = "true" *) ArbiterStage s5 (path_signals[6], path_signals[7], Challenge[4], path_signals[8], path_signals[9]);
    (* DONT_TOUCH = "true" *) ArbiterStage s6 (path_signals[8], path_signals[9], Challenge[5], path_signals[10], path_signals[11]);
    (* DONT_TOUCH = "true" *) ArbiterStage s7 (path_signals[10], path_signals[11], Challenge[6], path_signals[12], path_signals[13]);
    (* DONT_TOUCH = "true" *) ArbiterStage s8 (path_signals[12], path_signals[13], Challenge[7], path_signals[14], path_signals[15]);

    (* DONT_TOUCH = "true" *)
    ArbiterCell arbiter (
        .path_a_sig(path_signals[14]),
        .path_b_sig(path_signals[15]),
        .response_bit(Response)
    );
endmodule

//==========================================================
// ComplexPUF_Chain: Combines demux/mux with PUF stages
//==========================================================
(* DONT_TOUCH = "true" *)
module ComplexPUF_Chain(
    input        Trigger,
    input  [7:0] Challenge,
    input        Select,
    output       Response
);
    wire [23:0] w;

    (* DONT_TOUCH = "true" *) ArbiterStage s1 (Trigger, Trigger, Challenge[0], w[0], w[1]);
    (* DONT_TOUCH = "true" *) ArbiterStage s2 (w[0], w[1], Challenge[1], w[2], w[3]);
    (* DONT_TOUCH = "true" *) DualDemuxStage ds1 (w[2], w[3], Select, w[4], w[5], w[6], w[7]);
    (* DONT_TOUCH = "true" *) ArbiterStage s3 (w[4], w[6], Challenge[2], w[8], w[9]);
    (* DONT_TOUCH = "true" *) ArbiterStage s4 (w[8], w[9], Challenge[3], w[10], w[11]);
    (* DONT_TOUCH = "true" *) Mux2to1 m1 (w[10], w[5], Select, w[12]);
    (* DONT_TOUCH = "true" *) Mux2to1 m2 (w[11], w[7], Select, w[13]);
    (* DONT_TOUCH = "true" *) ArbiterStage s5 (w[12], w[13], Challenge[4], w[14], w[15]);
    (* DONT_TOUCH = "true" *) ArbiterStage s6 (w[14], w[15], Challenge[5], w[16], w[17]);
    (* DONT_TOUCH = "true" *) Mux2to1 m3 (w[16], w[5], Select, w[18]);
    (* DONT_TOUCH = "true" *) Mux2to1 m4 (w[17], w[7], Select, w[19]);
    (* DONT_TOUCH = "true" *) ArbiterStage s7 (w[18], w[19], Challenge[6], w[20], w[21]);
    (* DONT_TOUCH = "true" *) ArbiterStage s8 (w[20], w[21], Challenge[7], w[22], w[23]);

    (* DONT_TOUCH = "true" *)
    ArbiterCell arbiter (
        .path_a_sig(w[22]),
        .path_b_sig(w[23]),
        .response_bit(Response)
    );
endmodule

//==========================================================
// XOR_PUF: 8-parallel Arbiter + Complex PUFs XORed together
//==========================================================
(* DONT_TOUCH = "true" *)
module XOR_PUF(
    input        Trigger,
    input  [7:0] Challenge,
    output       FinalResponse
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

    assign FinalResponse = ^puf_bits;
endmodule

//==========================================================
// XOR_PUF_Top: Core top-level (without pads)
//==========================================================
(* DONT_TOUCH = "true" *)
module XOR_PUF_Top(
    input        trigger,
    input  [7:0] challenge,
    output       response
);
    (* DONT_TOUCH = "true" *)
    XOR_PUF puf_inst (
        .Trigger(trigger),
        .Challenge(challenge),
        .FinalResponse(response)
    );
endmodule

//==========================================================
// XOR_PUF_Top_With_Pads: Wrapper with IO pad cells
//==========================================================
(* DONT_TOUCH = "true" *)
module XOR_PUF_Top_With_Pads(
    input  i_trigger_pad,
    input  [7:0] i_challenge_pad,
    output o_response_pad
);

    // Internal nets
    wire trigger_int;
    wire [7:0] challenge_int;
    wire response_int;

    // Input pads -> internal nets
    pc3d01 pad_trigger(.PAD(i_trigger_pad), .CIN(trigger_int));
    pc3d01 pad_ch7(.PAD(i_challenge_pad[7]), .CIN(challenge_int[7]));
    pc3d01 pad_ch6(.PAD(i_challenge_pad[6]), .CIN(challenge_int[6]));
    pc3d01 pad_ch5(.PAD(i_challenge_pad[5]), .CIN(challenge_int[5]));
    pc3d01 pad_ch4(.PAD(i_challenge_pad[4]), .CIN(challenge_int[4]));
    pc3d01 pad_ch3(.PAD(i_challenge_pad[3]), .CIN(challenge_int[3]));
    pc3d01 pad_ch2(.PAD(i_challenge_pad[2]), .CIN(challenge_int[2]));
    pc3d01 pad_ch1(.PAD(i_challenge_pad[1]), .CIN(challenge_int[1]));
    pc3d01 pad_ch0(.PAD(i_challenge_pad[0]), .CIN(challenge_int[0]));

    // Internal XOR_PUF instance
    XOR_PUF_Top core (
        .trigger(trigger_int),
        .challenge(challenge_int),
        .response(response_int)
    );

    // Output internal -> pad
    pc3o05 pad_resp(.I(response_int), .PAD(o_response_pad));

endmodule

