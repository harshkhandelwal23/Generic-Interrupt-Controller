# --- Paths ---
override path       ?= ./
#override define     = /home/harsh-khandelwal/UVM/UVM_PROJECT/SV/ENV/defines.svh
override package     = /home/harsh-khandelwal/UVM/UVM_PROJECT/SV/ENV/package.svh
override interface   = /home/harsh-khandelwal/UVM/UVM_PROJECT/SV/ENV/interrupt_if.sv
override reg_if      = /home/harsh-khandelwal/UVM/UVM_PROJECT/SV/ENV/reg_if.sv
override rtl         = /home/harsh-khandelwal/UVM/UVM_PROJECT/SVE/reg_core.sv
override top         = /home/harsh-khandelwal/UVM/UVM_PROJECT/TOP/tb_top.sv
override WAVES      ?= 0
override TESTNAME   ?= sanity_test  # Default test name
override seed       ?= 100          # Default seed
override TRANSACTION_COUNT ?= 1
override int_exp_pkt ?= 0
override reg_exp_pkt ?= 0
override out_exp_pkt ?= 0
override no_of_sources ?= 0
override int_in ?= 1
override int_enable ?= 1
override int_mask ?= 0
override out_mode ?= 0
override out_polarity ?= 1
override pulse_width ?= 1

# --- Sources to Compile ---
SRC = $(package) $(interface) $(reg_if) $(rtl) $(top)

# --- Default Target ---
all: compile sim run

# --- Compile Target ---
compile:
	@echo "Compiling: $(SRC)"
	vlog $(SRC) \
		/home/harsh-khandelwal/Downloads/uvm-1.2/src/dpi/uvm_dpi.cc \
		"+incdir+/home/harsh-khandelwal/Downloads/uvm-1.2/src" \
		-ccflags "-Wno-missing-declarations -Wno-maybe-uninitialized -Wno-return-type -Wformat-overflow=0 -DQUESTA"

# --- Simulation Target ---
sim:
	vopt work.tb_top -o tb_opt +acc=arn

run: 
ifeq ($(WAVES),1)
	vsim -c work.tb_opt +TRANSACTION_COUNT=$(TRANSACTION_COUNT) +int_exp_pkt=$(int_exp_pkt) +reg_exp_pkt=$(reg_exp_pkt) +out_exp_pkt=$(out_exp_pkt) +no_of_sources=$(no_of_sources) +int_in=$(int_in) +int_enable=$(int_enable) +int_mask=$(int_mask) +out_mode=$(out_mode) +out_polarity=$(out_polarity) +pulse_width=$(pulse_width) -sv_seed $(seed) -l run.log -do "add wave -r /*; run -all; quit;" +UVM_TESTNAME=$(TESTNAME) 
else
	vsim -c work.tb_opt +TRANSACTION_COUNT=$(TRANSACTION_COUNT) +int_exp_pkt=$(int_exp_pkt) +reg_exp_pkt=$(reg_exp_pkt) +out_exp_pkt=$(out_exp_pkt) +no_of_sources=$(no_of_sources) +int_in=$(int_in) +int_enable=$(int_enable) +int_mask=$(int_mask) +out_mode=$(out_mode) +out_polarity=$(out_polarity) +pulse_width=$(pulse_width) -sv_seed $(seed) -l run.log -do "run -all; quit;" +UVM_TESTNAME=$(TESTNAME)  
endif

# --- Scenario Target ---
sanity_tc: all
	@echo "Running Scenario 1"
	$(MAKE) TRANSACTION_COUNT=1 int_exp_pkt=1 reg_exp_pkt=12 out_exp_pkt=1 \
	        no_of_sources=10 int_in=1 int_enable=1 int_mask=0 out_mode=0 \
	        out_polarity=1 pulse_width=1 WAVES=1 TESTNAME=sanity_test seed=$(seed) 

	@echo "Running Scenario 2"
	$(MAKE) TRANSACTION_COUNT=1 int_exp_pkt=1 reg_exp_pkt=12 out_exp_pkt=1 \
	        no_of_sources=10 int_in=471 int_enable=471 int_mask=0 out_mode=0 \
	        out_polarity=1 pulse_width=1 WAVES=1 TESTNAME=sanity_test seed=$(seed)

	@echo "Running Scenario 3"
	$(MAKE) TRANSACTION_COUNT=1 int_exp_pkt=1 reg_exp_pkt=12 out_exp_pkt=1 \
	        no_of_sources=10 int_in=471 int_enable=7 int_mask=0 out_mode=0 \
	        out_polarity=1 pulse_width=1 WAVES=1 TESTNAME=sanity_test seed=$(seed)

# --- Clean Target ---
clean:
	rm -rf work transcript vsim.wlf *.vcd *.log *.jou *.pb *.vstf
