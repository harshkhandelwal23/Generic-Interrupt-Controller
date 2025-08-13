class test_cfg #(int N = 10,int W = 8) extends uvm_object;
  `uvm_object_utils(test_cfg)

  bit [N-1:0] int_in;
  bit [N-1:0] int_enable;
  bit [N-1:0] int_mask;
  bit [N-1:0] int_clear;
  bit         out_mode;
  bit         out_polarity;
  bit [W-1:0] pulse_width;

  function new(string name = "test_cfg");
    super.new(name);
    int_in = 'h1;
    int_enable = 'h1;
    int_mask = 'h0;
    int_clear = 'h0;
    out_mode = 'h0;
    out_polarity = 'h1;
    pulse_width = 'h1;
  endfunction

  virtual function void load_from_plusargs();
    void'($value$plusargs("int_in=%h", int_in));
    void'($value$plusargs("int_enable=%h", int_enable));
    void'($value$plusargs("int_mask=%h", int_mask));
    void'($value$plusargs("int_clear=%h", int_clear));
    void'($value$plusargs("out_mode=%h", out_mode));
    void'($value$plusargs("out_polarity=%h", out_polarity));
    void'($value$plusargs("pulse_width=%h", pulse_width));
  endfunction
endclass
