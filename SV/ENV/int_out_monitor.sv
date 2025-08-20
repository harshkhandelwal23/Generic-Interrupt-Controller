////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//File : Int_out monitor
//Description : samples the int_out coming from the dut 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class int_out_monitor extends uvm_monitor;
 
  `uvm_component_utils(int_out_monitor)
 
  virtual int_if vif;
 
  uvm_analysis_port #(interrupt_seq_item) mon_out_ap;
 
  interrupt_seq_item item_out;
 
  test_cfg cfg;

  int out_transaction_seen;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Constructor 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  function new(string name = "int_out_monitor", uvm_component parent = null);
    super.new(name, parent);
    mon_out_ap = new("mon_out_ap", this);
  endfunction
 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Build Phase 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual int_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("MON_OUT", "Failed to get virtual interface from config DB")
    end
    if (!uvm_config_db#(test_cfg)::get(this, "", "test_cfg", cfg)) begin
      `uvm_fatal(get_type_name(), "test_cfg not set")
    end
  endfunction
 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Run phase 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever 
      begin
      //@(posedge vif.clk iff (|vif.int_in));
        @(posedge vif.clk);
        if (out_transaction_seen >= cfg.Transaction_count)
         begin
           `uvm_info(get_type_name(), $sformatf("[OUT] Reached %0d Transactions, stopped sampling Tc = %0d", out_transaction_seen,cfg.Transaction_count), UVM_LOW)
           break;
         end
      //`uvm_info(get_type_name(), $sformatf("after2 int_out monitor"), UVM_MEDIUM);
      //@(vif.cb_mon.int_out);
      //@(vif.int_in);
        if (vif.int_in) 
          begin
            @(posedge vif.clk);
            item_out = interrupt_seq_item#(`no_of_sources)::type_id::create("item_out", this);
            item_out.int_out = vif.int_out;
            `uvm_info(get_type_name(), $sformatf("Sampled int_out = %0h  int_in %0h at time %0t",item_out.int_out,item_out.int_in, $time), UVM_MEDIUM);
            mon_out_ap.write(item_out);
            out_transaction_seen++;
          end
      end
  endtask
 
endclass
