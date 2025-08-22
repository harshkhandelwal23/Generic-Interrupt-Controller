# Generic Interrupt Controller (INTC) UVM Verification Environment

## 📌 Overview
This project implements a complete **UVM-based verification environment** for a generic interrupt controller (INTC) module.  
The DUT supports:
- N-bit interrupt vector input (`int_in`)
- Enable/mask control
- Priority settings
- Level or pulse output modes
- Programmable output polarity
- Configurable pulse width

The verification environment includes **agents**, **monitors**, **drivers**, **scoreboard**, and a **UVM Register Model (RAL)** for configuration and status checking.

---

## 🛠 DUT Specifications
**Main registers:**
| Register Name     | Access | Description |
|-------------------|--------|-------------|
| INT_ENABLE        | RW     | Enable bits per interrupt source |
| INT_MASK          | RW     | Mask bits per interrupt source |
| INT_PRIORITY      | RW     | Priority for each source |
| INT_STATUS        | RO     | Pending interrupt status |
| INT_CLEAR         | WO     | Write-1-to-clear |
| OUT_MODE          | RW     | 0 = Level, 1 = Pulse |
| OUT_POLARITY      | RW     | 0 = Active-Low, 1 = Active-High |
| PULSE_WIDTH       | RW     | Pulse width in clock cycles |

---

## 📂 Directory Structure
```

project\_root/
├── rtl/                # DUT source files
├── tb/                 # Testbench files
│   ├── interfaces/     # int\_if, reg\_if
│   ├── agents/         # reg\_agt, int\_agt
│   ├── env/            # UVM environment, scoreboard
│   ├── sequences/      # reg\_seq, interrupt\_seq
│   ├── tests/          # sanity\_test, other tests
│   └── top.sv          # TB top module
├── docs/               # Documentation
└── README.md           # This file

````

---

## 🚀 How to Run

### 1️⃣ FOR RUNNING with Sanity
make string=single_int seed=500 -C ../SCRIPTS/ (if user wants to run sanity)
make string=multi_ints_same_enabled seed=500 -C ../SCRIPTS/
make string=multi_ints_diff_enabled seed=500 -C ../SCRIPTS/

### 2️⃣ Run Randomly
a = user_oriented(positive values)
b = 2*10-1(max currently)
c = 2*10-1(max currently)
d = 2*10-1(max currently)
make TRANSACTION_COUNT=(a)  no_of_sources=10 int_in=(b) int_enable=(c) int_mask=(d) out_mode=0 out_polarity=1 pulse_width=1 WAVES=(1 or 0) TESTNAME=sanity_test seed=(random) -C ../SCRIPTS/

