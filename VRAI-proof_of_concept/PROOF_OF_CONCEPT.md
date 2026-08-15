# VRAI Proof of Concept

This document is a work in progress. Information here is subject to change. 

This section of this project contains images of the first implementation of VRAI in the digital logic simulator Turing 
Complete. 

As some of the components are harder to reason about, refer to this document to know the specifics of how they were 
connected.

The components will be discussed based on the units they are represented by. The ordering is as follows:
- Map of the Core
- Components of the overall System
- Components of UNIT SYS
- Components of UNIT ALU
- Components of UNIT BIT
- Components of UNIT JMP
- Components of UNIT MEM

Refer to the main ISA document for specifics on the encoding scheme for each unit. 


## The Core
![Core](images/core/sram-single_cycle/VRAI_CORE.png "VRAI Single-Cycle SRAM Core")

The above image is the overall core design. Due to the size of the core, it may be difficult to identify where each 
main part of the VRAI processor lies. For that reason, refer to the following map of the Core to understand where each 
unit lies and how they interact with the system. 

(need image of map)


From this point onward, this document will be discussing the actual implementation details of the Turing Complete 
version of VRAI-16. 

## Components of UNIT SYS

Decoding a UNIT SYS instruction involves the following:
- Decoding the 4b field "CODE"
- Decoding the 4b field "SUBCODE"

Thus, the implementation of UNIT SYS (in Turing Complete) uses 1 main "CODE" decoder whose outputs are tied to the 
enable signals of the "SUBCODE" decoders. 


The implementation of "CODE" decoder can be referenced below:
![UNIT_SYS](images/unit/sys/SYS_DECODER.png "VRAI-16 UNIT SYS (TC)")

This implementation is functionally identical to a 4b-decoder (4-to-16 decoder) with an enable input.
The enable input used comes from the Unit Decoder. 

The outputs "EX CTRL" and "ACCESS" indicate the two main aspects of UNIT SYS instructions:
- "EX CTRL" refers to aspects of the processor related to the execution control. This primarily refers to the HALT
register and the nop instruction. 
- "ACCESS" refers to instructions that access specific architectural values of the system. Unlike the registers of the 
register file, these do have meaning attached (as they only live in UNIT SYS). The most common of these is the counter.

Similarly, the SUBCODE decoders are implemented using 4b decoders with enable inputs. The enable signal is tied to the 
respective CODE decoder output specifying the category of the instruction. 
Full 4b-decoders are used here, but not all outputs have been given meaning. A majority of these outputs are a part of 
the reserved space of SYS instructions. Since the Turing Complete implementation is the primary way for the design 
process of VRAI, the full decoder was used to easily access those outputs in the future. 

The implementation of the 4b-decoder is trivial. 

As implied by the description of "ACCESS", the counter is considered part of UNIT SYS. While the main manipulation 
exists outside of UNIT SYS, accessing the counter value for future use is done through UNIT SYS 
(using the counter\[+x\]) instruction. 

## Components of UNIT ALU

### Overall Implementation
The implementation of UNIT ALU can be referenced below:
![UNIT_ALU](images/unit/alu/UNIT_ALU.png "VRAI-16 UNIT ALU (TC)")

The highest bit of the code field is used to determine whether to use the register version of argument B or the 
immediate representation. This becomes the multiplexer (2-to-1) in the design. 

The block "ALU CORE" is the main implementation of the ALU. Since the instructions for both immediate B and register B 
are the same, the implementation can be isolated from the selection of value. 

This block's implementation can be found below:
![ALU_CORE](images/unit/alu/ALU_CORE.png "VRAI-16 ALU CORE (TC)")

### Specifics about Comparison

## Components of UNIT BIT

## Components of UNIT JMP

## Components of UNIT MEM