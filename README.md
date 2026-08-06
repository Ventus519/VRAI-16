# VRAI 

## About 
VRAI is a custom RISC architecture that describes the system from a 
modular perspective. It assumes structural clarity and a clear separation 
of responsibilities to accurately describe what the processor should do. 
This repository uses the original 16-bit definition of VRAI. 

Some of the main goals of VRAI were to make the relationship between the ISA, 
hardware implementation, and software interfacing easier to understand for 
quicker extensibility and improvement. 
More on this can be found in the [Philosophy](https://github.com/Ventus519/VRAI-16#Philosophy) section, which discusses the main 
design philosophies of VRAI. 


As a result of the above, this project repository includes the following: 
- A custom assembler used to assemble programs written in the custom assembly 
language for VRAI 

- A Verilog implementation of VRAI - Generated reports from LibreLane, which 
include details on the physical implementation 

- Proof-of-Concept implementation (images) in a digital logic simulator 



While VRAI wasn't originally intended for educational purposes, the structural 
clarity that arises from how responsibilities are separated in the processor may 
be useful in educational settings.

This document contains the information needed to understand testing with VRAI. More information on VRAI can be found in
the following:
- [ISA](https://github.com/Ventus519/VRAI-16/VRAI-VERILOG/ISA.md): (in progress) Specification of how instructions are
encoded. 
- Proof-of-Concept Implementation: (in progress) Implementation using digital logic simulator "Turing Complete".
- Verilog Implementation: (in progress)
- Assembler Design: (in progress)

## Philosophy
The following are the main philosophies behind the design of VRAI

### Explicit Separation of Responsibilities
Each aspect of the processor is divided into smaller divisions ("units") that must have well-defined responsibilities. 
Whereas combining different aspects of the processor could lead to decreased space taken up, the potential structural 
ambiguity of such designs is avoided in VRAI. Each specific unit is responsible for giving meaning to a given 
instruction.

Structurally, these units are designed to define boundaries between the instruction interpretation and execution 
behavior. 

This naturally leads to a modular representation of execution units. 


### Contextual Meaning of Data
Register data is treated as raw data as opposed to values with fixed interpretation. 

The meanings of stored values depend on the context they are used in. These contexts are usually determined by the 
execution units. 

VRAI therefore avoids assigning unnecessary restrictions on data before it is used. This allows the execution units, as 
well as the programmer, to define meaning to these values when needed. 

### Extensibility through Modularity

VRAI is designed with modularity in mind, through the philosophy of explicit separation of responsibilities. Execution 
units are structured with a governing structural responsibility in mind, allowing the rest of the system to interact 
with them through well-defined boundaries. . 

Similarly, the strictly low count of standardized execution units is also intentional. This is done to allow additional 
needed functionality to be introduced through new responsibilities in the form of units.

## Testing VRAI

### Dependencies
VRAI uses the following in its testing environment:
- Icarus Verilog (iverilog)
- Yosys
- LibreLane
- GTKWave

Additionally, a C compiler is necessary to support assembling programs using the VRAI assembler. 

### Make Targets

VRAI comes with some default programs that can be used for testing. These programs are found under the "programs" 
directory. VRAI also comes with custom input streams (found in the "memories/inputs" directory) corresponding to each 
of these programs. While any of these inputs could be used for any VRAI program, it is recommended to use the program 
with its corresponding input stream. 

The following can be used to test the sorting program found in "programs/sorting.vrai":

```
make assembler
make vcompile
make assemble PROGRAM=programs/sorting.vrai
make run INPUT=memories/input_sorting.hex
```

The above does every step needed for setting up the testing environment explicitly. Alternatively, the run target 
could be used alone (given that the file "program_alpha.hex" does not exist).

```
make run PROGRAM=programs/sorting.vrai INPUT=memories/input_sorting.hex
```

The waveform can then be observed using
```
make wave
```


The following are the make targets that can be used:
- default
- cleanup
- assembler
- assemble
- vcompile
- run
- wave
- test

The "default" target compiles the assembler as well as compiling the Verilog target into a build directory.
This target does not assemble a program, nor does it test any program to be seen in a waveform. 

The "cleanup" target is used to remove the build directory as well as any temporary files used by the assembler. 

The "assembler" target compiles the assembler. This target does not assemble any programs written in VRAI assembly. 

The "assemble" target is used to assemble a program and output the hex dump of the finalized machine 
instructions. The hex dump is then copied into the hex file "program_alpha.hex", which is used by the
Verilog testbench. A program should be provided for this target to work properly. If no program is provided, 
make will attempt to use a file "program.vrai" in the "programs" directory. This file does not exist by default.

By convention, programs written in VRAI assembly use the file extension .vrai. An example of using this target 
to assemble the program found in "programs/sorting.vrai" is shown below:

```
make assemble PROGRAM=programs/sorting.vrai 
```

This command will result in the creation of "programs/sorting.hex" as well as "program.vrai_preproc". 
"programs/sorting.hex" is the hex dump of "programs/sorting.vrai". "program.vrai_preproc" is an internal file
used for one of the processing passes for the assembler. 

The vcompile target creates the "build" directory and compiles the Verilog target using iverilog with the 
iverilog command file "source.cmd". The Verilog target is then found in the build directory. This Verilog target 
can be renamed using the VERILOG_TARGET make variable. The VERILOG_TARGET variable is also used when generating 
waveforms. 

The run target uses a provided hex file to overwrite the contents of "memories/input.hex". This overwritten input is 
then used as the standard input stream for the VRAI program specified in "program_alpha.hex". If "program_alpha.hex" 
does not exist, then the assembler is run to generate the instruction stream. The waveform is then 
opened in GTKWave. 

Removing "program_alpha.hex" allows for also specifying a program to assemble to use as the instruction stream. 

The example below will generate a waveform with the standard input stream specified by 
"memories/inputs/input_tower_of_hanoi.hex". The waveform will use whatever program is specified by "program_alpha.hex"
```
make run INPUT=memories/inputs/input_tower_of_hanoi.hex
```

Assuming program_alpha.hex doesn't exist, the following can be used to instead also use the program specified in 
"programs/tower_of_hanoi.vrai".

```
make run PROGRAM=programs/tower_of_hanoi.vrai INPUT=memories/inputs/input_tower_of_hanoi.hex
```

The wave and test targets both achieve the same result of generating a waveform and opening it in GTKWave. 
These targets use the default input (which is the standard input that VRAI receives values from, not the instruction 
memory) target, "memories/input.hex". To set the input using some other input hex file, use the run target instead. 
