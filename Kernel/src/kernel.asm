global kern_entry

section .text
bits 32

kern_entry:
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

db "ENDKERN!"