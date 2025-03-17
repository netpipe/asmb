BITS 16
ORG 0x7C00  ; BIOS loads bootloader at 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00  ; Stack grows downward from 0x7C00
    sti

    mov si, welcome_msg
    call print_string

    jmp $

; Prints a null-terminated string (BIOS INT 10h)
print_string:
    lodsb
    or al, al
    jz done
    mov ah, 0x0E  ; BIOS Teletype
    mov bh, 0x00
    int 0x10
    jmp print_string
done:
    ret

welcome_msg db "Booting Assembler...", 0

; Fill up to 510 bytes, then add boot signature
times 510 - ($ - $$) db 0
dw 0xAA55  ; Bootable signature
