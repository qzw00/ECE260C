`include "dut_if.sv"

module top_tb;
    dut_if intf();  // 实例化接口

    // DUT的实例
    top_level_4_260 dut(
        .clk(intf.clk),
        .reset(intf.reset),
        .data_in(intf.data_in),
        .data_out(intf.data_out)
    );

    initial begin
        intf.reset = 1;
        #100;  // 为DUT提供100ns的重置
        intf.reset = 0;
        intf.run_clock();  // 开始时钟
    end
endmodule