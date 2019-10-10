;
; Tic Tac Toe
; 
org 0x100

board: equ 0x0300

start:
    mov bx, board   ; put the address of the game board into BX
    mov cx, 9       ; count 9 squares
    mov al, '1'     ; Move 0x31 '1' into AL
b09:
    mov [bx], al    ; save it into the square (1 byte)
    inc al          ; increase al, giving us the next digit
    inc bx          ; increase direction
    loop b09        ; decrement CX, jmp if non-zero

b10:
    call show_board
    call get_movement
    mov byte [bx], 'X'
    call show_board
    call get_movement
    mov byte [bx], '0'
    jmp b10

get_movement:
    call read_keyboard
    cmp al, 0x1b
    je do_exit
    sub al, 0x31
    jc get_movement
    cmp al, 0x09
    jnc get_movement
    cbw
    mov bx, board
    add bx, ax
    mov al, [bx]
    cmp al, 0x40
    

do_exit:
    int 0x20

show_board:
    mov bx, board
    call show_row
    call show_div
    mov bx, board+3
    call show_row
    call show_div
    mov bx, board+6
    jmp show_row

show_row:
    call show_square
    mov al, 0x7c
    call display_letter
    call show_square
    mov al, 0x7c
    call display_letter
    call show_square

show_crlf:
    mov al, 0x0d
    call display_letter
    mov al, 0x0a
    jmp display_letter

show_div:
    mov al, 0x2d
    call display_letter
    mov al, 0x2b
    call display_letter
    mov al, 0x2d
    call display_letter
    mov al, 0x2b
    call display_letter
    mov al, 0x2d
    call display_letter
    jmp show_crlf

show_square:
    mov al, [bx]
    inc bx
    jmp display_letter

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