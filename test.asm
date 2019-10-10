org 0x100

call start_a_thing

display_letter:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    mov cx, 0xffff
display_letter2:
    mov ah, 0x0e   ; Load AH with the code for terminal output
    mov bx, 0x000f ; Load BH page zero and BL color (graphic mode)
    int 0x10       ; Call BIOS to display one letter
    loop display_letter2 
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax

    int 0x20

start_a_thing:
    mov ax, 0x00b2
    ret