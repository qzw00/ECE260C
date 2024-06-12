class decrypter_seq_item extends uvm_sequence_item;
  rand bit [7:0] pre_length;
  rand bit [5:0] LFSR_init;
  rand bit [2:0] LFSR_ptrn_sel;
  rand string str;
  
  constraint c1 { pre_length inside {[7:63]}; }
  constraint c2 { LFSR_ptrn_sel < 6; }
  constraint c3 { LFSR_init != 0; }
  
  `uvm_object_utils_begin(my_seq_item)
    `uvm_field_int(pre_length, UVM_ALL_ON)
    `uvm_field_int(LFSR_init, UVM_ALL_ON) 
    `uvm_field_int(LFSR_ptrn_sel, UVM_ALL_ON)
    `uvm_field_string(str, UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new(string name = "my_seq_item");
    super.new(name);
  endfunction
endclass
