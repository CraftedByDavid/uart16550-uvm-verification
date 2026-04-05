class wr_sequencer extends uvm_sequencer #(apb_xtn);
	`uvm_component_utils(wr_sequencer)
	extern function new(string name = "wr_sequencer",uvm_component parent);
endclass
function wr_sequencer::new(string name="wr_sequencer",uvm_component parent);
	super.new(name,parent);
endfunction
