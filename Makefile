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