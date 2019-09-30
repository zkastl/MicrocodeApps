;
; The Incredible Keyboard Reading Program
;
org 0x0100 ; Declares that every instruction after this starts at this address
start:
    mov ah, 0x00   ; Read from keyboard
    int 0x16       ; Call the BIOS to read it

    cmp al, 0x1b   ; ESC key pressed?
    mov ah, 0x0e   ; Load AH with code for terminal output
    je exit
    mov bx, 0x010f ; BH is page zero, BL is color (graphics mode)
    int 0x10       ; Call the BIOS for displaying one letter
    jmp start
exit:
    int 0x20