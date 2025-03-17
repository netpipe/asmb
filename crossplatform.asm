BITS 16  ; Run in real mode (for DOS, compatible with bootloaders)

section .data
    input_file db "example.asm", 0
    output_file db "output.bin", 0
    buffer resb 256
    opcode_table db "MOV", 0, "ADD", 0, "SUB", 0

section .bss
    fd_input resb 2
    fd_output resb 2
    instruction resb 16

section .text
    global _start

_start:
    ; ==== DOS (INT 21h) FILE OPEN ====
    mov ah, 0x3D    ; DOS open file
    mov al, 0       ; Read-only mode
    mov dx, input_file
    int 0x21
    jc error        ; Check for errors
    mov [fd_input], ax

    ; ==== DOS (INT 21h) CREATE OUTPUT FILE ====
    mov ah, 0x3C    ; DOS create file
    mov cx, 0       ; Normal file attributes
    mov dx, output_file
    int 0x21
    jc error
    mov [fd_output], ax

read_line:
    ; ==== DOS (INT 21h) READ FILE ====
    mov ah, 0x3F    ; DOS read file
    mov bx, [fd_input]
    mov cx, 256
    mov dx, buffer
    int 0x21
    cmp ax, 0
    je close_files

    call parse_instruction
    call process_instruction
    jmp read_line

close_files:
    ; ==== DOS (INT 21h) CLOSE FILES ====
    mov ah, 0x3E
    mov bx, [fd_input]
    int 0x21
    mov bx, [fd_output]
    int 0x21
    jmp exit

parse_instruction:
    mov si, buffer
    mov di, instruction
    mov cx, 8
parse_loop:
    lodsb
    cmp al, ' '
    je end_parse
    stosb
    loop parse_loop
end_parse:
    ret

process_instruction:
    mov si, instruction
    mov di, opcode_table
    mov cx, 3
find_opcode:
    repe cmpsb
    je generate_code
    add di, 4
    loop find_opcode
    jmp error

generate_code:
    ; MOV opcode (B8)
    cmp word [instruction], 'MOV'
    jne not_mov
    mov al, 0xB8
    jmp write_code
not_mov:
    cmp word [instruction], 'ADD'
    jne not_add
    mov al, 0x01
    jmp write_code
not_add:
    cmp word [instruction], 'SUB'
    jne error
    mov al, 0x29

write_code:
    mov ah, 0x40    ; DOS write file
    mov bx, [fd_output]
    mov dx, instruction
    mov cx, 1
    int 0x21
    ret

error:
    mov ah, 0x09
    mov dx, error_msg
    int 0x21
    jmp exit

exit:
    mov ax, 0x4C00
    int 0x21

section .data
error_msg db "Error!", 0x0D, 0x0A, "$"
