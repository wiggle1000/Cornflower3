org 0x20000
bits 16 ;still in real mode

;CR;LF
%define ENDL 0x0D, 0x0A

CODE_SEG equ GDT_code - GDT_Start
DATA_SEG equ GDT_data - GDT_Start

start:
	jmp main

db "MARKER!!"

;#### UTIL FUNCTIONS ####

enter_protected_mode:
	cli ; disable interrupts
	lgdt [GDT_Descriptor] ; load Start and Size of GDT
	;change last bit of cr0 to 1 (enter protected mode)
	mov eax, cr0
	or eax, 1
	mov cr0, eax
	;jump to protected mode!
	jmp CODE_SEG:prot_entry

;Print string
; Params:
;  - ds:si = string
bios_print:
	push si
	push ax
	push bx
	.loop:
		lodsb ;special instruction that loads from ds:si into al and increments si
		
		cmp al, 0
		je .post

		;bios call to write char
		mov ah, 0x00E
		mov bh, 0
		int 0x10

		jmp .loop
	.post:

	pop bx
	pop ax
	pop si
	ret

bios_setTextMode:
	push ax
	mov ax, 0x30
	int 0x10
	pop ax
	ret

await_and_reboot:
	mov si, msg_rebooting
	call bios_print
	mov ah, 0
	int 16h		;await keypress
	jmp 0FFFFh:0	;jump to beginning of bios

await_key:
	pusha
	mov si, msg_continue
	call bios_print
	mov ah, 0
	int 16h		;await keypress
	popa
	ret

;#### MAIN ENTRY ####
main:

	call bios_setTextMode ;clear screen

	;print hello message
	mov si, msg_hello
	call bios_print

	mov si, msg_prot
	call bios_print

	call await_key
	
	call bios_setTextMode ;clear screen
	jmp enter_protected_mode

halt:
	;print message
	mov si, msg_halt
	call bios_print
	.haltLoop: ;in case hlt gets resumed by nmi
		cli
		hlt
		jmp .haltLoop



;#### STRINGS ####
msg_hello: 		db "-------- CORNFLOWER BOOTLOADER S2 --------", ENDL, "Hello from Stage 2!", ENDL, 0
msg_prot: 		db "About to enter protected mode.", ENDL, 0
msg_halt: 		db "Halting.", ENDL, 0
msg_rebooting: 	db "Press any key to reboot...", ENDL, 0
msg_continue: 	db "Press any key to continue...", ENDL, 0


;#### GDT ####
;set up code and data segments to max size, spanning full memory
GDT_Start:
	GDT_null: ;can't use first entry
		times 8 db 0
	GDT_code:
		;first 16 bits of limit
		dw 0xffff
		;first 24 bits of base
		dw 0
		db 0
		;"Access Byte" contains these flags (reading order):
		; - Present?
		; - Privelege level (bit 2)
		; - Privelege level (bit 1)
		; - Type (0 = system, 1 = code or data)
		; - Executable (0=data, 1=code)
		; - Direction (0 grows up),
		; - RW (if code segment 1=readable 0=nonreadable; if data segment 1=writable 0=readonly)
		; - Accessed (used by CPU, 1=disabled; should be disabled(1) unless needed, causes page fault in read only segments)
		db 10011011b ; present, privelege 0, code/data, code, grow up, readable, access bit disabled
		;other flags + last 4 bits of limit
		; - Granularity (0=1 byte, 1=4KiB)
		; - "DB" (0=real mode, 1=protected mode)
		; - Long Mode (0=other, 1=64bit)
		; - Reserved (0)
		db 11001111b ;large grains, protected mode
		;last 8 bits of base
		db 0
	GDT_data:
		dw 0xffff
		dw 0
		db 0
		db 10010010b ; present, privelege 0, code/data, data, grow up, writable, access bit enabled
		db 11001111b ;large grains, protected mode
		db 0
GDT_End:


GDT_Descriptor:
	dw GDT_End - GDT_Start-1 	;size
	dd GDT_Start 				;start


[bits 32]
prot_entry:
		;set up segment registers and stack
		;TODO: learn more about this
		mov ax, DATA_SEG ;set ax to data segment
		mov ds, ax
		mov ss, ax
		mov es, ax
		mov fs, ax
		mov gs, ax
		mov ebp, 0x9000
		mov esp, ebp
		
		call PROT_print
		jmp $
	
[bits 32]
PROT_print:
	;vid mem starts at 0xb8000
	mov al, 'H'
	mov ah, 0x1B ;cyan on blue
	mov [0xb8000], ax
	ret


; write ENDRSVD! at the end of the last block for debug purposes.
times (15*512 - 8)-($-$$) db 0 ;$ = current addr, $$ = start of section
db "ENDRSVD!"