.PHONY: all
all: wave

.PHONY: clean
clean: wave
	rm -r build

.PHONY: cleanup
cleanup: build
	rm -r build

.PHONY: compile
compile:
	mkdir build
	iverilog -c source.cmd -o build/sim.out

.PHONY: run
run: compile
	vvp build/sim.out

.PHONY: wave
wave: run
	gtkwave build/VRAI_SYNC_TEST.vcd

.PHONY: assemble
assemble:
	gcc -o VRAIa VRAI-ASSEMBLER/main.c \
				 VRAI-ASSEMBLER/Assembler.c VRAI-ASSEMBLER/Assembler.h \
				 VRAI-ASSEMBLER/field_definitions_vrai.h \
				 VRAI-ASSEMBLER/processing/AsciiTree.c VRAI-ASSEMBLER/processing/AsciiTree.h \
				 VRAI-ASSEMBLER/processing/instructs/Instructions.c VRAI-ASSEMBLER/processing/instructs/Instructions.h