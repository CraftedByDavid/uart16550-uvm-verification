module top;
	import uvm_pkg::*;
	import uart_test_pkg::*;
	
	bit clk0;
	bit clk1;
	
	wire tx,rx;

	initial begin
		clk0 = 1'b0;
		forever #10 clk0 =~ clk0;
	end

	initial begin
        	clk1 = 1'b0;
        	forever #5 clk1 =~ clk1;
        end

	uart_if in0(clk0);
	uart_if in1(clk1);

	uart_16550 dut1 (
  	  // APB Signals
    	.PCLK    (clk0),
    	.PRESETn (in0.Presetn),
    	.PADDR   (in0.Paddr),
    	.PWDATA  (in0.Pwdata),
    	.PRDATA  (in0.Prdata),
    	.PWRITE  (in0.Pwrite),
    	.PENABLE (in0.Penable),
    	.PSEL    (in0.Psel),
    	.PREADY  (in0.Pready),
    	.PSLVERR (in0.Pslverr),

    	// UART interrupt request line
    	.IRQ     (in0.IRQ),

    	// UART signals
    	.TXD     (tx),
    	.RXD     (rx),

    	// Baud rate generator output
    	.baud_o  (in0.baud_o)
	);	

	uart_16550 dut2 (
          // APB Signals
        .PCLK    (clk1),
        .PRESETn (in1.Presetn),
        .PADDR   (in1.Paddr),
        .PWDATA  (in1.Pwdata),
        .PRDATA  (in1.Prdata),
        .PWRITE  (in1.Pwrite),
        .PENABLE (in1.Penable),
        .PSEL    (in1.Psel),
        .PREADY  (in1.Pready),
        .PSLVERR (in1.Pslverr),

        // UART interrupt request line
        .IRQ     (in1.IRQ),

        // UART signals
        .TXD     (rx),
        .RXD     (tx),

        // Baud rate generator output
        .baud_o  (in1.baud_o)
        );


	initial begin
		`ifdef VCS
         	$fsdbDumpvars(0, top);
        	`endif
		
		uvm_config_db #(virtual uart_if)::set(null,"*","vif_0",in0);
		uvm_config_db #(virtual uart_if)::set(null,"*","vif_1",in1);

		run_test;
	end

endmodule
