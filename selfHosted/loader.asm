ORG 0x7E00  ; Load assembler at 0x7E00

load_assembler:
    mov ah, 2       ; BIOS Read Sectors
    mov al, 10      ; Read 10 sectors
    mov ch, 0       ; Cylinder 0
    mov cl, 2       ; Start at sector 2
    mov dh, 0       ; Head 0
    mov dl, 0       ; Drive 0 (floppy)
    mov bx, 0x9000  ; Load at 0x9000
    mov es, bx
    mov bx, 0       ; Offset 0
    int 13h         ; BIOS Disk Read

    jc disk_error   ; If carry flag set, print error

    jmp 0x9000      ; Jump to assembler code

disk_error:
    mov si, err_msg
    call print_string
    jmp $

err_msg db "Disk Read Error!", 0
