class reg_driver extends uvm_driver #(reg_seq_item);
  `uvm_component_utils(reg_driver)

  virtual reg_if reg_vif;

  reg_seq_item item;

  function new(string name = "reg_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual reg_if)::get(this, "", "reg_vif", reg_vif))
      `uvm_fatal("REG_DRIVER", "reg_vif not set")
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever 
      begin
        if (!reg_vif.rst_n) 
          begin 
            reg_vif.driver_cb.addr  <= 0;
            reg_vif.driver_cb.wr_en <= 0;
            reg_vif.driver_cb.rd_en <= 0;
            reg_vif.driver_cb.wdata <= 0;
          end
        else 
          begin
            seq_item_port.get_next_item(item);
            @(reg_vif.driver_cb);
            reg_vif.driver_cb.addr  <= item.addr;
            reg_vif.driver_cb.wdata <= item.wdata;
            if (item.we) 
              begin
              reg_vif.driver_cb.wr_en <= 1;
              `uvm_info(get_type_name(), $sformatf("Sending WRITE to addr: 0x%0h data: 0x%0h", item.addr, item.wdata), UVM_MEDIUM)
              end 
            else 
              begin
              reg_vif.driver_cb.rd_en <= 1;
              `uvm_info(get_type_name(), $sformatf("Sending READ to addr: 0x%0h", item.addr), UVM_MEDIUM)
              end
            @(reg_vif.driver_cb);
            // Capture rdata for READ
            if (!item.we) 
              begin
                item.rdata = reg_vif.driver_cb.rdata;
               end
            // Deassert controls
            reg_vif.driver_cb.wr_en <= 0;
            reg_vif.driver_cb.rd_en <= 0;
            //@(reg_vif.driver_cb); // Ensure signals settle
            seq_item_port.item_done();
          end
    end
  endtask
endclass
