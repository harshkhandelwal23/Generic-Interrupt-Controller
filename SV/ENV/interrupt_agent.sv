//----------------------------------------------------------------------------------------------------//
// File Name : interrupt_agent.sv
// ---------------------------------------------------------------------------------------------------//
class interrupt_agent extends uvm_agent;

  //Factory Registration
  `uvm_component_utils(interrupt_agent)

  //Virtual Interface Handle
  virtual int_if vif;

  //Interrupt driver Handle
  interrupt_driver drv;

  //Interrupt Monitor Handle
  interrupt_monitor mon;

  //Interrupt Sequencer Handle
  interrupt_seqr seqr; 

//----------------------------------------------------------------------------------------------------//
// New constructor
// ---------------------------------------------------------------------------------------------------//
  function new (string name = "interrupt_agent", uvm_component parent = null);
    super.new(name,parent);
  endfunction

//----------------------------------------------------------------------------------------------------//
// Build Phase
// ---------------------------------------------------------------------------------------------------//
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // intf not requred
    if (!uvm_config_db#(virtual int_if)::get(this, "", "vif", vif))
      `uvm_fatal("AGENT", "vif not set")
 
    if (get_is_active() == UVM_ACTIVE) 
      begin
        drv = interrupt_driver::type_id::create("drv", this);
        seqr = interrupt_seqr::type_id::create("seqr", this);
      end
        mon = interrupt_monitor::type_id::create("mon", this);
  endfunction
 
//----------------------------------------------------------------------------------------------------//
// Connect Phase
// ---------------------------------------------------------------------------------------------------//
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (get_is_active() == UVM_ACTIVE)
      drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction 

endclass
