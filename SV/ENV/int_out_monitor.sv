////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//File : Int_out monitor
//Description : samples the int_out coming from the dut 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class int_out_monitor extends uvm_monitor;
 
  `uvm_component_utils(int_out_monitor)
 
  virtual int_if vif;
 
  uvm_analysis_port #(interrupt_seq_item) mon_out;
 
  interrupt_seq_item item2;
 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Constructor 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  function new(string name = "int_out_monitor", uvm_component parent = null);
    super.new(name, parent);
    mon_out = new("mon_out", this);
  endfunction
 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Build Phase 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual int_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("MON2", "Failed to get virtual interface from config DB")
    end
  endfunction
 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Run phase 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      `uvm_info(get_type_name(), $sformatf("before0 int_out monitor"), UVM_MEDIUM);
      @(vif.cb_mon.int_in);
      `uvm_info(get_type_name(), $sformatf("before1 int_out monitor"), UVM_MEDIUM);
      @(vif.cb_mon);
      `uvm_info(get_type_name(), $sformatf("after2 int_out monitor"), UVM_MEDIUM);
      //@(vif.cb_mon.int_out);
      item2 = interrupt_seq_item#()::type_id::create("item2", this);
      item2.int_out = vif.cb_mon.int_out;
      //item2.int_out = vif.int_out;
      `uvm_info(get_type_name(), $sformatf("MON2: Sampled int_out = %0h  int_in %0h at time %0t",item2.int_out,item2.int_in, $time), UVM_MEDIUM);
      mon_out.write(item2);
    end
  endtask
 
endclass
