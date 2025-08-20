/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//File : reg_monitor 
//Description : samples the signals coming from the DUT when any of the read
//or write happens.
////////////////////////////////////////////////////////////////////////////////////////////////////////////
class reg_monitor extends uvm_monitor;
  `uvm_component_utils(reg_monitor)

  virtual reg_if reg_vif;
  uvm_analysis_port#(reg_seq_item) reg_ap;
  
  int reg_transaction_seen;
  
  test_cfg cfg;

  reg_seq_item item3;

  function new(string name = "reg_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    reg_ap = new("reg_ap", this);
    if (!uvm_config_db#(virtual reg_if)::get(this, "", "reg_vif", reg_vif))
      `uvm_fatal("REG_MONITOR", "reg_vif not set")
    if (!uvm_config_db#(test_cfg)::get(this, "", "test_cfg", cfg)) begin
      `uvm_fatal(get_type_name(), "test_cfg not set")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
  //  reg_seq_item item3;
    forever 
      begin
          //`uvm_info(get_type_name(), $sformatf("MONITOR1"), UVM_MEDIUM)
        @(posedge reg_vif.clk); // Sync with clock to ensure valid sampling
         if (reg_transaction_seen >= 12*cfg.Transaction_count)//cfg.reg_exp_pkt)
         begin
           `uvm_info(get_type_name(), $sformatf("Reached %0d Transactions, stopped sampling", reg_transaction_seen), UVM_LOW)
           break;
         end
          //`uvm_info(get_type_name(), $sformatf("MONITOR2"), UVM_MEDIUM)
        // Only process transactions when not in reset and wr_en or rd_en is active
          if (reg_vif.wr_en || reg_vif.rd_en) 
            begin
          //`uvm_info(get_type_name(), $sformatf("MONITOR3"), UVM_MEDIUM)
              item3 = reg_seq_item::type_id::create("item3");
              item3.we = reg_vif.wr_en;
              item3.addr = reg_vif.addr;
              item3.wdata = reg_vif.wdata;
              if (reg_vif.rd_en) begin 
                  item3.rdata = reg_vif.rdata; // Capture rdata for READs only
                  reg_write_read_check();
              end
              //reg_write_read_check();
              `uvm_info(get_type_name(), $sformatf("MONITOR: addr=%0h, wdata=%0h, rdata=%0h",item3.addr, item3.wdata, item3.rdata), UVM_MEDIUM)
              reg_ap.write(item3);
              reg_transaction_seen++;
            end
      end
  endtask

  task reg_write_read_check();
    if (!item3.we) 
      begin
        case(item3.addr)
          8'h00 : if (item3.rdata !== cfg.int_enable)
                    `uvm_fatal(get_type_name(), $sformatf("INT_ENABLE mismatch: Wrote=%0h, Read=%0h", cfg.int_enable, item3.rdata))
                  else 
                    `uvm_info(get_type_name(), $sformatf("INT_ENABLE match: Wrote=%0h, Read=%0h", cfg.int_enable, item3.rdata), UVM_LOW)
          8'h04 : if (item3.rdata !== cfg.int_mask)
                    `uvm_fatal(get_type_name(), $sformatf("INT_MASK mismatch: Wrote=%0h, Read=%0h", cfg.int_mask, item3.rdata))
                  else 
                    `uvm_info(get_type_name(), $sformatf("INT_MASK match: Wrote=%0h, Read=%0h", cfg.int_mask, item3.rdata), UVM_LOW)
          8'h0C : if (item3.rdata !== cfg.out_mode)
                    `uvm_fatal(get_type_name(), $sformatf("OUT_MODE mismatch: Wrote=%0h, Read=%0h", cfg.out_mode, item3.rdata))
                  else 
                    `uvm_info(get_type_name(), $sformatf("OUT_MODE match: Wrote=%0h, Read=%0h", cfg.out_mode, item3.rdata), UVM_LOW)
          8'h10 : if (item3.rdata !== cfg.out_polarity)
                    `uvm_fatal(get_type_name(), $sformatf("OUT_POLARITY mismatch: Wrote=%0h, Read=%0h", cfg.out_polarity, item3.rdata))
                  else 
                    `uvm_info(get_type_name(), $sformatf("OUT_POLARITY match: Wrote=%0h, Read=%0h", cfg.out_polarity, item3.rdata), UVM_LOW)
          8'h14 : if (item3.rdata !== cfg.pulse_width)
                    `uvm_fatal(get_type_name(), $sformatf("PULSE_WIDTH mismatch: Wrote=%0h, Read=%0h", cfg.pulse_width, item3.rdata))
                  else 
                    `uvm_info(get_type_name(), $sformatf("PULSE_WIDTH match: Wrote=%0h, Read=%0h", cfg.pulse_width, item3.rdata), UVM_LOW)
        endcase
      end
  endtask
endclass
