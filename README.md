SimpleOS (16-bit real-mode demo)
**SimpleOS** is a tiny educational operating system that demonstrates the x86 PC boot flow and a minimalist
shell in **16-bit real mode**.
A 512-byte boot sector (`boot.asm`) is loaded by the BIOS at `0x7C00`, reads the next sector (the kernel) into
memory at `0x0000:0x8000`, and jumps there.
The kernel (`kernel.asm`) sets up a small stack, reads keys via BIOS `int 16h`, and prints text via BIOS teletype
`int 10h` (AH=0Eh).
It implements **four simple (stub) commands**:
• `ls` — lists example files (`README.TXT`, `OTHER.TXT`)
• `rn ` — prints: `Renamed to `
• `mv ` — prints: `Moved to `
• `del ` — prints: `Deleted `
These handlers demonstrate parsing and output and **do not** modify files on disk (kept simple for the
assignment).

**Instructions to run**

1. **Install requirements (Ubuntu/Debian):**
sudo apt-get update
sudo apt-get install -y nasm qemu-system-i386 dosfstools
2. **Make scripts executable (if needed):**
chmod +x build.sh run.sh
3. **Build the floppy image:**
./build.sh
This assembles `boot.asm` and `kernel.asm`, creates a FAT12 `floppy.img`,
copies `README.TXT` and `OTHER.TXT` into it, then writes the boot sector and kernel.
4. **Run in QEMU:**
./run.sh
5. **Try the commands in QEMU:**
 ls
 rn foo bar
 mv alpha beta
 del gamma
Files
• `boot.asm` — 512-byte boot sector; loads kernel from sector 2 and jumps to it
• `kernel.asm` — simple shell with `ls`, `rn`, `mv`, `del`
• `README.TXT`, `OTHER.TXT` — demo files shown by `ls`
• `build.sh` — builds the FAT12 image and writes boot+kernel
• `run.sh` — launches QEMU with the built image
Troubleshooting
• If QEMU doesn’t boot, re-run `./build.sh` to regenerate the image.
• If scripts give “permission denied”, run `chmod +x build.sh run.sh`.
Tested environment
WSL (Ubuntu), NASM, QEMU, dosfstools.
