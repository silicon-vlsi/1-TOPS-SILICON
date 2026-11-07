# RISC V SoC - MVP Configuration

We recommend 3 viable minimal viable production configurations.

## Recommendation

| Application | ISA | Pipelining | Privilege | Memory Organization |
|---|---|---|---|---|
| Simple embedded applications (control/sensing, tiny firmware) | RV32I | 1 or 3 in-order | Machine mode | On-chip 8KB-32KB SRAM<br>4KB Boot ROM |
| General-purpose (rich bare-metal firmware) | RV32IM | 3 or 5 in-order<br>Prefetch Buffer | Machine mode | 32-64 KB instruction SRAM + 32-64 KB data SRAM (64-128 KB total)<br>4KB Boot ROM<br>Prefetch Buffer - 2K |
| Advanced project (RTOS/Linux) | RV32IMC | 5 stage in-order<br>Prefetch Buffer<br>Instruction Cache | Machine mode and Supervisor mode | At least 64KB each SRAM memory<br>4KB Boot ROM<br>Prefetch Buffer - 2K<br>On-chip I Cache - 4-8K |

**Please note:** MMU will be needed to boot Linux.

## Recommended peripheral set

| Peripheral | # of instance | Usage | Source | Mandatory |
|---|---|---|---|---|
| 32 pin GPIO | 1 | Controlling, configuring, and reading the digital state of the physical pins | https://github.com/pulp-platform/gpio | Yes |
| UART | 1-2 | One for debug, one for application communication | https://github.com/pulp-platform/apb_uart | Yes |
| SPI/QSPI | 1 | For sensor comms/flash access & booting via SPI Flash | https://github.com/pulp-platform/apb_spi_master | Yes |
| I2C | 1 | Sensor communication | https://github.com/pulp-platform/apb_i2c/blob/master/apb_i2c.sv | Can be used if needed |
| I2S | 1 | Orchestrator of digital audio transmission | ?? | Can be used if needed |
| PLIC | 1 | Interrupt controller supporting 16-32 interrupt sources | https://github.com/pulp-platform/rv_plic/blob/master/rtl/plic_top.sv | Yes |
| Timer | 1 | System tick, general-purpose | https://github.com/pulp-platform/apb_timer | Yes |
| CLIC/CLINT | 1 | Timer and SW interrupts | https://github.com/pulp-platform/clic | Yes |

Another open source peripheral source: https://opencores.org/projects

## Recommended Interconnect

For core to peripheral communication, AXI4-Lite:
https://github.com/pulp-platform/axi/blob/master/src/axi_lite_to_apb.sv

## Recommended VIPs

https://mbits-mirafra.github.io/projects/

## Boot Plans

| Option | Description |
|---|---|
| Boot ROM and/or SPI | Teams can have a BootROM and load the instruction memory before the CPU reset is de-asserted.<br><br>We also recommend adding a SPI slave in the peripheral list, so that boot code can be fetched from an external SPI memory.<br><br>Need external boot mode selection pin. When 1'b0, boot code is fetched from internal ROM; otherwise boot code is fetched from external SPI memory.<br><br>SPI is a backup option if boot from ROM fails.<br><br>Teams need to plan for the verification of both the paths. |
