//================================================================
// PUF CORE MODULES (Unchanged)
//================================================================

(* DONT_TOUCH = "true" *)
module ArbiterCell(
    input path_a_sig,   
    input path_b_sig,   
    output reg response_bit
);
    always @(posedge path_b_sig)
        response_bit <= path_a_sig;
endmodule

(* DONT_TOUCH = "true" *)
module Mux2to1(
    input  InputA,
    input  InputB,
    input  Select,
    output OutputMux
);
    assign OutputMux = (~Select & InputA) | (Select & InputB);
endmodule

//================================================================
// 16-BIT PUF CHAIN MODULES (MODIFIED)
//================================================================

(* DONT_TOUCH = "true" *)
module ArbiterStage(
    input  PathTopIn,
    input  PathBottomIn,
    input  ChallengeBit,
    output PathTopOut,
    output PathBottomOut
);
    Mux2to1 mux_top (
        .InputA(PathTopIn), .InputB(PathBottomIn), .Select(ChallengeBit), .OutputMux(PathTopOut)
    );
    Mux2to1 mux_bottom (
        .InputA(PathBottomIn), .InputB(PathTopIn), .Select(ChallengeBit), .OutputMux(PathBottomOut)
    );
endmodule

(* DONT_TOUCH = "true" *)
module ArbiterPUF_Chain_16bit(
    input      Trigger,
    input [15:0] Challenge, // CHANGED: 16-bit challenge
    output     Response
);
    wire [31:0] path_signals; // CHANGED: 16 stages * 2 = 32 signals

    // CHANGED: Expanded to 16 ArbiterStages
    ArbiterStage s1 (Trigger, Trigger, Challenge[0], path_signals[0], path_signals[1]);
    ArbiterStage s2 (path_signals[0], path_signals[1], Challenge[1], path_signals[2], path_signals[3]);
    ArbiterStage s3 (path_signals[2], path_signals[3], Challenge[2], path_signals[4], path_signals[5]);
    ArbiterStage s4 (path_signals[4], path_signals[5], Challenge[3], path_signals[6], path_signals[7]);
    ArbiterStage s5 (path_signals[6], path_signals[7], Challenge[4], path_signals[8], path_signals[9]);
    ArbiterStage s6 (path_signals[8], path_signals[9], Challenge[5], path_signals[10], path_signals[11]);
    ArbiterStage s7 (path_signals[10], path_signals[11], Challenge[6], path_signals[12], path_signals[13]);
    ArbiterStage s8 (path_signals[12], path_signals[13], Challenge[7], path_signals[14], path_signals[15]);
    ArbiterStage s9 (path_signals[14], path_signals[15], Challenge[8], path_signals[16], path_signals[17]);
    ArbiterStage s10(path_signals[16], path_signals[17], Challenge[9], path_signals[18], path_signals[19]);
    ArbiterStage s11(path_signals[18], path_signals[19], Challenge[10], path_signals[20], path_signals[21]);
    ArbiterStage s12(path_signals[20], path_signals[21], Challenge[11], path_signals[22], path_signals[23]);
    ArbiterStage s13(path_signals[22], path_signals[23], Challenge[12], path_signals[24], path_signals[25]);
    ArbiterStage s14(path_signals[24], path_signals[25], Challenge[13], path_signals[26], path_signals[27]);
    ArbiterStage s15(path_signals[26], path_signals[27], Challenge[14], path_signals[28], path_signals[29]);
    ArbiterStage s16(path_signals[28], path_signals[29], Challenge[15], path_signals[30], path_signals[31]);

    ArbiterCell arbiter (
        .path_a_sig(path_signals[30]), // CHANGED
        .path_b_sig(path_signals[31]), // CHANGED
        .response_bit(Response)
    );
endmodule

