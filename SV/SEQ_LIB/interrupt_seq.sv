class interrupt_seq extends uvm_sequence #(interrupt_seq_item);
  `uvm_object_utils(interrupt_seq)

  interrupt_seq_item req;
  
  test_cfg cfg;


  function new(string name = "interrupt_seq");
    super.new(name);
  endfunction
  
  virtual task pre_body();
  endtask

  virtual task body();
    repeat (cfg.Transaction_count) 
      begin
        req = interrupt_seq_item#(`no_of_sources)::type_id::create("req");
        $display("Count = %0d", cfg.Transaction_count);
        start_item(req);
        if (cfg.int_in !=='hx && cfg.Transaction_count == 1) 
          begin
            req.int_in = cfg.int_in;
            `uvm_info(get_type_name(), $sformatf("Using cmdline int_in = %0b", req.int_in), UVM_MEDIUM)
          end
        else if (cfg.Transaction_count >=2)  
               begin
               assert(req.randomize());
               `uvm_info(get_type_name(), $sformatf("Randomized int_in = %0b", req.int_in), UVM_MEDIUM)
               end
        finish_item(req);
      end
  endtask
endclass
