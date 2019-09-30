;
;   Sieve of Eratosthenes
;
org 0x0100

table:              equ 0x8000
table_size:         equ 1000

start:
    mov bx, table
    mov cx, table_size
    mov al, 0

p1:
    mov [bx], al        ; Write AL into address pointed to by BX
    inc bx              ; Increment BX
    loop p1             ; Decrease CX, jump if non-zero
    mov ax, 2           ; Start at 2
p2:
    mov bx, table       ; BX = table address
    add bx, ax          ; BX = BX + AX
    cmp byte [bx], 0    ; Is it prime?
    jne p3
    push ax
    call display_number
    mov al, 0x2c        ; Comma
    call display_letter
    pop ax
    mov bx, table
    add bx, ax
p4:
    add bx, ax
    cmp bx, table+table_size
    jnc p3
    mov byte [bx], 1
    jmp p4
p3: 
    inc ax
    cmp ax, table_size
    jne p2

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