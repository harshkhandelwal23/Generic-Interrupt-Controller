//-----------------------------------------------------------------------------
// File Name : intc_scoreboard.sv
// Description: Functional scoreboard for interrupt controller
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Multiple Ports Declaration
//-----------------------------------------------------------------------------
`uvm_analysis_imp_decl(_in)
`uvm_analysis_imp_decl(_out)
`uvm_analysis_imp_decl(_reg)

class intc_scoreboard #(
  int INT_WIDTH = 10,          // Width of interrupt signals
  int ADDR_WIDTH = 8,         // Width of register address
  int DATA_WIDTH = 32        // Width of register data
  ) extends uvm_scoreboard;
  `uvm_component_utils(intc_scoreboard #(INT_WIDTH, ADDR_WIDTH, DATA_WIDTH))

//-----------------------------------------------------------------------------
// Analysis imports from agents
//-----------------------------------------------------------------------------
  uvm_analysis_imp_in  #(interrupt_seq_item, intc_scoreboard #(INT_WIDTH, ADDR_WIDTH, DATA_WIDTH)) mon_ap;   // int_in
  uvm_analysis_imp_out #(interrupt_seq_item, intc_scoreboard #(INT_WIDTH, ADDR_WIDTH, DATA_WIDTH)) mon_out;  // int_out
  uvm_analysis_imp_reg #(reg_seq_item, intc_scoreboard #(INT_WIDTH, ADDR_WIDTH, DATA_WIDTH)) reg_ap;         // register config

//-----------------------------------------------------------------------------
// Configuration state (from reg interface)
//-----------------------------------------------------------------------------
  bit [INT_WIDTH-1:0] int_enable,
                      int_mask,
                      eff_in,
                      int_status,  // Actual interrupt status 
                      exp_int_status;
  bit out_mode,  // 0 = level, 1 = pulse
      out_polarity,  // 1 = active high
      expected_out,
      pulse_active;  // Track pulse state
  int int_exp_pkt, //Expected Packet count for the interrupt packet
      int_act_pkt, //Actual Packet count for the interrupt packet
      reg_act_pkt,   //Actual Packet count for the reg packet 
      reg_exp_pkt,   //Expected Packet count for the reg packet 
      out_exp_pkt, // Expected Packet count for the int_out packet
      out_act_pkt, // Actual packet count for the int_out packet
      pulse_width;
  interrupt_seq_item in_queue [$]; //Queue for Storing int_in packet
  interrupt_seq_item out_queue [$]; //Queue for Storing int_out packet
  reg_seq_item reg_queue [$]; //Queue for Storing reg packet
  reg_seq_item rpkt;
  interrupt_seq_item pkt1;
  interrupt_seq_item pkt2;
//-----------------------------------------------------------------------------
// Constructor
//-----------------------------------------------------------------------------
  function new(string name = "intc_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    mon_ap  = new("mon_ap", this);
    mon_out = new("mon_out", this);
    reg_ap  = new("reg_ap", this);
    out_polarity = 1;  // 1 = active high
    pulse_width  = 1;
    int_exp_pkt = 1;
    out_exp_pkt = 1;
    reg_exp_pkt = 12;
  endfunction

//-----------------------------------------------------------------------------
// Handle register updates
//-----------------------------------------------------------------------------
  virtual function void write_reg(reg_seq_item t);
    // Use 8-bit addresses to match reg_seq_item.addr
    reg_act_pkt++;
    
    reg_queue.push_back(t); //Pushing the packet(reg) in the reg_queue
    `uvm_info("SCB",$sformatf("item addr = %0h",t.addr),UVM_NONE) 
  endfunction

//-----------------------------------------------------------------------------
// Handle int_in from monitor
//-----------------------------------------------------------------------------
  virtual function void write_in(interrupt_seq_item t);

    int_act_pkt++; //Increment the Int actual packet when the write method of interrupt monitor is called
    in_queue.push_back(t); //Pushing the packet(int_in) in the in_queue
   
    `uvm_info("Write_in method", $sformatf("int_in packet: %0h", t.int_in), UVM_LOW);
    /*if ((eff_in == 'b0) | (|eff_in)) //Expected packet counting for the int_in
      begin
          int_exp_pkt++;
      end*/
  endfunction
  
//-----------------------------------------------------------------------------
// Handle int_out from monitor
//-----------------------------------------------------------------------------
  virtual function void write_out(interrupt_seq_item t);

    out_queue.push_back(t); //Pushing the packet(int_out) in the out_queue
    
    out_act_pkt++;

  endfunction

//-----------------------------------------------------------------------------
// Run Phase : All the Checkers 
//-----------------------------------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork 
      check_reg();
      check_int_in();
      check_int_out();
    join
  endtask

//-----------------------------------------------------------------------------
// Checker for int_in packets
//-----------------------------------------------------------------------------
  task check_int_in();
      forever 
        begin
          wait (in_queue.size() > 0);
          pkt1 = in_queue.pop_front();
          `uvm_info("INT_IN_CHECK", $sformatf("Checking int_in packet: %0h", pkt1.int_in), UVM_LOW);
                                       
          exp_int_status = pkt1.int_in & int_enable;
          `uvm_info("SCB", $sformatf("int_in1 = %0d",pkt1.int_in),UVM_NONE);
                                       
          eff_in = pkt1.int_in & int_enable & ~int_mask;
        end
  endtask
  
//-----------------------------------------------------------------------------
// Checker for int_out packets
//-----------------------------------------------------------------------------
  task check_int_out();
      forever 
        begin
          wait (out_queue.size() > 0);
          pkt2 = out_queue.pop_front();

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
                    // Simplified pulse duration check 
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
                `uvm_info("SCB", $sformatf("Sampled int_in = %0h and Expected int_out = %0h (mode=%0h, pulse_active=%0h)",pkt2.int_in, expected_out, out_mode, pulse_active), UVM_NONE);

          if (pkt2.int_out !== expected_out) 
            begin
              `uvm_error("SCB", $sformatf("Mismatch Detected! Expected int_out = %0h, Actual int_out = %0h (mode=%0h, pulse_active=%0h)",expected_out, pkt2.int_out, out_mode, pulse_active))
            end 
          else 
            begin
              `uvm_info("SCB", $sformatf("int_out MATCHED: %0h", pkt2.int_out), UVM_NONE)
              if (out_mode && pulse_active) 
                begin
                  // Reset pulse state after duration (simplified, assume 1 cycle for now)
                  pulse_active = 0;
                end
            end
        end
  endtask
  
//-----------------------------------------------------------------------------
// Checker for register packets
//-----------------------------------------------------------------------------
  task check_reg();
      forever 
        begin
          wait (reg_queue.size() > 0);
          rpkt = reg_queue.pop_front();
          case (rpkt.addr)
            8'h00: int_enable   = rpkt.we ? rpkt.wdata[INT_WIDTH-1:0] : rpkt.rdata[INT_WIDTH-1:0];     // INT_ENABLE
            8'h04: int_mask     = rpkt.we ? rpkt.wdata[INT_WIDTH-1:0] : rpkt.rdata[INT_WIDTH-1:0];     // INT_MASK
            8'h0C: out_mode     = rpkt.we ? rpkt.wdata[0] : rpkt.rdata[0];       // OUT_MODE
            8'h10: out_polarity = rpkt.we ? rpkt.wdata[0] : rpkt.rdata[0];       // OUT_POLARITY
            8'h14: pulse_width  = rpkt.we ? rpkt.wdata[DATA_WIDTH-1:0] : rpkt.rdata[DATA_WIDTH-1:0];     // PULSE_WIDTH
            //8'h18: if (!rpkt.we) int_status  =  rpkt.rdata[INT_WIDTH-1:0];     // INT_STATUS
            8'h18: if (!rpkt.we) 
                     begin
                       int_status = rpkt.rdata[INT_WIDTH-1:0];
                         if (int_status === exp_int_status) 
                           begin
                             `uvm_info("SCB", $sformatf("int_status matched: %0h", int_status), UVM_NONE);
                           end
                         else
                           begin
                             `uvm_error("SCB", $sformatf("INT_STATUS mismatch! Expected: %0h, Got: %0h",exp_int_status, int_status));
                           end
                     end
            default: ; // Ignore other registers for now
          endcase
          `uvm_info("SCB", $sformatf("Reg Update: addr=0x%0h, we=%0h, wdata=0x%0h | enable=%0h mask=%0h out_mode=%0h out_polarity=%0h pulse_width=%0d int_status=%0h",rpkt.addr, rpkt.we, rpkt.wdata, int_enable, int_mask, out_mode, out_polarity, pulse_width, int_status), UVM_NONE);
        end
  endtask

//-----------------------------------------------------------------------------
// Check Phase : Actual and Expected Packet Comparison
//-----------------------------------------------------------------------------
  virtual function void check_phase(uvm_phase phase);
    super.check_phase(phase);
      if (int_exp_pkt !== int_act_pkt) begin
        `uvm_error("SCB", $sformatf(" INT_IN Packet count mismatch! Expected: %0d, Actual: %0d",int_exp_pkt, int_act_pkt));
      end else begin
        `uvm_info("SCB", $sformatf("INT_IN Packet count matched : Expected: %0d, Actual: %0d",int_exp_pkt, int_act_pkt ), UVM_LOW);
      end

      if (reg_exp_pkt !== reg_act_pkt) begin
        `uvm_error("SCB", $sformatf("REG Packet count mismatch! Expected: %0d, Actual: %0d",reg_exp_pkt, reg_act_pkt));
      end else begin
        `uvm_info("SCB", $sformatf("REG Packet count matched : Expected: %0d, Actual: %0d",reg_exp_pkt, reg_act_pkt ), UVM_LOW);
      end

      if (out_exp_pkt !== out_act_pkt) begin
        `uvm_error("SCB", $sformatf("INT_OUT Packet count mismatch! Expected: %0d, Actual: %0d",out_exp_pkt, out_act_pkt));
      end else begin
        `uvm_info("SCB", $sformatf("INT_OUT Packet count matched : Expected: %0d, Actual: %0d",out_exp_pkt, out_act_pkt ), UVM_LOW);
      end
  endfunction

//-----------------------------------------------------------------------------
// Report Phase : Test Pass and Fail Check
//-----------------------------------------------------------------------------
  virtual function void report_phase(uvm_phase phase);
   uvm_report_server svr;
   super.report_phase(phase);
   svr = uvm_report_server::get_server();
   if(svr.get_severity_count(UVM_FATAL)+svr.get_severity_count(UVM_ERROR)>0) begin
     `uvm_info("SCB", "---------------------------------------", UVM_NONE)
     `uvm_info("SCB", "----            TEST FAIL          ----", UVM_NONE)
     `uvm_info("SCB", "---------------------------------------", UVM_NONE)
    end
    else begin
     `uvm_info("SCB", "---------------------------------------", UVM_NONE)
     `uvm_info("SCB", "----           TEST PASS           ----", UVM_NONE)
     `uvm_info("SCB", "---------------------------------------", UVM_NONE)
    end
  endfunction
endclass
