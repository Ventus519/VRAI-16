CC ?= gcc

PROGRAM ?= program.vrai
HEX_DUMP = $(PROGRAM:.vrai=.hex)

ASSEMBLER_SOURCES := VRAI-ASSEMBLER/main.c \
					 VRAI-ASSEMBLER/Assembler.c VRAI-ASSEMBLER/Assembler.h \
					 VRAI-ASSEMBLER/field_definitions_vrai.h \
					 VRAI-ASSEMBLER/processing/AsciiTree.c VRAI-ASSEMBLER/processing/AsciiTree.h \
					 VRAI-ASSEMBLER/processing/instructs/Instructions.c VRAI-ASSEMBLER/processing/instructs/Instructions.h

VERILOG_TARGET ?= build/sim.out

.PHONY: default
default: VRAIa $(VERILOG_TARGET)

.PHONY: cleanup
cleanup:
	rm -r build
	rm -f program.vrai_preproc program_alpha.hex

.PHONY: assembler
assembler: VRAIa

VRAIa: $(ASSEMBLER_SOURCES)
	$(CC) -o VRAIa $(ASSEMBLER_SOURCES)

.PHONY: assemble
assemble: VRAIa
	./VRAIa $(HEX_DUMP) $(PROGRAM)
ifneq ($(PROGRAM), program_alpha.vrai)
# used for waveform generation via the Verilog compiled result. 
	cat $(HEX_DUMP) > program_alpha.hex 
endif

program_alpha.hex: VRAIa
	./VRAIa $(HEX_DUMP) $(PROGRAM)
ifneq ($(PROGRAM), program_alpha.vrai)
# used for waveform generation via the Verilog compiled result. 
	cat $(HEX_DUMP) > program_alpha.hex 
endif


.PHONY: vcompile
vcompile: $(VERILOG_TARGET)

$(VERILOG_TARGET): source.cmd
	mkdir build
	iverilog -c source.cmd -o $(VERILOG_TARGET)

.PHONY: run
run: VRAI_SYNC_TEST.vcd

VRAI_SYNC_TEST.vcd: program_alpha.hex $(VERILOG_TARGET)
	vvp $(VERILOG_TARGET)


.PHONY: wave
wave: VRAI_SYNC_TEST.vcd
	gtkwave build/VRAI_SYNC_TEST.vcd

.PHONY: test
test: VRAI_SYNC_TEST.vcd
	gtkwave build/VRAI_SYNC_TEST.vcd
