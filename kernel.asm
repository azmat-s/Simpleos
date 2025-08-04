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

    ; Dispatch "ls" command
    mov si, input_buf
    mov al, [si]
    cmp al, 'l'
    jne .check_rn
    mov al, [si+1]
    cmp al, 's'
    jne .check_rn
    call do_ls
    jmp .after_cmd

.check_rn:
    ; Dispatch "rn" command
    mov si, input_buf
    mov al, [si]
    cmp al, 'r'
    jne .check_mv
    mov al, [si+1]
    cmp al, 'n'
    jne .check_mv
    call do_rn
    jmp .after_cmd

.check_mv:
    ; Dispatch "mv" command
    mov si, input_buf
    mov al, [si]
    cmp al, 'm'
    jne .check_del
    mov al, [si+1]
    cmp al, 'v'
    jne .check_del
    call do_mv
    jmp .after_cmd

.check_del:
    ; Dispatch "del" command
    mov si, input_buf
    mov al, [si]
    cmp al, 'd'
    jne .after_cmd
    mov al, [si+1]
    cmp al, 'e'
    jne .after_cmd
    mov al, [si+2]
    cmp al, 'l'
    jne .after_cmd
    call do_del

.after_cmd:
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
    ; Newline before list
    mov al, 0x0D
    mov ah, 0x0E
    int 0x10
    mov al, 0x0A
    mov ah, 0x0E
    int 0x10

    mov si, ls_files
.print_file:
    lodsb
    cmp al, 0
    je .ls_done
    mov ah, 0x0E
    int 0x10
    jmp .print_file
.ls_done:
    ret

ls_files:
    db 'README.TXT',0x0D,0x0A
    db 'OTHER.TXT', 0x0D,0x0A
    db 0

;----------------------------------------
; do_rn: stub to rename a file
;----------------------------------------
do_rn:
    ; Newline before output
    mov al, 0x0D
    mov ah, 0x0E
    int 0x10
    mov al, 0x0A
    mov ah, 0x0E
    int 0x10

    ; Print “Renamed ”
    mov si, rn_msg1
.print1:
    lodsb
    cmp al, 0
    je .print_old
    mov ah, 0x0E
    int 0x10
    jmp .print1

.print_old:
    ; Echo old name from input_buf, skipping "rn "
    mov di, input_buf
    add di, 3          ; skip 'r','n',' '
.copy_old:
    mov al, [di]
    cmp al, ' '        ; stop at next space
    je .print_to
    mov ah, 0x0E
    int 0x10
    inc di
    jmp .copy_old

.print_to:
    ; Print “ to ”
    mov si, rn_msg2
.print2:
    lodsb
    cmp al, 0
    je .print_new
    mov ah, 0x0E
    int 0x10
    jmp .print2

.print_new:
    ; Echo new name (skip space after old name)
    inc di             ; skip the space
.copy_new:
    mov al, [di]
    cmp al, 0         ; until null
    je .rn_done
    mov ah, 0x0E
    int 0x10
    inc di
    jmp .copy_new

.rn_done:
    ret

rn_msg1 db 'Renamed ',0
rn_msg2 db ' to ',0

;----------------------------------------
; do_mv: stub to move a file
;----------------------------------------
do_mv:
    ; Newline before output
    mov al, 0x0D
    mov ah, 0x0E
    int 0x10
    mov al, 0x0A
    mov ah, 0x0E
    int 0x10

    ; Print “Moved ”
    mov si, mv_msg1
.print_moved:
    lodsb
    cmp al, 0
    je .print_src
    mov ah, 0x0E
    int 0x10
    jmp .print_moved

.print_src:
    ; Echo source name (skip “mv ”)
    mov di, input_buf
    add di, 3          ; skip 'm','v',' '
.copy_src:
    mov al, [di]
    cmp al, ' '        ; stop at space before dest
    je .print_to
    mov ah, 0x0E
    int 0x10
    inc di
    jmp .copy_src

.print_to:
    ; Print “ to ”
    mov si, mv_msg2
.print_to_loop:
    lodsb
    cmp al, 0
    je .print_dest
    mov ah, 0x0E
    int 0x10
    jmp .print_to_loop

.print_dest:
    ; Echo dest name (skip space)
    inc di
.copy_dest:
    mov al, [di]
    cmp al, 0
    je .mv_done
    mov ah, 0x0E
    int 0x10
    inc di
    jmp .copy_dest

.mv_done:
    ret

mv_msg1 db 'Moved ',0
mv_msg2 db ' to ',0

;----------------------------------------
; do_del: stub to delete a file
;----------------------------------------
do_del:
    ; Newline before output
    mov al, 0x0D
    mov ah, 0x0E
    int 0x10
    mov al, 0x0A
    mov ah, 0x0E
    int 0x10

    mov si, del_msg
.print6:
    lodsb
    cmp al, 0
    je .del_done
    mov ah, 0x0E
    int 0x10
    jmp .print6

.del_done:
    ret

del_msg db 'Deleted file',0
EOF
