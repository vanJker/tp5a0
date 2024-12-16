BOCHS:=./bochs
BUILD:=./build
SRC:=./src

build:
	bximage -q -func=create -hd=60M -imgmode=flat $(BUILD)/master.img

run:
	bochs -f $(BOCHS)/bochsrc.disk

clean:
	@rm -rf $(BUILD)

.PHONY: build run
