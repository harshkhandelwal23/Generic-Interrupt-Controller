//----------------------------------------------------------------------------------------------------//
// File Name : interrupt_seq_item.sv
// ---------------------------------------------------------------------------------------------------//
class interrupt_seq_item #(int N = 10) extends uvm_sequence_item;

  //Input signal declaration
  rand bit [N-1:0] int_in; // TODO rand control support with plusargs

  //output signal declaration
  bit int_out;
  //Factory registration
  `uvm_object_param_utils(interrupt_seq_item #(N))

//----------------------------------------------------------------------------------------------------//
// New constructor
// ---------------------------------------------------------------------------------------------------//
  function new(string name = "interrupt_seq_item");
      super.new(name);
  endfunction
endclass
