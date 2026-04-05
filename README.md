# 🔁 UVM-Based Design & Verification of UART 16550 Protocol

<div align="center">

![Methodology](https://img.shields.io/badge/Methodology-UVM%201.2-blue?style=for-the-badge)
![Coverage](https://img.shields.io/badge/Functional%20Coverage-91.33%25-brightgreen?style=for-the-badge)
![Language](https://img.shields.io/badge/Language-SystemVerilog-orange?style=for-the-badge)
![Interface](https://img.shields.io/badge/Bus-APB%20(AMBA)-purple?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Complete-success?style=for-the-badge)

**Full design and UVM verification of a UART 16550 controller over APB**  
*Two cross-wired UART DUTs, 2 active agents, scoreboard with 4 covergroups — 91.33% functional coverage*

</div>

---

## 📑 Table of Contents

- [Project Overview](#-project-overview)
- [DUT Architecture](#-dut-architecture)
- [Testbench Architecture](#-testbench-architecture)
- [Directory Structure](#-directory-structure)
- [UVM Component Breakdown](#-uvm-component-breakdown)
- [Test Plan](#-test-plan)
- [Functional Coverage](#-functional-coverage)
- [TLM Connection Map](#-tlm-connection-map)
- [Interface & Clocking Blocks](#-interface--clocking-blocks)
- [How to Run](#-how-to-run)
- [Simulation Results](#-simulation-results)
- [Key Learnings](#-key-learnings)

---

## 📌 Project Overview

This project covers both the **RTL design** and **UVM-based functional verification** of a **UART 16550** controller — one of the most widely used serial communication IPs in embedded systems. The DUT is interfaced through the **APB (Advanced Peripheral Bus)** and supports full UART 16550 features including configurable baud rates, parity, stop bits, 16-entry FIFOs, interrupt generation, loopback, and break condition.

The testbench instantiates **two independent uart_16550 DUTs** with their serial lines cross-connected, enabling real bidirectional UART communication for full-duplex, half-duplex, and loopback test scenarios.

### Project Highlights

| Parameter | Value |
|-----------|-------|
| **DUT** | `uart_16550` — APB-interfaced UART 16550 controller |
| **Sub-modules** | `uart_register_file`, `uart_tx`, `uart_rx`, `uart_fifo` (x2) |
| **Bus Interface** | APB (AMBA) — PCLK, PADDR[31:0], PWDATA[31:0], PRDATA[31:0], PSEL, PENABLE, PWRITE, PREADY, PSLVERR |
| **UART Features** | Configurable baud rate, 5–8 data bits, odd/even/stick parity, 1–2 stop bits, 16-entry FIFO, IRQ, loopback, break |
| **No. of DUTs** | 2 (TXD/RXD cross-wired between DUT1 and DUT2) |
| **Clocks** | DUT1: 20ns period (clk0) \| DUT2: 10ns period (clk1) |
| **UVM Agents** | 2 × Write Agent (Active) — one per DUT |
| **Functional Coverage** | **91.33%** |
| **Tests** | 6 test scenarios (Full-Duplex, Half-Duplex, Loopback, Parity, Break, Overrun/Framing/Timeout) |

---

## 🏗️ DUT Architecture

### Module Hierarchy

```
uart_16550  (Top-level APB peripheral)
├── uart_register_file     ← APB slave FSM + all UART control registers
│     ├── Baud rate generator (16-bit divisor counter)
│     ├── Interrupt controller (IRQ: RX, TX, Line Status, Timeout)
│     ├── APB FSM: IDLE → SETUP → ACCESS
│     └── Registers: DR, IER, IIR, FCR, LCR, MCR, LSR, MSR, DIV1, DIV2
│
├── uart_tx                ← 13-state TX FSM + 16-entry TX FIFO
│     ├── uart_fifo (TX)   ← 16 × 8-bit FIFO (push on APB write to DR)
│     └── TX FSM: IDLE → START → BIT0-7 → PARITY → STOP1 → STOP2
│
└── uart_rx                ← 13-state RX FSM + 16-entry RX FIFO
      ├── uart_fifo (RX)   ← 16 × 8-bit FIFO (pop on APB read from DR)
      └── RX FSM: IDLE → START → BIT0-7 → PARITY → STOP1 → STOP2
            ├── x16 oversampling using baud enable
            ├── Break counter (8-bit, resets when RXD=1)
            └── Timeout counter (10-bit, resets on FIFO access)
```

### UART Register Map

| Offset | Register | Abbrev | Description |
|--------|----------|--------|-------------|
| `0x00` | Data Register | DR / THR / RBR | Write: push to TX FIFO (THR). Read: pop from RX FIFO (RBR) |
| `0x01` | Interrupt Enable | IER | `[0]`=RX, `[1]`=TX, `[2]`=Line Status, `[3]`=Modem Status |
| `0x02` | Interrupt ID / FIFO Ctrl | IIR / FCR | Read: interrupt identity. Write: FIFO control |
| `0x03` | Line Control | LCR | `[1:0]`=data bits, `[2]`=stop, `[5:3]`=parity, `[6]`=break |
| `0x04` | Modem Control | MCR | `[4]`=loopback enable |
| `0x05` | Line Status | LSR | RX data ready, overrun, parity, framing, break, TX empty |
| `0x06` | Modem Status | MSR | Modem status flags |
| `0x07` | Divisor LSB | DIV1 | Baud rate divisor `[7:0]` |
| `0x08` | Divisor MSB | DIV2 | Baud rate divisor `[15:8]` |

### Baud Rate Configuration

The baud rate is set via a 16-bit DIVISOR split across DIV1 and DIV2. A down-counter fires an `enable` pulse when it reaches zero, which both TX and RX FSMs use as their clock tick (x16 oversampling).

| DUT | DIVISOR | Clock Period | Resulting Baud Tick |
|-----|---------|-------------|---------------------|
| DUT1 | 27 (0x1B) | 20ns | Every 27×16 PCLK cycles |
| DUT2 | 54 (0x36) | 10ns | Every 54×16 PCLK cycles |

### Cross-Wire Connection

```
top.sv:
  wire tx, rx;
  DUT1.TXD ──► tx ──► DUT2.RXD
  DUT2.TXD ──► rx ──► DUT1.RXD
```

This enables real UART serial communication between the two DUTs — the testbench itself does not need to model the serial data path.

---

## 🧪 Testbench Architecture

```
┌────────────────────────────────────────────────────────────────────────────┐
│                              TEST LAYER                                    │
│  uart_base_test                                                            │
│  ├── seq1duplex         ├── half_dup_seq_test   ├── loop_back_test         │
│  ├── parity_test        ├── break_error_test    └── (overrun/framing/tmout)│
└─────────────────────────────────┬──────────────────────────────────────────┘
                                  │ creates env, config
┌─────────────────────────────────▼──────────────────────────────────────────┐
│                   env  (UVM Environment)                                   │
│                                                                            │
│  ┌──────────────────────┐        ┌──────────────────────┐                 │
│  │   wagt_top[0]         │        │   wagt_top[1]         │                 │
│  │  (DUT1 / clk0/20ns)  │        │  (DUT2 / clk1/10ns)  │                 │
│  │  ┌────────────────┐  │        │  ┌────────────────┐  │                 │
│  │  │  wr_driver     │  │        │  │  wr_driver     │  │                 │
│  │  │  wr_monitor ───┼──┼──────► │  │  wr_monitor ───┼──┼──┐             │
│  │  │  wr_sequencer  │  │        │  │  wr_sequencer  │  │  │             │
│  │  └────────────────┘  │        │  └────────────────┘  │  │             │
│  └──────────────────────┘        └──────────────────────┘  │             │
│          │ analysis_port                  │ analysis_port   │             │
│  ┌───────▼────────────────────────────────▼─────────────────┘             │
│  │                    sb  (Scoreboard)                                     │
│  │  fifo_h[0] ──► APB_0_cg + UART_0_REG_cg                               │
│  │  fifo_h[1] ──► APB_1_cg + UART_1_REG_cg                               │
│  │  check_phase: 7 pass/fail checks (duplex/loopback/errors)              │
│  └────────────────────────────────────────────────────────────────────────┘
│                                                                            │
│  env_config  |  wr_agent_config[0]  |  wr_agent_config[1]                 │
└────────────────────────────────────────────────────────────────────────────┘
                        │
              uart_if in0 (clk0) | uart_if in1 (clk1)
              drv_cb (posedge) | mon_cb (posedge)
                        │
┌───────────────────────▼────────────────────────────────────────────────────┐
│   DUT1: uart_16550                    DUT2: uart_16550                     │
│   (PCLK=clk0, DIVISOR=27)             (PCLK=clk1, DIVISOR=54)             │
│   TXD ──────────────────────────────► RXD                                  │
│   RXD ◄────────────────────────────── TXD                                  │
└────────────────────────────────────────────────────────────────────────────┘
```

---

## 📁 Directory Structure

```
uart-16550-uvm-verification/
│
├── rtl/
│   ├── uart_16550.v           # Top-level DUT — APB I/O, TX, RX, loopback mux
│   ├── uart_register_file.v   # APB slave FSM + all UART registers + IRQ + baud gen
│   ├── uart_tx.v              # 13-state TX FSM + TX FIFO instantiation
│   ├── uart_rx.v              # 13-state RX FSM + RX FIFO + break/timeout counters
│   └── uart_fifo.v            # Generic 16×8 synchronous FIFO (shared by TX and RX)
│
├── tb/
│   ├── top.sv                 # UVM top — clock gen, 2×DUT, cross-wire, run_test()
│   ├── uart_if.sv             # SystemVerilog interface — APB signals, drv_cb, mon_cb
│   ├── uart_test_pkg.sv       # Package importing all TB classes
│   │
│   ├── transaction/
│   │   └── apb_xtn.sv         # APB transaction sequence item
│   │
│   ├── config/
│   │   ├── env_config.sv      # Env-level config (no_of_duts, has_wagent, agent cfgs)
│   │   └── wr_agent_config.sv # Per-agent config (vif, is_active)
│   │
│   ├── agent/
│   │   ├── wr_driver.sv       # APB driver — drives via drv_cb clocking block
│   │   ├── wr_monitor.sv      # APB monitor — samples all signals via mon_cb
│   │   ├── wr_sequencer.sv    # Standard UVM sequencer
│   │   ├── wr_agent.sv        # Active agent packaging driver + monitor + sequencer
│   │   └── wr_agt_top.sv      # Agent top wrapper
│   │
│   ├── scoreboard/
│   │   └── sb.sv              # SB + 4 covergroups + 7-scenario check_phase
│   │
│   ├── env/
│   │   └── env.sv             # UVM environment — 2 agent tops + scoreboard
│   │
│   ├── sequences/
│   │   ├── apb_base_seq.sv         # Base APB sequence (write/read tasks)
│   │   ├── full_dup_seq1/2.sv      # Full-duplex sequences for DUT1 and DUT2
│   │   ├── half_dup_seq1/2.sv      # Half-duplex sequences
│   │   ├── loop_back_seq1/2.sv     # Loopback sequences (MCR[4]=1)
│   │   ├── parity_seq1/2.sv        # Parity error sequences
│   │   └── break_error_seq1/2.sv   # Break condition sequences (LCR[6]=1)
│   │
│   └── tests/
│       └── uart_test.sv       # All 6 test classes
│
├── sim/
│   └── Makefile
│
└── README.md
```

---

## 🔩 UVM Component Breakdown

### `uart_base_test`
Base test class. Every test inherits from it. Responsibilities:
- Creates `env_config` with `no_of_duts=2`
- Creates two `wr_agent_config` objects, fetches `vif_0` and `vif_1` from `uvm_config_db`
- Sets both agents as `UVM_ACTIVE`
- Calls `uvm_top.print_topology()` in `end_of_elaboration_phase`

### `env` (UVM Environment)
| Component | Count | Role |
|-----------|-------|------|
| `wagt_top[]` | 2 | One write agent top per DUT |
| `sb_h` | 1 | Scoreboard with 4 covergroups + 7-check pass/fail logic |

**connect_phase** wires: `wagt_top[i].agnth.monh.mp` → `sb_h.fifo_h[i].analysis_export`

### Write Agent (`wr_agt_top` → `wr_agent`)

| Component | Role |
|-----------|------|
| `wr_driver` | Drives `Presetn`, `Paddr`, `Psel`, `Pwrite`, `Penable`, `Pwdata` via `drv_cb` (posedge). Reads back `Pready`, `Prdata`, `IRQ`, `baud_o`. |
| `wr_monitor` | Samples all APB signals + `IRQ` + `baud_o` via `mon_cb` (posedge). Publishes `apb_xtn` on analysis port `mp`. |
| `wr_sequencer` | Standard UVM sequencer — arbitrates sequence items to driver. |

### Scoreboard (`sb`)

| Element | Description |
|---------|-------------|
| `fifo_h[0]` | TLM analysis FIFO — receives `apb_xtn` from DUT1 monitor |
| `fifo_h[1]` | TLM analysis FIFO — receives `apb_xtn` from DUT2 monitor |
| `APB_0_cg` | Covergroup — APB signal coverage for DUT1 |
| `APB_1_cg` | Covergroup — APB signal coverage for DUT2 |
| `UART_0_REG_cg` | Covergroup — UART register coverage for DUT1 |
| `UART_1_REG_cg` | Covergroup — UART register coverage for DUT2 |
| `check_phase` | 7-scenario pass/fail check (full-duplex, half-duplex, loopback, parity, break, overrun, framing, timeout) |
| `report_phase` | Prints `no_of_pass` / `no_of_fails` |

---

## 🧾 Test Plan

All tests fork two parallel sequences (one per DUT agent) using `raise_objection` / `drop_objection` around the `fork...join` block.

| Test Class | Sequences | Scenario | Scoreboard Check |
|------------|-----------|----------|-----------------|
| `seq1duplex` | `full_dup_seq1` + `full_dup_seq2` | Both DUTs simultaneously TX and RX — true full-duplex | IIR=0x4 on both; `THR[1]==RBR[2]` AND `THR[2]==RBR[1]` |
| `half_dup_seq_test` | `half_dup_seq1` + `half_dup_seq2` | One DUT transmits, other receives | IIR=0x4 on either; THR of TX DUT == RBR of RX DUT |
| `loop_back_test` | `loop_back_seq1` + `loop_back_seq2` | MCR[4]=1 — DUT receives its own TX | MCR=0x10, IIR=0x4, THR==RBR within same DUT |
| `parity_test` | `parity_seq1` + `parity_seq2` | LCR[3]=1 on both, LCR[4] differs — parity mismatch | LSR parity error bit asserted on receiver |
| `break_error_test` | `break_error_seq1` + `break_error_seq2` | LCR[6]=1 — break condition on TXD | LSR[4] (break error) asserted |
| *(in sb check_phase)* | — | Overrun (17 writes to full FIFO) | LSR[1] asserted |
| *(in sb check_phase)* | — | Framing (mismatched LCR[1:0] word length) | LSR[3] asserted |
| *(in sb check_phase)* | — | THR empty interrupt (IER[1]=1, empty TX FIFO) | IIR=0x2 |
| *(in sb check_phase)* | — | Timeout (IER=0x0, data sits in RX FIFO) | IIR=0xC |

---

## 📊 Functional Coverage

Coverage is collected inside `sb` via 4 covergroups, sampled in `run_phase` on every transaction received from each monitor.

### APB Signal Coverage (`APB_0_cg` / `APB_1_cg`)

| Coverpoint | Bins | Description |
|-----------|------|-------------|
| `PRESETN` | `[0:1]` | Reset asserted and deasserted |
| `PADDR` | `[0:$]` | Full APB address range |
| `PWDATA` | `[0:$]` | Full write data range |
| `PWRITE` / `PSEL` / `PENABLE` | `[0:1]` each | All APB control signal states |
| `PRDATA` | `[0:$]` | Full read data range |
| `PREADY` / `PSLVERR` / `IRQ` / `BAUD_O` | `[0:1]` each | All status and interrupt outputs |

### UART Register Coverage (`UART_0_REG_cg` / `UART_1_REG_cg`)

| Coverpoint | Bins (DUT1 / DUT2) | Description |
|-----------|-------------------|-------------|
| `DIV` | `8'd27` / `16'd54` | Specific divisor values per DUT |
| `LCR` | `0x03, 0x0B, 0x43` / `0x00, 0x03, 0x1B, 0x43` | 8N1, parity configs, break condition |
| `FCR` | `0x06` | FIFO enabled, threshold=1 |
| `IER` | `0x00, 0x02, 0x04, 0x05` | All interrupt enable combinations |
| `IIR[3:0]` | `0x2, 0x4, 0x6, 0xC` | TX empty / RX data / Line status / Timeout |
| `MCR` | `0x10` | Loopback enabled |
| `LSR[0..4]` | `0, 1` each | RX data ready, overrun, parity, framing, break |

### Result

```
Overall Functional Coverage:  91.33%
```

> Remaining ~8.67% gap is in PSLVERR error response paths and unused IER bit combinations not stimulated by directed sequences.

---

## 🔌 TLM Connection Map

| From | To | Transaction | Purpose |
|------|----|-------------|---------|
| `wagt_top[0].agnth.monh.mp` | `sb_h.fifo_h[0].analysis_export` | `apb_xtn` | DUT1 APB transactions to scoreboard |
| `wagt_top[1].agnth.monh.mp` | `sb_h.fifo_h[1].analysis_export` | `apb_xtn` | DUT2 APB transactions to scoreboard |
| `wr_driver.seq_item_port` | `wr_sequencer.seq_item_export` | `apb_xtn` | Driver pulls sequence items |
| `wr_driver.rsp_port` | `wr_sequencer.rsp_export` | `apb_xtn` | Driver response back |

---

## ⏱️ Interface & Clocking Blocks

```
interface uart_if (input bit clk);
  // APB signals + IRQ + baud_o

  clocking drv_cb @(posedge clk);   // Used by wr_driver
    output: Presetn, Paddr, Psel, Pwrite, Penable, Pwdata
    input:  Pready, Pslverr, Prdata, IRQ, baud_o
  endclocking

  clocking mon_cb @(posedge clk);   // Used by wr_monitor
    input:  Presetn, Paddr, Psel, Pwrite, Penable, Pwdata,
            Pready, Pslverr, Prdata, baud_o, IRQ
  endclocking

  modport DRV_MP (clocking drv_cb);
  modport MON_MP (clocking mon_cb);
endinterface
```

> **Note:** TXD and RXD are raw `wire` signals in `top.sv` — they are outside the interface and cross-connected directly between DUT ports.

---

## ▶️ How to Run

### Prerequisites
- UVM-compatible SystemVerilog simulator (Synopsys VCS, Cadence Xcelium, Mentor Questa)
- UVM 1.2 library

### Compile + Run with VCS

```bash
# Compile
vcs -sverilog -ntb_opts uvm-1.2 \
    rtl/uart_fifo.v rtl/uart_tx.v rtl/uart_rx.v \
    rtl/uart_register_file.v rtl/uart_16550.v \
    tb/uart_if.sv tb/top.sv tb/uart_test_pkg.sv \
    +incdir+tb/ -o simv

# Full-duplex test
./simv +UVM_TESTNAME=seq1duplex +UVM_VERBOSITY=UVM_MEDIUM

# Half-duplex test
./simv +UVM_TESTNAME=half_dup_seq_test +UVM_VERBOSITY=UVM_MEDIUM

# Loopback test
./simv +UVM_TESTNAME=loop_back_test +UVM_VERBOSITY=UVM_MEDIUM

# Parity error test
./simv +UVM_TESTNAME=parity_test +UVM_VERBOSITY=UVM_MEDIUM

# Break error test
./simv +UVM_TESTNAME=break_error_test +UVM_VERBOSITY=UVM_MEDIUM

# Dump waveforms
./simv +UVM_TESTNAME=seq1duplex -ucli -do "fsdbDumpvars 0 top; run; exit"
```

### Regression (all tests)

```bash
for test in seq1duplex half_dup_seq_test loop_back_test parity_test break_error_test; do
    echo "Running $test..."
    ./simv +UVM_TESTNAME=$test +UVM_VERBOSITY=UVM_LOW | tee logs/${test}.log
done
```

---

## 📈 Simulation Results

### UVM Topology (from print_topology)

```
uvm_test_top          uart_base_test
  envh                env
    sb_h              sb
      fifo_h[0]       uvm_tlm_analysis_fifo  (DUT1 transactions)
      fifo_h[1]       uvm_tlm_analysis_fifo  (DUT2 transactions)
    wagt_top[0]       wr_agt_top  (DUT1 / clk0)
      agnth           wr_agent
        drvh          wr_driver
        monh          wr_monitor
        seqrh         wr_sequencer
    wagt_top[1]       wr_agt_top  (DUT2 / clk1)
      agnth           wr_agent
        drvh          wr_driver
        monh          wr_monitor
        seqrh         wr_sequencer
```

### Scoreboard Report

```
------------ Scoreboard Report ------------
Number of pass transactions  :  N
Number of fail transactions  :  0
-------------------------------------------
```

---

## 💡 Key Learnings

- **Dual-DUT Cross-Wire Setup** — Connecting two DUT instances with swapped TXD/RXD wires in `top.sv` allows real UART serial communication to be tested without a behavioral model — the DUT itself becomes the loop.

- **Multi-Clock Domain Testbench** — Running DUT1 at 20ns and DUT2 at 10ns and assigning separate `uart_if` instances validates that the APB interface and baud rate generator are truly clock-frequency agnostic.

- **APB FSM Verification** — The 3-state APB FSM (IDLE→SETUP→ACCESS) is implicitly tested through every register read/write, ensuring PREADY and PSLVERR behave correctly on every access.

- **IIR-Based Interrupt Checking** — Using IIR register readback to identify interrupt type (TX empty=0x2, RX data=0x4, Line Status=0x6, Timeout=0xC) in the scoreboard is a clean way to verify interrupt priority logic without needing a dedicated interrupt monitor.

- **Covergroup Sampling in run_phase** — Sampling coverage on every transaction (not just at end of test) ensures that transient states like PSLVERR, IRQ, and baud_o glitches are captured even if they're immediately cleared.

- **check_phase vs run_phase** — Separating data collection (run_phase) from comparison (check_phase) keeps the scoreboard clean and ensures all transactions are in the FIFO before checking begins.

---

## 📄 License

RTL design and testbench structure based on training material from [Maven Silicon](https://www.maven-silicon.com). Extended, verified, and documented as part of a personal learning project.

---

<div align="center">
  <b>Built with ❤️ using SystemVerilog + UVM 1.2</b><br>
  If this helped you, consider giving it a ⭐
</div>
