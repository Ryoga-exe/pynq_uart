
module uart_hello #(
    parameter int unsigned CLOCK_FREQUENCY = 100_000_000,
    parameter int unsigned BAUD_RATE       = 115200
) (
    input  logic clk,
    input  logic rst_n,  // active-low (pl_resetn0を直結でOK)
    output logic tx,
    output logic led0
);
  // 送信メッセージ（前に出た "r" を避けるため LF(0x0A)だけにする）
  localparam int MSG_LEN = 15;
  logic [7:0] msg[0:MSG_LEN-1];
  initial begin
    msg[0]  = "U";
    msg[1]  = "9";
    msg[2]  = "6";
    msg[3]  = " ";
    msg[4]  = "P";
    msg[5]  = "L";
    msg[6]  = " ";
    msg[7]  = "U";
    msg[8]  = "A";
    msg[9]  = "R";
    msg[10] = "T";
    msg[11] = " ";
    msg[12] = "O";
    msg[13] = "K";
    msg[14] = 8'h0A;  // '\n'
  end

  // 1秒タイマ
  logic [$clog2(CLOCK_FREQUENCY)-1:0] sec_cnt;
  logic kick;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      sec_cnt <= '0;
      kick    <= 1'b0;
      led0    <= 1'b0;
    end else begin
      kick <= 1'b0;
      if (sec_cnt == CLOCK_FREQUENCY - 1) begin
        sec_cnt <= '0;
        kick    <= 1'b1;
        led0    <= ~led0;
      end else begin
        sec_cnt <= sec_cnt + 1;
      end
    end
  end

  // “FIFOもどき”：core_transmitter の re を見て1byteずつ供給
  logic                     active;  // 送信中（フィード中）
  logic [$clog2(MSG_LEN):0] idx;
  logic [              7:0] din_reg;
  logic                     empty;
  logic                     re;

  assign empty = ~active;

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      active  <= 1'b0;
      idx     <= '0;
      din_reg <= 8'h00;
    end else begin
      // 1秒ごとに開始（前回がactive中なら無視）
      if (kick && !active) begin
        active <= 1'b1;
        idx    <= '0;
      end

      // transmitter が “次の1byte” を要求したら供給
      if (active && re) begin
        din_reg <= msg[idx];
        if (idx == MSG_LEN - 1) begin
          active <= 1'b0;     // これで empty=1 になり、次の要求は止まる
          idx    <= '0;
        end else begin
          idx <= idx + 1;
        end
      end
    end
  end

  core_transmitter #(
      .CLOCK_FREQUENCY(CLOCK_FREQUENCY),
      .BAUD_RATE(BAUD_RATE),
      .WORD_WIDTH(8)
  ) u_tx (
      .clk  (clk),
      .rst  (rst_n),     // ← core_transmitter は active-low reset
      .din  (din_reg),
      .empty(empty),
      .re   (re),
      .dout (tx)
  );

endmodule
