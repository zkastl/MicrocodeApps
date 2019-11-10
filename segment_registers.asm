;
; Color circles
; 
org 0x7c00

mov ax, 0x0002
int 0x10

mov ax,0xb800
mov ds, ax
mov es, ax

; Main loop
main_loop:
    mov ah, 0x00            ; set up bios clock service
    int 0x1a                ; call bios, put value into 
    mov al, dl              ; CX AND DX (clock ticks are 32bit)
                            ; moving from dl into al takes the lowest
                            ; byte (0-255)
    test al, 0x40           ; is bit 6 1?
    je m2                   ; no, jump
    not al                  ; complement bits for reverse effect
m2:
    and al, 0x3f            ; separate lower 6 bits
    sub al, 0x20            ; make range -32 to 61
    cbw                     ; extend this value to a word
    mov cx, ax              ; save to CX
    mov di, 0x0000          ; point to the screen
    mov dh, 0x00            ; row 0
m0:
    mov dl, 0x00            ; column 0
m1:
    push dx                 ; save DX (DH and DL)
    mov bx, data
    
    mov al, dh              ; take the row
    shl al, 1               ; multiply by 2 (because of the aspect ratio)
    and al, 0x3f            ; limit to 0-63
    cs xlat                 ; extract the sin value
    cbw                     ; expand to short
    push ax                 ; save in stack
    
    mov al, dl              ; take the column
    and al, 0x3f            ; limit 0-63
    cs xlat                 ; extract sin value
    cbw                     ; expand to short
    pop dx                  
    add ax, dx              ; add with previous sin
    add ax, cx              ; add with clock
    mov ah, al              ; use as color background/foreground
    mov al, 0x2a            ; use asterisk as letter
    mov [di], ax            ; put in display (word)
    add di, 2               ; go to next letter (word)
    
    pop dx                  ; restore dx
    inc dl                  ; increment column
    cmp dl, 80              ; check for end of row (80 columns)
    jne m1

    inc dh                  ; change rows
    cmp dh, 25              ; reached 25 rows?
    jne m0
    jmp main_loop

data:
    db 0,6,12,19,25,30,36,41
    db 45,49,53,56,59,61,63,64
    db 64,64,63,61,59,56,53,49
    db 45,41,36,30,24,19,12,6
    db 0,-6,-12,-19,-24,-30,-36,-41
    db -45,-49,-53,-56,-59,-61,-63,-64
    db -64,-64,-63,-61,-59,-56,-53,-49
    db -45,-41,-36,-30,-24,-19,-12,-6
    times 510-($-$$) db 0   ; Fills boot sector (510 bytes)
    db 0x55,0xaa            ; Signature so BIOS detects it as bootable