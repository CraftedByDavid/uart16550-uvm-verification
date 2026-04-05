class wr_monitor extends uvm_monitor;

	`uvm_component_utils(wr_monitor)
	virtual uart_if.MON_MP vif;

	wr_agent_config m_cfg;
	apb_xtn xtn;
	
	uvm_analysis_port #(apb_xtn) mp;

	extern function new(string name = "wr_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
//	extern function void report_phase(uvm_phase phase);

endclass

//-----------------  constructor new method  -------------------//
function wr_monitor::new(string name = "wr_monitor", uvm_component parent);
	super.new(name,parent);
	mp = new("mp",this);
 endfunction

//-----------------  build() phase method  -------------------//
 function void wr_monitor::build_phase(uvm_phase phase);
        super.build_phase(phase);
	if(!uvm_config_db #(wr_agent_config)::get(this,"","wr_agent_config",m_cfg))
		`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?") 
	
	xtn = apb_xtn::type_id::create("xtn");
endfunction

function void wr_monitor::connect_phase(uvm_phase phase);
	vif = m_cfg.vif;
endfunction

task wr_monitor::run_phase(uvm_phase phase);
	repeat(2)@(vif.mon_cb);
	xtn.Presetn = vif.mon_cb.Presetn;
	mp.write(xtn);
	`uvm_info("UART_MONITOR", $sformatf("\n%s", xtn.sprint), UVM_LOW)
	@(vif.mon_cb);
	forever begin
		collect_data();
	end
endtask

task wr_monitor::collect_data();
	
		while(vif.mon_cb.Pready !== 1)
			@(vif.mon_cb);
		xtn.Presetn = vif.mon_cb.Presetn;
		xtn.Paddr = vif.mon_cb.Paddr;
		xtn.Psel = vif.mon_cb.Psel;
		xtn.Pwrite = vif.mon_cb.Pwrite;
		xtn.Penable = vif.mon_cb.Penable;
		xtn.Pwdata = vif.mon_cb.Pwdata;
		xtn.Prdata = vif.mon_cb.Prdata;
		xtn.Pready = vif.mon_cb.Pready;
		xtn.IRQ = vif.mon_cb.IRQ;

		if(xtn.Paddr == 32'h8 && xtn.Pwrite == 1'b0)
			begin
				while(vif.mon_cb.IRQ !== 1)
					@(vif.mon_cb);
				xtn.IRQ = vif.mon_cb.IRQ;
				xtn.Prdata = vif.mon_cb.Prdata;
				xtn.IIR = xtn.Prdata;
			end
		@(vif.mon_cb);
		if(xtn.Pwrite == 1'b1) begin
			if(xtn.Paddr == 32'h0)
				xtn.THR.push_back(xtn.Pwdata);	
			if(xtn.Paddr == 32'h4)
				xtn.IER = xtn.Pwdata;
			if(xtn.Paddr == 32'h8)
				xtn.FCR = xtn.Pwdata;
			if(xtn.Paddr == 32'hc)
				xtn.LCR = xtn.Pwdata;
			if(xtn.Paddr == 32'h20)
				xtn.DIV2 = xtn.Pwdata;
			if(xtn.Paddr == 32'h1c)
				xtn.DIV1 = xtn.Pwdata;
			if(xtn.Paddr == 32'h10)
				xtn.MCR = xtn.Pwdata;
		end
		if(xtn.IRQ == 1'b1)begin
			if(xtn.Paddr == 32'h0)
				xtn.RBR.push_back(xtn.Prdata);
			if(xtn.Paddr == 32'h14 && xtn.Pwrite == 1'b0)
				xtn.LSR = xtn.Prdata;
		end
		
		mp.write(xtn);		
		`uvm_info("UART_MONITOR", $sformatf("\n%s", xtn.sprint), UVM_LOW)

endtask

