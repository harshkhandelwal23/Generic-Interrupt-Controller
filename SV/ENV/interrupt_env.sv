//----------------------------------------------------------------------------------------------------//
// File Name : Interrupt env.sv
// ---------------------------------------------------------------------------------------------------//
class interrupt_env extends uvm_env;
  `uvm_component_utils(interrupt_env)

  // Interrupt input signal agent (drives/samples int_in)
  interrupt_agent agent;

  //Bus-based register agent (for RAL access)
  reg_agent reg_agt;

  // Scoreboard for checking functional correctness
  intc_scoreboard #(8,32) scb;

  // Register block handle
  intc_reg_block reg_block;

  // Adapter for connecting RAL model to the bus agent
  reg_adapter reg_adap;
  
  int_out_agent out_agent;

  int no_of_sources;

  function new(string name = "interrupt_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create standard functional agent
    agent = interrupt_agent::type_id::create("agent", this);
    out_agent = int_out_agent::type_id::create("out_agent", this);

    // Create bus-based register access agent
    reg_agt = reg_agent::type_id::create("reg_agt", this);

    // Create the register block model
    reg_block = intc_reg_block::type_id::create("reg_block", this);
    //reg_block.build(10);  // Calls build() of your register block class
    reg_block.build(`no_of_sources);  // Calls build() of your register block class

    // Create register adapter
    reg_adap = reg_adapter::type_id::create("reg_adap", this);

    // Create scoreboard
    scb = intc_scoreboard#()::type_id::create("scb", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Functional monitor to scoreboard connection
    agent.mon.mon_ap.connect(scb.mon_ap);
    out_agent.mon2.mon_out_ap.connect(scb.mon_out_ap);
    reg_agt.monitor.reg_ap.connect(scb.reg_ap);
    // Connect register block's map to reg_agent's sequencer and adapter
    reg_block.default_map.set_sequencer(.sequencer(reg_agt.sequencer), .adapter(reg_adap) );
  endfunction
endclass
