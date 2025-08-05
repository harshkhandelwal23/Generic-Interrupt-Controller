//----------------------------------------------------------------------------------------------------//
// File Name : intr_test.sv
// ---------------------------------------------------------------------------------------------------//
class intr_test extends uvm_test;

  //Factory Registration
  `uvm_component_utils(intr_test)
  //Environment Handle
  interrupt_env env;

  //Sequence Handle
  interrupt_seq intr_seq;

// ---------------------------------------------------------------------------------------------------//
// New Contructor
// ---------------------------------------------------------------------------------------------------//
  function new (string name ="intr_test" , uvm_component parent);
      super.new(name,parent);
  endfunction

// ---------------------------------------------------------------------------------------------------//
// Build Phase
// ---------------------------------------------------------------------------------------------------//
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = interrupt_env::type_id::create("interrupt_env", this);
  endfunction

// ---------------------------------------------------------------------------------------------------//
// End of Elaboration phase : for printing the topology
// ---------------------------------------------------------------------------------------------------//
  virtual function void end_of_elaboration_phase (uvm_phase phase);
    uvm_top.print_topology();
  endfunction

// ---------------------------------------------------------------------------------------------------//
// Run-Phase
// ---------------------------------------------------------------------------------------------------//
  virtual task run_phase (uvm_phase phase);
    intr_seq = interrupt_seq::type_id::create("intr_seq");
    phase.phase_done.set_drain_time(this,20);
    phase.raise_objection (this);
    intr_seq.start(env.agent.seqr);
    phase.drop_objection(this);
  endtask
endclass
