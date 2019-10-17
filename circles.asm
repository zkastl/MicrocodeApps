;
; Color circles
; 
org 0x100

mov ax, 0x0002      ; setup text 80x25 mode color
int 0x10            ; call BIOS

mov ax, 0xb800     ; segment for video data
mov ds, ax          ; ... load into DS
mov es, ax          ; ... load into ES

;
; Main loop
;
main_loop:
    mov ah, 0x00    ; service to read the clock
    int 0x1a        ; call the BIOS
    mov al, dl
    test al, 0x40   ; bit 6 is 1?
    je m2           ; no, jump
    not al         ; complement bits for referse effect
m2:
    and al, 0x3f    ; separate lower six bits
    sub al, 0x20    ; make it -32 to +31
    cbw             ; extend byte to word
    mov cx, ax      ; save to CX
    mov di, 0x0000  ; point to the screen
    mov dh, 0       ; row
m0:
    mov dl, 0       ; column
m1:
    push dx         ; save dx to stack (dh and dl)
    mov bx, sin_table

    mov al, dh      ; take the row
    shl al, 1       ; multiply by 2 (because aspect ratio)
    and al, 0x3f    ; limit to 0-63
    cs xlat         ; extract sin value
    cbw             ; exten to 16 bits
    push ax         ; save to stack

    mov al, dl      ; take hte column
    and al, 0x3f    ; limit to 0-63
    cs xlat         ; extract sin value
    cbw
    pop dx
    add ax, dx      ; add with previous sin
    add ax, cx      ; add with clock time
    mov ah, al      ; use as color backgorund/foreground
    mov al, 0x2a    ; use asterisk as lettter
    mov [di], ax    ; put in display [word]
    add di, 2       ; go to next letter [word]
    
    pop dx          ; restore dx
    inc dl          ; increment column
    cmp dl, 80      ; reached 80 columns?
    jne m1          ; no, jump

    inc dh          ; increment row
    cmp dh, 25      ; reached 25 rows?
    jne m0          ; no, jump
    
    mov ah, 0x01    ; bios service, get keyboard state
    int 0x16        ; call bios
    jne key_pressed ; jump if a key is pressed
    jmp main_loop   ; repeat

key_pressed:
    int 0x20        ; exit to command line

; sin table of 360 degrees in 64 bytes
; -1.0 is -64 and +1.0 is 64
sin_table:
    db 0,6,12,19,24,30,36,41
    db 45,49,53,56,59,61,63,64
    db 64,64,63,61,59,56,53,49
    db 45,41,36,30,24,19,12,6
    db 0,-6,-12,-19,-24,-30,-36,-41
    db -45,-49,-53,-56,-59,-61,-63,-64
    db -64,-64,-63,-61,-59,-56,-53,-49
    db -45,-41,-36,-30,-24,-19,-12,