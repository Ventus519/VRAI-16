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