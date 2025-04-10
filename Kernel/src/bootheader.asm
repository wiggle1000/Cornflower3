bits 32
section .multiboot2_header
multiboot2_start:
	dd 0xE85250D6 	;magic number
	dd 0 			;environment info TODO:
	dd multiboot2_end - multiboot2_start	;header length
	dd 0x100000000 - (0xE85250D6 + 0 + (multiboot2_end - multiboot2_start))	;checksum
	dd 0,0,0,0,8	;end of data
multiboot2_end:
