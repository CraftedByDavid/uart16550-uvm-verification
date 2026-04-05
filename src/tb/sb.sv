class sb extends uvm_scoreboard;

  `uvm_component_utils(sb)

  uvm_tlm_analysis_fifo #(apb_xtn) fifo_h[];

  env_config m_cfg;

  apb_xtn t1,t2,uart1, uart2;

  int no_of_pass, no_of_fails;
covergroup APB_0_cg;
  PRESETN: coverpoint uart1.Presetn {bins Presetn = {[0 : 1]};}
  PADDR  : coverpoint uart1.Paddr   {bins Paddr   = {[0 : $]};}
  PWDATA : coverpoint uart1.Pwdata  {bins Pwdata  = {[0 : $]};}
  PWRITE : coverpoint uart1.Pwrite  {bins Pwrite  = {[0 : 1]};}
  PENABLE: coverpoint uart1.Penable {bins Pneable = {[0 : 1]};}
  PSEL   : coverpoint uart1.Psel    {bins Psel    = {[0 : 1]};}
  PRDATA : coverpoint uart1.Prdata  {bins Prdata  = {[0 : $]};}
  PREADY : coverpoint uart1.Pready  {bins Pready  = {[0 : 1]};}
  PSLVERR: coverpoint uart1.Pslverr {bins Pslverr = {[0 : 1]};}
  IRQ    : coverpoint uart1.IRQ     {bins IRQ     = {[0 : 1]};}
  BAUD_O : coverpoint uart1.baud_o  {bins baud_o  = {[0 : 1]};}
endgroup : APB_0_cg


covergroup APB_1_cg;
  PRESETN: coverpoint uart2.Presetn {bins Presetn = {[0 : 1]};}
  PADDR  : coverpoint uart2.Paddr   {bins Paddr   = {[0 : $]};}
  PWDATA : coverpoint uart2.Pwdata  {bins Pwdata  = {[0 : $]};}
  PWRITE : coverpoint uart2.Pwrite  {bins Pwrite  = {[0 : 1]};}
  PENABLE: coverpoint uart2.Penable {bins Pneable = {[0 : 1]};}
  PSEL   : coverpoint uart2.Psel    {bins Psel    = {[0 : 1]};}
  PRDATA : coverpoint uart2.Prdata  {bins Prdata  = {[0 : $]};}
  PREADY : coverpoint uart2.Pready  {bins Pready  = {[0 : 1]};}
  PSLVERR: coverpoint uart2.Pslverr {bins Pslverr = {[0 : 1]};}
  IRQ    : coverpoint uart2.IRQ     {bins IRQ     = {[0 : 1]};}
  BAUD_O : coverpoint uart2.baud_o  {bins baud_o  = {[0 : 1]};}
endgroup : APB_1_cg


covergroup UART_0_REG_cg;
  DIV : coverpoint uart1.DIV1       {bins DIV1 = {8'd27};}
  LCR : coverpoint uart1.LCR       {bins LCR[] = {8'h03, 8'h0b, 8'h43};}
  FCR : coverpoint uart1.FCR       {bins FCR = {8'h06};}
  IER : coverpoint uart1.IER       {bins IER[] = {8'h00, 8'h02, 8'h04, 8'h05};}
  THR : coverpoint uart1.THR[$]    {bins THR = {[0 : $]};}
  RBR : coverpoint uart1.RBR[$]    {bins RBR = {[0 : $]};}
  IIR : coverpoint uart1.IIR[3:0]  {bins IIR[] = {4'h2, 4'h4, 4'h6, 4'hc};}
  MCR : coverpoint uart1.MCR       {bins MCR = {8'h10};}
  LSR0: coverpoint uart1.LSR[0]    {bins LSR0[] = {0, 1};}
  LSR1: coverpoint uart1.LSR[1]    {bins LSR1[] = {0, 1};}
  LSR2: coverpoint uart1.LSR[2]    {bins LSR2[] = {0, 1};}
  LSR4: coverpoint uart1.LSR[4]    {bins LSR4[] = {0, 1};}
endgroup : UART_0_REG_cg


covergroup UART_1_REG_cg;
  DIV : coverpoint uart2.DIV1       {bins DIV1 = {16'd54};}
  LCR : coverpoint uart2.LCR       {bins LCR[] = {8'h00, 8'h03, 8'h1b, 8'h43};}
  FCR : coverpoint uart2.FCR       {bins FCR = {8'h06};}
  IER : coverpoint uart2.IER       {bins IER[] = {8'h00, 8'h02, 8'h04, 8'h05};}
  THR : coverpoint uart2.THR[$]    {bins THR = {[0 : $]};}
  RBR : coverpoint uart2.RBR[$]    {bins RBR = {[0 : $]};}
  IIR : coverpoint uart2.IIR[3:0]  {bins IIR[] = {4'h2, 4'h4, 4'h6, 4'hc};}
  MCR : coverpoint uart2.MCR       {bins MCR = {8'h10};}
  LSR0: coverpoint uart2.LSR[0]    {bins LSR0[] = {0, 1};}
  LSR1: coverpoint uart2.LSR[1]    {bins LSR1[] = {0, 1};}
  LSR2: coverpoint uart2.LSR[2]    {bins LSR2[] = {0, 1};}
  LSR3: coverpoint uart2.LSR[3]    {bins LSR3[] = {0, 1};}
  LSR4: coverpoint uart2.LSR[4]    {bins LSR4[] = {0, 1};}
endgroup : UART_1_REG_cg


  extern function new(string name = "sb", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern task collect_reset_data;
  extern task run_phase(uvm_phase phase);
  extern function void check_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);

endclass


function sb::new(string name = "sb", uvm_component parent);
  super.new(name, parent);
	 APB_0_cg = new;
  UART_0_REG_cg = new;

  APB_1_cg = new;
  UART_1_REG_cg = new;
endfunction


function void sb::build_phase(uvm_phase phase);
  super.build_phase(phase);

  if (!uvm_config_db #(env_config)::get(this, "", "env_config", m_cfg))
    `uvm_fatal("CONFIG", "cannot get() m_cfg from uvm_config_db. Have you set() it?")
