org 0x7c00

cls:
    mov bx, 0x000f
    mov ax, 0x0e0a
    mov cx, 0x25
cls_loop:
    int 0x10
    cmp cx, 0x00
    je start
    dec cx
    jmp cls_loop
start:
    push cs                 ; Assumes CS contains 0x0000
    pop ds
    mov bx, string
repeat:
    mov al, [bx]
    test al, al
    je end
    push bx
    mov ah, 0x0e
    mov bx, 0x000f
    int 0x10
    pop bx
    inc bx
    jmp repeat
end:
    jmp $                   ; Jump over itself ($ gives current address)

string:
    db "Hello, World!",0
    times 510-($-$$) db 0   ; Fills boot sector (510 bytes)
    db 0x55,0xaa            ; Signature so BIOS detects it as bootable