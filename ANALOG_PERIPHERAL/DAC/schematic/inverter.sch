v {xschem version=3.4.8RC file_version=1.2}
G {}
K {}
V {}
S {}
E {}
N 0 -10 -0 80 {lab=op}
N 0 140 -0 190 {lab=GND}
N -100 -40 -40 -40 {lab=ip}
N -100 -40 -100 110 {lab=ip}
N -100 110 -40 110 {lab=ip}
N -0 -40 50 -40 {lab=#net1}
N 50 -80 50 -40 {lab=#net1}
N 0 -80 50 -80 {lab=#net1}
N 0 110 40 110 {lab=GND}
N 40 110 40 160 {lab=GND}
N 0 160 40 160 {lab=GND}
N 0 40 60 40 {lab=op}
N -180 40 -100 40 {lab=ip}
N 0 -90 0 -70 {lab=#net1}
C {sky130_fd_pr/nfet_01v8.sym} -20 110 0 0 {name=M2
L=0.15
W=1  
nf=1 mult=1
model=nfet_01v8
spiceprefix=X
}
C {gnd.sym} 0 190 0 0 {name=l2 lab=GND}
C {ipin.sym} -180 40 0 0 {name=p2 lab=ip}
C {opin.sym} 60 40 0 0 {name=p1 lab=op}
C {vsource.sym} 0 -120 0 0 {name=V2 value=1.8 savecurrent=false}
C {gnd.sym} 0 -150 2 0 {name=l1 lab=GND}
C {sky130_fd_pr/pfet_01v8.sym} -20 -40 0 0 {name=M11
L=0.15
W=1
nf=1 mult=1
model=pfet_01v8
spiceprefix=X
}
