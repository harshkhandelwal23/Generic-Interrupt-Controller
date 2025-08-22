class test_cfg extends uvm_object;

  `uvm_object_utils(test_cfg)

  int Transaction_count;
  int no_of_sources;
  int int_in;
  int int_enable;
  int int_mask;
  int out_mode;
  int out_polarity;
  int pulse_width;
  int reg_count;
   
  function new(string name = "test_cfg");
    super.new(name);
    //Transaction_count = 1;
    //int_exp_pkt = 1;
    //reg_exp_pkt = 12;
    //out_exp_pkt = 1;
    //no_of_sources = 10;
    //int_in = 1;
    //int_enable = 1;
    //int_mask = 0;
    //out_mode = 0;
    //out_polarity = 1;
    //pulse_width = 1;
  endfunction

  virtual function void load_from_plusargs();
    if ($value$plusargs("TRANSACTION_COUNT=%d", Transaction_count))
        `uvm_info(get_type_name(), $sformatf("Transaction_count found = %0d", Transaction_count), UVM_LOW)
    else 
        `uvm_info(get_type_name(), $sformatf("Transaction count not provided, using default = %0d", Transaction_count), UVM_LOW)

    if ($value$plusargs("no_of_sources=%d", no_of_sources))
        `uvm_info(get_type_name(), $sformatf("no_of_sources found = %0d", no_of_sources), UVM_LOW)
    else 
        `uvm_info(get_type_name(), $sformatf("no_of_sources not provided, using default = %0d", no_of_sources), UVM_LOW)

    if ($value$plusargs("int_in=%d", int_in))
        `uvm_info(get_type_name(), $sformatf("int_in found = %0d", int_in), UVM_LOW)
    else 
        `uvm_info(get_type_name(), $sformatf("int_in not provided, using default = %0d", int_in), UVM_LOW)

    if ($value$plusargs("int_enable=%d", int_enable))
        `uvm_info(get_type_name(), $sformatf("int_enable found = %0d", int_enable), UVM_LOW)
    else 
        `uvm_info(get_type_name(), $sformatf("int_enable not provided, using default = %0d", int_enable), UVM_LOW)

    if ($value$plusargs("int_mask=%d", int_mask))
        `uvm_info(get_type_name(), $sformatf("int_mask found = %0d", int_mask), UVM_LOW)
    else 
        `uvm_info(get_type_name(), $sformatf("int_mask not provided, using default = %0d", int_mask), UVM_LOW)

    if ($value$plusargs("out_mode=%d", out_mode))
        `uvm_info(get_type_name(), $sformatf("out_mode found = %0d", out_mode), UVM_LOW)
    else 
        `uvm_info(get_type_name(), $sformatf("out_mode not provided, using default = %0d", out_mode), UVM_LOW)

    if ($value$plusargs("out_polarity=%d", out_polarity))
        `uvm_info(get_type_name(), $sformatf("out_polarity found = %0d", out_polarity), UVM_LOW)
    else 
        `uvm_info(get_type_name(), $sformatf("out_polarity not provided, using default = %0d", out_polarity), UVM_LOW)

    if ($value$plusargs("pulse_width=%d", pulse_width))
        `uvm_info(get_type_name(), $sformatf("pulse_width found = %0d", pulse_width), UVM_LOW)
    else 
        `uvm_info(get_type_name(), $sformatf("pulse_width not provided, using default = %0d", pulse_width), UVM_LOW)
  endfunction
endclass
