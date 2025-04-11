bits 32
global jump_into_GDT

gdtr DW 0 ; For limit storage
     DD 0 ; For base storage

jump_into_GDT:
	mov   ax, [esp + 4]
	mov   [gdtr], ax
	mov   eax, [esp + 8]
	mov   [gdtr + 2], eax
	lgdt  [gdtr]
	; Reload CS register containing code selector:
	jmp   0x08:.reload_CS ; 0x08 = kernel code segment's offset << 3
.reload_CS:
   ; Reload data segment registers:
   mov   AX, 0x10 ; 0x10 = kernel data segment's offset << 3
   mov   DS, AX
   mov   ES, AX
   mov   FS, AX
   mov   GS, AX
   mov   SS, AX
   ret