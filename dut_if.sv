interface dut_if;
    logic clk, reset;
    logic wr_en, rd_en;
    logic [7:0] data_in;
    logic [7:0] data_out;

    // 接口中的时钟生成（可选）
    modport tb (
        input clk, reset, data_in,
        output data_out
    );

    modport dut (
        output clk, reset, data_in,
        input data_out
    );

    // 时钟生成任务
    task run_clock();
        forever #5 clk = ~clk;  // 100MHz时钟，10ns周期
    endtask
endinterface