🔐 Design and Development of a Physical Unclonable Function (PUF) for Hardware Security
## 📖 Overview

This project presents the **design, implementation, evaluation, and ASIC synthesis of a Hybrid XOR-Based Arbiter Physical Unclonable Function (PUF)** for secure hardware authentication.

The system leverages intrinsic silicon manufacturing variations to generate **unique, device-specific digital fingerprints**, eliminating the need for stored cryptographic keys.

The proposed architecture is:

* ✅ Implemented on Basys-3 FPGA (Xilinx Artix-7)
* ✅ Evaluated using statistical performance metrics
* ✅ Integrated with UART-based challenge–response protocol
* ✅ Synthesized for ASIC (180nm CMOS) using Cadence Genus
* ✅ Designed for IoT and resource-constrained systems

---

# 🧠 What is a PUF?

A **Physical Unclonable Function (PUF)** is a hardware security primitive that generates unique responses based on uncontrollable manufacturing variations in integrated circuits.

For a given challenge:

* Same device → Same response
* Different device → Different response

This property makes PUFs ideal for:

* Device authentication
* Secure key generation
* Hardware root-of-trust
* Anti-counterfeiting systems

---

# 🏗️ Implemented Architectures

This project implements and evaluates multiple PUF variants:

* Basic Arbiter PUF
* XOR Arbiter PUF
* 16-Bit XOR Arbiter PUF
* MUX–DEMUX Arbiter PUF
* Proposed Hybrid Architecture (Improved Reliability)

---

# 🚀 Proposed 16-Bit XOR Arbiter PUF

## Architecture Features

* 16-bit challenge input
* 8 parallel Arbiter chains
* XOR-combined final response
* Modular design
* UART interface (9600 baud)

## Why XOR?

Standard Arbiter PUF is linear and vulnerable to machine learning attacks.

XOR-based architecture:

* Introduces non-linearity
* Improves entropy
* Enhances unpredictability
* Increases resistance to modeling attacks

Trade-off:

* Slight reliability reduction under environmental variation.

---

# 🔄 Authentication Protocol

## 1️⃣ Enrollment Phase

* 256 challenges applied
* CRPs collected via UART
* Stored in CSV database
* Reference fingerprint created

## 2️⃣ Authentication Phase

* Same 256 challenges re-applied
* Responses compared
* Match threshold: ≥ 240 / 256

If threshold satisfied → ✅ Authenticated
Else → ❌ Authentication Failed

This threshold accounts for environmental noise and voltage variation.

---

# 📊 Performance Analysis

Performance is evaluated using:

* Uniformity
* Uniqueness (HDinter)
* Randomness (Entropy)
* Reliability (HDintra)

## Measured Results

| Architecture   | Uniformity | Uniqueness | Randomness |
| -------------- | ---------- | ---------- | ---------- |
| Arbiter PUF    | 99.4%      | 0%         | 67%        |
| XOR PUF        | 98.8%      | 30.21%     | 44.21%     |
| 16-Bit XOR PUF | 98.8%      | 35.44%     | 49.5%      |

### Key Observations

* XOR improves uniqueness significantly.
* Hybrid design improves statistical balance.
* Reliability depends on delay margin stability.

---

# 📸 FPGA Implementation Results

> Hardware validation of PUF architecture on Basys-3 FPGA board.

(Add here:)

* Board images
* UART terminal screenshots
* Real-time challenge–response demonstration
* Multi-board comparison photos

---

# 📊 Inter-Chip & Intra-Chip Analysis 


---

Good. If you’re doing hardware security, you don’t hide equations. You show them clearly. It makes your work look serious, not superficial.

Below is your updated **README section with all performance formulas properly written in Markdown (LaTeX format)** so GitHub can render them.

You can paste this directly into your README.

---

# 📊 Performance Analysis & Mathematical Formulation

Performance of the implemented PUF architectures is evaluated using four primary metrics:

* Uniformity
* Uniqueness (HDinter)
* Randomness (Entropy)
* Reliability (HDintra)

---

## 1️⃣ Uniformity

Uniformity measures the balance between `0`s and `1`s in the response bits.

Ideal Value → **50%**

If the response is biased toward 0 or 1, the PUF becomes predictable.

### Formula:

[
Uniformity_a = \frac{1}{n} \sum_{b=1}^{n} r_{a,b} \times 100%
]

