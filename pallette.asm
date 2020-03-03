; Show VGA palette (oscar toledo g.)

cpu 8086
org 0x7c00

; memory screen uses 64000 pixels
; this means that 0xfa00 is the first byte
; of memory not visible on the screen

v_a: equ 0xfa00
v_b: equ 0xfa02

start:
    mov ax, 0x0013      ; set mode 320x200x256
    int 0x10            ; video interruption vector

    mov ax, 0xa000      ; 0xa000 video segment
    mov ds, ax          ; setup data segment
    mov es, ax          ; setup extended segment

m4:
    mov ax, 127         ; 127 as row
    mov [v_a], ax       ; save into v_a

m0:
    mov ax, 127         ; 127 as column
    mov [v_b], ax

m1:
    mov ax,[v_a]        ; get y-coordinate
    mov dx, 320         ; multiply by 320 (size of pixel row)
    mul dx              ; multiply dx by al? or ax? store in ax?
    add ax, [v_b]       ; add x-coordinate to result
    xchg ax, di         ; pass ax into di (more efficient than [mov di, ax])
    
    mov ax, [v_a]       ; get y-coordinate
    and ax, 0x78        ; separate 4 bits- = 16 rows
    add ax, ax          ; value between 0x00 and 0xf0
    
    mov bx, [v_b]       ; get current x-coordinate
    and bx, 0x78        ; separate 4 bits = 16 columns
    mov cl, 3
    shr bx, cl          ; shift right by 3
    add ax, bx          ; combine with previous value
    stosb               ; write al into previous address pointed by DI
    
    dec word [v_b]      ; decrease column
    jns m1              ; is it negative? No, jump
    
    dec word [v_a]      ; decrease row
    jns m0              ; is it negative? No, jump

    mov ah, 0x00        ; wait for a key
    int 0x16            ; keyboard interrupt vector

    mov ax, 0x0002      ; set mode 80x25 text
    int 0x10            ; video interruption vector

data:
    times 509-($-$$) db 0x21
    db 0x00,0x55,0xaa
    ; int 0x20            ; exit to command line