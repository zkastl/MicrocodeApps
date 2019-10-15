;
; Tic Tac Toe
; 
org 0x100

board: equ 0x0300

start:
    mov bx, board       ; put the address of the game board into BX
    mov cx, 9           ; count 9 squares
    mov al, '1'         ; Move 0x31 '1' into AL
b09:
    mov [bx], al        ; save it into the square (1 byte)
    inc al              ; increase al, giving us the next digit
    inc bx              ; increase direction
    loop b09            ; decrement CX, jmp if non-zero

b10:
    call show_board
    call get_movement   ; Get Movement
    mov byte [bx], 'X'  ; Put X into the square
    call show_board     ; Show board
    call get_movement   ; Get movement
    mov byte [bx], '0'  ; put 0 into the square
    jmp b10

get_movement:
    call read_keyboard
    cmp al, 0x1b        ; Esc key pressed
    je do_exit          ; Yes, exit
    sub al, 0x31        ; Subtract code for ASCII '1'
    jc get_movement     ; If it is less than? wait for another key
    cmp al, 0x09        ; compare with 9
    jnc get_movement    ; is it greater than or equal to? wait
    cbw                 ; expand AL to 16 bits using AH
    mov bx, board       ; BX points to board
    add bx, ax          ; add the key entered
    mov al, [bx]        ; get square content
    cmp al, 0x40        ; compare with 0x40
    jnc get_movement    ; is it greater than or equal to? Wait
    call show_crlf      ; line change
    ret                 ; return, now BX points to square
    
find_line:
    ; first horizontal row
    mov al, [board]
    cmp al, [board+1]
    jne b01
    cmp al, [board+2]
    je won

b01:
    ;leftmost vertical row
    cmp al, [board+3]
    jne b04
    cmp al, [board+6]
    je won

b04:
    cmp al, [board+4]
    jne b05
    cmp al, [board+8]
    je won

b05:
    mov al, [board+3]
    cmp al, [board+4]
    jne b02
    cmp al, [board+5]
    je won
b02:
    mov al, [board+6]
    cmp al, [board+7]
    jne b03
    cmp al, [board+8]
    je won
b03:
    mov al, [board+1]
    cmp al, [board+4]
    jne b06
    cmp al, [board+7]
    je won
b06:
    mov al, [board+2]
    cmp al, [board+5]
    jne b07
    cmp al, [board+8]
    je won
b07:
    cmp al, [board+4]
    jne b08
    cmp al, [board+6]
    je won
b08:
    ret

won:
    call display_letter
    mov al, 0x20
    call display_letter
    mov al, 0x77 ; 'w'
    call display_letter
    mov al, 0x69
    call display_letter
    mov al, 0x6e ; 'n'
    call display_letter
    mov al, 0x73
    call display_letter

do_exit:
    int 0x20            ; exit to command line

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