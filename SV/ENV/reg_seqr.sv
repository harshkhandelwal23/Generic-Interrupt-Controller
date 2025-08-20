class reg_sequencer extends uvm_sequencer#(reg_seq_item); //TODO : COMMENTS

  `uvm_component_utils(reg_sequencer) 

  //---------------------------------------
  //constructor
  //---------------------------------------
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  
endclass
