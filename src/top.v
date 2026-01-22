module top (
    input wire CLK,
    input wire RST_N,
    output wire [1:0] LED,
    output wire HD_GPIO_1,  // J5 pin5 (UART0_TxD)
    input wire HD_GPIO_2  // J5 pin7 (UART0_RxD)
);
  wire led0;

  uart_hello #(
      .CLOCK_FREQUENCY(100_000_000),
      .BAUD_RATE(115200)
  ) u_hello (
      .clk(CLK),
      .rst_n(RST_N),
      .tx(HD_GPIO_1),
      .led0(led0)
  );

  assign LED[0] = led0;
  assign LED[1] = 1'b0;
endmodule
