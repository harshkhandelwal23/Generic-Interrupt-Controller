module generic_intc #(
    parameter integer N = 8,                // Number of interrupt sources
    parameter integer P = 3,                // Priority width (enough for N sources)
    parameter integer W = 8                 // Pulse width register width
)(
    input  logic                  clk,
    input  logic                  rst_n,

    // Interrupt sources
    input  logic [N-1:0]          int_in,

    // Register interface (connect to your register file or bus)
    input  logic  [N-1:0]          int_enable,      // Enable for each source
    input  logic  [N-1:0]          int_mask,        // Mask for each source
    input  logic  [N-1:0][P-1:0]   int_priority,    // Priority for each source
    input  logic  [N-1:0]          int_clear,       // Clear for each source

    input  logic                   out_mode,        // 0=level, 1=pulse
    input  logic                   out_polarity,    // 0=active-low, 1=active-high
    input  logic  [W-1:0]          pulse_width,     // Pulse width in cycles

    // Status outputs
    output logic [N-1:0]          int_status,      // Pending status for each source
    output logic                  int_out,         // Output interrupt pin
    output logic [$clog2(N)-1:0]  int_vector       // Highest-priority pending source
);

    // Internal registers
    logic [N-1:0] pending;
    logic [N-1:0] masked;
    logic [$clog2(N)-1:0] prio_idx;
    logic                 new_irq;
    logic [W-1:0]         pulse_cnt;
    logic                 pulse_active;
    logic [P-1:0]         max_prio;

    // Masking and enable logic
    always_comb begin
        for (int i = 0; i < N; i++) begin
            masked[i] = int_in[i] & int_enable[i] & ~int_mask[i];
        end
    end

    // Pending status logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pending <= '0;
        end else begin
            for (int i = 0; i < N; i++) begin
                // Set pending if masked input is high
                if (masked[i])
                    pending[i] <= 1'b1;
                // Clear if clear signal is asserted
                else if (int_clear[i])
                    pending[i] <= 1'b0;
                // Auto-clear if input goes low (level-sensitive)
                else if (!int_in[i])
                    pending[i] <= 1'b0;
            end
        end
    end

    //assign int_status = pending;
    assign int_status = int_in & int_enable ;

    // Priority arbitration
    always_comb begin
        prio_idx = '0;
        max_prio = '0;
        for (int i = 0; i < N; i++) begin
            if (pending[i]) begin
                if (int_priority[i] > max_prio) begin
                    max_prio = int_priority[i];
                    prio_idx = i[$clog2(N)-1:0];
                end
            end
        end
    end
    assign int_vector = prio_idx;

    // New interrupt detection (for pulse mode)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            new_irq <= 1'b0;
        end else begin
            new_irq <= (|pending) && !(pulse_active || int_out);
        end
    end

    // Pulse mode logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pulse_cnt   <= '0;
            pulse_active <= 1'b0;
        end else if (out_mode && new_irq) begin
            pulse_cnt   <= pulse_width;
            pulse_active <= 1'b1;
        end else if (pulse_active) begin
            if (pulse_cnt > 0)
                pulse_cnt <= pulse_cnt - 1'b1;
            else
                pulse_active <= 1'b0;
        end else begin
            pulse_active <= 1'b0;
        end
    end

    // Output interrupt logic
    logic int_out_raw;
    always_comb begin
        if (out_mode) // Pulse mode
            int_out_raw = pulse_active;
        else          // Level mode
            int_out_raw = |pending;
    end

    // Output polarity
    assign int_out = out_polarity ? int_out_raw : ~int_out_raw;

endmodule
