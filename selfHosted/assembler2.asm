[BITS 16]
[ORG 0x7C00]

start:
    ; Display welcome message
    mov si, welcome_msg
    call print_string

    ; Assemble a simple MOV AX, 4C00h instruction
    mov si, input_code
    mov di, output_code
    call assemble

    ; Write compiled binary to disk
    mov si, filename
    mov bx, output_code
    mov cx, 1  ; Number of sectors
    call write_file

    ; List stored files
    call list_files

    ; Execute stored file
    call run_file

    jmp $

; ==========================
;  Simple Assembler
; ==========================
assemble:
    lodsb
    cmp al, 0
    je done

    cmp al, 'M'      ; MOV instruction?
    jne assemble

    mov byte [di], 0xB8   ; Opcode for "MOV AX, imm16"
    inc di
    mov word [di], 0x4C00
    add di, 2
    jmp assemble

done:
    ret

; ==========================
;  Write File to Disk
; ==========================
write_file:
    call find_empty_slot
    jc error

    ; Store filename in file table
    mov di, 0x8000
    mov cx, 8
copy_name:
    movsb
    loop copy_name

    mov word [di], start_sector
    add di, 2
    mov word [di], num_sectors
    add di, 2

    ; Write file table to disk (Sector 20)
    mov ah, 3  
    mov al, 1
    mov ch, 0
    mov cl, 20
    mov dh, 0
    mov dl, 0
    mov bx, 0x8000
    int 13h

    ; Write file data
    mov cx, num_sectors
    mov si, file_buffer
    mov bx, start_sector
write_loop:
    mov ah, 3
    mov al, 1
    mov ch, 0
    mov cl, bl
    mov dh, 0
    mov dl, 0
    mov bx, si
    int 13h
    add bx, 512
    loop write_loop

    ret

; ==========================
;  Read File from Disk
; ==========================
read_file:
    call find_file_entry
    jc file_not_found

    mov di, 0x8000
    add di, 8
    mov bx, [di]  ; Start sector
    add di, 2
    mov cx, [di]  ; Number of sectors

    mov si, 0x9000
read_loop:
    mov ah, 2
    mov al, 1
    mov ch, 0
    mov cl, bl
    mov dh, 0
    mov dl, 0
    mov bx, si
    int 13h
    add si, 512
    loop read_loop

    ret

; ==========================
;  Run File from Disk
; ==========================
run_file:
    call read_file
    jmp 0x9000

; ==========================
;  Delete File from Disk
; ==========================
delete_file:
    call find_file_entry
    jc file_not_found

    mov di, 0x8000
    mov cx, 12
clear_entry:
    mov byte [di], 0
    inc di
    loop clear_entry

    ; Write updated file table back
    mov ah, 3  
    mov al, 1
    mov ch, 0
    mov cl, 20
    mov dh, 0
    mov dl, 0
    mov bx, 0x8000
    int 13h

    ret

; ==========================
;  List Files on Disk
; ==========================
list_files:
    mov si, 0x8000
    mov cx, 42

print_loop:
    lodsb
    or al, al
    jz done
    mov ah, 0x0E
    int 0x10
    jmp print_loop

done:
    ret

; ==========================
;  Print String Routine
; ==========================
print_string:
    lodsb
    or al, al
    jz print_done
    mov ah, 0x0E
    int 0x10
    jmp print_string

print_done:
    ret

; ==========================
;  Data and Buffers
; ==========================
welcome_msg db "Assembler & File System", 0
input_code db "MOV AX, 4C00h", 0
output_code times 512 db 0
filename db "TEST    ", 0
