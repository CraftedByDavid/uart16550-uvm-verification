class wr_driver extends uvm_driver #(apb_xtn);

	`uvm_component_utils(wr_driver)
	virtual uart_if.DRV_MP vif;


	wr_agent_config m_cfg;

	extern function new(string name ="wr_driver",uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task send_to_dut(apb_xtn xtn);
//	extern function void report_phase(uvm_phase phase);


endclass

//-----------------  constructor new method  -------------------//
 // Define Constructor new() function
function wr_driver::new(string name ="wr_driver",uvm_component parent);
		super.new(name,parent);
endfunction

//-----------------  build() phase method  -------------------//
function void wr_driver::build_phase(uvm_phase phase);
          super.build_phase(phase);
	  if(!uvm_config_db #(wr_agent_config)::get(this,"","wr_agent_config",m_cfg))
		`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?") 
endfunction

function void wr_driver::connect_phase(uvm_phase phase);
	vif = m_cfg.vif;
endfunction

task wr_driver::run_phase(uvm_phase phase);
	@(vif.drv_cb);
		vif.drv_cb.Presetn <= 1'b0;
	@(vif.drv_cb);
		vif.drv_cb.Presetn <= 1'b1;
	$display("reset was sucessfull");
	forever
		begin
		seq_item_port.get_next_item(req);
		//$display("asking the sequnece for data");
		send_to_dut(req);
		//$display("successfully send data to duv");
		seq_item_port.item_done();
	end
endtask

task wr_driver::send_to_dut(apb_xtn xtn);
	
	vif.drv_cb.Psel <= 1'b1;
	vif.drv_cb.Pwrite <= xtn.Pwrite;
	vif.drv_cb.Paddr <= xtn.Paddr;
	vif.drv_cb.Pwdata <= xtn.Pwdata;
	@(vif.drv_cb);
	vif.drv_cb.Penable <= 1'b1;
	while(vif.drv_cb.Pready !== 1'b1)
		@(vif.drv_cb);
	if(xtn.Paddr ==  32'h08 && xtn.Pwrite == 0)
		begin
		while(vif.drv_cb.IRQ !== 1'b1)
			@(vif.drv_cb);
		xtn.IIR = vif.drv_cb.Prdata;
		seq_item_port.put_response(xtn);
	end
	vif.drv_cb.Psel <= 1'b0;
	vif.drv_cb.Pwrite <= 1'b0;
	vif.drv_cb.Penable <= 1'b0;
	`uvm_info("UART_WR_DRIVER",$sformatf("printing from driver \n %s", xtn.sprint()),UVM_LOW)
	@(vif.drv_cb);
endtask


