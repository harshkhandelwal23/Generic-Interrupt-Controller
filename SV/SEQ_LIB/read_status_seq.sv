class read_status_seq extends uvm_sequence #(reg_seq_item);
  `uvm_object_utils(read_status_seq)

  intc_reg_block reg_block;

  test_cfg cfg;


  function new(string name = "read_status_seq");
    super.new(name);
  endfunction

  virtual task body();
    uvm_status_e status;
    uvm_reg_data_t rdata;

        // Read status
        `uvm_info("before READ_SEQ", $sformatf("INT_STATUS = %0b", rdata), UVM_NONE)
        reg_block.int_status.read(status, rdata);
        cfg.reg_count++;
        `uvm_info("READ_SEQ", $sformatf("INT_STATUS = %0b", rdata), UVM_NONE);
        `uvm_info(get_type_name(),$sformatf("CFG handle = %0p counter = %0d", cfg, cfg.reg_count),UVM_LOW)
      //end
  endtask
endclass
