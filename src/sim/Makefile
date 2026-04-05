# =============================================================================
# Makefile for UVM UART Testbench (Questa + VCS aligned)
# =============================================================================
#please edit the makefile ..it may be prone to any error
SIMULATOR = VCS
FSDB_PATH=/home/cad/eda/SYNOPSYS/VERDI_2022/verdi/T-2022.06-SP1/share/PLI/VCS/LINUX64

RTL      = ../rtl/*
SVTB_TOP = ../tb/top.sv
SVTB_PKG = ../test/uart_test_pkg.sv

INC = +incdir+../tb \
      +incdir+../test \
      +incdir+../wr_agt_top

work = work

# -----------------------------------------------------------------------------
# Test Names (COMMON for Questa & VCS)
# -----------------------------------------------------------------------------
TEST0 = uart_base_test
TEST1 = seq1duplex
TEST2 = half_dup_seq_test
TEST3 = loop_back_test
TEST4 = parity_test
TEST5 = break_error_test
TEST6 = overrun_error_test
TEST7 = framing_error_test
TEST8 = thr_empty_test
TEST9 = time_out_error_test

# =============================================================================
# HELP
# =============================================================================
help:
	@echo "=============================================================="
	@echo " make clean       -> Clean build"
	@echo " make sv_cmp      -> Compile"
	@echo " make run_test0   -> Base Test (Sanity / Topology)"
	@echo " make run_test1   -> Full Duplex"
	@echo " make run_test2   -> Half Duplex"
	@echo " make run_test3   -> Loopback"
	@echo " make run_test4   -> Parity Error"
	@echo " make run_test5   -> Break Error"
	@echo " make run_test6   -> Overrun Error"
	@echo " make run_test7   -> Framing Error"
	@echo " make run_test8   -> THR Empty"
	@echo " make run_test9   -> Timeout Error"
	@echo " make regress     -> Run all tests"
	@echo "=============================================================="

# =============================================================================
# COMMON TARGETS
# =============================================================================
clean       : clean_$(SIMULATOR)
sv_cmp      : sv_cmp_$(SIMULATOR)

run_test0   : run_test0_$(SIMULATOR)
run_test1   : run_test1_$(SIMULATOR)
run_test2   : run_test2_$(SIMULATOR)
run_test3   : run_test3_$(SIMULATOR)
run_test4   : run_test4_$(SIMULATOR)
run_test5   : run_test5_$(SIMULATOR)
run_test6   : run_test6_$(SIMULATOR)
run_test7   : run_test7_$(SIMULATOR)
run_test8   : run_test8_$(SIMULATOR)
run_test9   : run_test9_$(SIMULATOR)

regress     : regress_$(SIMULATOR)

# =============================================================================
# QUESTA
# =============================================================================

sv_cmp_Questa:
	vlib $(work)
	vmap work $(work)
	vlog -work $(work) $(RTL) $(INC) $(SVTB_PKG) $(SVTB_TOP)

define RUN_QUESTA
vsim -c -coverage -vopt -voptargs=+acc \
     -sv_seed random \
     work.uart_tb_top \
     +UVM_VERBOSITY=UVM_MEDIUM \
     +UVM_TESTNAME=$(1) \
     -do "run -all; coverage save -onexit uart_cov$(2); exit"
vcover report -html uart_cov$(2)
endef

run_test0_Questa: clean sv_cmp ; $(call RUN_QUESTA,$(TEST0),0)
run_test1_Questa: clean sv_cmp ; $(call RUN_QUESTA,$(TEST1),1)
run_test2_Questa: clean sv_cmp ; $(call RUN_QUESTA,$(TEST2),2)
run_test3_Questa: clean sv_cmp ; $(call RUN_QUESTA,$(TEST3),3)
run_test4_Questa: clean sv_cmp ; $(call RUN_QUESTA,$(TEST4),4)
run_test5_Questa: clean sv_cmp ; $(call RUN_QUESTA,$(TEST5),5)
run_test6_Questa: clean sv_cmp ; $(call RUN_QUESTA,$(TEST6),6)
run_test7_Questa: clean sv_cmp ; $(call RUN_QUESTA,$(TEST7),7)
run_test8_Questa: clean sv_cmp ; $(call RUN_QUESTA,$(TEST8),8)
run_test9_Questa: clean sv_cmp ; $(call RUN_QUESTA,$(TEST9),9)

regress_Questa:
	make run_test0_Questa run_test1_Questa run_test2_Questa run_test3_Questa \
	     run_test4_Questa run_test5_Questa run_test6_Questa \
	     run_test7_Questa run_test8_Questa run_test9_Questa

clean_Questa:
	rm -rf work transcript *.wlf uart_cov* *.log
	clear

# =============================================================================
# VCS
# =============================================================================

sv_cmp_VCS:
	vcs -l vcs.log -full64 -sverilog -timescale=1ns/1ps \
	    -ntb_opts uvm -debug_access+all -kdb -lca \
	    -cm assert \
	    -P $(FSDB_PATH)/novas.tab $(FSDB_PATH)/pli.a \
	    $(RTL) $(INC) $(SVTB_PKG) $(SVTB_TOP)

define RUN_VCS
	./simv +fsdbfile+wave$(2).fsdb \
	       +ntb_random_seed_automatic \
	       +UVM_VERBOSITY=UVM_MEDIUM \
	       +UVM_TESTNAME=$(1) \
	       -cm_dir uart_cov$(2)
	urg -dir uart_cov$(2).vdb -format both -report urgReport$(2)
endef

run_test0_VCS: sv_cmp ; $(call RUN_VCS,$(TEST0),0)
run_test1_VCS: sv_cmp ; $(call RUN_VCS,$(TEST1),1)
run_test2_VCS: sv_cmp ; $(call RUN_VCS,$(TEST2),2)
run_test3_VCS: sv_cmp ; $(call RUN_VCS,$(TEST3),3)
run_test4_VCS: sv_cmp ; $(call RUN_VCS,$(TEST4),4)
run_test5_VCS: sv_cmp ; $(call RUN_VCS,$(TEST5),5)
run_test6_VCS: sv_cmp ; $(call RUN_VCS,$(TEST6),6)
run_test7_VCS: sv_cmp ; $(call RUN_VCS,$(TEST7),7)
run_test8_VCS: sv_cmp ; $(call RUN_VCS,$(TEST8),8)
run_test9_VCS: sv_cmp ; $(call RUN_VCS,$(TEST9),9)

regress_VCS: clean_VCS sv_cmp_VCS \
	run_test0_VCS run_test1_VCS run_test2_VCS run_test3_VCS \
	run_test4_VCS run_test5_VCS run_test6_VCS \
	run_test7_VCS run_test8_VCS run_test9_VCS

clean_VCS:
	rm -rf simv* csrc* *.vdb *.fsdb *.log urgReport*
	clear

