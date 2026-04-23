# **1-TOPS** proposed architecture   

<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/main/ANALOG_PERIPHERAL/ADC/media/top_architecture.png" title="Figure 3" height="350" width="3000">
<p align="center"> Figure 1: Top level Architecture</p> 

--------

# 8 BIT SAR-ADC (**ADC Analog Peripheral**)
------

A Successive Approximation Register Analog-to-Digital Converter (SAR ADC) is a type of ADC architecture that converts an analog input signal into a digital output through a binary search process. It offers a balance of speed, accuracy, and power efficiency, making it widely used in mixed-signal and embedded systems.    

The main fundamental building blocks of a SAR-ADC are :         
**1. Sample & Hold circuit**      
**2. DAC**     
**3. Comparator**     
**4. SAR logic (Successive Aproximation register)**   
 

<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/main/ANALOG_PERIPHERAL/ADC/media/conventional_architecture.jpg" title="Figure 3" height="300" width="4000">
<p align="center"> Figure 2: Conventional Architecture</p>   



<img src="https://github.com/amitops2103/1-TOPS-SILICON-ANALOG/blob/main/ANALOG_PERIPHERAL/ADC/media/monotonic_architecture.jpg" title="Figure 3" height="300" width="4000">
<p align="center"> Figure 3: Monotonic Architecture</p>   

- Brief Working of SAR ADC    
   1. The Capacitor network serves as both S/H circuit and a reference DAC capacitor array.      
   2. **Sampling the Input** : The analog input voltage is first sampled and held by a sample-and-hold circuit so it remains constant during the conversion process.    
   3. **Initial Guess (MSB Test)** : The SAR logic sets the most significant bit (MSB) to 1 and all other bits to 0. This digital code is sent to the DAC.
   4. **DAC Generates Comparison Voltage** : The Digital-to-Analog Converter converts this digital code into an analog voltage.
   5. **Comparison** : A Analog Comparator compares ***Vin*** and ***Vdac***.  
      - If ***Vin > Vdac*** -> keep that bit as 1.    
      - If ***Vin < Vdac*** -> keep that bit as 0.     
   6. **Binary Search Process** : This process continues bit-by-bit from MSB to LSB, each time refining the approximation.
   7. **Final Digital Output** : After N clock cycles for an N-bit ADC, the SAR register contains the final digital representation of ***Vin***.

- **Conventional Switching Architecture**
  - no. of unit cap -> 2^N -> 256
  - Total cap -> 2N + 2 -> 18
  - Total switches -> 4N+10 -> 42
  - Large switchingg energy : Large capacitors causes large energy consumption.
    - The average switching energy for 8 bit ≈ 339.34 CV²_ref

$$E_{avg,conv} = \sum_{i=1}^{n} 2^{n+1-2i}(2^i - 1)CV_{ref}^2$$

  - Bidirectionl switching
    - Vreff -> GND
    - GND -> Vreff
  - High switch counts : Each cap needs switches for three state : Vin, Vreff, GND


- **Monotonic Switching Architecture**
  - no. of unit cap -> 2^(N-1) -> 128
  - Total cap -> 2N -> 16
  - Total switches -> 4N -> 32
  - Less switching energy : average switching energy for 8 bit ≈ 63.5 CV²_ref

$$E_{avg,mono} = \sum_{i=1}^{n-1} 2^{n-2-i} CV_{ref}^2$$

  - Unidirectional switching : Vreff -> GND
  - Each cap needs switvhes for two state : Vreff, GND

---------------------

## Monotonic Switching Architecture

- Two identical capacitor arrays  
   - Top array -> connected to comparator positive (+)  
   - Bottom array -> connected to comparator negative (–)
   - Each array has:
     - Binary weighted capacitors :       

$$
C_i = 2C_{i+1}
$$


   - A fully differential comparator
   - SAR logic controlling switches S1p…S8p and S1n…S8n
​
-----
## Individual Block :

### **1. Capacitor DAC**

- The Capacitor network serves as both S/H circuit and a reference DAC capacitor array. 

- **Phase 1 - Sampling phase**
  - Input signals ***Vip*** and ***Vin*** are sampled onto the top plates of capacitors via transmission gate switches switches
  - Bottom plates -> ***Vreff***
  - So both arrays sample the input.

  - The voltage stored on capacitors :
    
