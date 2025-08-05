class interrupt_seq extends uvm_sequence #(interrupt_seq_item#(10));
  `uvm_object_utils(interrupt_seq)

  function new(string name = "interrupt_seq");
    super.new(name);
  endfunction

  virtual task body();
    interrupt_seq_item#(10) req;
    `uvm_info(get_type_name(), "Starting interrupt sequence", UVM_MEDIUM)
    req = interrupt_seq_item#()::type_id::create("req");
    start_item(req);
    assert(req.randomize() with { int_in == 10'b0000_0100; }); // Only bit[2] high
    finish_item(req);
    `uvm_info(get_type_name(), $sformatf("Driven int_in = %0b", req.int_in), UVM_MEDIUM)
  endtask
endclass
