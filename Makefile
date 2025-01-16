BOCHS:=./bochs
BUILD:=./build
SRC:=./src

Include:=$(SRC)/include
Bootloader:=bootloader
Kernel:=kernel

CFLAGS=-Wall -Wextra -Wswitch-enum -Wmissing-prototypes -std=c11 -pedantic
LDFLAGS=-Ttext 0xC0001500 -e main

$(BUILD)/$(Bootloader)/%.bin: $(SRC)/$(Bootloader)/%.asm
	@if [ ! -d "$(dir $@)" ]; then mkdir -p $(dir $@); fi
	nasm -I $(Include) $< -o $@

$(BUILD)/$(Kernel)/%.bin: $(BUILD)/$(Kernel)/%.o
	@if [ ! -d "$(dir $@)" ]; then mkdir -p $(dir $@); fi
	$(LD) $(LDFLAGS) $< -o $@

$(BUILD)/$(Kernel)/%.o: $(SRC)/$(Kernel)/%.c
	@if [ ! -d "$(dir $@)" ]; then mkdir -p $(dir $@); fi
	$(CC) $(CFLAGS) -c $< -o $@

build: $(BUILD)/$(Bootloader)/boot.bin $(BUILD)/$(Bootloader)/loader.bin $(BUILD)/$(Kernel)/main.bin
	yes | bximage -q -func=create -hd=60M -imgmode=flat $(BUILD)/master.img
	dd if=$(BUILD)/$(Bootloader)/boot.bin of=$(BUILD)/master.img bs=512 count=1 conv=notrunc
	dd if=$(BUILD)/$(Bootloader)/loader.bin of=$(BUILD)/master.img bs=512 count=4 seek=2 conv=notrunc

run:
	bochs -f $(BOCHS)/bochsrc.disk

clean:
	@rm -rf $(BUILD)

.PHONY: build run
