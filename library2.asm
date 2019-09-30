; Save this Library as library.asm
int 0x20 ; Exit to command line

; display letter contained in AL (ASCII code, see appendix B)
display_letter:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    mov ah, 0x0e   ; Load AH with the code for terminal output
    mov bx, 0x000f ; Load BH page zero and BL color (graphic mode)
    int 0x10       ; Call BIOS to display one letter
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret            ; return to caller

; Read Keyboard into AL
read_keyboard:
    push bx
    push cx
    push dx
    push si
    push di
    mov ah, 0x00    ; Load AH with code for keyboard read
    int 0x16        ; Call the BIOS for reading keyboard
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret             ; Returns to caller

;
; Display the value of AX as a decimal number
;
display_number:
    mov dx, 0               ; Set DX to 0
    mov cx, 10              ; Set CX to 10
    div cx                  ; AX = DX:AX / CX
    push dx                 
    cmp ax, 0               ; If AX is Zero...
    je display_number_1     ; ...jump
    call display_number     ; else, call itself
display_number_1:
    pop ax
    add al, '0'             ; Convert remainder to ASCII digit
    call display_letter     ; Display on screen
    ret