(* DONT_TOUCH = "true" *)
module XOR_PUF_16bit(
    input      Trigger,
    input [15:0] Challenge, // CHANGED
    output     FinalResponse
);
    wire [7:0] puf_bits;

    ArbiterPUF_Chain_16bit puf1 (Trigger, Challenge, puf_bits[0]);
    ArbiterPUF_Chain_16bit puf2 (Trigger, ~Challenge, puf_bits[1]);
    ArbiterPUF_Chain_16bit puf3 (Trigger, Challenge, puf_bits[2]);
    ArbiterPUF_Chain_16bit puf4 (Trigger, ~Challenge, puf_bits[3]);
    ArbiterPUF_Chain_16bit puf5 (Trigger, Challenge, puf_bits[4]);
    ArbiterPUF_Chain_16bit puf6 (Trigger, ~Challenge, puf_bits[5]);
    ArbiterPUF_Chain_16bit puf7 (Trigger, Challenge, puf_bits[6]);
    ArbiterPUF_Chain_16bit puf8 (Trigger, ~Challenge, puf_bits[7]);

    assign FinalResponse = ^puf_bits;
endmodule


// UART Receiver
(* DONT_TOUCH = "true" *)
module uart_rx(
    input  i_clk,
    input  i_rx_serial,
    output o_rx_dv,
    output [7:0] o_rx_byte
);
    parameter CLKS_PER_BIT = 10417; // For 9600 baud @ 100MHz clock

    localparam IDLE         = 2'b00;
    localparam RX_START_BIT = 2'b01;
    localparam RX_DATA_BITS = 2'b10;
    localparam RX_STOP_BIT  = 2'b11;

    reg [1:0]    r_state = IDLE;
    reg [13:0]   r_clk_counter = 0;
    reg [2:0]    r_bit_index = 0;
    reg [7:0]    r_rx_byte = 0;
    reg          r_rx_dv = 0;

    always @(posedge i_clk) begin
        case (r_state)
            IDLE: begin
                r_rx_dv <= 1'b0;
                if (i_rx_serial == 1'b0) begin
                    r_clk_counter <= 0;
                    r_state       <= RX_START_BIT;
                end
            end
            RX_START_BIT: begin
                if (r_clk_counter == (CLKS_PER_BIT / 2) - 1) begin
                    if (i_rx_serial == 1'b0) begin
                        r_clk_counter <= 0;
                        r_bit_index   <= 0;
                        r_state       <= RX_DATA_BITS;
                    end else begin
                        r_state <= IDLE;
                    end
                end else begin
                    r_clk_counter <= r_clk_counter + 1;
                end
            end
            RX_DATA_BITS: begin
                if (r_clk_counter == CLKS_PER_BIT - 1) begin
                    r_clk_counter <= 0;
                    r_rx_byte[r_bit_index] <= i_rx_serial;
                    if (r_bit_index < 7) begin
                        r_bit_index <= r_bit_index + 1;
                    end else begin
                        r_state <= RX_STOP_BIT;
                    end
                end else begin
                    r_clk_counter <= r_clk_counter + 1;
                end
            end
            RX_STOP_BIT: begin
                if (r_clk_counter == CLKS_PER_BIT - 1) begin
                    r_clk_counter <= 0;
                    r_rx_dv       <= 1'b1;
                    r_state       <= IDLE;
                end else begin
                    r_clk_counter <= r_clk_counter + 1;
                end
            end
            default:
                r_state <= IDLE;
        endcase
    end
    assign o_rx_dv   = r_rx_dv;
    assign o_rx_byte = r_rx_byte;
endmodule

// UART Transmitter
(* DONT_TOUCH = "true" *)
module uart_tx(
    input        i_clk,
    input        i_tx_start,
    input  [7:0] i_tx_byte,
    output       o_tx_serial,
    output       o_tx_busy
);
    parameter CLKS_PER_BIT = 10417; // For 9600 baud @ 100MHz clock

    localparam IDLE         = 2'b00;
    localparam TX_START_BIT = 2'b01;
    localparam TX_DATA_BITS = 2'b10;
    localparam TX_STOP_BIT  = 2'b11;

    reg [1:0]    r_state = IDLE;
    reg [13:0]   r_clk_counter = 0;
    reg [2:0]    r_bit_index = 0;
    reg [7:0]    r_tx_byte = 0;
    reg          r_tx_serial = 1'b1;
    reg          r_tx_busy = 1'b0;

    always @(posedge i_clk) begin
        case (r_state)
            IDLE: begin
                r_tx_serial <= 1'b1;
                r_tx_busy   <= 1'b0;
                if (i_tx_start) begin
                    r_tx_byte     <= i_tx_byte;
                    r_clk_counter <= 0;
                    r_tx_busy     <= 1'b1;
                    r_state       <= TX_START_BIT;
                end
            end
            TX_START_BIT: begin
                r_tx_serial <= 1'b0;
                if (r_clk_counter == CLKS_PER_BIT - 1) begin
                    r_clk_counter <= 0;
                    r_bit_index   <= 0;
                    r_state       <= TX_DATA_BITS;
                end else begin
                    r_clk_counter <= r_clk_counter + 1;
                end
            end
            TX_DATA_BITS: begin
                r_tx_serial <= r_tx_byte[r_bit_index];
                if (r_clk_counter == CLKS_PER_BIT - 1) begin
                    r_clk_counter <= 0;
                    if (r_bit_index < 7) begin
                        r_bit_index <= r_bit_index + 1;
                    end else begin
                        r_state <= TX_STOP_BIT;
                    end
                end else begin
                    r_clk_counter <= r_clk_counter + 1;
                end
            end
            TX_STOP_BIT: begin
                r_tx_serial <= 1'b1;
                if (r_clk_counter == CLKS_PER_BIT - 1) begin
                    r_clk_counter <= 0;
                    r_state       <= IDLE;
                end else begin
                    r_clk_counter <= r_clk_counter + 1;
                end
            end
            default:
                r_state <= IDLE;
        endcase
    end
    assign o_tx_serial = r_tx_serial;
    assign o_tx_busy   = r_tx_busy;
endmodule


//================================================================
// 16-BIT FULL-DUPLEX TOP MODULE (MODIFIED)
//================================================================

module Basys3_XOR_PUF_Top_16bit(
    input clk,          
    input rx,           
    output tx,
    output [0:0] led    
);

    // FSM states - ADDED a state for receiving the second byte
    localparam STATE_IDLE              = 3'b001;
    localparam STATE_WAIT_FOR_BYTE_2   = 3'b010; // NEW STATE
    localparam STATE_TRIGGER_PUF       = 3'b011;
    localparam STATE_SEND_RESPONSE     = 3'b100;
    
    reg [2:0] current_state = STATE_IDLE; // Changed to 3 bits

    // Internal signals (no changes here)
    wire       rx_dv;
    wire [7:0] rx_byte;
    wire       tx_busy;
    wire       puf_response;

    reg [15:0] challenge_reg = 16'b0;
    reg        trigger_reg = 1'b0;
    reg [7:0]  response_to_send = 8'b0;
    reg        tx_start_reg = 1'b0;

    // Instantiations (no changes here)
    uart_rx uart_receiver_inst (
        .i_clk(clk), .i_rx_serial(rx), .o_rx_dv(rx_dv), .o_rx_byte(rx_byte)
    );
    uart_tx uart_transmitter_inst (
        .i_clk(clk), .i_tx_start(tx_start_reg), .i_tx_byte(response_to_send), .o_tx_serial(tx), .o_tx_busy(tx_busy)
    );
    XOR_PUF_16bit puf_inst (
        .Trigger(trigger_reg), .Challenge(challenge_reg), .FinalResponse(puf_response)
    );
    
    assign led[0] = puf_response;

    // --- Main control FSM (CORRECTED for 2-byte reception) ---
    always @(posedge clk) begin
        trigger_reg  <= 1'b0;
        tx_start_reg <= 1'b0;

        case (current_state)
            STATE_IDLE: begin
                if (rx_dv) begin
                    challenge_reg[7:0] <= rx_byte;  // Store first byte
                    current_state <= STATE_WAIT_FOR_BYTE_2; // Move to next state
                end
            end

            STATE_WAIT_FOR_BYTE_2: begin
                if (rx_dv) begin
                    challenge_reg[15:8] <= rx_byte; // Store second byte
                    current_state <= STATE_TRIGGER_PUF; // Both bytes received, now trigger
                end
            end
            
            STATE_TRIGGER_PUF: begin
                trigger_reg <= 1'b1;
                current_state <= STATE_SEND_RESPONSE;
            end

            STATE_SEND_RESPONSE: begin
                response_to_send <= puf_response ? 8'h31 : 8'h30;
                tx_start_reg <= 1'b1;
                // Wait for the transmitter to become free before going back to idle
                if (!tx_busy) begin
                    current_state <= STATE_IDLE;
                end
            end
            
            default: begin
                current_state <= STATE_IDLE;
            end
        endcase
    end
endmodule
