class int_out_monitor extends uvm_monitor;

  `uvm_component_utils(int_out_monitor)

  virtual int_if vif;

  uvm_analysis_port #(interrupt_seq_item) mon_out;

  interrupt_seq_item item2;

  bit any_int_in_active;

  function new(string name = "int_out_monitor", uvm_component parent = null);
    super.new(name, parent);
    mon_out = new("mon_out", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual int_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("MON2", "Failed to get virtual interface from config DB")
    end
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever 
      begin
        // Wait for any change in int_in (drive event)
        @(posedge vif.clk);
        `uvm_info(get_type_name(), $sformatf("after posedege of clk int_out Monitor"), UVM_MEDIUM);
        any_int_in_active = |vif.cb_mon.int_in;
        `uvm_info(get_type_name(), $sformatf("after posedege of clk int_out Monitor2 int_any = %b | vif.cb_mon.int_in = %b",any_int_in_active, vif.cb_mon.int_in), UVM_MEDIUM);
        if (any_int_in_active) 
          begin
            `uvm_info(get_type_name(), $sformatf("after posedege of clk int_out Monitor3"), UVM_MEDIUM);
            // Wait for *next* clock after int_in is asserted
            @(posedge vif.clk);
            `uvm_info(get_type_name(), $sformatf("after posedege of clk int_out Monitor4"), UVM_MEDIUM);
            item2 = interrupt_seq_item#()::type_id::create("item2", this);
            item2.int_out = vif.cb_mon.int_out;
            `uvm_info(get_type_name(), $sformatf("MON2: Sampled int_out = %0h at time %0t",item2.int_out, $time), UVM_MEDIUM);
            mon_out.write(item2);
            `uvm_info(get_type_name(), $sformatf("after posedege of clk int_out Monitor5"), UVM_MEDIUM);
          end
      end
  endtask
endclass
