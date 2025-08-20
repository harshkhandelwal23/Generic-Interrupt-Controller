class single_int extends base_test;
  `uvm_component_utils(single_int)

  interrupt_env env;
  reg_seq rseq;
  interrupt_seq iseq;
  read_status_seq read_s;

  test_cfg cfg;

  function new(string name = "single_int", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = interrupt_env::type_id::create("env", this);
    if (!uvm_config_db#(test_cfg)::get(this, "*", "test_cfg", cfg))
         `uvm_fatal(get_type_name(), "test_cfg not found")
    env.no_of_sources = cfg.no_of_sources;//to pass test config to the reg_block
  endfunction
// ---------------------------------------------------------------------------------------------------//
// End of Elaboration phase : for printing the topology
// ---------------------------------------------------------------------------------------------------//
  virtual function void end_of_elaboration_phase (uvm_phase phase);
    uvm_top.print_topology();
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    rseq = reg_seq::type_id::create("rseq");
    rseq.cfg = cfg;
    rseq.reg_block = env.reg_block; // Connect RAL model
    rseq.start(env.reg_agt.sequencer);
    fork
      begin
        iseq = interrupt_seq::type_id::create("iseq");
        iseq.cfg = cfg;
        iseq.start(env.agent.seqr, this, with { int_in =='b1; }); // Drive int_in
      end
      begin
          @(posedge env.reg_agt.driver.reg_vif.clk);
          repeat (cfg.Transaction_count) begin
            read_s = read_status_seq::type_id::create("read_s");
            //read_s.cfg = cfg;
            read_s.reg_block = env.reg_block;
            read_s.start(env.reg_agt.sequencer);
          end
      end
    join
    //read_s = read_status_seq::type_id::create("read_s");
    //read_s.reg_block = env.reg_block;
    //read_s.start(env.reg_agt.sequencer);
    
    phase.phase_done.set_drain_time(this,30);
    phase.drop_objection(this);
  endtask
endclass
