# mandelbrot set 
# by Oscar T.
# comments by Zak K.

# Algorithm
# 
# PsuedoCode
# X = 0
# Y = 0
#
# While Iteration < 1000 and X^2 + Y^2 < 4
#   t = x^2 - y^2 - ix
#   y = 2xy + iy
#   x = t
#   iteration = iteration + 1
#
# C version
# /* ix and iy are fractions for offset and zoom */
# iteraion = 0;
# x = 0.0
# y = 0.0
# while(iteraion < 100 && x*x + y*y < 4.0) {
#       t = x*x + y*y + ix;
#       y = 2*x*y + iy;
#       x = t;
#       iteration++;
# }
# /* Now use 'iteration' variable as color */

cpu 8086            ; NASM warns us of non-8086 instructions
org 0x0100          ; Start of code

; working in VGA 320x200x256 colors
; 
; 0xfa00 is the first byte of video memory
; not visible on the screen

v_a:    equ 0xfa00  ; Y-coordinate
v_b:    equ 0xfa02  ; X-coordinate
v_x:    equ 0xfa04  ; x 32-bit for Mandelbrot 24.8 fraction
v_y:    equ 0xfa08  ; y 32-bit for Mandelbrot 24.8 fraction
v_s1:   equ 0xfa0c  ; temporal s1
v_s1:   equ 0xfa10  ; temproal s2 (48-bit/6 bytes)

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
