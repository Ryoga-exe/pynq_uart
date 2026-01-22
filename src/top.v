module top (
    input wire CLK,
    input wire RST_N,
    output wire [1:0] LED,
    output wire HD_GPIO_1,  // J5 pin5 (UART0_TxD)
    input wire HD_GPIO_2  // J5 pin7 (UART0_RxD)
);
  //-------------------------------------------------------------------------
  // Reset synchronizer (ARESETN is async, internal ARST is sync / active-high)
  //-------------------------------------------------------------------------
  reg [1:0] arst_ff;
  always @(posedge CLK) begin
    arst_ff <= {arst_ff[0], ~RST_N};
  end
  wire RST;
  assign RST = arst_ff[1];

  // Simple Echo-back

  wire uart_tx;

  echo_back #(
      .CLOCK_FREQUENCY(100_000_000),
      .BAUD_RATE(115200)
  ) u_echo (
      .clk(CLK),
      .rst(RST),
      .rxd(HD_GPIO_2),
      .txd(uart_tx),
  );

  assign HD_GPIO_1 = uart_tx;
  assign LED[0] = 1'b0;
  assign LED[1] = 1'b0;
endmodule
