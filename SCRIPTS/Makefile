# --- Paths ---
override path       ?= ./
#override define     = /home/harsh-khandelwal/UVM/UVM_PROJECT/SV/ENV/defines.svh
override package     = /home/harsh-khandelwal/UVM/UVM_PROJECT/SV/ENV/package.sv
override interface   = /home/harsh-khandelwal/UVM/UVM_PROJECT/SV/ENV/interrupt_if.sv
override reg_if      = /home/harsh-khandelwal/UVM/UVM_PROJECT/SV/ENV/reg_if.sv
override rtl         = /home/harsh-khandelwal/UVM/UVM_PROJECT/SVE/reg_core.sv
override top         = /home/harsh-khandelwal/UVM/UVM_PROJECT/TOP/tb_top.sv
override WAVES      ?= 0
override TESTNAME   ?= sanity_test  # Default test name
override seed       ?= 100          # Default seed
override TRANSACTION_COUNT ?= 1
no_of_sources ?= 0
int_in ?= 1
int_enable ?= 1
int_mask ?= 0
out_mode ?= 0
out_polarity ?= 1
pulse_width ?= 1
override string ?= single_int

# Select configuration based on string
ifeq ($(string),single_int)
    TRANSACTION_COUNT = 1
    no_of_sources    = 10
    int_in           = 1
    int_enable       = 1
    int_mask         = 0
    out_mode         = 0
    out_polarity     = 1
    pulse_width      = 1
    WAVES            = 1
else ifeq ($(string),multi_ints_same_enabled)
    TRANSACTION_COUNT = 1
    no_of_sources    = 10
    int_in           = 1023
    int_enable       = 1023
    int_mask         = 0
    out_mode         = 0
    out_polarity     = 1
    pulse_width      = 1
    WAVES            = 1
else ifeq ($(string),multi_ints_diff_enabled)
    TRANSACTION_COUNT = 1
    no_of_sources    = 10
    int_in           = 471
    int_enable       = 7
    int_mask         = 0
    out_mode         = 0
    out_polarity     = 1
    pulse_width      = 1
    WAVES            = 1
else 
    $(error Unknown string=$(string). Use Another string)
endif
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
	vsim -c work.tb_opt +TRANSACTION_COUNT=$(TRANSACTION_COUNT) +no_of_sources=$(no_of_sources) +int_in=$(int_in) +int_enable=$(int_enable) +int_mask=$(int_mask) +out_mode=$(out_mode) +out_polarity=$(out_polarity) +pulse_width=$(pulse_width) -sv_seed $(seed) -l run.log -do "add wave -r /*; run -all; quit;" +UVM_TESTNAME=$(TESTNAME) 
else
	vsim -c work.tb_opt +TRANSACTION_COUNT=$(TRANSACTION_COUNT) +no_of_sources=$(no_of_sources) +int_in=$(int_in) +int_enable=$(int_enable) +int_mask=$(int_mask) +out_mode=$(out_mode) +out_polarity=$(out_polarity) +pulse_width=$(pulse_width) -sv_seed $(seed) -l run.log -do "run -all; quit;" +UVM_TESTNAME=$(TESTNAME)  
endif

# --- Scenario Target ---
sanity_tc: all
	@echo "Running Scenario 1"
	$(MAKE) string=single_int

	@echo "Running Scenario 2"
	$(MAKE) string=multi_ints_same_enabled

	@echo "Running Scenario 3"
	$(MAKE) string=multi_ints_diff_enabled

# --- Clean Target ---
clean:
	rm -rf work transcript vsim.wlf *.vcd *.log *.jou *.pb *.vstf
