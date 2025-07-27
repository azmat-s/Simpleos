; boot.asm — your 512-byte bootloader
BITS 16
org 0x7C00

    cli
    xor ax,ax
    mov ss,ax
    mov sp,0x7C00
    mov ax,0x0000
    mov ds,ax
    mov es,ax

    ; Read sector #2 (kernel) into 0x0000:0x8000
    mov ah,0x02       ; BIOS read sectors
    mov al,1          ; read 1 sector
    mov ch,0          ; cylinder 0
    mov cl,2          ; sector 2
    mov dh,0          ; head 0
    mov bx,0x8000     ; ES:BX → 0x0000:0x8000
    int 0x13
    jc .disk_error

    ; Jump to our kernel at 0x0000:0x8000
    jmp 0x0000:0x8000

.disk_error:
    hlt
    jmp .disk_error

; Pad to exactly 510 bytes
times 510-($-$$) db 0
dw 0xAA55           ; Boot signature
