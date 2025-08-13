class read_status_seq extends uvm_sequence #(reg_seq_item);
  `uvm_object_utils(read_status_seq)

  intc_reg_block reg_block;

  function new(string name = "read_status_seq");
    super.new(name);
  endfunction

  virtual task body();
    uvm_status_e status;
    uvm_reg_data_t rdata;

    // Wait for DUT to respond
    //`#(10); // Or wait for scoreboard or monitor notification

    // Read status
    `uvm_info("before READ_SEQ", $sformatf("INT_STATUS = %0b", rdata), UVM_NONE);
    reg_block.int_status.read(status, rdata);
    `uvm_info("READ_SEQ", $sformatf("INT_STATUS = %0b", rdata), UVM_NONE);
  endtask
endclass
