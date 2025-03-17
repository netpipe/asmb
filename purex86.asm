BITS 32  ; Ensure we're in 32-bit mode (for raw binary execution)

section .data
    input_file db "example.asm", 0  ; Input source file
    output_file db "output.bin", 0  ; Output binary file
    buffer resb 256                 ; Buffer for reading lines
    opcode_table db "MOV", 0, "ADD", 0, "SUB", 0  ; Supported mnemonics

section .bss
    fd_input resb 4  ; File descriptor for input
    fd_output resb 4 ; File descriptor for output
    instruction resb 32  ; Buffer for parsed instruction
    operand1 resb 8
    operand2 resb 8

section .text
    global _start

_start:
    ; Open input file (example.asm)
    mov eax, 5           ; sys_open
    mov ebx, input_file  ; filename
    mov ecx, 0           ; read-only mode
    int 0x80
    mov [fd_input], eax  ; Store file descriptor

    ; Open output file (output.bin)
    mov eax, 5           ; sys_open
    mov ebx, output_file ; filename
    mov ecx, 0x42        ; O_WRONLY | O_CREAT
    mov edx, 0x1B6       ; File permissions 0666
    int 0x80
    mov [fd_output], eax ; Store file descriptor

read_line:
    ; Read line from input file
    mov eax, 3           ; sys_read
    mov ebx, [fd_input]
    mov ecx, buffer
    mov edx, 256
    int 0x80
    cmp eax, 0           ; EOF?
    je close_files

    ; Parse instruction
    call parse_instruction

    ; Process the instruction
    call process_instruction

    jmp read_line  ; Continue reading

close_files:
    ; Close files
    mov eax, 6       ; sys_close
    mov ebx, [fd_input]
    int 0x80

    mov eax, 6
    mov ebx, [fd_output]
    int 0x80

    ; Exit
    mov eax, 1       ; sys_exit
    xor ebx, ebx
    int 0x80

parse_instruction:
    ; Basic parser: extract instruction & operands from the buffer
    mov esi, buffer
    mov edi, instruction
    mov ecx, 8
copy_instr:
    lodsb
    cmp al, ' '
    je end_instr
    stosb
    loop copy_instr
end_instr:
    mov edi, operand1
    lodsb
    cmp al, 0
    je end_parse
    stosb
    mov edi, operand2
    lodsb
    cmp al, 0
    je end_parse
    stosb
end_parse:
    ret

process_instruction:
    ; Match instruction and write machine code
    mov esi, instruction
    mov edi, opcode_table
    mov ecx, 3  ; Number of opcodes

find_opcode:
    mov ebx, 0
    repe cmpsb
    je generate_code
    add edi, 4  ; Move to next mnemonic
    loop find_opcode

    jmp error_unknown  ; If no match

generate_code:
    ; MOV opcode (B8 + reg value)
    cmp dword [instruction], 'MOV'
    jne not_mov
    mov al, 0xB8  ; MOV opcode for immediate-to-register
    jmp write_code

not_mov:
    cmp dword [instruction], 'ADD'
    jne not_add
    mov al, 0x01  ; ADD opcode
    jmp write_code

not_add:
    cmp dword [instruction], 'SUB'
    jne error_unknown
    mov al, 0x29  ; SUB opcode

write_code:
    ; Write the opcode to output file
    mov eax, 4
    mov ebx, [fd_output]
    mov ecx, instruction
    mov edx, 1
    int 0x80
    ret

error_unknown:
    ; Print error message
    mov eax, 4
    mov ebx, 1
    mov ecx, unknown_msg
    mov edx, unknown_len
    int 0x80
    ret

section .data
    unknown_msg db "Error: Unknown instruction", 10
    unknown_len equ $ - unknown_msg
