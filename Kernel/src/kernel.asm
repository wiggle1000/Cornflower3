org 0x
bits 32

db "KERNEL.BIN PLACEHOLDER CONTENTS",0


PROT_print:
	;vid mem starts at 0xb8000
	mov al, 'H'
	mov ah, 0x1B ;cyan on blue
	mov [0xb8000], ax
	ret