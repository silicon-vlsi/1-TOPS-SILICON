 # 8-Bit Binary-Weighted Current Steering DAC

> **Project:** 8-Bit Binary-Weighted Current Steering DAC — Analog Peripheral of a RISC-V SoC  
> **Technology:** 0.13 µm CMOS (SKY130) | **Supply:** 1.8 V | **Tool:** xschem + ngspice  
> **References:** Razavi (2018), Deveugele & Steyaert (2006), Mercer (2007), Murmann & Jespers (2017), Silveira et al. (1996)

---
## 1-TOPS proposed architecture   

<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/75508664f0830c82739f57189771d07b50ff45a8/ANALOG_PERIPHERAL/DAC/media/1tops_architecture.jpeg" title="Figure 3" height="350" width="3000">
<p align="center"> Figure 1: Top level Architecture</p>

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [What is a DAC?](#2-what-is-a-dac)
3. [DAC Architectures — Comparative Study](#3-dac-architectures--comparative-study)
4. [Why Current Steering?](#4-why-current-steering)
5. [Binary-Weighted vs Thermometer-Coded](#5-binary-weighted-vs-thermometer-coded)
6. [Why Binary Weighted?](#6-why-binary-weighted)
7. [Single Switch vs Differential Current Steering](#7-single-switch-vs-differential-current-steering)
8. [The Current Cell — Razavi's Cascode Switch Concept](#8-the-current-cell--razavis-cascode-switch-concept)
9. [Current Mirror Architectures](#9-current-mirror-architectures)
10. [Why Wide-Swing Cascode Current Mirror?](#10-why-wide-swing-cascode-current-mirror)
11. [Choosing the Reference Current — Why 4 µA?](#11-choosing-the-reference-current--why-4-µa)
12. [Transistor Sizing via the gm/ID Methodology](#12-transistor-sizing-via-the-gmid-methodology)
13. [gm/ID Design Tradeoff Table](#13-gmid-design-tradeoff-table)
14. [Complete Transistor Sizing Table](#14-complete-transistor-sizing-table)
15. [Bit-Weighting and Current Mapping](#15-bit-weighting-and-current-mapping)
16. [Input Switching — Digital Control](#16-input-switching--digital-control)
17. [Circuit Architecture and Operation](#17-circuit-architecture-and-operation)
18. [Simulation Results](#17-simulation-results)
19. [Performance Summary](#18-performance-summary)
20. [References](#19-references)

---

## 1. Project Overview

This project is an 8-bit Binary-Weighted Current Steering DAC designed as an analog peripheral of a **RISC-V System-on-Chip (SoC)**. The CPU writes an 8-bit digital word to a DAC register via the APB bus, and the DAC converts it into a proportional analog current output for driving external analog circuits.

```
RISC-V CPU  ──APB Bus──>  DAC Register  ──>  8-Bit Current Steering DAC  ──>  Analog Output
             (digital)                         (this design)                   (0V to 1.2V)
```

**Design Targets:**

| Parameter | Specification |
|-----------|--------------|
| Resolution | 8 bits (256 levels) |
| Output Range | 0 V to 1.2 V |
| LSB Step Size | ~4.7 mV |
| Power | Low (µA-range currents) |
| Frequency | Low (SoC peripheral, not RF) |
| Supply | 1.8 V |
| Technology | 0.13 µm CMOS (SKY130 TT models) |
| Integration | Fully on-chip — no op-amps, no external components |
| Offset Error Spec | ≤ ±0.5 LSB (≤ ±2.35 mV) |

---

## 2. What is a DAC?
<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/a28a87e40f93ffea5176bf63c7f3740d4254a496/ANALOG_PERIPHERAL/DAC/media/pg1.jpeg" title="Figure 3" height="400" width="350">
A Digital-to-Analog Converter (DAC) is a circuit that translates a discrete digital binary code into a continuous analog quantity — typically a voltage or current.

In a digital system, a processor works with binary numbers. In the real world, signals are analog — voltages, currents, sounds, sensor readings. A DAC bridges this gap: it takes a number written by a CPU and produces a proportional physical signal that can drive speakers, actuators, displays, sensors, or any analog load.

##  Understanding DAC Using an Inverting Amplifier

The working of a DAC can be understood using a simple **inverting op-amp**
  
<table>
  <tr>
    <td align="center">
       <img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/16f2fbcd73452b5dc65e5f006eaa1463f8775409/ANALOG_PERIPHERAL/DAC/media/pg2.jpeg" width="300"/>
    </td>
    <td align="center">
        <img src="https://latex.codecogs.com/svg.image?\color{white}V_{out}=-\frac{R_f}{R}\cdot%20V_{in}" />
    </td>
  </tr>
</table>


- The output voltage depends on the resistor **R**.

- Different binary inputs (01, 10, …) change the resistance, which in turn changes the output voltage.

- Each digital value produces a corresponding **analog output level**.

- Increasing the digital input results in a **step-wise change**, forming an analog signal.
 
<table>
  <tr>
    <td align="center">
      <img src="https://raw.githubusercontent.com/amitops2103/1-TOPS-SILICON-ANALOG/e0f594d322899db0fb4607fe2d18a6702004477f/ANALOG_PERIPHERAL/DAC/media/pg3.jpeg" height="200" width="350"/>
    </td>
    <td align="center">
      <img src="https://raw.githubusercontent.com/amitops2103/1-TOPS-SILICON-ANALOG/e0f594d322899db0fb4607fe2d18a6702004477f/ANALOG_PERIPHERAL/DAC/media/pg4.jpeg" height="200" width="350"/>
    </td>
  </tr>
</table>

### Transfer Function

For an N-bit DAC:

```
V_out = (Digital Code / 2^N) × V_ref

For our 8-bit design:
  V_out = (code / 256) × 1.2V
  Code 0x00 → 0V
  Code 0x80 → 0.6V  (midscale)
  Code 0xFF → 1.2V  (full scale)
```

### Key Performance Metrics

| Metric | What it Measures |
|--------|-----------------|
| **Resolution** | Number of discrete steps = 2^N |
| **LSB Size** | Smallest output step = Full Scale / (2^N − 1) |
| **Offset Error** | Deviation of actual output at code 0x00 from ideal 0V |
| **Gain Error** | Deviation of full-scale slope from ideal |
| **INL** | Max deviation of actual transfer curve from ideal straight line |
| **DNL** | Max deviation of any single step from ideal 1-LSB step |
| **Monotonicity** | Output always increases as code increases (requires DNL > −1 LSB) |
| **Settling Time** | Time for output to reach within ½ LSB of final value |

---

## 3. DAC Architectures — Comparative Study

Five standard DAC architectures were evaluated against our design constraints before committing to a topology.

---

### 3.1 Binary-Weighted Resistor DAC
<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/b37bbd1a474572099c1bdd84b80482b0e002b3e2/ANALOG_PERIPHERAL/DAC/media/pg05.jpeg" title="Figure 3" height="400" width="350">
Each bit drives a resistor scaled R, 2R, 4R, 8R… Currents sum at a virtual-ground node via an op-amp.


| Pros | Cons |
|------|------|
| Conceptually simple | Requires 128:1 resistor ratio for 8 bits |
| Fast settling | On-chip resistor matching extremely difficult beyond 4–6 bits |
| | Mandatory op-amp adds power, area, offset |
| | INL/DNL degrade badly with resistor mismatch |

**Eliminated:** The 128:1 resistor spread is impractical in standard CMOS. On-chip resistors have ~20% absolute accuracy and ~0.1% matching — causing significant linearity errors at 8-bit resolution.

---

### 3.2 R-2R Ladder DAC

Uses only two resistor values (R and 2R) in a ladder network. Thevenin resistance at any node is always R — fully scalable.

<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/bff1e1911556137de1c08ef851150cae5b1c5a3a/ANALOG_PERIPHERAL/DAC/media/pg6.jpeg" title="Figure 3" height="400" width="350">

| Pros | Cons |
|------|------|
| Only two resistor values | Output impedance varies with digital code |
| No exponential resistor spread | Requires buffer op-amp to prevent output loading |
| Scales easily | RC ladder delay limits speed |

**Eliminated:** Code-dependent output impedance and the mandatory buffer op-amp conflict with low-power, no-external-components requirements.

---

### 3.3 Capacitive (Charge Redistribution) DAC
<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/85de1a0cc8e151a77f9703ca101b43846e1c9ce7/ANALOG_PERIPHERAL/DAC/media/pg23.jpeg" title="Figure 3" height="400" width="350">
Binary-weighted capacitor array. Reference voltage charges/discharges caps proportionally. Core of SAR ADC architectures.

```
V_out = (C_eq / C_net) × V_ref
```

| Pros | Cons |
|------|------|
| Zero static power | Large cap array for 8 bits — area intensive |
| Natural fit for SAR ADCs | Speed limited by RC redistribution |
| | Capacitor mismatch limits linearity |
| | Not a continuous-time output DAC |

**Eliminated:** Sampled-data architecture — produces a held voltage on a capacitor, not a continuously available output. Unsuitable as a standalone output peripheral.

---

### 3.4 Sigma-Delta (ΣΔ) DAC
<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/85de1a0cc8e151a77f9703ca101b43846e1c9ce7/ANALOG_PERIPHERAL/DAC/media/pg22.jpeg" title="Figure 3" height="400" width="350">
<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/a40e809444a5d70f089dd7fd9a9a4c794a75556e/ANALOG_PERIPHERAL/DAC/media/pg24.jpeg "title="Figure 3" height="350" width="350">
Oversampling + noise shaping. 1-bit DAC runs at N× signal frequency. Low-pass filter recovers high-resolution analog output.

```
Digital Input ──> [ΣΔ Modulator] ──> [1-bit DAC] ──> [Reconstruction Filter] ──> V_out
```

| Pros | Cons |
|------|------|
| Very high resolution achievable | High latency — oversampling + filter group delay |
| Relaxed analog matching | Narrow bandwidth |
| | Complex digital modulator |
| | Incompatible with low-latency APB register writes |

**Eliminated:** Incompatible with the SoC model. CPU writes 8-bit value → expects immediate analog output. ΣΔ filtering latency cannot be reconciled with direct register-mapped operation.

---

### 3.5 Current Steering DAC ✅ Selected
<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/9520e48fe60d0eddfb5302fb9fabe2a1e5fa34c0/ANALOG_PERIPHERAL/DAC/media/pg7.jpeg" title="Figure 3" height="400" width="350">
Each bit controls a dedicated current source. Current is steered between output nodes via a differential switch pair — never switched off.

| Pros | Cons |
|------|------|
| MOSFET is a natural current source — no resistors needed | Output swing limited by current source headroom |
| No op-amp or buffer required | Output impedance must be very high for good linearity |
| Total supply current nearly constant — low noise injection | Requires careful layout for matching |
| Fast switching — no large RC nodes | |
| Scales cleanly with CMOS processes | |

---

## 4. Why Current Steering?

Three fundamental properties made current steering the only viable candidate.

### 4.1 Native CMOS — No Passive Components

A MOSFET biased in saturation **is** a current source:

```
I_D = (1/2) × µ_n × C_ox × (W/L) × V_ov²
```

The entire DAC is built from transistors only — compact, process-compatible, no special process options needed.

### 4.2 No Buffer Amplifier Required

The high-impedance current output drives the load resistor directly to produce voltage. This eliminates the op-amp — removing its power consumption, area, offset, and bandwidth limitations. Critical for a low-power SoC peripheral.

### 4.3 Constant Total Supply Current → Minimal Noise Injection

Each current source is **always active** — current is steered between output nodes, never switched off. Total current drawn from VDD is nearly constant regardless of the digital input code.

In a mixed-signal SoC, digital switching causes supply current transients that appear as noise. If the DAC itself draws code-dependent current, every code change injects a glitch into the supply. Constant total current eliminates this mechanism — essential when analog and digital domains share the same chip.

---

## 5. Binary-Weighted vs Thermometer-Coded 

### 5.1 Thermometer-Coded
<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/bb991eb830d8bc0a754f1f083c8b1f9e94ca2d75/ANALOG_PERIPHERAL/DAC/media/pg8.jpeg" title="Figure 3" height="400" width="350">

8-bit binary decoded to 255-bit thermometer code. Each bit drives one identical unit current source.

| Metric | Thermometer Coded |
|--------|-----------------|
| Current sources needed | **255 for 8 bits** |
| Decoder required | Yes — 8-to-255 decoder |
| Monotonicity | Guaranteed by construction |
| DNL | Excellent — each step adds exactly one unit source |
| Glitch at major carry | None — only one source changes per step |
| Area | Very large |
| Routing complexity | Extremely high |

### 5.2 Binary Weighted
<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/bb991eb830d8bc0a754f1f083c8b1f9e94ca2d75/ANALOG_PERIPHERAL/DAC/media/pg7.jpeg" title="Figure 3" height="400" width="350">

Each of the N bits directly controls a current source scaled to 2^k × I_unit. No decoder needed.

| Metric | Binary Weighted |
|--------|----------------|
| Current sources needed | **8 for 8 bits** |
| Decoder required | **No** — bits drive switches directly |
| Monotonicity | Depends on matching |
| DNL | Can degrade at MSB transition |
| Glitch at major carry (0x7F→0x80) | Present |
| Area | Minimal |
| Routing complexity | Minimal |

---

## 6. Why Binary Weighted?

**Reason 1 — Direct SoC Compatibility:**
The RISC-V CPU writes a natural 8-bit binary value to the DAC register via APB. Each bit **directly drives** its corresponding switch — no decoder. A thermometer DAC needs an 8-to-255 decoder between CPU and switches, adding area, power, and timing skew. For a simple SoC peripheral, this complexity is unjustified.

**Reason 2 — 255 Branches is Impractical:**
An 8-bit thermometer DAC needs 255 matched current sources, 255 switch pairs, a 255-output decoder, and common-centroid placement of all 255 cells. Binary weighting achieves identical resolution with 8 current sources.

**Reason 3 — Glitch Energy is Irrelevant at Low Frequency:**
The major-carry glitch (0x7F→0x80) matters in high-speed RF DACs where it folds into the signal band. Our DAC is **low frequency** — the output fully settles within each clock period and the glitch decays before the next transition. This disadvantage simply does not apply.

---
## 7. Single Switch vs Differential Current Steering

<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/bb991eb830d8bc0a754f1f083c8b1f9e94ca2d75/ANALOG_PERIPHERAL/DAC/media/pg9.jpeg" title="Figure 3" height="400" width="350">

### The Problem with Simple Current Switching

A naive current cell would connect a current source to a switch MOSFET and turn it on/off. When the switch turns off, the current source node collapses — the source has nowhere to send its current. When the switch turns on again, the parasitic capacitance at that node must charge back up, drawing a large transient current and injecting glitch energy on every transition.

---
## 8. Solution — Razavi's Differential Pair Switch

<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/bb991eb830d8bc0a754f1f083c8b1f9e94ca2d75/ANALOG_PERIPHERAL/DAC/media/pg10.jpeg" title="Figure 3" height="400" width="350">


### The Razavi Insight: Always Steer, Never Switch Off

Instead of switching the current source off, the current **always flows** and is simply *directed* between two complementary output nodes using a differential pair:


- `bit = 1` → M1 ON, M2 OFF → current goes to I_out+
- `bit = 0` → M1 OFF, M2 ON → current goes to I_out−

- `bit = 1, bit_bar = 0` → M1 ON, M2 OFF → current flows to I_out+
- `bit = 0, bit_bar = 1` → M1 OFF, M2 ON → current flows to I_out−

---
## 9. Current Mirror Architectures

Three current mirror topologies were evaluated to distribute the 4 µA reference to all 8 bit branches.

### 9.1 Simple Current Mirror
<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/bb991eb830d8bc0a754f1f083c8b1f9e94ca2d75/ANALOG_PERIPHERAL/DAC/media/pg11.jpeg" title="Figure 3" height="350" width="350">

**Operation:**

- A current *Iref* is forced through M1, this sets Vgs₁. Gate of M1 = Gate of M2 ⟹ **Vgs₁ = Vgs₂**
- Since both transistors are identical: ***Iout ≈ Iref***
- Both transistors must be in saturation region. Condition: **Vds ≥ Vgs − Vt**

**Disadvantages:**

- Low output resistance → current varies with Vout
- Channel length modulation → non-linear output (INL/DNL errors)
- Poor current matching between branches
- Not accurate for precision DAC applications

**Conclusion:** Output impedance is only r_ds (~50 kΩ). Channel-length modulation makes I_out vary with V_DS — current changes as output voltage swings. This produces code-dependent INL errors. Unacceptable for a precision DAC.

---

### 9.2 Cascode Current Mirror
<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/bb991eb830d8bc0a754f1f083c8b1f9e94ca2d75/ANALOG_PERIPHERAL/DAC/media/pg12.jpeg" title="Figure 3" height="400" width="350">

**Operation:**

- Iref flows through M1, sets Vgs₁ so **Vgs₁ = Vgs₂**, therefore ***Iout ≈ Iref***
- M3 & M4 keep Vds of M1 & M2 constant, which shields the mirror from output voltage variations
- Output current becomes almost independent of Vout

**Disadvantages:**

- Requires high voltage headroom → not suitable for low-voltage design
- Reduces output voltage swing → limits DAC output range
- Stacked transistors need more Vds → difficult to keep all in saturation
- Not ideal for low-power, low-supply systems

**Conclusion:** Output impedance g_m × r_ds² (~5 MΩ) is much better, but requires V_DS_sat + V_GS ≈ 1.0–1.2 V of headroom just for biasing. On a 1.8 V supply, this leaves insufficient room for the output swing and switch stack.

---

### 9.3 Wide-Swing Cascode Current Mirror ✅ Selected
<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/bb991eb830d8bc0a754f1f083c8b1f9e94ca2d75/ANALOG_PERIPHERAL/DAC/media/pg13.jpeg" title="Figure 3" height="400" width="350">

**Operation:**

- M1 is diode-connected with 4 µA, generates Vgs
- Gates of M3 & M4 are tied to M1 so **I3 ≈ I4 ≈ Iref**
- M2 (Vt + 2Von) and M5 (Vt + Von) act as cascode to keep Vds of mirror transistors constant
- M6 provides output: ***Iout ≈ Iref* (4 µA)**
- Biasing ensures: **Minimum Vout ≈ Von**


**Conclusion:** Self-generated bias sets the cascode gate voltage so that the bottom transistor operates **at exactly the edge of saturation** — using minimum V_DS = V_ov. This recovers the headroom cost while retaining the same high output impedance.


**Key properties:**
- Output impedance: g_m × r_ds² — same as simple cascode
- Minimum output voltage: 2 × V_ov ≈ 0.5 V — maximizes output swing
- Bias: self-contained — no external bias generator required

---

## 10. Why Wide-Swing Cascode Current Mirror?

| Mirror Type | Output Impedance | Min V_out | External Bias | Verdict |
|-------------|-----------------|-----------|---------------|---------|
| Simple | r_ds (~50 kΩ) | V_DS_sat | None | Insufficient Z_out for DAC linearity |
| Cascode | g_m r_ds² | ~1.0–1.2 V | Required | Headroom too high for 1.8V supply |
| **Wide-Swing Cascode** | **g_m r_ds²** | **~0.5 V** | **Self-generated** | ✅ Selected |

- Reduces voltage headroom requirement (minimum V_out ≈ V_on)
- Keeps all transistors in saturation
- Maintains very high output resistance
- Provides accurate and constant current replication
- Allows larger output swing — essential for DAC linearity

---

## 11. Choosing the Reference Current — Why 4 µA?

The reference current of **4 µA** emerged from three converging constraints — not an arbitrary choice.

### Constraint 1 — Low Power Target

```
I_total_max = 4 µA × 255 = 1.02 mA  (all bits ON, code 0xFF)
```

Sensible for a low-power peripheral — usable output voltage, total dissipation well under 2 mW.

### Constraint 2 — gm/ID Methodology Naturally Gives 4 µA

The transistor sizing (Section 12) uses gm/ID = 8 with layout-friendly dimensions W = 3 µm, L = 2.2 µm:

```
I_D = (1/2) × µ_n × C_ox × (W/L) × V_ov²
    = (1/2) × 180 µA/V² × (3/2.2) × (0.25)²
    ≈ 3.78 µA ≈ 4 µA
```

The methodology **naturally arrives at 4 µA**. We accepted what the physics gave — a clean, process-justified result rather than distorting transistor sizes to hit an arbitrary current.

### Constraint 3 — Output Swing is Well-Suited to 1.8 V Supply

```
V_out_max = 255 × 1 µA × 4.7 kΩ = 1.2 V   (well within 1.8V supply with comfortable headroom)
```

### Why Not Other Values?

| I_LSB | W/L Required | Problem |
|-------|-------------|---------|
| 1 µA | ~0.18 | Extremely narrow — edge effects dominate, very poor matching |
| 2 µA | ~0.35 | Small — matching concerns remain |
| **4 µA** | **~0.71 → W=3 µm, L=2.2 µm** | **Layout-friendly, excellent matching ✅** |
| 10 µA | ~1.78 | Total I_max ≈ 2.5 mA — unnecessarily high power |

**Why is 4 µA fed into the current mirror reference specifically?**
The mirror reference is set to 4 µA because this is the unit cell current from the sizing methodology. All 8 bit currents are integer multiples of this single reference — if the reference drifts with temperature, all outputs drift proportionally, preserving relative accuracy and linearity. The reference naturally sits at Bit 2 in the weight table (4 µA = 2² × I_LSB).

---

## 12. Transistor Sizing via the gm/ID Methodology

### What is gm/ID?
<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/bb991eb830d8bc0a754f1f083c8b1f9e94ca2d75/ANALOG_PERIPHERAL/DAC/media/pg14.jpeg" title="Figure 3" height="400" width="350">

gm/ID is the transconductance efficiency — gm per unit bias current. It continuously spans all operating regions:


| gm/ID (V⁻¹) | Region  | Best For |
|-------|-------------|---------|
| 25–35 | Weak inversion | Ultra-low power |
| 8–20 | Moderate inversion | Speed-power trade-off |
| 2–8 | Strong inversion | Matching, speed |

              
             
               


Core equation (strong inversion):

```
gm/ID = 2 / V_ov    where V_ov = V_GS − V_th
```

### Why gm/ID = 8 for Current Source Transistors?

Current sources must be **well-matched**. The dominant error is threshold mismatch :

```
σ(V_th) = A_VTH / √(W × L)

Fractional current error:
σ(I_D) / I_D = (gm/ID) × σ(V_th)
```

**Lower gm/ID = lower sensitivity to V_th mismatch = better current matching.**

gm/ID = 8 gives V_ov = 0.25 V — robustly in saturation, minimized mismatch sensitivity, good linearity.

### Step-by-Step Sizing

```
Process: 0.18 µm CMOS (SKY130)
  µ_n × C_ox = 180 µA/V²
  V_th (NMOS) = 0.51 V
  Target I_D  = 4 µA

Step 1 — Gate overdrive:
  V_ov = 2 / (gm/ID) = 2 / 8 = 0.25 V

Step 2 — Gate-source voltage:
  V_GS = V_th + V_ov = 0.51 + 0.25 = 0.76 V

Step 3 — W/L from drain current equation:
  W/L = (2 × I_D) / (µ_n × C_ox × V_ov²)
      = (2 × 4×10⁻⁶) / (180×10⁻⁶ × 0.0625)
      = 0.711

Step 4 — Physical dimensions:
  L = 2.2 µm  (long channel — see reasons below)
  W = 0.711 × 2.2 = 1.56 µm → rounded to W = 3 µm (layout-friendly)

Step 5 — Verify:
  I_D = (1/2) × 180×10⁻⁶ × (3/2.2) × (0.25)²
      ≈ 3.78 µA ≈ 4 µA  ✓ CONFIRMED
```


---

## 13. gm/ID Design Tradeoff Table

Different circuit blocks in the DAC require different gm/ID operating points:

| Circuit Block | gm/ID Range | Region | Why This Choice |
|---------------|-------------|--------|-----------------|
| **Current Mirror** | 7–10 | Moderate/Strong inversion | Stable current generation; low noise sensitivity; good linearity in DAC |
| **Differential Pair (Switches)** | 10–20 | Moderate/Weak inversion | High transconductance; higher gain; better sensitivity to small signals |
| **Switches S1, S2** | Not critical | Strong inversion | Fast switching; low ON-resistance |
| **Bias Transistors** | 8–12 | Moderate inversion | Balance between power and stability |

---

## 14. Complete Transistor Sizing Table

Base unit cell: **W = 3 µm, L = 2.2 µm**. Binary-weighted currents are achieved by connecting M unit cells in parallel — all physical transistors are identical for best matching.

### Current Mirror and Current Source Transistors
<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/bb991eb830d8bc0a754f1f083c8b1f9e94ca2d75/ANALOG_PERIPHERAL/DAC/media/pg15.jpeg" title="Figure 3" height="600" width="350">


| Transistor | Role | L (µm) | W (µm) | Multiplier M |
|------------|------|---------|---------|-------------|
| pcm1 | Wide-swing cascode mirror — reference leg | 2.2 | 3 | 3 |
| pcm2 | Wide-swing cascode mirror — cascode leg | 2.2 | 3 | 3 |
| pcm3 | Wide-swing cascode mirror — output leg | 2.2 | 3 | 3 |
| n1 | Bit 0 (LSB) current source | 2.2 | 3 | 1 |
| n2 | Bit 1 current source | 2.2 | 3 | 1 |
| n3 | Bit 2 current source | 2.2 | 3 | 1 |
| n4 | Bit 3 current source | 2.2 | 3 | 1 |
| n5 | Bit 4 current source | 2.2 | 3 | 1 |
| n6 | Bit 5 current source | 2.2 | 3 | 1 |
| n7 | Bit 6 current source | 2.2 | 3 | 1 |
| n8 | Bit 7 (MSB) current source | 2.2 | 3 | 1 |
| n9, n10, n11 | Mirror bias cells | 2.2 | 3 | 32 |
| n12, n13, n14 | Mirror bias cells | 2.2 | 3 | 16 |

### Switch Transistors
<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/bb991eb830d8bc0a754f1f083c8b1f9e94ca2d75/ANALOG_PERIPHERAL/DAC/media/pg16.jpeg" title="Figure 3" height="400" width="350">

| Transistor | Role | L (µm) | W (µm) |
|------------|------|---------|---------|
| S1 (per bit) | Switch — bit side (M1) | 2.2 | 0.2 |
| S2 (per bit) | Switch — bit_bar side (M2) | 2.2 | 1.2 |

Switch transistors use near-minimum width to minimize parasitic capacitance at node X. Fast switching, low glitch. The slight size asymmetry between S1 and S2 equalizes on-resistance for both switching paths, balancing rise and fall times.

---

## 15. Bit-Weighting and Current Mapping

Each bit controls a current source that is a binary-weighted multiple of the LSB:

| Bit | Weight | Current | Note |
|-----|--------|---------|------|
| b0 (LSB) | 2⁰ = 1× | ~1 µA | Least significant |
| b1 | 2¹ = 2× | ~2 µA | |
| b2 | 2² = 4× | ~4 µA | = mirror reference current |
| b3 | 2³ = 8× | ~8 µA | |
| b4 | 2⁴ = 16× | ~16 µA | |
| b5 | 2⁵ = 32× | ~32 µA | |
| b6 | 2⁶ = 64× | ~64 µA | |
| b7 (MSB) | 2⁷ = 128× | ~128 µA | Most significant |
| All ON (0xFF) | 255× | ~255 µA | Full scale |

Output current for any 8-bit code:

```
I_out = Σ(k=0 to 7) b_k × 2^k × I_LSB = code × I_LSB

With R_load = 4.7 kΩ:
  V_out = I_out × R_load
  1 LSB  = 1 µA × 4.7 kΩ = 4.7 mV
  Full scale = 255 µA × 4.7 kΩ ≈ 1.2 V
```

---

## 16. Input Switching — Digital Control

Each bit drives a differential switch pair. The bit signal and its complement are both required:

```
bit = 1, bit_bar = 0  →  M1 ON,  M2 OFF  →  current steers to I_out+
bit = 0, bit_bar = 1  →  M1 OFF, M2 ON   →  current steers to I_out−
```

In the final SoC, the RISC-V CPU writes to the DAC register via APB. Each clock cycle can update all 8 bits simultaneously.

### Example — Input Word `1011 0011`

```
Bit:      b7  b6  b5  b4  b3  b2  b1  b0
Value:     1   0   1   1   0   0   1   1

Active bits: b7 (128µA) + b5 (32µA) + b4 (16µA) + b1 (2µA) + b0 (1µA)
I_out = 128 + 32 + 16 + 2 + 1 = 179 × I_LSB ≈ 179 µA
```

In simulation, CPU register writes are mimicked with rectangular pulse waveforms. Bit periods are successive powers of 2, so the 8 input pulses together generate a natural binary count from 0 to 255 across the simulation window — exercising all 256 output codes in sequence.

---

## 17. Circuit Architecture and Operation

### Internal DAC Structure
<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/32c85ddc283f0e394449c4627e322751d9c97101/ANALOG_PERIPHERAL/DAC/media/pg15.jpeg" title="Figure 3" height="500" width="550">



### Output Code Table

| Input Code | Active Bits | I_out | V_out (10 kΩ load) |
|------------|-------------|-------|---------------------|
| 0x00 | None | 0 µA | 0 V |
| 0x01 | b0 | ~4 µA | ~40 mV |
| 0x80 | b7 only | ~128 µA | ~0.51 V |
| 0xB3 (1011 0011) | b7+b5+b4+b1+b0 | ~179 µA | ~0.72 V |
| 0xFF | All bits | ~255 µA | ~1.02 V |

---

## 18. Simulation Results

All simulations: **ngspice** with **SKY130 TT (typical-typical) MOSFET models**, schematic in **xschem**.

---

### 18.1 Stage 1 — 2-Bit Sub-DAC (MSBs b7 and b8)
<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/263c3ceaec33dfcd2f0d565e56383773bc490c89/ANALOG_PERIPHERAL/DAC/media/pg17.jpeg" title="Figure 3" height="4000" width="3500">

A 2-bit sub-DAC using the two MSBs was built and validated first before scaling to 8 bits. This approach confirms wide-swing cascode mirror biasing at the highest current levels, differential switch pair operation, and settling/glitch behavior.

**Measured output levels:**

<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/2f202686a00616e32230f876630bd8360e69f499/ANALOG_PERIPHERAL/DAC/media/pg20.jpeg" title="Figure 3" height="4000" width="3500">

| b8 | b7 | Expected | Measured | Status |
|----|----|---------|---------|----|
| 0 | 0 | 0 µA | ~0 µA | ✅ |
| 0 | 1 | ~64 µA | ~67 µA | ✅ |
| 1 | 0 | ~128 µA | ~130 µA | ✅ |
| 1 | 1 | ~192 µA | ~195 µA | ✅ |

Small ~3 µA overshoot is consistent with channel-length modulation effects. Levels are clearly distinct, monotonic, and equally spaced — binary weighting and differential switching confirmed working correctly.

---

### 18.2 Stage 2 — Full 8-Bit DAC

**Testbench Setup:**
<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/638083e5779bfc1bb7ad651e8cf38048f11bdbb5/ANALOG_PERIPHERAL/DAC/media/pg21.jpeg" title="Figure 3" height="4000" width="3500">

| Parameter | Value |
|-----------|-------|
| DAC block | dac (8-bit) |
| Supply | V1 = 1.8 V |
| Reference current | I0 = 4 µA |
| R_load | 4.7 kΩ |
| Offset cancellation | I_fix = 128 µA sinking + V_ref = 0.6 V |
| MOSFET models | SKY130 TT |
| Simulation | ngspice transient |

**Final 8-Bit Simulation — v(op) vs time:**
<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/263c3ceaec33dfcd2f0d565e56383773bc490c89/ANALOG_PERIPHERAL/DAC/media/pg18.jpeg" title="Figure 3" height="4000" width="3500">

The output is a **rising staircase from ~0V to ~1.2V**, sweeping through all 256 codes as the binary input counts 0x00 to 0xFF. Each bit doubling the current step means staircase steps grow progressively larger as higher bits toggle — the characteristic DAC transfer curve.


---

### 18.3 Output Code Table

| Input Code | Active Bits | I_out | V_out (4.7 kΩ load) |
|------------|------------|-------|---------------------|
| 0x00 | None | 0 µA | ~0 V |
| 0x01 | b0 | ~1 µA | ~4.7 mV |
| 0x80 | b7 only | ~128 µA | ~0.6 V |
| 0xB3 (1011 0011) | b7+b5+b4+b1+b0 | ~179 µA | ~0.841 V |
| 0xFF | All bits | ~255 µA | ~1.2 V |

---

## 19. Performance Summary

### Verified Simulation Results

| Parameter | Measured Value | Spec | Status |
|-----------|---------------|------|--------|
| Output range | 0V to ~1.2V | 0V to 1.2V | 
| LSB step size | 4.7 mV | 4.7 mV | 
| Offset error | −1.641 mV = −0.349 LSB | ≤ ±0.5 LSB | 
| Gain error | ~0 mV (swing = 1.2212V vs ideal 1.2V) | Negligible | 
| Monotonicity | Confirmed — all 256 codes | Required | 
| Technology | SKY130 0.13 µm CMOS | 0.13 µm | 
| Supply | 1.8 V | 1.8 V | 

### Offset Error Calculation

```
At code 0x00 (all bits OFF):
  V_actual  = −0.001641 V = −1.641 mV
  V_ideal   =  0 V

  Offset Error = V_actual − V_ideal = −1.641 mV = −0.349 LSB

  Specification: ≤ ±0.5 LSB = ≤ ±2.35 mV
  Result:        |−1.641 mV| < 2.35 mV  
```

### Design Flow Summary

```
[Specification]
  8-bit | low power | low frequency | 1.8V CMOS | SoC APB peripheral
        ↓
[Architecture Selection]
  Current Steering → native CMOS | no buffer | constant supply current
        ↓
[Encoding Selection]
  Binary Weighted → 8 sources | direct APB drive | glitch irrelevant at low freq
        ↓
[Cell Design — Razavi Differential Pair Switch]
  Current always flowing → steered by bit/bit_bar via NMOS diff pair
        ↓
[Biasing — Wide-Swing Cascode Current Mirror]
  Self-biased | high Z_out | minimum headroom on 1.8V supply
        ↓
[Transistor Sizing — gm/ID Methodology]
  gm/ID = 8 → V_ov = 0.25V → W = 3µm, L = 2.2µm → I_D = 4µA
        ↓
[Schematic Capture — xschem, SKY130]
  dac_9 (2-bit): inverters + wide-swing cascode mirror + diff switch pairs
  dac_10 (8-bit): 8× scaled current sources + 8× diff switch pairs
        ↓
[Simulation — ngspice, SKY130 TT]
  2-bit: 4 levels verified (0, 67, 130, 195 µA) 
  8-bit: 256-code staircase, 0V to 1.2V, monotonic 
  Offset: −0.349 LSB  (spec: ≤ ±0.5 LSB)
```

---

## 20. References

| # | Reference | Used For | Link |
|---|-----------|----------|------|
| [1] | F. Silveira, D. Flandre, P.G.A. Jespers, *"A gm/ID Based Methodology for the Design of CMOS Analog Circuits,"* IEEE JSSC, 1996 | gm/ID theory; strong inversion; sizing equations | [View Paper](https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/772cece77fbb6b32ce722c1f1a4d8185cac97327/ANALOG_PERIPHERAL/DAC/literature/1996-Jespers-gmIdMethodForAnalogDesign-JSSCC.pdf) |
| [2] | B. Razavi, *"The Current-Steering DAC,"* IEEE SSC Magazine, 2018 | Differential pair switch; cascode switch; glitch energy; output impedance | [View Paper](https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/772cece77fbb6b32ce722c1f1a4d8185cac97327/ANALOG_PERIPHERAL/DAC/literature/A%20Circuit%20for%20All%20Seasons%20The%20Current-Steering%20DAC%20Behzad%20Razavi.pdf) |
| [3] | A. Narayanan et al., *"A 0.35 µm CMOS 6-bit Current Steering DAC,"* IEEE, 2012 | Hybrid thermometer/binary architecture | [View Paper](https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/772cece77fbb6b32ce722c1f1a4d8185cac97327/ANALOG_PERIPHERAL/DAC/literature/A_0.35m_CMOS_6-bit_current_steering_DAC.pdf) |
| [4] | J. Deveugele, M.S.J. Steyaert, *"A 10-bit 250-MS/s Binary-Weighted Current-Steering DAC,"* IEEE JSSC, 2006 | Binary weighting; SFDR; glitch analysis | [View Paper](https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/772cece77fbb6b32ce722c1f1a4d8185cac97327/ANALOG_PERIPHERAL/DAC/literature/A_10-bit_250-MS_s_binary-weighted_current-steering_DAC.pdf) |
| [5] | D.A. Mercer, *"Low-Power Approaches to High-Speed Current-Steering DACs in 0.18-µm CMOS,"* IEEE JSSC, 2007 | Low-power biasing; cascode output impedance; matching vs Vov | [View Paper](https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/772cece77fbb6b32ce722c1f1a4d8185cac97327/ANALOG_PERIPHERAL/DAC/literature/Low-Power_Approaches_to_High-Speed_Current-Steering_Digital-to-Analog_Converters_in_0.18-mum_CMOS.pdf) |

---

*8-Bit Binary-Weighted Current Steering DAC — Analog Peripheral of RISC-V SoC*  
*Technology: 0.18 µm CMOS (SKY130) | Supply: 1.8 V | Tool: xschem + ngspice*  
*Offset Error: −0.349 LSB | Output Range: 0V to 1.2V | Monotonic across all 256 codes *
