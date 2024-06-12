class decrypter_sequence extends uvm_sequence;
  `uvm_object_utils(my_sequence)
  
  function new(string name = "my_sequence");
    super.new(name);
  endfunction
  
  virtual task body();
    my_seq_item req = my_seq_item::type_id::create("req");
    start_item(req);
    assert(req.randomize());
    finish_item(req);
  endtask
endclass