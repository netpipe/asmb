[BITS 16]      
[ORG 0x7C00]   

mov ah, 0x02    ; BIOS read sector function
mov al, 1       ; Read 1 sector
mov ch, 0       ; Cylinder 0
mov cl, 2       ; Sector 2 (Assembler is stored here)
mov dh, 0       ; Head 0
mov dl, 0       ; First floppy/hard disk
mov bx, 0x7E00  ; Load to address 0x7E00
int 0x13        ; Call BIOS disk read

jc disk_error   ; Jump if error
jmp 0x7E00      ; Jump to loaded assembler

disk_error:
    mov si, disk_err_msg
    call print_string
    jmp $

print_string:
    lodsb
    or al, al
    jz done
    mov ah, 0x0E
    int 0x10
    jmp print_string
done:
    ret

disk_err_msg db "Disk Read Error!", 0

times 510 - ($ - $$) db 0  ; Fill to 510 bytes
dw 0xAA55                  ; Boot sector signature
