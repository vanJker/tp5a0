BOCHS:=./bochs
BUILD:=./build
SRC:=./src

build:
	bximage -q -func=create -hd=60M -imgmode=flat $(BUILD)/master.img
	nasm $(SRC)/bootloader/boot.asm -o $(BUILD)/boot.bin
	dd if=$(BUILD)/boot.bin of=$(BUILD)/master.img bs=512 count=1 conv=notrunc

run:
	bochs -f $(BOCHS)/bochsrc.disk

clean:
	@rm -rf $(BUILD)/*

.PHONY: build run
