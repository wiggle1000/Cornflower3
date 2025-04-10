bits 32
global kern_entry
extern main

section .bss
align 16
stack_bottom:
	resb 16*1024 ; 16kb
stack_top:


section .text
kern_entry:
		mov esp, stack_top ; set stack pointer to new stack

		call PROT_print ;print pre-kernel debug message
		
		call main ; pass to high level kernel

		call PROT_print2 ;print post-kernel debug message


		cli ; disable interrupts
	.halt:	;halt
		hlt
		jmp short .halt

PROT_print:
	push ax
		;vid mem starts at 0xb8000
		mov al, 0x02 ;smiley
		mov ah, 0x1B ;cyan on blue
		mov [0xb8000], ax
	pop ax
	ret

PROT_print2:
	push ax
		;vid mem starts at 0xb8000
		mov al, 0x03 ;heart
		mov ah, 0x1C ;red on blue
		mov [0xb8000], ax
	pop ax
	ret
