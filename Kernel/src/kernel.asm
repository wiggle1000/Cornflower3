org 0x0
bits 32

db "KERNEL.BIN PLACEHOLDER CONTENTS",0

start:
	jmp k_main

PROT_print:
	;vid mem starts at 0xb8000
	mov al, 0x02 ;smiley
	mov ah, 0x1B ;cyan on blue
	mov [0xb8000], ax
	ret

k_main:
	call PROT_print
	jmp $

; write ENDKERN! at the end of the last block for debug purposes
times (16*512 - 8)-($-$$) db 0 ;$ = current addr, $$ = start of section
db "ENDKERN!"