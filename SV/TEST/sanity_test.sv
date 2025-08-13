class sanity_test extends uvm_test;
  `uvm_component_utils(sanity_test)

  interrupt_env env;
  reg_seq rseq;
  interrupt_seq iseq;
  read_status_seq read_s;

  function new(string name = "sanity_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = interrupt_env::type_id::create("env", this);
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
    rseq.reg_block = env.reg_block; // Connect RAL model
    rseq.start(env.reg_agt.sequencer);
    fork
      begin
        iseq = interrupt_seq::type_id::create("iseq");
        iseq.start(env.agent.seqr); // Drive int_in
      end
      begin
          $display("[%0t] hi Bhau bhai",$time);
          //#10;
          @(posedge env.reg_agt.driver.reg_vif.clk);
          $display("[%0t] hi hi bhau bhai",$time);
          repeat (1) begin
            read_s = read_status_seq::type_id::create("read_s");
            read_s.reg_block = env.reg_block;
            read_s.start(env.reg_agt.sequencer);
          end
      end
    join
    //read_s = read_status_seq::type_id::create("read_s");
    //read_s.reg_block = env.reg_block;
    //read_s.start(env.reg_agt.sequencer);
    
    phase.phase_done.set_drain_time(this,10);
    phase.drop_objection(this);
  endtask
endclass
