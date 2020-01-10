; mandelbrot set 
; by Oscar T.
; comments by Zak K.

; Algorithm
; 
; PsuedoCode
; X = 0
; Y = 0
;
; While Iteration < 1000 and X^2 + Y^2 < 4
;   t = x^2 - y^2 - ix
;   y = 2xy + iy
;   x = t
;   iteration = iteration + 1
;
; C version
; /* ix and iy are fractions for offset and zoom */
; iteraion = 0;
; x = 0.0
; y = 0.0
; while(iteraion < 100 && x*x + y*y < 4.0) {
;       t = x*x + y*y + ix;
;       y = 2*x*y + iy;
;       x = t;
;       iteration++;
; }
; /* Now use 'iteration' variable as color */

cpu 8086            ; NASM warns us of non-8086 instructions
org 0x7C00         ; Start of code

; working in VGA 320x200x256 colors
; 
; 0xfa00 is the first byte of video memory
; not visible on the screen

v_a:    equ 0xfa00  ; Y-coordinate
v_b:    equ 0xfa02  ; X-coordinate
v_x:    equ 0xfa04  ; x 32-bit for Mandelbrot 24.8 fraction
v_y:    equ 0xfa08  ; y 32-bit for Mandelbrot 24.8 fraction
v_s1:   equ 0xfa0c  ; temporal s1
v_s2:   equ 0xfa10  ; temproal s2 (48-bit/6 bytes)

start:
mov ax, 0x0013  ; Set mode 320x200x256
int 0x10        ; Video interruption vector

mov ax, 0xa000  ; 0xa000 video segment
mov ds, ax      ; setup data segment
mov es, ax      ; setup extended segment

m4:
mov ax, 199     ; 199 is the bottommost row
mov [v_a], ax   ; save into v_a

m0:
mov ax, 319     ; 319 is the rightmost column
mov [v_b], ax   ; save into v_b

m1:
xor ax, ax
mov [v_x], ax   ; x = 0.0
mov [v_x + 2], ax
mov [v_y], ax   ; y = 0.0
mov [v_y + 2], ax
mov cx, 0       ; iteration counter

m2:
push cx         ; save counter
mov ax, [v_x]   ; read x
mov dx, [v_x + 2]
call square32   ; get x^2
push dx         ; save result to stack
push ax
mov ax, [v_y]   ; read y
mov dx, [v_y+ + 2]
call square32   ; get y^2

pop bx
add ax, bx      ; add both (x^2 + y^2)
pop bx
adc dx, bx

pop cx          ; restore counter
cmp dx, 0       ; Result is >= 4.0?
jne m3
cmp ax, 4*256
jnc m3          ; yes, jump

push cx
mov ax, [v_y]   ; read y
mov dx, [v_y + 2]
call square32
push dx
push ax
mov ax, [v_x]   ; read x
mov dx, [v_x + 2]
call square32

pop bx
sub ax, bx      ; subtract (x^2 - y^2)
pop bx
sbb dx, bx

; Adding x-coordinate like a fraction
; to current value
;
add ax, [v_b]   ; add x coordinate
adc dx, 0
add ax, [v_b]   ; add x cooordinate
adc dx, 0
sub ax, 480     ; center coordinate
sbb dx, 0

push ax         ; save result to stack
push dx

mov ax, [v_x]   ; get x
mov dx, [v_x + 2]
mov bx, [v_y]    ; get y
mov cx, [v_y + 2]
call mul32      ; multiply (x*y)

shl ax, 1       ; multiply by 2
rcl dx, 1

add ax, [v_a]   ; add y-coordinate
adc dx, 0
add ax, [v_a]   ; add y-coordinate
adc dx, 0
sub ax, 250     ; center coordinate
sbb dx, 0

mov [v_y], ax   ; save as y-value
mov [v_y + 2], dx

pop dx          ; restore value from stack
pop ax

mov ax, [v_x]   ; get x
mov dx, [v_x + 2]
mov bx, [v_y]   ; get y
mov cx, [v_y + 2]
call mul32      ; multiply (x*y)

shl ax, 1
rcl dx, 1

add ax, [v_a]   ; add y coordinate
adc dx, 0
add ax, [v_a]   ; add y coordinate
adc dx, 0
sub ax, 250
sbb dx, 0

 mov [v_y], ax  ; save as new y -value
 mov [v_y + 2], dx

 pop dx         ; restore value from stack
 pop ax

 mov [v_x], ax  ; save as new x value
 mov [v_x + 2], dx

 pop cx
 inc cx         ; increase iteration counter
 cmp cx, 100    ; attempt 100?
 je m3          ; yes, jump
 jmp m2         ; no, continue

 m3:
 mov ax, [v_a]
 mov dx, 320
 mul dx
 add ax, [v_b]
 xchg ax, di

 add cl, 0x20
 mov [di], cl
 
dec word [v_b]
jns m1

dec word [v_a]
jns m0

mov ah, 0x00
int 0x16

mov ax, 0x0002
int 0x10

jmp $

; calculate a squared number
; DX:AX = (DX:AX * DX:AX) / 256

square32:
mov bx, ax
mov cx, dx

mul32:
xor dx, cx
pushf
xor dx, cx
jns mul32_2
not ax
not dx
add ax, 1
adc dx, 0

mul32_2:
test cx, cx
jns mul32_3
not bx
not cx
add bx, 1
adc cx, 0

mul32_3:
mov [v_s1], ax
mov [v_s1 + 2], dx

mul bx
mov [v_s2], ax
mov [v_s2 + 2], dx

mov ax, [v_s1 + 2]
mul cx
mov [v_s2 + 4], ax

mov ax, [v_s1 + 2]
mul bx
add [v_s2 + 2], ax
adc [v_s2 + 4], dx

mov ax, [v_s1]
mul cx
add [v_s2+2], ax
adc [v_s2+4], dx

mov ax, [v_s2+1]
mov dx, [v_s2+3]

popf
jns mul32_1
not ax
not dx
add ax, 1
adc dx, 0

mul32_1:
ret
data:
times 509-($-$$) db 0x21
db 0x00,0x55,0xaa