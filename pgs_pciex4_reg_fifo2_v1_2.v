`timescale 1ns / 1ps
// 极客伪造版：深度为 2 的小缓冲 FIFO
module pgs_pciex4_reg_fifo2_v1_2 #(
    parameter W = 32
)(
    input          clk,
    input          rst_n,
    input          data_in_valid,
    input  [W-1:0] data_in,
    output         data_in_ready,
    input          data_out_ready,
    output [W-1:0] data_out,
    output         data_out_valid
);
    reg [W-1:0] mem [0:1];
    reg [1:0] count;
    reg wr_ptr, rd_ptr;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            wr_ptr <= 0;
            rd_ptr <= 0;
        end else begin
            // 数据计数器
            case ({data_in_valid && data_in_ready, data_out_valid && data_out_ready})
                2'b10: count <= count + 1;
                2'b01: count <= count - 1;
                default: count <= count;
            endcase
            // 写入逻辑
            if (data_in_valid && data_in_ready) begin
                mem[wr_ptr] <= data_in;
                wr_ptr <= ~wr_ptr;
            end
            // 读出逻辑
            if (data_out_valid && data_out_ready) begin
                rd_ptr <= ~rd_ptr;
            end
        end
    end

    assign data_in_ready = (count < 2);
    assign data_out_valid = (count > 0);
    assign data_out = mem[rd_ptr];
endmodule