`include "design.sv"
module reg_core #(
    parameter N = 8,
    parameter P = 3,
    parameter W = 8
)(
    input  logic                  clk,
    input  logic                  rst_n,
 
    // Register interface
    input  logic                  wr_en,
    input  logic                  rd_en,
    input  logic [7:0]            addr,
    input  logic [31:0]           wdata,
    output logic [31:0]           rdata,
 
    // External interrupt inputs and output pin
    input  logic [N-1:0]          int_in,
    output logic                  int_out
);
 
    // Internal wires to/from DUT
    logic [N-1:0]          int_enable;
    logic [N-1:0]          int_mask;
    logic [N-1:0][P-1:0]   int_priority;
    logic [N-1:0]          int_clear;
    logic                  out_mode;
    logic                  out_polarity;
    logic [W-1:0]          pulse_width;
 
    logic [N-1:0]          int_status;
    logic [$clog2(N)-1:0]  int_vector;
 
    // Instantiate DUT
    generic_intc #(.N(N), .P(P), .W(W)) u_dut (
        .clk(clk),
        .rst_n(rst_n),
        .int_in(int_in),
        .int_enable(int_enable),
        .int_mask(int_mask),
        .int_priority(int_priority),
        .int_clear(int_clear),
        .out_mode(out_mode),
        .out_polarity(out_polarity),
        .pulse_width(pulse_width),
        .int_status(int_status),
        .int_out(int_out),
        .int_vector(int_vector)
    );
 
    // Register storage
    logic [N-1:0]          int_enable_reg;
    logic [N-1:0]          int_mask_reg;
    logic [N-1:0][P-1:0]   int_priority_reg;
    logic [N-1:0]          int_clear_reg;
    logic                  out_mode_reg;
    logic                  out_polarity_reg;
    logic [W-1:0]          pulse_width_reg;
 
    // Drive inputs to DUT
    assign int_enable   = int_enable_reg;
    assign int_mask     = int_mask_reg;
    assign int_priority = int_priority_reg;
    assign int_clear    = int_clear_reg;
    assign out_mode     = out_mode_reg;
    assign out_polarity = out_polarity_reg;
    assign pulse_width  = pulse_width_reg;
 
    // Register write logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            int_enable_reg   <= '0;
            int_mask_reg     <= '0;
            int_clear_reg    <= '0;
            out_mode_reg     <= 1'b0;
            out_polarity_reg <= 1'b0;
            pulse_width_reg  <= '0;
            for (int i = 0; i < N; i++) begin
                int_priority_reg[i] <= '0;
        end
        end else begin
            int_clear_reg <= '0; // auto-clear W1C
            if (wr_en) begin
                case (addr)
                    8'h00: int_enable_reg   <= wdata[N-1:0];
                    8'h04: int_mask_reg     <= wdata[N-1:0];
                    8'h08: int_clear_reg    <= wdata[N-1:0];
                    8'h0C: out_mode_reg     <= wdata[0];
                    8'h10: out_polarity_reg <= wdata[0];
                    8'h14: pulse_width_reg  <= wdata[W-1:0];
                    default: begin
                        if (addr >= 8'h20 && addr < 8'h20 + N*4)
                            int_priority_reg[(addr - 8'h20)>>2] <= wdata[P-1:0];
                    end
                endcase
            end
        end
    end
 
    // Register read logic
    always_comb begin
        rdata = 32'hDEADBEEF;
        if (rd_en) begin
            case (addr)
                8'h00: rdata = int_enable_reg;
                8'h04: rdata = int_mask_reg;
                8'h08: rdata = '0;
                8'h0C: rdata = {31'b0, out_mode_reg};
                8'h10: rdata = {31'b0, out_polarity_reg};
                8'h14: rdata = pulse_width_reg;
                8'h18: rdata = int_status;
                8'h1C: rdata = int_vector;
                default: begin
                    if (addr >= 8'h20 && addr < 8'h20 + N*4)
                        rdata = int_priority_reg[(addr - 8'h20)>>2];
                end
            endcase
        end
    end
 
endmodule
