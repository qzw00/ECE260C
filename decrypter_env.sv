class decrypter_env extends uvm_env;
  my_driver driver;
  my_monitor monitor;
  my_scoreboard scoreboard;
  virtual dut_if vif;
  
  `uvm_component_utils(my_env)
  
  function new(string name = "my_env", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif))
      `uvm_error("my_env", "virtual interface must be set for vif!!!")
      
    uvm_config_db#(virtual dut_if)::set(this, "driver", "vif", vif);
    uvm_config_db#(virtual dut_if)::set(this, "monitor", "vif", vif);
    
    driver = my_driver::type_id::create("driver", this);
    monitor = my_monitor::type_id::create("monitor", this);
    scoreboard = my_scoreboard::type_id::create("scoreboard", this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
    monitor.item_collected_port.connect(scoreboard.item_collected_export);
  endfunction
endclass