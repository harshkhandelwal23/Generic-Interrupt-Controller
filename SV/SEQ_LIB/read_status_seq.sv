class read_status_seq extends uvm_sequence #(reg_seq_item);
  `uvm_object_utils(read_status_seq)

  intc_reg_block reg_block;

  //test_cfg cfg;

  function new(string name = "read_status_seq");
    super.new(name);
  endfunction

  virtual task body();
    /*if (!uvm_config_db#(test_cfg)::get(null, "*", "test_cfg", cfg))
    begin
        `uvm_fatal (get_type_name(), "test_cfg not found");
    end*/

    //`uvm_info(get_type_name(), $sformatf("Generating %0d READ transactions", cfg.Transaction_count), UVM_MEDIUM)
  
    //repeat (cfg.Transaction_count)
      //begin
        uvm_status_e status;
        uvm_reg_data_t rdata;

        // Read status
        `uvm_info("before READ_SEQ", $sformatf("INT_STATUS = %0b", rdata), UVM_NONE);
        reg_block.int_status.read(status, rdata);
        `uvm_info("READ_SEQ", $sformatf("INT_STATUS = %0b", rdata), UVM_NONE);
      //end
  endtask
endclass
