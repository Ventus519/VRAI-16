# VRAI 

## About 
VRAI is a custom RISC architecture that describes the system from a 
modular perspective. It assumes structural clarity and a clear separation 
of responsibilities to accurately describe what the processor should do. 
This repository uses the original 16-bit definition of VRAI. 

Some of the main goals of VRAI were to make the relationship between the ISA, 
hardware implementation, and software interfacing easier to understand for 
quicker extensibility and improvement. 
More on this can be found in the [Philosophy]() section, which discusses the main 
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
