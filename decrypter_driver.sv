class decrypter_driver extends uvm_driver #(my_seq_item);
  virtual dut_if vif;
  `uvm_component_utils(my_driver)
   
  function new(string name = "my_driver", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif))
      `uvm_error("my_driver", "virtual interface must be set for vif!!!")
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive();
      seq_item_port.item_done();
    end
  endtask
   
  virtual task drive();
    @(posedge vif.clk);
    vif.init   <= 1'b1;
    vif.wr_en  <= 1'b0;
    vif.waddr  <= 8'b0;
    vif.raddr  <= 8'b0;
    vif.data_in <= 8'b0;
    
    // 等待reset完成
    repeat(5) @(posedge vif.clk);
    vif.init <= 1'b0;
    repeat(5) @(posedge vif.clk);
    
    // 开始驱动DUT
    forever begin
      my_seq_item item;
      seq_item_port.get_next_item(item);
      
      // 写入控制信号
      @(posedge vif.clk);
      vif.wr_en <= 1'b1;
      vif.waddr <= 8'd61;
      vif.data_in <= item.pre_length;
      
      @(posedge vif.clk);
      vif.waddr <= 8'd62;
      vif.data_in <= {3'b0, item.LFSR_ptrn_sel};
      
      @(posedge vif.clk);
      vif.waddr <= 8'd63;
      vif.data_in <= {2'b0, item.LFSR_init};
      
      // 写入原始消息
      for(int i=0; i<item.str.len(); i++) begin
        @(posedge vif.clk);
        vif.waddr <= i;
        vif.data_in <= item.str[i];
      end
      
      // 写入结束
      @(posedge vif.clk);
      vif.wr_en <= 1'b0;
      
      // 等待DUT完成
      @(posedge vif.done);
      
      // 读取加密后的消息
      for(int i=0; i<64; i++) begin
        @(posedge vif.clk);
        vif.raddr <= i+64;
      end
      
      seq_item_port.item_done();
    end
  endtask
endclass