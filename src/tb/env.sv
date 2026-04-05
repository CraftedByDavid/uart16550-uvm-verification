class env extends uvm_env;

	`uvm_component_utils(env)

	wr_agt_top wagt_top[];
	env_config m_cfg;
	sb sb_h;

	extern function new(string name = "env", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);



endclass

function env::new(string name = "env", uvm_component parent);
		super.new(name,parent);
endfunction

function void env::build_phase(uvm_phase phase);
	if(!uvm_config_db #(env_config)::get(this,"","env_config",m_cfg))
		`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
	if(m_cfg.has_wagent) begin
		wagt_top = new[m_cfg.no_of_duts];	 
                foreach(wagt_top[i])begin
			uvm_config_db #(wr_agent_config)::set(this,$sformatf("wagt_top[%0d]*",i),"wr_agent_config", m_cfg.m_wr_agent_cfg[i]);
			wagt_top[i]=wr_agt_top::type_id::create($sformatf("wagt_top[%0d]",i) ,this);
                end
		end
	sb_h = sb::type_id::create("sb_h",this);
        	super.build_phase(phase);
               
endfunction

function void env::connect_phase(uvm_phase phase);

	foreach(wagt_top[i])
		wagt_top[i].agnth.monh.mp.connect(sb_h.fifo_h[i].analysis_export);


endfunction
