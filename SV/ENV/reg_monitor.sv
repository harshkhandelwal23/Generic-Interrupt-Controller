class reg_monitor extends uvm_monitor;
  `uvm_component_utils(reg_monitor)

  virtual reg_if reg_vif;
  uvm_analysis_port#(reg_seq_item) reg_ap;

  function new(string name = "reg_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    reg_ap = new("reg_ap", this);
    if (!uvm_config_db#(virtual reg_if)::get(this, "", "reg_vif", reg_vif))
      `uvm_fatal("REG_MONITOR", "reg_vif not set")
  endfunction

  virtual task run_phase(uvm_phase phase);
    reg_seq_item item3;
    forever 
      begin
        @(reg_vif.monitor_cb); // Sync with clock to ensure valid sampling
        // Only process transactions when not in reset and wr_en or rd_en is active
          if (reg_vif.monitor_cb.wr_en || reg_vif.monitor_cb.rd_en) 
            begin
              item3 = reg_seq_item::type_id::create("item3");
              item3.we = reg_vif.monitor_cb.wr_en;
              item3.addr = reg_vif.monitor_cb.addr;
              item3.wdata = reg_vif.monitor_cb.wdata;
          if (!item3.we) 
              item3.rdata = reg_vif.monitor_cb.rdata; // Capture rdata for READs only
          `uvm_info(get_type_name(), $sformatf("MONITOR: addr=%0h, wdata=%0h, rdata=%0h",item3.addr, item3.wdata, item3.rdata), UVM_MEDIUM)
          reg_ap.write(item3);
            end
      end
  endtask
endclass
