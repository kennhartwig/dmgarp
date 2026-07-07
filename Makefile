ROOT  := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
TOOLS := $(ROOT)/tools
BUILD := $(ROOT)/build
ROMS  := $(ROOT)/roms
ROM   := $(ROMS)/dmg-arp.gb
RGBASM  := $(TOOLS)/rgbasm
RGBLINK := $(TOOLS)/rgblink
RGBFIX  := $(TOOLS)/rgbfix
MGBA    := $(TOOLS)/mgba-root/usr/bin/mgba

.PHONY: all setup build build-sramtest run debug smoke clean

all: build

setup: $(RGBASM) $(MGBA)

build: $(ROM)

$(RGBASM) $(MGBA): $(ROOT)/scripts/bootstrap-tools.sh
	$(ROOT)/scripts/bootstrap-tools.sh

$(ROM): $(ROOT)/src/arpeggio.asm $(ROOT)/src/euclid-table.inc $(RGBASM)
	mkdir -p $(BUILD) $(ROMS)
	$(RGBASM) -o $(BUILD)/arpeggio.o $<
	$(RGBLINK) -o $@ $(BUILD)/arpeggio.o
	$(RGBFIX) -v -p 0xFF -m 0x03 -r 3 -t DMGARP $@

# SRAM banking probe for EMS 64M flash carts — writes/verifies signatures in all
# four 8 KB SRAM banks and shows per-bank PASS/FAIL (see docs/HARDWARE-NOTES.md).
SRAMTEST_ROM := $(ROMS)/sram-test.gb

$(SRAMTEST_ROM): $(ROOT)/src/sramtest.asm $(RGBASM)
	mkdir -p $(BUILD) $(ROMS)
	$(RGBASM) -o $(BUILD)/sramtest.o $<
	$(RGBLINK) -o $@ $(BUILD)/sramtest.o
	$(RGBFIX) -v -p 0xFF -m 0x03 -r 3 -t SRAMTEST $@

build-sramtest: $(SRAMTEST_ROM)

run: $(ROM) $(MGBA)
	$(ROOT)/scripts/run-emulator.sh $(ROM)

debug: $(ROM) $(MGBA)
	$(ROOT)/scripts/run-debugger.sh $(ROM)

smoke: $(ROM) $(MGBA)
	$(ROOT)/scripts/smoke-test.sh $(ROM)

clean:
	rm -rf $(BUILD) $(ROM)
