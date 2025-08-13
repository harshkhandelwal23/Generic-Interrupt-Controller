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

### 1️⃣ Compile
```bash
vlog +incdir+tb +incdir+tb/agents +incdir+tb/env +incdir+tb/interfaces \
     rtl/*.sv tb/top.sv
````

### 2️⃣ Run Simulation

```bash
vsim -c top -do "run -all; quit"
```

(Adjust commands if using a different simulator like `vcs` or `xrun`.)

---
