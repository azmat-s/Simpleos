; kernel.asm — simple shell kernel at 0x8000
BITS 16
org 0x8000

    cli
    xor ax, ax
    mov ss, ax
    mov sp, 0x0700       ; stack at 0x0000:0x0700
    mov ax, 0x0000
    mov ds, ax
    mov es, ax

    ; Print prompt
    mov si, prompt
.print_prompt:
    lodsb
    cmp al, 0
    je .halt
    mov ah, 0x0E
    int 0x10
    jmp .print_prompt

.halt:
    call read_line

    ; Dispatch “ls” command
    mov si, input_buf
    mov al, [si]
    cmp al, 'l'
    jne .not_ls
    mov al, [si+1]
    cmp al, 's'
    jne .not_ls
    call do_ls
.not_ls:

    ; Print CR+LF
    mov al, 0x0D
    mov ah, 0x0E
    int 0x10
    mov al, 0x0A
    mov ah, 0x0E
    int 0x10

    ; Redisplay prompt
    mov si, prompt
    jmp .print_prompt

; Data
prompt     db 'simpleos> ', 0
input_buf  times 64 db 0      ; buffer for up to 63 chars + null

;----------------------------------------
; read_line: read keys until Enter, echo and store
;----------------------------------------
read_line:
    mov di, input_buf
.read_char:
    mov ah, 0x00
    int 0x16             ; BIOS keyboard
    cmp al, 0x0D         ; Enter?
    je .done_read
    mov ah, 0x0E         ; BIOS teletype
    int 0x10             ; echo
    stosb                ; store in buffer
    jmp .read_char
.done_read:
    mov byte [di], 0     ; null-terminate
    ret

;----------------------------------------
; do_ls: stub that prints a fixed file list
;----------------------------------------
do_ls:
    ; Move to new line before listing
    mov al, 0x0D        ; Carriage Return
    mov ah, 0x0E
    int 0x10
    mov al, 0x0A        ; Line Feed
    mov ah, 0x0E
    int 0x10

    mov si, ls_files
.print_file:
    lodsb
    cmp al, 0
    je .done
    mov ah, 0x0E
    int 0x10
    jmp .print_file

.done:
    ret

ls_files:
    db 'README.TXT', 0x0D, 0x0A
    db 'OTHER.TXT', 0x0D, 0x0A
    db 0

