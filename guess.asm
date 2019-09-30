; guess.asm
; Guess a number between 0 and 7
org 0x0100
start:
    in al, (0x40)           ; Read the timer chip
    and al, 0x07            ; Mask bits so the values is in the range 0-7
    add al, 0x30            ; Convert to ASCII digit
    mov cl, al              ; Save AL into CL
game_loop:
    mov al, '?'            ; AL is now the '?' char
    call display_letter
    call read_keyboard      ; read keyboard
    cmp al, cl              ; compare read-in value to the generated one
    jne game_loop           ; no, start over
    call display_letter     ; display number
    mov al, ':'            ; display happy face
    call display_letter
    mov al, ')'
    call display_letter

; Save this Library as library1.asm
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