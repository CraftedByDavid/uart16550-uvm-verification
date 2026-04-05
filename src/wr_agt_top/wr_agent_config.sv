class wr_agent_config extends uvm_object;

`uvm_object_utils(wr_agent_config)

virtual uart_if vif;
uvm_active_passive_enum is_active = UVM_ACTIVE;
static int drv_data_sent_cnt = 0;

extern function new(string name = "wr_agent_config");

endclass

function wr_agent_config::new(string name = "wr_agent_config");
  super.new(name);
endfunction
