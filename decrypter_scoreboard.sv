class my_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(my_scoreboard)
  
  uvm_analysis_imp#(my_seq_item, my_scoreboard) item_collected_export;
  
  function new(string name = "my_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_collected_export = new("item_collected_export", this);
  endfunction
  
  virtual function void write(my_seq_item item);
    my_seq_item expected_item;
    
    // 创建一个期望的seq_item
    expected_item = my_seq_item::type_id::create("expected_item");
    
    // 复制输入数据
    expected_item.in_length = item.in_length;
    expected_item.in_msg = new[item.in_length];
    for(int i=0; i<item.in_length; i++) expected_item.in_msg[i] = item.in_msg[i];
    
    // 计算期望的输出数据
    encrypt_message(expected_item);
    
    // 比较实际输出和期望输出
    if(item.out_length != expected_item.out_length) begin
      `uvm_error("my_scoreboard", $sformatf("Output length mismatch! Expected: %0d, Actual: %0d", 
                                             expected_item.out_length, item.out_length))
    end
    else begin
      for(int i=0; i<item.out_length; i++) begin
        if(item.out_msg[i] != expected_item.out_msg[i]) begin
          `uvm_error("my_scoreboard", $sformatf("Output data mismatch at index %0d! Expected: %0h, Actual: %0h",
                                                 i, expected_item.out_msg[i], item.out_msg[i]))
        end
      end
    end
  endfunction

  virtual function void encrypt_message(my_seq_item item);
    logic [5:0] LFSR_ptrn[6] = {6'h39, 6'h36, 6'h33, 6'h30, 6'h2D, 6'h21};
    logic [5:0] LFSR[64];
    int foundit;
    
    // 初始化LFSR
    for(int i=0; i<7; i++) LFSR[i] = item.in_msg[i][5:0] ^ 6'h1f;
    
    // 找到正确的LFSR模式
    for(int i=0; i<6; i++) begin
      logic [5:0] trial_LFSR = LFSR[0];
      for(int j=0; j<6; j++) 
        trial_LFSR = (trial_LFSR << 1) + (^(trial_LFSR & LFSR_ptrn[i]));
      if(trial_LFSR == LFSR[6]) begin
        foundit = i;
        break;
      end
    end
    
    // 生成完整的LFSR序列
    for(int i=7; i<64; i++)
      LFSR[i] = (LFSR[i-1] << 1) + (^(LFSR[i-1] & LFSR_ptrn[foundit]));
      
    // 执行解密
    item.out_length = 0;
    for(int i=0; i<64; i++) begin
      logic [7:0] decrypted_byte = item.in_msg[i] ^ {2'b0, LFSR[i]};
      if(decrypted_byte != 8'h5f || item.out_length != 0) begin
        item.out_msg[item.out_length] = decrypted_byte;
        item.out_length++;
      end
    end
  endfunction
endclass