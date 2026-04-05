class apb_xtn extends uvm_sequence_item;

    `uvm_object_utils(apb_xtn)

    function new(string name = "apb_xtn");
        super.new(name);
    endfunction

    // ----------------------------------------------------
    // APB SIGNALS
    // ----------------------------------------------------
    bit         Presetn;
   rand bit[31:0] Paddr;
    bit         Psel;
    rand bit    Pwrite;
    bit         Penable;
    rand bit[31:0] Pwdata;
    bit  [31:0] Prdata;
    bit         Pready;
    bit         Pslverr;
    bit         IRQ;
    bit         baud_o;

    // ----------------------------------------------------
    // UART REGISTERS
    // ----------------------------------------------------
    bit [7:0] LCR, IER, IIR, LSR, MSR, FCR, MCR;

    // FIFO Buffers
    bit [7:0] THR[$];
    bit [7:0] RBR[$];

    // Divisor latch
    bit [7:0] DIV1, DIV2;

    // ----------------------------------------------------
    // do_print()
    // ----------------------------------------------------
    function void do_print(uvm_printer printer);
        super.do_print(printer);

        // ----------------------------------------------------
        // APB SIGNALS
        // ----------------------------------------------------
        printer.print_field("Presetn",    this.Presetn,    1,  UVM_DEC);
        printer.print_field("Paddr",      this.Paddr,      32, UVM_DEC);
        printer.print_field("Psel",       this.Psel,       1,  UVM_DEC);
        printer.print_field("Pwrite",     this.Pwrite,     1,  UVM_DEC);
        printer.print_field("Penable",    this.Penable,    1,  UVM_DEC);
        printer.print_field("Pwdata",     this.Pwdata,     32, UVM_DEC);
        printer.print_field("Prdata",     this.Prdata,     32, UVM_DEC);
        printer.print_field("Pready",     this.Pready,     1,  UVM_DEC);
        printer.print_field("Pslverr",    this.Pslverr,    1,  UVM_DEC);

        // ----------------------------------------------------
        // UART OUTPUT SIGNALS
        // ----------------------------------------------------
        printer.print_field("IRQ",        this.IRQ,        1,  UVM_DEC);
        printer.print_field("baud_o",     this.baud_o,     1,  UVM_DEC);

        // ----------------------------------------------------
        // CONTROL REGISTERS
        // ----------------------------------------------------
        printer.print_field("LCR",        this.LCR,        8, UVM_DEC);
        printer.print_field("IER",        this.IER,        8, UVM_DEC);
        printer.print_field("IIR",        this.IIR,        8, UVM_DEC);
        printer.print_field("LSR",        this.LSR,        8, UVM_DEC);
        printer.print_field("MSR",        this.MSR,        8, UVM_DEC);
        printer.print_field("FCR",        this.FCR,        8, UVM_DEC);
        printer.print_field("MCR",        this.MCR,        8, UVM_DEC);

        // ----------------------------------------------------
        // DIVISOR LATCH VALUES
        // ----------------------------------------------------
        printer.print_field("DIV1",       this.DIV1,       8, UVM_DEC);
        printer.print_field("DIV2",       this.DIV2,       8, UVM_DEC);

        // ----------------------------------------------------
        // THR DYNAMIC ARRAY
        // ----------------------------------------------------
        printer.print_array_header("THR", this.THR.size());
        foreach (this.THR[i]) begin
            printer.print_field($sformatf("THR[%0d]", i),
                                this.THR[i],
                                8,
                                UVM_DEC);
        end
        printer.print_array_footer(this.THR.size());

        // ----------------------------------------------------
        // RBR DYNAMIC ARRAY
        // ----------------------------------------------------
        printer.print_array_header("RBR", this.RBR.size());
        foreach (this.RBR[i]) begin
            printer.print_field($sformatf("RBR[%0d]", i),
                                this.RBR[i],
                                8,
                                UVM_DEC);
        end
        printer.print_array_footer(this.RBR.size());

    endfunction : do_print

endclass : apb_xtn

