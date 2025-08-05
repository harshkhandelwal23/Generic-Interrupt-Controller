//-----------------------------------------------------------------------------
// File Name : intc_scoreboard.sv
// Description: Functional scoreboard for interrupt controller
//-----------------------------------------------------------------------------

`uvm_analysis_imp_decl(_in)
`uvm_analysis_imp_decl(_out)
`uvm_analysis_imp_decl(_reg)

class intc_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(intc_scoreboard)

  // Analysis imports from agents
  uvm_analysis_imp_in  #(interrupt_seq_item, intc_scoreboard) mon_ap;   // int_in
  uvm_analysis_imp_out #(interrupt_seq_item, intc_scoreboard) mon_out;  // int_out
  uvm_analysis_imp_reg #(reg_seq_item,       intc_scoreboard) reg_ap;   // register config

  // Configuration state (from reg interface)
  bit [9:0] int_enable;
  bit [9:0] int_mask;
  bit [9:0] last_int_in;
  bit [9:0] eff_in;
  bit actual_out;
  bit out_mode;  // 0 = level, 1 = pulse
  bit out_polarity;  // 1 = active high
  int pulse_width;
  bit expected_out;
  bit pulse_active;  // Track pulse state

  // Constructor
  function new(string name = "intc_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    mon_ap  = new("mon_ap", this);
    mon_out = new("mon_out", this);
    reg_ap  = new("reg_ap", this);
    int_enable   = 10'b0;
    int_mask     = 10'b0;
    last_int_in  = 10'b0;
    out_mode     = 0;  // 0 = level, 1 = pulse
    out_polarity = 1;  // 1 = active high
    pulse_width  = 1;
    expected_out = 0;
    pulse_active = 0;  // Track pulse state
  endfunction

  //virtual function void build_phase(uvm_phase phase);
  //  super.build_phase(phase);   
  //endfunction

  // Handle register updates
  virtual function void write_reg(reg_seq_item t);
    // Use 8-bit addresses to match reg_seq_item.addr
    if (t.we) 
      begin
        case (t.addr)
          8'h00: int_enable   = t.wdata[9:0];     // INT_ENABLE
          8'h04: int_mask     = t.wdata[9:0];     // INT_MASK
          8'h0C: out_mode     = t.wdata[0];       // OUT_MODE
          8'h10: out_polarity = t.wdata[0];       // OUT_POLARITY
          8'h14: pulse_width  = t.wdata[7:0];     // PULSE_WIDTH
          default: ; // Ignore other registers for now
        endcase
      end
    `uvm_info(get_type_name(), $sformatf(
      "Reg Update: addr=0x%0h, we=%0h, wdata=0x%0h | enable=%0h mask=%0h out_mode=%0h out_polarity=%0h pulse_width=%0d",t.addr, t.we, t.wdata, int_enable, int_mask, out_mode, out_polarity, pulse_width), UVM_NONE);
  endfunction

  // Handle int_in from monitor
  virtual function void write_in(interrupt_seq_item t);
    last_int_in = t.int_in;
    `uvm_info(get_type_name(), $sformatf(" BEFORE %0h %0h %0h %0h",eff_in , last_int_in , int_enable , int_mask),UVM_NONE);
    eff_in = last_int_in & int_enable & ~int_mask;
    `uvm_info(get_type_name(), $sformatf(" AFTER %0h %0h %0h %0h",eff_in , last_int_in , int_enable , int_mask),UVM_NONE);

    if (out_mode) 
      begin // Pulse mode
      // Trigger pulse if new interrupt and not currently active
        if (|eff_in && !pulse_active) 
          begin
            pulse_active = 1;
            expected_out = out_polarity ? 1'b1 : 1'b0;
          end 
        else 
          if (pulse_active) 
            begin
              // Simplified pulse duration check (assume tracked externally for now)
              expected_out = out_polarity ? 1'b1 : 1'b0;
            end 
          else 
            begin
              expected_out = 1'b0;
            end
      end 
    else 
      begin // Level mode
        expected_out = |eff_in;
        expected_out = out_polarity ? expected_out : ~expected_out;
      end

    `uvm_info(get_type_name(), $sformatf("Sampled int_in = %0h and Expected int_out = %0h (mode=%0h, pulse_active=%0h)",t.int_in, expected_out, out_mode, pulse_active), UVM_NONE);
  endfunction

  // Handle int_out from monitor
  virtual function void write_out(interrupt_seq_item t);
    actual_out = t.int_out;

    if (actual_out !== expected_out) 
      begin
        `uvm_error(get_type_name(), $sformatf("Mismatch Detected! Expected int_out = %0h, Actual int_out = %0h (mode=%0h, pulse_active=%0h)",expected_out, actual_out, out_mode, pulse_active))
      end 
    else 
      begin
        `uvm_info(get_type_name(), $sformatf("int_out MATCHED: %0h", actual_out), UVM_NONE)
        if (out_mode && pulse_active) 
          begin
            // Reset pulse state after duration (simplified, assume 1 cycle for now)
            pulse_active = 0;
          end
      end
  endfunction

  virtual function void report_phase(uvm_phase phase);
   uvm_report_server svr;
   super.report_phase(phase);
   svr = uvm_report_server::get_server();
   if(svr.get_severity_count(UVM_FATAL)+svr.get_severity_count(UVM_ERROR)>0) begin
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
     `uvm_info(get_type_name(), "----            TEST FAIL          ----", UVM_NONE)
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
    end
    else begin
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
     `uvm_info(get_type_name(), "----           TEST PASS           ----", UVM_NONE)
     `uvm_info(get_type_name(), "---------------------------------------", UVM_NONE)
    end
  endfunction
endclass