uart1 = apb_xtn::type_id::create("uart1");
uart2 = apb_xtn::type_id::create("uart2");


  fifo_h = new[m_cfg.no_of_duts];

  foreach (fifo_h[i])
    fifo_h[i] = new($sformatf("fifo_h[%0d}", i), this);

endfunction

task sb::collect_reset_data;
  fork
    begin
      fifo_h[0].get(uart1);
      APB_0_cg.sample;
    end
    begin
      fifo_h[1].get(uart2);
      APB_1_cg.sample;
    end
  join
endtask 


task sb::run_phase(uvm_phase phase);
//collect_reset_data;

    fork forever
      begin
        fifo_h[0].get(uart1);
	APB_0_cg.sample;
      	UART_0_REG_cg.sample;
      end

      forever begin
        fifo_h[1].get(uart2);
	APB_1_cg.sample;
      	UART_1_REG_cg.sample;
      end
    join
endtask


function void sb::check_phase(uvm_phase phase);

  `uvm_info("UART_SB",
            $sformatf("UART_MONITOR[0]\n%s", uart1.sprint()),
            UVM_LOW)

  `uvm_info("UART_SB",
            $sformatf("UART_MONITOR[1]\n%s", uart2.sprint()),
            UVM_LOW)
//	$display("starting the check_phase");

  if ((uart1.LCR == 8'h03 && uart1.FCR == 8'h06 && uart1.IER == 8'h01) ||
      (uart2.LCR == 8'h03 && uart2.FCR == 8'h06 && uart2.IER == 8'h01)) begin
    if ((uart1.IIR[3:0] == 4'h4 && uart1.THR == uart2.RBR) &&
        (uart2.IIR[3:0] == 4'h4 && uart2.THR == uart1.RBR)) begin

      `uvm_info("UART_SB", "Full-Duplex test passed", UVM_LOW)
      no_of_pass++;

    end
    else if ((uart1.IIR[3:0] == 4'h4 && uart1.THR == uart2.RBR) ||
             (uart2.IIR[3:0] == 4'h4 && uart2.THR == uart1.RBR)) begin

      `uvm_info("UART_SB", "Half-Duplex test passed", UVM_LOW)
      no_of_pass++;

    end
    else if ((uart1.MCR == 8'h10 &&
              uart1.IIR[3:0] == 4'h4 &&
              uart1.THR == uart1.RBR) ||
             (uart2.MCR == 8'h10 &&
              uart2.IIR[3:0] == 4'h4 &&
              uart2.THR == uart2.RBR)) begin

      `uvm_info("UART_SB", "Loopback test passed", UVM_LOW)
      no_of_pass++;

    end
    else begin
      `uvm_error("UART_SB", "Full-Duplex/Half-Duplex/Loopback test failed")
      no_of_fails++;
    end

  end


  // Parity Error Test
  if (uart1.LCR[3] && uart2.LCR[3] && uart1.LCR[4] != uart2.LCR[4]) begin
    if (uart1.LCR[2] || uart2.LCR[2]) begin
      `uvm_info("UART_SB", "Parity error test passed", UVM_LOW)
      no_of_pass++;
    end
    else begin
      `uvm_error("UART_SB", "Parity error test failed")
      no_of_fails++;
    end
  end


  // Break Error Test
  if (uart1.LCR[6] || uart2.LCR[6]) begin
    if (uart1.LSR[4] || uart2.LSR[4]) begin
      `uvm_info("UART_SB", "Break error test passed", UVM_LOW)
      no_of_pass++;
    end
    else begin
      `uvm_error("UART_SB", "Break error test failed")
      no_of_fails++;
    end
  end


  // Overrun Error Test
  if ((uart1.IER == 8'h4 && uart1.THR.size == 17) ||
      (uart2.IER == 8'h4 && uart2.THR.size == 17)) begin
    if (uart1.LSR[1] || uart2.LSR[1]) begin
      `uvm_info("UART_SB", "Overrun error test passed", UVM_LOW)
      no_of_pass++;
    end
    else begin
      `uvm_error("UART_SB", "Overrun error test failed")
      no_of_fails++;
    end
  end


  // Framing Error Test
  if (uart1.LCR[1:0] != uart2.LCR[1:0]) begin
    if (uart1.LSR[3] || uart2.LSR[3]) begin
      `uvm_info("UART_SB", "Framing error test passed", UVM_LOW)
      no_of_pass++;
    end
    else begin
      `uvm_error("UART_SB", "Framing error test failed")
      no_of_fails++;
    end
  end


  // THR Empty Test
  if ((uart1.THR.size == 0 && uart1.IER[1]) ||
      (uart2.THR.size == 0 && uart2.IER[1])) begin
    if (uart1.IIR[3:0] == 4'h2 || uart2.IIR[3:0] == 4'h2) begin
      `uvm_info("UART_SB", "THR empty test passed", UVM_LOW)
      no_of_pass++;
    end
    else begin
      `uvm_error("UART_SB", "THR empty test failed")
      no_of_fails++;
    end
  end


  // Time-out Error Test
  if ((uart1.IER == 8'h0 && uart1.THR.size == 17) ||
      (uart2.IER == 8'h0 && uart2.THR.size == 17)) begin
    if (uart1.IIR[3:0] == 4'hc || uart2.IIR[3:0] == 4'hc) begin
      `uvm_info("UART_SB", "Time-out error test passed", UVM_LOW)
      no_of_pass++;
    end
    else begin
      `uvm_error("UART_SB", "Time-out error test failed")
      no_of_fails++;
    end
  end

endfunction

function void sb::report_phase(uvm_phase phase);
  super.report_phase(phase);
  $display("\n------------ Scoreboard Report ------------");
  $display("Number of pass transactions\t: %0d", no_of_pass);
  $display("Number of fail transactions\t: %0d", no_of_fails);
  $display("-------------------------------------------");
endfunction : report_phase


