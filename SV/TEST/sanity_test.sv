class sanity_test extends uvm_test;
  `uvm_component_utils(sanity_test)

  interrupt_env env;
  reg_seq rseq;
  interrupt_seq iseq;

  function new(string name = "sanity_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = interrupt_env::type_id::create("env", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);

    rseq = reg_seq::type_id::create("rseq");
    rseq.reg_block = env.reg_block; // Connect RAL model
    rseq.start(env.reg_agt.sequencer);

    iseq = interrupt_seq::type_id::create("iseq");
    iseq.start(env.agent.seqr); // Drive int_in

    #30; // Let int_out settle
    phase.drop_objection(this);
  endtask
endclass
