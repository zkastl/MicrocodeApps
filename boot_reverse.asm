org 0x7c00
start:
    push cs                 ; Assumes CS contains 0x0000
    pop ds                  ; set the ds register to cs, should be 0x0000
    mov bx, data
reverse:
    mov al, [bx]
    test al, al
    je something
    inc bx
    jmp reverse
something:
    dec bx
    mov al, [bx]
    push bx
    mov ah, 0x0e
    mov bx, 0x000f
    int 0x10
    pop bx
    cmp bx, data
    je end
    jmp something
end:
    jmp $                       ; Jump over itself ($ gives current address)
data:
    db "Hello, World!",0
    db "!dlroW ,olleH",0
    times 509-($-$$) db 0x21    ; Fills boot sector (510 bytes)
    db 0x00,0x55,0xaa           ; Signature so BIOS detects it as bootable

    ; Comments on this program
    ; This is your basic Hello world program, but does some other stupid stuff
    ; This program read in the data segment at the end of the program and increments 
    ; through it, displaying in basic monochrome font the char it reads. If it finds
    ; a zero, it halts
    ; however, this data field does not end its string with \0 (as proper). It instead
    ; continues to read through trash data, displaying it byte by byte until the last
    ; which is set to zero (to halt gracefuully)