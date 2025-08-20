class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  // Test configuration object
  test_cfg cfg;

  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
    `uvm_info(get_type_name(), "INSIDE NEW loaded and set in config DB", UVM_LOW)
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Create configuration object
    cfg = test_cfg::type_id::create("cfg");
    // Load values from command-line plusargs
    cfg.load_from_plusargs();

    // Put into UVM config DB so env, sequences, scoreboard, monitors can use it
    uvm_config_db#(test_cfg)::set(this, "*", "test_cfg", cfg);

    `uvm_info(get_type_name(), "Base test configuration loaded and set in config DB", UVM_LOW)
  endfunction

endclass
