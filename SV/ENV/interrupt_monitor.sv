//----------------------------------------------------------------------------------------------------//
// File Name : interrupt_monitor.sv
//----------------------------------------------------------------------------------------------------//
class interrupt_monitor extends uvm_monitor;

  `uvm_component_utils(interrupt_monitor)

  // Virtual interface handle
  virtual int_if vif;

  // Analysis port to send sampled data to scoreboard
  uvm_analysis_port #(interrupt_seq_item) mon_ap;

  interrupt_seq_item item;

  // Constructor
  function new(string name = "interrupt_monitor", uvm_component parent = null);
    super.new(name, parent);
    mon_ap = new("mon_ap", this);
  endfunction

  // Build phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual int_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("MON", "Failed to get virtual interface from config DB")
    end
  endfunction

  // Run phase - sample and send to scoreboard
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever 
      begin
        @(vif.cb_mon);
          if(vif.cb_mon.int_in)
          begin
          item = interrupt_seq_item#()::type_id::create("item");
          item.int_in = vif.cb_mon.int_in;
          `uvm_info(get_type_name(), $sformatf("Sampled int_in = %0b at time %0t", item.int_in, $time), UVM_MEDIUM);
          mon_ap.write(item);
      end
      end
  endtask
endclass
