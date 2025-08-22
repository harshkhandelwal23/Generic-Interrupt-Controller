//----------------------------------------------------------------------------------------------------//
// File Name : Reg Sequence.sv
// ---------------------------------------------------------------------------------------------------//
class reg_seq extends uvm_sequence #(reg_seq_item);
  `uvm_object_utils(reg_seq)

  intc_reg_block reg_block;

  test_cfg cfg;
//----------------------------------------------------------------------------------------------------//
// Constructor 
// ---------------------------------------------------------------------------------------------------//
  function new(string name = "reg_seq");
    super.new(name);
  endfunction

//----------------------------------------------------------------------------------------------------//
// Body Task for write and read on Registers 
// ---------------------------------------------------------------------------------------------------//
  virtual task body();
        uvm_status_e status;
        uvm_reg_data_t rdata;

        // INT_ENABLE
        cfg.reg_count++;
        reg_block.int_enable.write(status, cfg.int_enable);
        cfg.reg_count++;
        reg_block.int_enable.read(status, rdata);
        cfg.reg_count++;
        `uvm_info("reg_seq", $sformatf("int_enable = %0b", rdata), UVM_NONE);

        // INT_MASK
        reg_block.int_mask.write(status, cfg.int_mask);
        cfg.reg_count++;
        reg_block.int_mask.read(status, rdata);
        cfg.reg_count++;
        `uvm_info("reg_seq", $sformatf("int_mask = %0b", rdata), UVM_NONE);

        // OUT_MODE
        reg_block.out_mode.write(status, cfg.out_mode);
        cfg.reg_count++;
        reg_block.out_mode.read(status, rdata);
        cfg.reg_count++;
        `uvm_info("reg_seq", $sformatf("out_mode = %0b", rdata), UVM_NONE);
       
        // OUT_POLARITY
        reg_block.out_polarity.write(status, cfg.out_polarity);
        cfg.reg_count++;
        reg_block.out_polarity.read(status, rdata);
        cfg.reg_count++;
        `uvm_info("reg_seq", $sformatf("out_polarity = %0b", rdata), UVM_NONE);

        // PULSE_WIDTH
        reg_block.pulse_width.write(status, cfg.pulse_width);
        cfg.reg_count++;
        reg_block.pulse_width.read(status, rdata);
        cfg.reg_count++;
        `uvm_info("reg_seq", $sformatf("pulse_width = %0b", rdata), UVM_NONE);
        `uvm_info(get_type_name(),$sformatf("CFG handle = %0p counter = %0d", cfg, cfg.reg_count),UVM_LOW)
      //end
    endtask
endclass
