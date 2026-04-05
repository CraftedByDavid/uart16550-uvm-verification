class wr_agt_top extends uvm_env;

	`uvm_component_utils(wr_agt_top)

	wr_agent agnth;

	extern function new(string name = "wr_agt_top" , uvm_component parent);
	extern function void build_phase(uvm_phase phase);
//	extern task run_phase(uvm_phase phase);

endclass

function wr_agt_top::new(string name = "wr_agt_top" , uvm_component parent);
		super.new(name,parent);
endfunction


function void wr_agt_top::build_phase(uvm_phase phase);
     		super.build_phase(phase);
   		agnth=wr_agent::type_id::create("agnth",this);
endfunction
