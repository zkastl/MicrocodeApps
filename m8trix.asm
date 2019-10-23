; Credit to HellMood/DESiRE

org 100h

S:

; sets ES to the screen, assume si = 0x100
; 0x101 is SBB AL,9F and changes the char
; without the CR flag, there would be no
; animation ;)
les bx, [si]

; gets 0x02 (green) in the first run
; afterwards, it is not called again
; because of alignment ;)
lahf

; print the green color
; (it also 0xAB9F and works as segment)
stosw

; and skip one row
inc di

;
inc di

; repeat on 0x101
jmp short S+1
