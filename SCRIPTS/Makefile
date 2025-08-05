# --- Paths ---
override path       ?= ./
override package     = /home/harsh-khandelwal/UVM/UVM_PROJECT/SV/ENV/package.svh
override interface   = /home/harsh-khandelwal/UVM/UVM_PROJECT/SV/ENV/interrupt_if.sv
override reg_if      = /home/harsh-khandelwal/UVM/UVM_PROJECT/SV/ENV/reg_if.sv
override rtl         = /home/harsh-khandelwal/UVM/UVM_PROJECT/SVE/reg_core.sv
override top         = /home/harsh-khandelwal/UVM/UVM_PROJECT/TOP/tb_top.sv
override WAVES      ?= 0
override TESTNAME   ?= sanity_test  # Default test name
override seed       ?= 100          # Default seed

# --- Sources to Compile ---
SRC = $(package) $(interface) $(reg_if) $(rtl) $(top)

# --- Default Target ---
all: compile sim

# --- Compile Target ---
compile:
	@echo "Compiling: $(SRC)"
	vlog $(SRC) \
		/home/harsh-khandelwal/Downloads/uvm-1.2/src/dpi/uvm_dpi.cc \
		"+incdir+/home/harsh-khandelwal/Downloads/uvm-1.2/src" \
		-ccflags "-Wno-missing-declarations -Wno-maybe-uninitialized -Wno-return-type -Wformat-overflow=0 -DQUESTA"

# --- Simulation Target ---
sim:
	vopt work.tb_top -o tb_opt +acc=rn
ifeq ($(WAVES),1)
	vsim -c work.tb_opt -sv_seed $(seed) -l run.log -do "add wave -r /*; run -all; quit;" +UVM_TESTNAME=$(TESTNAME) 
else
	vsim -c work.tb_opt -sv_seed $(seed) -l run.log -do "run -all; quit;" +UVM_TESTNAME=$(TESTNAME)  
endif

# --- Clean Target ---
clean:
	rm -rf work transcript vsim.wlf *.vcd *.log *.jou *.pb *.vstf
