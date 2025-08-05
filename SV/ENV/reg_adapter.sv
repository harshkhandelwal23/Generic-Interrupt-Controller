class reg_adapter extends uvm_reg_adapter;
  `uvm_object_utils(reg_adapter)

  function new(string name = "reg_adapter");
    super.new(name);
  endfunction

  // Convert uvm_reg_bus_op to bus transaction
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    reg_seq_item bus;
    bus = reg_seq_item::type_id::create("bus");
    bus.we    = (rw.kind == UVM_WRITE) ? 1 : 0;
    bus.addr  = rw.addr;
    bus.wdata  = rw.data;
    `uvm_info ("adapter", $sformatf ("reg2bus addr=0x%0h data=0x%0h kind=%s", bus.addr, bus.wdata, rw.kind.name()), UVM_DEBUG)
    return bus;
  endfunction

  // Convert bus transaction back to uvm_reg_bus_op
  virtual function void bus2reg(uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);
    reg_seq_item bus;
    if (!$cast(bus, bus_item)) begin
      `uvm_fatal("REG_ADAPTER", "bus_item is not of type reg_seq_item")
    end
    rw.addr = bus.addr;
    rw.data = bus.rdata;
    rw.kind = (bus.we) ? UVM_WRITE : UVM_READ;
    rw.status = UVM_IS_OK;
    `uvm_info ("adapter", $sformatf("bus2reg : addr=0x%0h data=0x%0h kind=%s status=%s", rw.addr, rw.data, rw.kind.name(), rw.status.name()), UVM_DEBUG)
  endfunction
endclass