Where:

* ( n ) = number of response bits
* ( r_{a,b} ) = b-th bit of response from chip a

Interpretation:

* 50% → Perfect balance
* > 50% or <50% → Bias present

---

## 2️⃣ Uniqueness (Inter-Chip Hamming Distance – HDinter)

Uniqueness evaluates how different responses are between different chips when the same challenge is applied.

Ideal Value → **50%**

### Formula:

[
Uniqueness = \frac{2}{k(k-1)} \sum_{a=1}^{k-1} \sum_{b=a+1}^{k} \frac{HD(Q_a, Q_b)}{n} \times 100%
]

Where:

* ( k ) = number of chips
* ( Q_a, Q_b ) = n-bit responses of chip a and b
* ( HD(Q_a, Q_b) ) = Hamming Distance
* ( n ) = number of response bits

Interpretation:

* 50% → Perfect uniqueness
* <50% → Devices too similar
* > 50% → Excessive variation

---

## 3️⃣ Randomness (Entropy)

Randomness measures unpredictability of PUF responses.

High entropy means responses cannot be predicted.

### Formula:

[
H_n = -\log_2 \left( \max(p_n, 1 - p_n) \right)
]

Where:

* ( p_n ) = probability of occurrence of bit ‘1’
* ( 1 - p_n ) = probability of bit ‘0’

Interpretation:

* Maximum entropy when ( p_n = 0.5 )
* Lower entropy indicates bias

---

## 4️⃣ Reliability (Intra-Chip Hamming Distance – HDintra)

Reliability measures consistency of the same device under environmental variations (temperature, voltage).

Ideal Value → **100%**

### Step 1: Compute HDintra

[
HD_{INTRA_i} = \frac{1}{s} \sum_{t=1}^{s} \frac{HD(Q_i, Q_{i,t})}{n} \times 100%
]

Where:

* ( Q_i ) = reference response
* ( Q_{i,t} ) = response under variation
* ( s ) = number of measurements
* ( n ) = number of bits

### Step 2: Reliability

[
Reliability_i = 100% - HD_{INTRA_i}
]

Interpretation:

* 100% → Perfect stability
* Lower value → Bit flips occurring

---

# 📈 Summary of Ideal Values

| Metric      | Ideal Value     |
| ----------- | --------------- |
| Uniformity  | 50%             |
| Uniqueness  | 50%             |
| Randomness  | Maximum entropy |
| Reliability | 100%            |

---

# 🧮 ASIC Synthesis Results (Area, Power & Timing)

## Technology

* Node: 180nm CMOS
* Tool: Cadence Genus
* Standard Cell Library: tsl18fs120
* Timing Corner: Slow-Slow (SS)

## Flow

RTL → Elaboration → Generic Synthesis → Mapping → Optimization → Netlist → SDF → Reports

## Why ASIC?

| FPGA                  | ASIC              |
| --------------------- | ----------------- |
| Reconfigurable        | Permanent layout  |
| Higher static power   | Lower leakage     |
| Bitstream attack risk | Physically fixed  |
| Prototype-friendly    | Production secure |

ASIC provides stronger unclonability and power efficiency for IoT deployment.

(Add synthesis report summary here:)

* Total Area
* Gate Count
* Leakage Power
* Dynamic Power
* Timing Slack

---

# 📂 Project Structure

```
/rtl
    arbiter_stage.v
    arbiter_cell.v
    xor_puf.v
    top_module.v

/uart
    uart_tx.v
    uart_rx.v

/synthesis
    genus_script.tcl
    constraints.sdc

/results
    performance_metrics.xlsx
    synthesis_reports/

/docs
    PUF_Final_Report.pdf
```

---

# 🔐 Security Features

* No secret key storage
* Hardware-based device fingerprint
* Resistant to cloning
* XOR-based non-linearity
* Threshold-based authentication robustness
* ASIC-level physical immutability

---

# ⚠️ Limitations

* Environmental sensitivity (temperature/voltage)
* XOR increases delay instability
* CRP exposure may enable ML modeling
* No integrated ECC yet

---

# 🔮 Future Work

* Error Correction Code (ECC) integration
* Machine learning attack evaluation
* Strong PUF enhancement
* On-chip key extraction module
* Low-power ASIC optimization
* Full tape-out ready design

---



