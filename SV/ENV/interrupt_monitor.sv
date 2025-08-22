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

  int in_transaction_seen;
  
  test_cfg cfg;

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
    if (!uvm_config_db#(test_cfg)::get(this, "", "test_cfg", cfg)) begin
      `uvm_fatal(get_type_name(), "test_cfg not set")
    end
  endfunction

  // Run phase - sample and send to scoreboard
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever 
      begin
        @(posedge vif.clk);
        if (in_transaction_seen == cfg.Transaction_count)
         begin
           `uvm_info(get_type_name(), $sformatf("Reached %0d Transactions, stopped sampling", in_transaction_seen), UVM_LOW)
           break;
         end

        if(vif.int_in)
          begin
            item = interrupt_seq_item#(`no_of_sources)::type_id::create("item");
            item.int_in = vif.int_in;
            `uvm_info(get_type_name(), $sformatf("Sampled int_in = %0b at time %0t", item.int_in, $time), UVM_MEDIUM);
            mon_ap.write(item);
            in_transaction_seen++;
          end
        //---------------------------CHECKER FOR INT_IN == 0----------------//
        else if (vif.int_in == 0)
            `uvm_error(get_type_name(), "This INT_IN value is not allowed")
      end
  endtask
endclass
