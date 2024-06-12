class decrypter_test extends uvm_test;
  my_sequence seq;
  my_env env;
  virtual dut_if vif;
  
  `uvm_component_utils(my_test)
  
  function new(string name = "my_test", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif))
      `uvm_error("my_test", "virtual interface must be set for vif!!!")
      
    uvm_config_db#(virtual dut_if)::set(this, "env", "vif", vif);
    env = my_env::type_id::create("env", this);
    seq = my_sequence::type_id::create("seq");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    apply_reset();
    seq.start(env.driver.sequencer);
    phase.drop_objection(this);
  endtask
  
  virtual task apply_reset();
    vif.init <= 1;
    repeat(5) @(posedge vif.clk);
    vif.init <= 0;
    repeat(5) @(posedge vif.clk); 
  endtask
endclass