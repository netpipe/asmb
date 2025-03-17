ORG 0x9000  ; Loaded at 0x9000 by bootloader

start:
    mov si, prompt_msg
    call print_string

    call read_line  ; Read user input
    call assemble   ; Convert to machine code
    call write_disk ; Write output file

    jmp start

; Reads a line of input from keyboard
read_line:
    mov di, buffer
    xor cx, cx
input_loop:
    mov ah, 0x00  ; BIOS Keyboard Input
    int 0x16      ; Wait for key
    cmp al, 0x0D  ; Enter key?
    je end_input
    stosb         ; Store in buffer
    inc cx
    jmp input_loop
end_input:
    mov byte [di], 0  ; Null-terminate string
    ret

; Parses and translates assembly into binary
assemble:
    mov si, buffer
    mov di, binary_output
    lodsb
    cmp al, 'M'
    jne not_mov
    lodsb
    cmp al, 'O'
    jne not_mov
    lodsb
    cmp al, 'V'
    jne not_mov
    ; Convert MOV AX, 4C00h to opcode B8 00 4C
    mov byte [di], 0xB8
    inc di
    mov word [di], 0x4C00
    add di, 2
not_mov:
    ret

; Writes compiled binary to disk using BIOS INT 13h
write_disk:
    mov ah, 3   ; BIOS Write
    mov al, 1   ; 1 sector
    mov ch, 0   ; Cylinder 0
    mov cl, 3   ; Sector 3
    mov dh, 0   ; Head 0
    mov dl, 0   ; Drive 0 (Floppy)
    mov bx, binary_output
    mov es, bx
    mov bx, 0
    int 13h     ; Write sector
    ret

prompt_msg db "Enter Assembly Code: ", 0
buffer times 256 db 0
binary_output times 512 db 0  ; Output buffer (one sector)
