class reg_test extends base_test;
  `uvm_component_utils(reg_test)

  reg_seq reg_seq_h;
  
  interrupt_env env;

  function new(string name = "reg_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Create the environment (which includes the reg_block inside)
    env = interrupt_env::type_id::create("env", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    reg_seq_h = reg_seq::type_id::create("reg_seq_h");
    phase.phase_done.set_drain_time(this,20);
    reg_seq_h.reg_block = env.reg_block; // Assign the reg_block
    reg_seq_h.start(env.reg_agt.sequencer);
    phase.drop_objection(this);
  endtask
endclass
