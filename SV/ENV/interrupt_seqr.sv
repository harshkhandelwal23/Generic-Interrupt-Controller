// File Name : interrupt_seqr.sv
// ---------------------------------------------------------------------------------------------------//
class interrupt_seqr extends uvm_sequencer#(interrupt_seq_item);
  //Factory Registration
  `uvm_component_utils(interrupt_seqr)

//----------------------------------------------------------------------------------------------------//
// New Constructor
// ---------------------------------------------------------------------------------------------------//
  function new(string name = "interrupt_seqr",uvm_component parent = null);
      super.new(name,parent);
  endfunction

endclass
