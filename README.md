# TP5A0

TP5A0 is An Experimental 32-Bit Macrokernel.

## Quick Start

```sh
$ make build
$ make run
```

## Components

### Bootloader

Boot and load tp5a0 kernel, also enable protected mode and paging. 

- boot: In the 0th sector (LBA), and be loaded to memory address 0x7c00 ~ 0x7dff, size of 512B.
- loader: In the 2nd ~ 4th sectors (LBA), and be loaded to memory 0x900 ~ 0xcff, size of 2KB.
