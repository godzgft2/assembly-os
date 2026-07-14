# x86 Bootloader

A minimal 16-bit x86 bootloader written in NASM assembly. Boots directly from a floppy image with no OS and no C runtime underneath it.

## What it does

- Loads into memory at the standard boot-sector address (`0x7c00`)
- Reads two additional disk sectors via BIOS interrupt `0x13`, with error handling for failed reads or an incorrect sector count
- Prints the first word of each loaded sector in hexadecimal, using a hand-written hex-to-ASCII conversion routine
- Implements its own string-printing routine via BIOS interrupt `0x10`
- Ends with the required boot-sector padding and `0xaa55` magic number

## Build

```
nasm myfirst.asm -f bin -o myfirst.bin
dd if=myfirst.bin of=myfirst.flp bs=512 count=1 conv=notrunc
```

## Run

```
qemu-system-x86_64 -fda myfirst.flp
```
