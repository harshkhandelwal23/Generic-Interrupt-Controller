class sanity_seq extends uvm_sequence #(uvm_sequence_item);
  `uvm_object_utils(sanity_seq)

  intc_reg_block reg_block;
  reg_seq_item reg_item;
  interrupt_seq_item int_item;

  function new(string name = "sanity_seq");
    super.new(name);
  endfunction

  virtual task pre_body();
    super.pre_body();
    if (reg_block == null) begin
      `uvm_fatal("SANITY_SEQ", "Register block not set")
    end
    reg_item = reg_seq_item::type_id::create("reg_item");
    int_item = interrupt_seq_item::type_id::create("int_item");
  endtask

  virtual task body();
    uvm_status_e status;
    uvm_reg_data_t rdata;
    bit [9:0] int_in_value = 10'h4; // Target interrupt 2

    `uvm_info(get_type_name(), "Starting sanity sequence", UVM_MEDIUM)

    // Configure all registers
    `uvm_info(get_type_name(), "Configuring int_enable", UVM_MEDIUM)
    reg_item.addr = 8'h00; 
    reg_item.we = 1; 
    reg_item.wdata = 32'h0001;
    start_item(reg_item); 
    finish_item(reg_item);
    reg_block.int_enable.read(status, rdata); 
    if (rdata != 32'h0001) 
        `uvm_error(get_type_name(), "int_enable mismatch")

    `uvm_info(get_type_name(), "Configuring int_mask", UVM_MEDIUM)
    reg_item.addr = 8'h04; reg_item.wdata = 32'h0000;
    start_item(reg_item); finish_item(reg_item);
    reg_block.int_mask.read(status, rdata); if (rdata != 32'h0000) `uvm_error(get_type_name(), "int_mask mismatch")

    `uvm_info(get_type_name(), "Configuring out_mode", UVM_MEDIUM)
    reg_item.addr = 8'h0C; reg_item.wdata = 32'h0; // Level mode
    start_item(reg_item); finish_item(reg_item);
    reg_block.out_mode.read(status, rdata); if (rdata != 32'h0) `uvm_error(get_type_name(), "out_mode mismatch")

    `uvm_info(get_type_name(), "Configuring out_polarity", UVM_MEDIUM)
    reg_item.addr = 8'h10; reg_item.wdata = 32'h1;
    start_item(reg_item); finish_item(reg_item);
    reg_block.out_polarity.read(status, rdata); if (rdata != 32'h1) `uvm_error(get_type_name(), "out_polarity mismatch")

    `uvm_info(get_type_name(), "Configuring pulse_width", UVM_MEDIUM)
    reg_item.addr = 8'h14; reg_item.wdata = 32'h02;
    start_item(reg_item); finish_item(reg_item);
    reg_block.pulse_width.read(status, rdata); if (rdata != 32'h02) `uvm_error(get_type_name(), "pulse_width mismatch")

    `uvm_info(get_type_name(), "Clearing int_status", UVM_MEDIUM)
    reg_item.addr = 8'h08; reg_item.wdata = 32'hffff;
    start_item(reg_item); finish_item(reg_item);

    `uvm_info(get_type_name(), $sformatf("Driving int_in = %0h", int_in_value), UVM_MEDIUM)
    start_item(int_item); assert(int_item.randomize() with { int_in == int_in_value; }); finish_item(int_item);

    #20; // Delay for DUT response

    `uvm_info(get_type_name(), "Reading int_status", UVM_MEDIUM)
    reg_item.addr = 8'h18; reg_item.we = 0;
    start_item(reg_item); finish_item(reg_item);
    reg_block.int_status.read(status, rdata); if (rdata[2] != 1) `uvm_error(get_type_name(), $sformatf("int_status[2] expected 1, got 0x%0h", rdata))

    //`uvm_info(get_type_name(), "Reading int_vector", UVM_MEDIUM)
    //reg_item.addr = 8'h1C;
    //start_item(reg_item); finish_item(reg_item);
    //reg_block.int_vector.read(status, rdata); if (rdata != 32'h4) `uvm_error(get_type_name(), $sformatf("int_vector expected 0x4, got 0x%0h", rdata))

    `uvm_info(get_type_name(), "Sanity sequence completed", UVM_MEDIUM)
  endtask
endclass
