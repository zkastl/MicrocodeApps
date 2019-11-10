;
; Color circles
; 
org 0x7c00


    times 510-($-$$) db 0   ; Fills boot sector (510 bytes)
    db 0x55,0xaa            ; Signature so BIOS detects it as bootable