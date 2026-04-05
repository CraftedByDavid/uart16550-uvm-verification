class uart_base_test extends uvm_test;//if there is any erro at uart_pkg then check if the name of the module is correct or wrong
	
	`uvm_component_utils(uart_base_test)

	env envh;
	env_config m_tb_cfg;
	wr_agent_config m_wr_cfg[];

	int no_of_duts = 2;
	int has_wagent = 1;

	extern function new(string name = "uart_base_test" , uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void config_uart();
	extern function void end_of_elaboration_phase(uvm_phase phase);
endclass

function uart_base_test::new(string name = "uart_base_test" , uvm_component parent);
	super.new(name,parent);
endfunction

function void uart_base_test::build_phase(uvm_phase phase);
                // create the config object using uvm_config_db 
	m_tb_cfg=env_config::type_id::create("m_tb_cfg");
        if(has_wagent)
         	m_tb_cfg.m_wr_agent_cfg = new[no_of_duts];
        config_uart; 
	uvm_config_db #(env_config)::set(this,"*","env_config",m_tb_cfg);
     	super.build_phase(phase);
	envh=env::type_id::create("envh", this);
endfunction


function void uart_base_test::config_uart();
 	  if (has_wagent) begin
                m_wr_cfg = new[no_of_duts];
	        foreach(m_wr_cfg[i]) begin
                	m_wr_cfg[i]=wr_agent_config::type_id::create($sformatf("m_wr_cfg[%0d]", i));
	  if(!uvm_config_db #(virtual uart_if)::get(this,"", $sformatf("vif_%0d",i),m_wr_cfg[i].vif))
		`uvm_fatal("VIF CONFIG","cannot get()interface vif from uvm_config_db. Have you set() it?") 
                m_wr_cfg[i].is_active = UVM_ACTIVE;
                m_tb_cfg.m_wr_agent_cfg[i] = m_wr_cfg[i];
                end
            end
            m_tb_cfg.no_of_duts = no_of_duts;
            m_tb_cfg.has_wagent = has_wagent;
endfunction 

function void uart_base_test::end_of_elaboration_phase(uvm_phase phase);
	super.end_of_elaboration_phase(phase);
    	uvm_top.print_topology();

endfunction

class seq1duplex extends uart_base_test;

	`uvm_component_utils(seq1duplex)
	
	full_dup_seq1 seq1_h;
	full_dup_seq2 seq2_h;

	extern function new(string name = "seq1duplex" , uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);

endclass

function seq1duplex::new(string name = "seq1duplex" , uvm_component parent);
	super.new(name,parent);
endfunction

function void seq1duplex::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

task seq1duplex::run_phase(uvm_phase phase);
    	phase.raise_objection(this);
	
    	seq1_h = full_dup_seq1::type_id::create("seq1_h");
	seq2_h = full_dup_seq2::type_id::create("seq2_h");

	fork 
    		begin
			seq1_h.start(envh.wagt_top[0].agnth.seqrh);
		end
		begin
			seq2_h.start(envh.wagt_top[1].agnth.seqrh);
		end
	join

    	phase.drop_objection(this);
endtask

class half_dup_seq_test extends uart_base_test;

	 `uvm_component_utils(half_dup_seq_test)

	half_dup_seq1 seq1_h;
	half_dup_seq2 seq2_h;

	extern function new(string name = "half_dup_seq_test" , uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);

endclass 


function half_dup_seq_test::new(string name = "half_dup_seq_test", uvm_component parent);
        super.new(name,parent);
endfunction

function void half_dup_seq_test::build_phase(uvm_phase phase);
        super.build_phase(phase);
endfunction



task half_dup_seq_test::run_phase(uvm_phase phase);
        phase.raise_objection(this);

        seq1_h = half_dup_seq1::type_id::create("seq1_h");
	seq2_h = half_dup_seq2::type_id::create("seq2_h");
	

        fork
                begin
                        seq1_h.start(envh.wagt_top[0].agnth.seqrh);
                end
                begin
                        seq2_h.start(envh.wagt_top[1].agnth.seqrh);
                end
        join

        phase.drop_objection(this);
endtask

class loop_back_test extends uart_base_test;

	`uvm_component_utils(loop_back_test);

	loop_back_seq1 seq1_h;
	loop_back_seq2 seq2_h;

	extern function new(string name = "loop_back_test" , uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
endclass

function loop_back_test::new(string name = "loop_back_test", uvm_component parent);
        super.new(name,parent);
endfunction

function void loop_back_test::build_phase(uvm_phase phase);
        super.build_phase(phase);
endfunction


task loop_back_test::run_phase(uvm_phase phase);
        phase.raise_objection(this);

        seq1_h = loop_back_seq1::type_id::create("seq1_h");
	seq2_h = loop_back_seq2::type_id::create("seq2_h");
	

        fork
                begin
                        seq1_h.start(envh.wagt_top[0].agnth.seqrh);
                end
                begin
                        seq2_h.start(envh.wagt_top[1].agnth.seqrh);
                end
        join

        phase.drop_objection(this);
endtask

class parity_test extends uart_base_test;

	`uvm_component_utils(parity_test)

	parity_seq1 seq1_h;
	parity_seq2 seq2_h;

	extern function new(string name = "parity_test",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);


endclass

function parity_test::new(string name = "parity_test", uvm_component parent);
        super.new(name,parent);
endfunction

function void parity_test::build_phase(uvm_phase phase);
        super.build_phase(phase);
endfunction



task parity_test::run_phase(uvm_phase phase);
        phase.raise_objection(this);

        seq1_h = parity_seq1::type_id::create("seq1_h");
        seq2_h = parity_seq2::type_id::create("seq2_h");


        fork
                begin
                        seq1_h.start(envh.wagt_top[0].agnth.seqrh);
                end
                begin
                        seq2_h.start(envh.wagt_top[1].agnth.seqrh);
                end
        join

        phase.drop_objection(this);
endtask

class break_error_test extends uart_base_test;

	`uvm_component_utils(break_error_test)

	break_error_seq1 seq1_h;
	break_error_seq2 seq2_h;
	
	extern function new(string name = "break_error_test",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass

function break_error_test::new(string name = "break_error_test", uvm_component parent);
        super.new(name,parent);
endfunction

function void break_error_test::build_phase(uvm_phase phase);
        super.build_phase(phase);
endfunction



task break_error::run_phase(uvm_phase phase);
        phase.raise_objection(this);

        seq1_h = parity_seq1::type_id::create("seq1_h");
        seq2_h = parity_seq2::type_id::create("seq2_h");


        fork
                begin
                        seq1_h.start(envh.wagt_top[0].agnth.seqrh);
                end
                begin
                        seq2_h.start(envh.wagt_top[1].agnth.seqrh);
                end
        join

        phase.drop_objection(this);
endtask



