package uart_test_pkg;
	import uvm_pkg::*;
	`include "apb_xtn.sv"
	`include "uvm_macros.svh"
	`include "wr_agent_config.sv"
	`include "env_config.sv"
	`include "wr_sequence.sv"

	`include "wr_driver.sv"
	`include "wr_monitor.sv"
	`include "wr_sequencer.sv"
	`include "wr_agent.sv"

	`include "sb.sv"	

	`include "wr_agt_top.sv"
	`include "env.sv"
	`include "uart_test.sv"


endpackage
