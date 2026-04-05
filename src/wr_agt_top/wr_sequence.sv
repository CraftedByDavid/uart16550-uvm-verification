class base_seq extends uvm_sequence #(apb_xtn);

	`uvm_object_utils(base_seq)
	
	function new (string name = "base_seq");
		super.new(name);
	endfunction

endclass


class full_dup_seq1 extends base_seq;
	
	`uvm_object_utils(full_dup_seq1)

	function new(string name = "full_dup_seq1");
		super.new(name);
	endfunction

	task body();
		req = apb_xtn::type_id::create("req");
		start_item(req);
		assert(req.randomize() with { Paddr == 32'h1c; Pwrite == 1'b1; Pwdata == 27;});
		finish_item(req);

		start_item(req);
                assert(req.randomize() with { Paddr == 32'h20; Pwrite == 1'b1; Pwdata == 0;});
                finish_item(req);
 //LCR
		start_item(req);
    		assert(req.randomize() with { Paddr == 32'h0c; Pwrite == 1'b1; Pwdata == 32'h03; });
    		finish_item(req);
//FCR
		start_item(req);
    		assert(req.randomize() with { Paddr == 32'h08; Pwrite == 1'b1; Pwdata == 32'h06; });
    		finish_item(req);
//IER
		start_item(req);
    		assert(req.randomize() with { Paddr == 32'h04; Pwrite == 1'b1; Pwdata == 32'h05; });
    		finish_item(req);
	//THR
		start_item(req);
    		assert(req.randomize() with { Paddr == 32'h00; Pwrite == 1'b1; Pwdata == 5; });
    		finish_item(req);

		start_item(req);
    		assert(req.randomize() with { Paddr == 32'h08; Pwrite == 1'b0; 
		Pwdata == 0;});
    		finish_item(req);

		get_response(req);

		if(req.IIR[3:0] == 4) begin
			start_item(req);
    			assert(req.randomize() with { Paddr == 32'h00; Pwrite ==1'b0;
			Pwdata == 0; });
    			finish_item(req);
		end

		if(req.IIR[3:0] == 4'h6)begin
			start_item(req);
    			assert(req.randomize() with { Paddr == 32'h14; Pwrite == 1'b0; 				Pwdata == 0;});
    			finish_item(req);
		end
	endtask


endclass

class full_dup_seq2 extends base_seq;

        `uvm_object_utils(full_dup_seq2)

        function new(string name = "full_dup_seq2");
                super.new(name);
	endfunction

	 task body();
                req = apb_xtn::type_id::create("req");
                start_item(req);
                assert(req.randomize() with { Paddr == 32'h1c; Pwrite == 1'b1; Pwdata == 54;});
                finish_item(req);

                start_item(req);
                assert(req.randomize() with { Paddr == 32'h20; Pwrite == 1'b1; Pwdata == 0;});
                finish_item(req);
	//LCR
                start_item(req);
                assert(req.randomize() with { Paddr == 32'h0c; Pwrite == 1'b1; Pwdata == 32'h03; });
                finish_item(req);
//FCR
                start_item(req);
                assert(req.randomize() with { Paddr == 32'h08; Pwrite == 1'b1; Pwdata == 32'h06; });
                finish_item(req);
//IER
                start_item(req);
                assert(req.randomize() with { Paddr == 32'h04; Pwrite == 1'b1; Pwdata == 32'h05; });
                finish_item(req);
//THR
                start_item(req);
                assert(req.randomize() with { Paddr == 32'h00; Pwrite == 1'b1; Pwdata == 6; });
                finish_item(req);

                start_item(req);
                assert(req.randomize() with { Paddr == 32'h08; Pwrite == 1'b0;
		Pwdata == 32'h00; });
                finish_item(req);

		get_response(req);

                if(req.IIR[3:0] == 4) begin
                        start_item(req);
                        assert(req.randomize() with { Paddr == 32'h00; Pwrite == 1'b0; 
			Pwdata == 32'h00 ;});
                        finish_item(req);
                end

                if(req.IIR[3:0] == 6)begin
                        start_item(req);
                        assert(req.randomize() with { Paddr == 32'h14; Pwrite == 1'b0; 				Pwdata == 32'h00 ;});
                        finish_item(req);
                end
		
	endtask
endclass
