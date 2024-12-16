BOCHS:=./bochs
BUILD:=./build
SRC:=./src

Include:=$(SRC)/include
Bootloader:=$(SRC)/bootloader

$(BUILD)/%.bin: $(Bootloader)/%.asm
	nasm -I $(Include) $< -o $@

build: $(BUILD)/boot.bin $(BUILD)/loader.bin
	bximage -q -func=create -hd=60M -imgmode=flat $(BUILD)/master.img
	dd if=$(BUILD)/boot.bin of=$(BUILD)/master.img bs=512 count=1 conv=notrunc
	dd if=$(BUILD)/loader.bin of=$(BUILD)/master.img bs=512 count=4 seek=2 conv=notrunc

run:
	bochs -f $(BOCHS)/bochsrc.disk

clean:
	@rm -rf $(BUILD)/*

.PHONY: build run
