class reg_seq_item extends uvm_sequence_item;
  //---------------------------------------
  //data and control fields
  //---------------------------------------
  rand bit [7:0] addr;
  rand bit       we;
  rand bit [31:0] wdata;
       bit [31:0] rdata;
  
  //---------------------------------------
  //Utility and Field macros
  //---------------------------------------
  `uvm_object_utils_begin(reg_seq_item)
    `uvm_field_int(addr,UVM_ALL_ON)
    `uvm_field_int(we,UVM_ALL_ON)
    `uvm_field_int(wdata,UVM_ALL_ON)
  `uvm_object_utils_end
  
  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name = "reg_seq_item");
    super.new(name);
  endfunction
  
endclass
