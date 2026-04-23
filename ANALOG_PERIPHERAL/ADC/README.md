 # 8-Bit SAR-ADC

> **Project:** 8-Bit SAR-ADC — Analog Peripheral for a RISC-V SoC


---
## 1-TOPS proposed architecture   

<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/main/ANALOG_PERIPHERAL/ADC/media/top_architecture.png" title="Figure 1" height="500" width="3000">
<p align="center"> Figure 1: Top level Architecture</p> 

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [what is ADC?](#2-what-is-a-adc)
3. [ADC Architectures](#3-adc-architectures)
4. [SAR-ADC](#4-sar-adc)
5. [Sample & Hold](#5-sample-&-hold)
6. [Internl-DAC](#6-internal-dac)   
7. [SAR-ADC Architectures](#7-sar-adc-architectures)
9. [Comparator](#8-comparator)
10. [References](#9-referencs)


----

### **1. Project Overview**


<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/main/ANALOG_PERIPHERAL/ADC/media/ADC_CPU_interface.png" title="Figure 2" height="200" width="600">
<p align="center"> Figure 2: ADC_CPU_interface</p> 

**1.1 ADC (Analog-to-Digital Converter) :**
 - This block takes a real-world analog signal (like voltage from a sensor).
 - It converts it into a digital value (binary number) that the system can understand.
Example: Temperature sensor voltage → digital number like `101101`

**1.2 APB Bus (Advanced Peripheral Bus) :**
 - This is a simple, low-speed communication bus.
 - Used to connect peripherals like ADC, UART, GPIO, etc.
 - The ADC sends its digital data onto this bus.

**1.3 AXI Bus (Advanced eXtensible Interface) :**
 - This is a high-speed, high-performance bus.
 - Used for communication between major system components (like CPU, memory).
 - Data from APB is usually passed to AXI through a bridge (APB-to-AXI bridge).

**1.4 CPU(RISC-V core)**
 - The processor reads the digital data via AXI.
 - It can process, store, or act on the data.

**Design Specification:**

| Parameter | Specification |
|-----------|--------------|
| Resolution | 8 bits (256 levels) |
| Input Range | 0 V to 1.2 V (diffrential)|
| LSB | ~4.7 mV |
| Power | Low (µA-range) |
| Frequency | 1M Hz|

-----

### **2. What is a ADC?**

<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/main/ANALOG_PERIPHERAL/ADC/media/ADC.png" title="Figure 3" height="500" width="800">
<p align="center"> Figure 3: ADC</p> 

An **Analog-to-Digital Converter (ADC)** is a crucial component that translates continuous, real-world analog signals (like sound, light, temperature) into discrete digital data (0s and 1s) for processing by computers and microcontrollers.

***How ADC Work ?***

1. **Sampling** — measuring the signal at regular intervals (Nyquist: fs ≥ 2×fmax).
2. **Quantization** — rounding each sample to the nearest discrete level (2ⁿ levels).
3. **Encoding** — converting each level to a binary code (e.g. 3.2V → 10110010).
4. **Output** — sending the digital word to a microcontroller/DSP for processing.
   
--------

### **3. ADC Architectures**

| Architecture	| Speed	| Resolution	| Typical Use |
|--------------|-------|------------|-------------|
| Flash	| Very high	| Low–Medium	|RF, high-speed systems |
| SAR	| Medium	| Medium–High	| Embedded systems |
| Sigma-Delta	| Low	| Very high	| Audio, sensors |
| Pipeline	| High	| Medium–High	| Communication, imaging |
| Dual-Slope	| Very low	| High	| Multimeters |

- As per the comparison and and specification for the RISC-V project the SAR-ADC should be good design option.
  
--------------------

### **4. SAR-ADC**

A Successive Approximation Register (SAR) ADC is a high-resolution, low-power analog-to-digital converter that uses a binary search algorithm to convert analog signals to digital.

<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/main/ANALOG_PERIPHERAL/ADC/media/SAR-ADC.png" title="Figure 4" height="400" width="800">
<p align="center"> Figure 4: SAR-ADC</p> 

- **Sample & Hold Circuit:** Acquires and holds the input voltage (***Vin***).
- **Comparator:** Compares the input voltage with a trial voltage from the DAC.
- **SAR Logic:** Implements a binary search algorithm to determine each bit of the digital output.
- **Internal DAC (Digital-to-Analog Converter):** Converts the current digital approximation back into a voltage for comparison.


 **SAR-ADC working**

<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/main/ANALOG_PERIPHERAL/ADC/media/SAR_ADC_logic.png" title="Figure 3" height="800" width="800">
<p align="center"> Figure 5: SAR-logic</p> 

I. Start & Sample
 - Start conversion and sample input voltage ***Vin**.
 - Initialize SAR register to 0.

II. Set Trial Bit
  - Set MSB = 1 (trial)
  - Generate corresponding ***Vdac***= ***Vreff/2***

III. Compare
   - Comparator compares ***Vin*** with ***Vdac***

IV. Bit Decision
  - If ***Vin*** > ***Vdac*** → keep bit = 1.
  - Else → reset bit = 0.

V. Repeat Until LSB
 - Move to next lower bit and repeat comparison
 - After all bits are tested → Output final digital code.

       For Example : 3-bit system

       Let Vin = 0.85 v
       - Step-1 : Set MSB = 1 (D = 100) Vdac = Vreff/2 = 0.6v
       - Step-2 : 0.85 > 0.6 → (D = 110) Vdac = mid range of 0.6v to 1.2v = 0.9
       - Step-3 : 0.85 < 0.9 → (D = 101) Vdac = mid range of 0.6v to 0.9v = 0.75
       - Step-4 : 0.85 > 0.75 → (D = 101) : Digital output = 101

----------------

### **6. Sample & Hold**

- In the present architecture the Capacitive network work as DAC as well as S&H circuit.
  
1. **Sample** — At a precise clock instant, the circuit reads ("samples") the instantaneous voltage of the incoming analog signal. This is the dot on the waveform 1 above.
2. **Hold** — It then freezes (holds) that voltage steady for the duration of one sampling period, giving the ADC's quantizer time to convert it to a digital number without the input changing underneath it. This creates the characteristic staircase shape shown in waveform 3.

**The Nyquist Sampling Theorem**

A band-limited signal with maximum frequency f can be perfectly reconstructed from its samples if and only if the sampling rate is greater than equal to the twice of the signal frquency.

$$f_s \geq 2f$$

fₛ = Sampling rate
f = Input Signal frequency 

- The minimum valid rate, fs = 2f, is called the Nyquist rate.
- The threshold f = fs/2 is the Nyquist frequency.
  
<table>
  <tr>
    <td align="center">
      <img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/main/ANALOG_PERIPHERAL/ADC/media/input.png" height="200" width="600"/>
      <p align="center"> Figure 6: Input </p> 
    </td>
    <td align="center">
      <img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/main/ANALOG_PERIPHERAL/ADC/media/S%26H_output.png" height="200" width="600"/>
      <p align="center"> Figure 7: S&H output</p> 
    </td>
  </tr>
</table>

Here
- Waveform 1 — continuous input sinusoid (2.5 Hz).
- Waveform 3 — overlay of input + S&H staircase output.
  
$$f_s = 10 \text{ Hz} \geq 2 \times 2.5 \text{ Hz} = 5 \text{ Hz}$$

**Nyquist satisfied, Signal can be perfectly reconstructed.**

------------------------------------------------

### **6. Internal-DAC**

**1. R-2R DAC**


<table>
  <tr>
    <td align="center">
       <img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/main/ANALOG_PERIPHERAL/ADC/media/R-2R.png" height="200" width="300"/>
       <p align="center"> Figure 8: R-2R DAC</p> 
    </td>
    <td align="center">
        <img src="https://latex.codecogs.com/svg.image?\color{white}V_{dac}=-\frac{R_f}{Rth}\cdot%20V_{th}" />
    </td>
  </tr>
</table>


- Uses only two resistor values: R and 2R.
- Each digital bit controls a switch
   - 1 → Connected to Vref
   - 0 → Connected to GND
- Resistor ladder creates binary weighted currentsand the currents combine at output node.
- Works on the concept of voltage divider.
- Output voltage proportional to digital input.

$$V_{dac} = V_{ref} \times \frac{D}{2^N}$$
  
**2. Capacitive DAC**
- Uses binary-weighted capacitors (C, 2C, 4C…).
- During sampling → Capacitors store input charge.
- During conversion → Bottom plates switches between:
   - Vref
   - Ground
- Charge redistribution changes output node voltage.

<table>
  <tr>
    <td align="center">
      <img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/main/ANALOG_PERIPHERAL/ADC/media/CDAC_1.png" height="200" width="350"/>
      <p align="center"> Figure 9: CDAC_Sampling</p> 
    </td>
    <td align="center">
      <img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/main/ANALOG_PERIPHERAL/ADC/media/CDAC_2.png" height="200" width="350"/>
      <p align="center"> Figure 10: CDAC_Conversion</p> 
    </td>
  </tr>
</table>

    Sampling phase (S1 close)
    - top plate → Gnd
    - bottom plate → Vin
    - Qi = - C(total) x Vin
 
    Conversion phase (S1 open)
    - top plate → Vx
    - bottom plate → Vreff/Gnd
    - Qf = Ck(Vx - Vbk) → for each cap.
     from the charge conservation
    - Qi = Qf

<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/main/ANALOG_PERIPHERAL/ADC/media/CDAC_3.png" title="Figure 3" height="800" width="1200">
<p align="center"> Figure 11: CDAC_equivalent</p> 

| Parameter	| R-2R DAC	| CDAC |
|-----------|----------|------|
| Power	 | Static current → Higher power	| No static current → Low power |
| Area	 | Larger for high resolution	| More area-efficient |
| Linearity	| Sensitive to resistor mismatch	| Better matching → Better linearity |
| SAR ADC Suitability	| Needs separate S/H	| Acts as S/H + DAC |

---------------------

### **7. SAR-ADC Architectures**

**Architecture-1 : Single Ended SAR Architecture**

<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/main/ANALOG_PERIPHERAL/ADC/media/Single_ended_architecture.png" title="Figure 3" height="800" width="1000">
<p align="center"> Figure 12: Single-ended Architecture</p> 

$$V_x = 2V_g - \frac{V_g \times D}{256} + \frac{D \times V_{ref}}{256} - V_{in}$$

- During DAC switching, ***Vx*** drops below 0v then the parasitic body diodes of the MOS switch ***S1*** can become forward biased.
- Forward-biased parasitic diodes create an unintended conduction path which allows the stored input voltage ***Vin*** to discharge.
- Results in signal distortion and dynamic conversion error which leads to degraded linearity (INL/DNL) and reduced accuracy.


**Architecture-2 : Conventional Architecture**

<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/main/ANALOG_PERIPHERAL/ADC/media/Conventional_architecture.jpeg" title="Figure 3" height="400" width="1000">
<p align="center"> Figure 13: Conventional Architecture</p> 

- Large switching energy : Large capacitors causes large energy consumption.
- The average switching energy for **8 bit ≈ 339.34 CV²_reff**.

<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/main/ANALOG_PERIPHERAL/ADC/media/Conventional_sar_logic.png" title="Figure 3" height="600" width="1000">
<p align="center"> Figure 14: Conventional Architecture energy cosumpution</p> 

**Architecture-3 : Monotonic switching Architecture**

<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/main/ANALOG_PERIPHERAL/ADC/media/Monotonic_architecture.jpeg" title="Figure 3" height="400" width="1000">
<p align="center"> Figure 15: Monotonic Switching Architecture</p> 

- Less switching energy : average switching energy for **8 bit ≈ 63.5 CV²_reff**

<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/main/ANALOG_PERIPHERAL/ADC/media/Monotonic_sar_logic.png" title="Figure 3" height="600" width="1000">
<p align="center"> Figure 16: Monotonic Architecture energy cosumpution</p> 

- During sampling, switches connect the capacitor array to Vip and Vin​ to store the input voltage.
- During conversion, the SAR logic sequentially switches the capacitors between Vref​ and ground to generate comparison voltages.
- The comparator compares the differential node voltages and the SAR logic determines the digital output bits D1–D8.
- The capacitve network acts as both S/H circuit and the DAC.
- Transmission gates are used for switching.
   - Unit capacitor **C = 5.52 fF**
   - **Ctotal = 1.413 pF** (for 8-bit)

----------------------

### **8. Comparator**

**Dyanamic Latch Comparator**

<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/main/ANALOG_PERIPHERAL/ADC/media/Comparator.jpg" title="Figure 3" height="600" width="600">
<p align="center"> Figure 17: Dyanamic Latch Comparator</p> 

| Group	| MOSFETs	| Function |
|-------|---------|----------|
| Input Differential Pair	| M1, M2 | Receive (V_+), (V_-) and convert voltage difference to current | 
| Regenerative Latch	| M3, M4 |	Cross-coupled pair providing positive feedback and fast decision |
| Bias / Current Source	| Mb 	| Provide bias and tail current for the comparator |
| Precharge / Reset	| M8, M9, M10, M11	| Precharge output nodes during reset phase |
| Clock Controlled Evaluation	| M7, M5, M6 |	Enabled by clock to start the comparison phase|

***Working***

- **1.RESET  (Clk = 1)**
  - Outputs Outp and Outn are precharged to Vdd​.
  - No current flows through the differential pair.
  - Comparator is initialized for the next comparison

- **2.COMPARE  (Clk = 0)**
  - Input pair (M1, M2) senses V+ and V−.
  - Regenerative latch (M3–M6) amplifies the difference.
  - Outputs resolve to one high and one low (digital decision).
 
    
- **Problem** : As the input common-mode voltage gradually decreases from Vref/2 toward ground during conversion (unlike the conventional method where it stays roughly constant), the effective gate overdrive voltage (VGS - VTH) of the comparator's input differential pair changes continuously. This causes a input-dependent dynamic offset that degraded linearity in the first prototype.

  
- **Solution** :  Improved Comparator with Current Source (Mb)
A biased MOS transistor Mb is cascoded at the top of the switch transistor in the dynamic comparator. Since Mb operates in saturation, changes in its drain-source voltage have only a minor effect on drain current. This keeps the effective overdrive voltage of the input pair nearly constant even as the common-mode voltage varies, suppressing the dynamic offset.

---------------------------------

**9. References**

[1]  Tang, Xiyuan, et al. "Low-power SAR ADC design: Overview and survey of state-of-the-art techniques." IEEE Transactions on Circuits and Systems I: Regular Papers 69.6 (2022): 2249-2262.

[2] McCreary, James L., and Paul R. Gray. "All-MOS charge redistribution analog-to-digital conversion techniques. I." IEEE Journal of Solid-State Circuits 10.6 (2003): 371-379.

[3] Liu, Chun-Cheng, et al. "A 10-bit 50-MS/s SAR ADC with a monotonic capacitor switching procedure." IEEE Journal of Solid-State Circuits 45.4 (2010): 731-740.
