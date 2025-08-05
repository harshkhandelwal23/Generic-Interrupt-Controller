class reg_test extends uvm_test;
  `uvm_component_utils(reg_test)

  reg_seq reg_seq_h;

  function new(string name = "reg_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create the environment (which includes the reg_block inside)
    env = interrupt_env::type_id::create("env", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Connect the adapter to reg_map inside the reg_block inside the env
    env.reg_block.default_map.set_sequencer(env.reg_agt.sequencer, env.reg_adap);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    reg_seq_h = reg_seq::type_id::create("reg_seq_h");
    reg_seq_h.start(env.reg_agt.sequencer);
    phase.drop_objection(this);
  endtask
endclass
