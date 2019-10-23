; "Essence" - by HellMood/DESiRE - 5 October 2019
; 64 byte msdos intro, showing animated raycasted objects
; with fake pathtracing and fake lighting while 
; playing ambient MIDI sound, which is coded for dosbox 0.74
; On a real MsDos/FreeDos, the demo will work but no sound
; will play unless a MIDI capable soundcard is present
; On Dosbox, some configuration is needed to provide sufficient
; emulation power and enable the MIDI UART mode, which saves
; a few bytes
; --------------------------------------------------------------
; assemble with "nasm.exe <this> -fbin -o <this>.com"
; --------------------------------------------------------------
; Set ES to the screen to perform the "Rrrola trick", see 
; http://www.sizecoding.org/wiki/General_Coding_Tricks
push 0x9FF6
pop es
; Set mode to 0x13, +0x80 means not deleting the screen content
; that is 320x200 pixes in 256 colors
mov al, 0x93
int 0x10
; Setting port to MIDI data port, assuming it is in UART mode
; 0x3F has to be sent to 0x331 first, if UART mode is not on.
mov dx, 0x330
; Effectivly outputting all the code to the MIDI data port.
; CX=255 at start, DS=CS, SI=0x100, see MIDI section below
rep outsb
; setting DS to zero, top stack normally contains the return 
; address. DS is needed to be 0 to access a timer later on
pop ds
; CL is the iteration count for a ray, CH is 0 all the time; 
; The value is chosen to generate a blue background texture
; Choosing 64 instead would lead to a totally black background
X: mov cl, 63
; BL is the current depth of the a ray. We start with minus 64.
; We cast rays in the negative direction to calculate a point
; in 3D and the texture color at the same time. If a ray hits 
; an object from this side, the object function has a reasonable
; texture value. From the other side, it would always be black.
; CL, BL are decoupled because decrementing -128 leads to 127
; and since we are using signed multiplication for keeping things
; centered, that would result in very buggy and ugly behavior.
; They are also decoupled becuase of visual beauty: due to the
; usage of signed 8-bit coordinates. Objects close to the projection
; center are way too coarse and move way too fast.
mov bl, -64
; At this point, AL contains the color of the previous pixel.
; By design, of the object formula, the last 4 bits contain the
; texture value while the 5th bit is always set, which maps it to
; the 16 color gray scale suitable for the VGA default colors. Other
; bits may be set too, so they are masked.
; https://www.fountainware.com/EXPL/vga_color_palettes.htm
; Simulaneously, the object function, in combination with the
; palette subset, creates the impression of lighting from the top left.
; The right, bottom, nad back side appears to be black. Changing the 
; object formula will result in changing the texture, visibility and
; lighting as well.
and al, 31
; Outputting the pixel on the screen and increment pointer
stosb
; Instead of going pixel by pixel, the following jmps psuedorandomly
; across the scrern, this smooths the animation a lot and looks a bit
; like pathtracing.
imul di,byte 117
; the inner loop of each ray, decrementing BX means advancing the ray
; in negative direction by 1
L: dec bx
; Assign the Rrrola constant to register AX
mov ax,0xcccd
; place the signed coordinates X and Y into DL and DH
mul di
; centering for X is implicitly done by offsetting the segment
; Centering Y has to be done "manually". Any value can be used as long
; as it doesn't show the signed overflow on the screen.
mov al, dh
sbb al, 73
; multiply AL=Y by the current distance to get a projection(1)
imul bl
; Get X into AL, while saving the result into DX (DH)
xchg ax, dx
; multiply AL=X by the current distance, to get a projection(2)
imul bl
; Considering an implicit division by 256, the projected coordinates
; now reside in DH and AH, while the depth is in BL. The following
; sequence calculates whether the current 3D position belongs to an
; object. Objects are normal cubes defined by:
; f(x,y,z) = (X & Y & Z & 16 != 0)
mov al, dh
; offset by X timer, effectively producing 18.2 FPS
; http://vitaly_filatov.tripod.com/ng/asm/asm_002.29.html
add ah, [0x46c]
and al, ah
and al, bl
test al, 16
; the inner loop is done when either the iteration count has reached
; zero or the function f(x,y,z) is true (object hit)
loopz L
; the outer loop repeats endlessly
jmp short X

; MIDI data section, actually code above and memory below is sent to
; the MIDI data port as well, but it doesn't matter.
db 0xc0     ; set instrunent on channel 0 to next value
db 89       ; instrunment 89 = pad2 of general MIDI
db 0x90     ; play notes on channel 0, minor chord over 4 octaves
db 28       ; note 1, very deep
db 127      ; volume 1, maximum value to let the subwoofers shake
db 59       ; note 2, fitting to note 1
db 80       ; volume 2, a bit reduced to not overshadow the bass
db 67       ; note 3 fitting to notes 1 and 2
db 65       ; volume 3, event more reduced to the other notes