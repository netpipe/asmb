[BITS 16]  
[ORG 0x7E00]  ; Loaded by bootloader at 0x7E00

mov si, input_code  ; Point to input assembly text
mov di, output_code ; Point to output buffer

parse_line:
    lodsb          ; Load character from input
    cmp al, 0      ; End of input?
    je write_binary
    cmp al, 'M'    ; Check for "MOV" instruction
    jne parse_line

    ; If we detect "MOV AX, 4C00h"
    mov byte [di], 0xB8  ; Opcode for "MOV AX, imm16"
    inc di
    mov word [di], 0x4C00 ; Operand (4C00h)
    add di, 2
    jmp parse_line

write_binary:
    mov ah, 0x03    ; BIOS write sector function
    mov al, 1       ; Write 1 sector
    mov ch, 0       ; Cylinder 0
    mov cl, 3       ; Write to sector 3
    mov dh, 0       ; Head 0
    mov dl, 0       ; First floppy/hard disk
    mov bx, output_code
    int 0x13        ; Call BIOS to write the file

    jmp $           ; Infinite loop (halt)

input_code db "MOV AX, 4C00h", 0
output_code times 512 db 0  ; Output binary buffer