$$
Q_{initial} = C(V_{ip} - V_{reff})
$$

$$
Q_{initial} = C(V_{in} - V_{reff})
$$

Each side stores equal charge.
  - Since it's differential:

$$
V_{d} = V_{ip} - V_{in}
$$


- **Phase 2 - Conversion Phase : First Comparison (No Switching!)**
  - After the switches turn off, the comparator immediately performs the first comparison without switching any capacitor.
  - Zero switching energy is consumed before the first comparison.

- **Phase 3 - MSB Decision**
  - The comparator output determines which side has the higher voltage ***Vip - Vin***.
  - The largest capacitor on the higher-voltage side is switched from ***V_ref*** down to ground.
  - The capacitor on the lower-voltage side remains unchanged at ***V_ref***.
    
- **Phase 4 - Subsequent Bit Decisions**
  - For each bit cycle, only one capacitor switch occurs - always downward.
  - The common-mode voltage of the DAC gradually decreases from ***V_ref/2*** to GND.
  - This continues until the LSB is resolved.
- **Problem**
  - As the input common-mode voltage gradually decreases from ***Vref/2*** toward ground during conversion (unlike the conventional method where it stays roughly constant), the effective gate overdrive voltage ***(VGS - VTH)*** of the comparator's input differential pair changes continuously. This causes a input-dependent dynamic offset that degraded linearity in the first prototype.

- **Solution: Improved Comparator with Current Source (Mb)**
  - A biased MOS transistor Mb is cascoded at the top of the switch transistor in the dynamic comparator. Since Mb operates in saturation, changes in its drain-source voltage have only a minor effect on drain current. This keeps the effective overdrive voltage of the input pair nearly constant even as the common-mode voltage varies, suppressing the dynamic offset.
    
------------

**Complete Working of 4-bit Monotonic SAR ADC**
Given:  
- **VDD = 1.8V**
- **Vref = 1.2V**
- **Vcm = Vref/2 = 0.6V**
- **Resolution = 4-bit -> 2⁴ = 16 levels**
- **LSB = V_ref / 2^N = 1.2 / 16 = 0.075V**
  
Capacitor Array (4-bit) : number of unit capacitors = 2^(N-1) = 2³ = 8      
 
    C1 = 8C  (MSB capacitor)
    C2 = 4C
    C3 = 2C
    C4 = C   (LSB capacitor)

- Differential Input (example we will trace):
  - V_ip = 0.85V (positive input)
  - V_in = 0.35V (negative input)
  - Differential input = 0.85 - 0.35 = 0.50V
  - 

- **PHASE 0 — SAMPLING PHASE**
  - Transmission switches ON.
  - Input voltages ***Vip*** and ***Vin*** are sampled onto the top plates.
  - Bottom plates of ALL capacitors on both sides are connected to ***Vref = 1.2V***



        POSITIVE SIDE:
        Top plates    = V_ip = 0.85V  (sampled input)
        Bottom plates = V_ref = 1.2V  (all reset to Vref)

        Voltage across each capacitor (V_top - V_bottom):
        C1p: 0.85 - 1.2 = -0.35V
        C2p: 0.85 - 1.2 = -0.35V
        C3p: 0.85 - 1.2 = -0.35V
        C4p: 0.85 - 1.2 = -0.35V

        NEGATIVE SIDE:
        Top plates    = V_in = 0.35V  (sampled input)
        Bottom plates = V_ref = 1.2V  (all reset to Vref)

        Voltage across each capacitor:
        C1n: 0.35 - 1.2 = -0.85V
        C2n: 0.35 - 1.2 = -0.85V
        C3n: 0.35 - 1.2 = -0.85V
        C4n: 0.35 - 1.2 = -0.85V

        Charge on top plate of positive side (total):
        Qp = (8C+4C+2C+C) x (0.85 - 1.2)
           = 15C x (-0.35)
           = -5.25C

        Charge on top plate of negative side (total):
        Q_n = 15C x (0.35 - 1.2)
            = 15C x (-0.85)
            = -12.75C

- **PHASE 1 — END OF SAMPLING (Transmission Switch Turns OFF)**
  - Bootstrapped switches turn OFF. 
  - Top plate charges are now frozen (charge conservation).
  - Bottom plates still at ***Vref = 1.2V***.
  - Comparator is ready for first comparison
