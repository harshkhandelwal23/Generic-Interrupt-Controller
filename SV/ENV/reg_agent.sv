class reg_agent extends uvm_agent;
  `uvm_component_utils(reg_agent)

  reg_driver driver;
  reg_monitor monitor;
  reg_sequencer sequencer;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    driver    = reg_driver   ::type_id::create("driver", this);
    monitor   = reg_monitor  ::type_id::create("monitor", this);
    sequencer = reg_sequencer::type_id::create("sequencer", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction
endclass
