class wr_agent extends uvm_agent;
	`uvm_component_utils(wr_agent)

	 wr_agent_config m_cfg;


	wr_monitor monh;
	wr_sequencer seqrh;
	wr_driver drvh;

	extern function new(string name = "wr_agent", uvm_component parent = null);
  	extern function void build_phase(uvm_phase phase);
 	extern function void connect_phase(uvm_phase phase);
endclass

function wr_agent::new(string name = "wr_agent", 
                               uvm_component parent = null);
         super.new(name, parent);
 endfunction

function void wr_agent::build_phase(uvm_phase phase);
		super.build_phase(phase);
                
	  if(!uvm_config_db #(wr_agent_config)::get(this,"","wr_agent_config",m_cfg))
		`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?") 
	        monh=wr_monitor::type_id::create("monh",this);	
		if(m_cfg.is_active==UVM_ACTIVE)
		begin
		drvh=wr_driver::type_id::create("drvh",this);
		seqrh=wr_sequencer::type_id::create("seqrh",this);
		end
endfunction

function void wr_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (m_cfg.is_active == UVM_ACTIVE) begin
        drvh.seq_item_port.connect(seqrh.seq_item_export);
    end
endfunction
