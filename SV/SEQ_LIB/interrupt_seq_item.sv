//----------------------------------------------------------------------------------------------------//
// File Name : interrupt_seq_item.sv
// ---------------------------------------------------------------------------------------------------//
class interrupt_seq_item #(parameter int N = `no_of_sources) extends uvm_sequence_item;

  //Input signal declaration
  rand bit [N-1:0] int_in;

  //output signal declaration
  bit int_out;
  //Factory registration
  `uvm_object_utils(interrupt_seq_item) 

//----------------------------------------------------------------------------------------------------//
// New constructor
// ---------------------------------------------------------------------------------------------------//
  function new(string name = "interrupt_seq_item");
      super.new(name);
  endfunction

// soft constraint to avoid all zeros
  constraint avoid_all_zero {
    soft (int_in != 0);
  }
endclass
