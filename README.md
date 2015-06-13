# COPYING

Toy SoC toolchain (c) by Meta Alternative Ltd, 2015

# DESCRIPTION

This is a sample toy machine backend for Clike compiler, designed for teaching
fundamentals of computing and for exploring hardware-software co-design and
higher-level HDL synthesis.

Default backend ("small1") is a placeholder for experimenting with various future CPU
designs and compiler backend techniques. There will be many other designs working within
the same SoC and toolchain infrastructure.

The default backend is targeting a toy stack machine, implemented on Spartan6
FPGAs. Sample SoCs are included for [LogiPi](http://valentfx.com/logi-pi/) and [Digilent Atlys](http://www.digilentinc.com/Products/Detail.cfm?Prod=ATLYS) boards.

This is a very trivial multi-stage CPU core without a hardware division,
optional hardware multiplication, no barrel shifter and no FPU. Everything
is supposed to be implemented in software. Only 32-bit word addressing is
supported.

Stack is implemented in 2-port block rams, while instruction and main
data memory is using DDR (with a small instruction cache provided, but no
data cache).

CPU core supports interrupts. At the moment there are only two IRQs implemented,
for incoming SPI/serial data and for memory access violation.
Timer IRQs should be trivial to add.

Compiler accepts a [C-like extensible language](https://github.com/combinatorylogic/clike). It
is possible to inline Verilog code into C to seamlessly enhance
the CPU core functionality, see backends/small1/sw/hdltests/test1.c for example.

# BUILDING

[MBase](https://github.com/combinatorylogic/mbase), [Xilinx ISE](http://www.xilinx.com/products/design-tools/ise-design-suite/ise-webpack.html) and [Verilator](http://www.veripool.org/wiki/verilator) are required for building.

[LogiPi tools](https://github.com/fpga-logi/logi-tools) are required for programming a LogiPi board.

Clike is included as a git submodule:

```bash
   git submodule update --init
``` 

To build a bitfile for your board, use:

```bash
   make logipi
```

or

```bash
   make atlys
```

Bitfiles will be located in backends/small1/hw/soc/logipi or backends/small1/hw/soc/atlys.

To build verilated tests, run (see backends/small1/sw/tests):

```bash
   make hwtests
```

Hex files generated by compiler can be loaded into SoC via an SPI (LogiPi) or USB serial (Atlys), see the contents of backends/small1/hw/soc/logipi/sw and backends/small1/hw/soc/atlys/sw for the host--side terminal and debugger tool.

Usage example:
```bash
   make clikecc.exe
   mono clikecc.exe /out os1 backends/small1/sw/os1.c
   
   # on your Raspberry Pi with a LogiPi attached:
   
   (cd backends/small1/hw/soc/logipi/sw; make spicomm)
   sudo ./backends/small1/hw/soc/logipi/sw/spicomm os1.hex
```


# Verilog inlining

If building a C code with inlined verilog, make sure to move the resulting
verilog output files to backends/small1/hw/custom/ and rebuild the bitfile
or simulation binaries (see backends/small1/sw/hdltest/runtest.sh for example).

For example:
```bash
    make clikecc.exe
    mono clikecc.exe /out hdltest1 backends/small1/sw/hdltests/test1.c
   # Install the generated Verilog files into the build infrastructure
    cp hdltest1_out/*.v   backends/small1/hw/custom/
   # Rebuild the bitfile
    make logipi

   # on your Raspberry Pi with a LogiPi attached:
    sudo logi_loader soc.bit
   
    (cd backends/small1/hw/soc/logipi/sw; make spicomm)
    SOCCOM_BATCH=1 sudo -E ./backends/small1/hw/soc/logipi/sw/spicomm hdltest1.hex
```


