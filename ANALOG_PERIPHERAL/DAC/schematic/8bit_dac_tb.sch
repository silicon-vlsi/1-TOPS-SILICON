v {xschem version=3.4.8RC file_version=1.2}
G {}
K {}
V {}
S {}
E {}
N 180 -60 250 -60 {lab=#net1}
N 330 -80 390 -80 {lab=#net2}
N 390 -40 390 -20 {lab=#net3}
N -160 80 -120 80 {lab=#net4}
N -160 80 -160 110 {lab=#net4}
N -130 100 -120 100 {lab=#net5}
N -130 100 -130 110 {lab=#net5}
N -280 40 -120 40 {lab=#net6}
N -280 40 -280 50 {lab=#net6}
N -210 60 -120 60 {lab=#net7}
N -210 60 -210 70 {lab=#net7}
N -370 20 -120 20 {lab=#net8}
N -370 20 -370 60 {lab=#net8}
N -450 0 -120 -0 {lab=#net9}
N -450 0 -450 60 {lab=#net9}
N -570 -20 -120 -20 {lab=#net10}
N -570 -20 -570 50 {lab=#net10}
N -640 -40 -120 -40 {lab=#net11}
N -640 -40 -640 50 {lab=#net11}
N -720 -60 -120 -60 {lab=#net12}
N -720 -60 -720 50 {lab=#net12}
N -810 -80 -120 -80 {lab=#net13}
N -810 -80 -810 40 {lab=#net13}
N 180 -80 250 -80 {lab=#net2}
N 430 -140 430 -90 {lab=op}
N 370 -140 370 -80 {lab=#net2}
N 250 -60 250 10 {lab=#net1}
N 310 -60 310 -0 {lab=op2}
N 290 -0 310 -0 {lab=op2}
N 250 -80 270 -80 {lab=#net2}
N 430 -110 510 -110 {lab=op}
N 270 -80 330 -80 {lab=#net2}
C {vsource.sym} 250 80 0 0 {name=V2 value=0.6 savecurrent=false}
C {vsource.sym} 390 10 0 0 {name=V3 value=0.6 savecurrent=false}
C {gnd.sym} 250 110 0 0 {name=l5 lab=GND}
C {gnd.sym} 390 40 0 0 {name=l6 lab=GND}
C {isource.sym} -160 140 0 0 {name=I0 value=4u}
C {vsource.sym} -130 140 0 0 {name=V1 value=1.8 savecurrent=false}
C {gnd.sym} -280 110 0 0 {name=l3 lab=GND}
C {vsource.sym} -280 80 0 0 {name=VB2 value="PULSE(1.8 0 230n 20n 20n 64u 128u)" savecurrent=false}
C {gnd.sym} -210 130 0 0 {name=l1 lab=GND}
C {vsource.sym} -210 100 0 0 {name=VB1 value="PULSE(1.8 0 260n 20n 20n 128u 256u)" savecurrent=false}
C {gnd.sym} -160 170 0 0 {name=l2 lab=GND}
C {gnd.sym} -130 170 0 0 {name=l4 lab=GND}
C {gnd.sym} -810 80 0 0 {name=l11 lab=GND}
C {vsource.sym} -810 50 0 0 {name=VB8 value="PULSE(1.8 0 50n 20n 20n 1u 2u)" savecurrent=false}
C {gnd.sym} -720 110 0 0 {name=l8 lab=GND}
C {vsource.sym} -720 80 0 0 {name=VB3 value="PULSE(1.8 0 80n 20n 20n 2u 4u)" savecurrent=false}
C {gnd.sym} -640 110 0 0 {name=l9 lab=GND}
C {vsource.sym} -640 80 0 0 {name=VB4 value="PULSE(1.8 0 110n 20n 20n 4u 8u)" savecurrent=false}
C {gnd.sym} -570 110 0 0 {name=l10 lab=GND}
C {vsource.sym} -570 80 0 0 {name=VB5 value="PULSE(1.8 0 140n 20n 20n 8u 16u)" savecurrent=false}
C {gnd.sym} -450 120 0 0 {name=l12 lab=GND}
C {vsource.sym} -450 90 0 0 {name=VB6 value="PULSE(1.8 0 170n 20n 20n 16u 32u)" savecurrent=false}
C {gnd.sym} -370 120 0 0 {name=l13 lab=GND}
C {vsource.sym} -370 90 0 0 {name=VB7 value="PULSE(1.8 0 200n 20n 20n 32u 64u)" savecurrent=false}
C {simulator_commands.sym} -1050 60 0 0 {name=COMMANDS
simulator=ngspice
only_toplevel=false 
value="

* transient analysis
.tran 1n 270u
*.op
.control
run


plot -i(V4)

plot v(op)
plot v(op2)


write dac_32tb.raw
.endc

.end


* ngspice commands
"}
C {devices/code.sym} -1060 -190 0 0 {name=TT_MODELS
only_toplevel=true
format="tcleval( @value )"
value="
** opencircuitdesign pdks install
.lib $::SKYWATER_MODELS/sky130.lib.spice tt
"
spice_ignore=false}
C {vcvs.sym} 430 -60 0 0 {name=E1 value=10000}
C {gnd.sym} 430 -30 0 0 {name=l7 lab=GND}
C {res.sym} 400 -140 3 0 {name=R1
value=4.7k
footprint=1206
device=resistor
m=1}
C {vcvs.sym} 290 30 0 0 {name=E2 value=10000}
C {gnd.sym} 290 70 0 0 {name=l14 lab=GND}
C {res.sym} 280 -60 3 0 {name=R2
value=4.7k
footprint=1206
device=resistor
m=1}
C {opin.sym} 510 -110 0 0 {name=p1 lab=op}
C {opin.sym} 310 -20 0 0 {name=p2 lab=op2}
C {isource.sym} 340 -110 0 0 {name=I1 value=128u}
C {isource.sym} 240 -90 0 0 {name=I2 value=128u}
C {gnd.sym} 240 -120 2 0 {name=l16 lab=GND}
C {gnd.sym} 340 -140 2 0 {name=l17 lab=GND}
C {8bit_dac.sym} 30 10 0 0 {name=x2}
