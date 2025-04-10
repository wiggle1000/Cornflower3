bits 32

section .bss
align 16
stack_bottom:
	resb 16*1024 ; 16kb
stack_top:


section .text
global kern_entry
kern_entry:
	; move stack to stack top (stack expands downwards)
	mov esp, stack_top

	
		call PROT_print
		
		call extern _main ; pass to high level kernel

		; if we get here the OS is over
		call PROT_print2
		cli ; disable interrupts
	.1:	
		hlt
		jmp short .1
	ret

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
