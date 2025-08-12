# SimpleOS (16-bit real-mode demo)

A tiny educational OS. A 512-byte boot sector (`boot.asm`) loads a one-sector kernel (`kernel.asm`) at 0x0000:0x8000. The kernel prints a prompt, reads input via BIOS int 16h, and prints via BIOS teletype int 10h (AH=0Eh). It implements four simple (stub) commands.

## Requirements (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install -y nasm qemu-system-i386 dosfstools

## Build & Run (quick)
chmod +x build.sh run.sh
./build.sh
./run.sh

## Commands in QEMU
ls               - list demo files (README.TXT, OTHER.TXT)
rn <old> <new>   - prints: Renamed <old> to <new>
mv <src> <dst>   - prints: Moved <src> to <dst>
del <file>       - prints: Deleted <file>

## Files
boot.asm    - boot sector; loads kernel from sector 2 and jumps
kernel.asm  - simple shell with the four commands above
README.TXT, OTHER.TXT - demo files shown by 'ls'
build.sh, run.sh - scripts to build the floppy image and run QEMU
