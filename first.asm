;
; The Incredible Hello World Program!
;
org 0x0100 ; Declares that every instruction after this starts at this address
start:
    mov bx, string ; Load register BX with the address of 'string'
repeat:
    mov al, [bx] ; Load a byte in AL from address pointed by BX
    test al, al ; Test AL for Zero
    je end ; Jump if the above is equal to the end label (jmp if zero)
    push bx ; push BX register into the Stack
    mov ah, 0x0e ; Load AH with code for terminal output
    mov bx, 0x000f ; BH is page zero, BL is color (graphic mode)
    int 0x10 ; Call the bios for displaying one character
    pop bx ; return BX from the stack
    inc bx ; increase register BX by 1 (next letter)
    jmp repeat ; Jump to 'repeat' label
end:
    int 0x20 ; Exit to command line
string:
    db "Hello, World",0 ; String literal