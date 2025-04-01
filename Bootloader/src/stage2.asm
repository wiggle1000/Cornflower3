org 0x20000
bits 16 ;still in real mode

;CR;LF
%define ENDL 0x0D, 0x0A

%define KERNEL_BUFF_SEGMENT 	0x7000
%define KERNEL_BUFF_OFFSET 		0

;free space after 1mb
%define KERNEL_TARGET_SEGMENT 	0x10000


CODE_SEG equ GDT_code - GDT_Start
DATA_SEG equ GDT_data - GDT_Start

start:
	jmp main

db "MARKER!!"

;TODO: figure out why the info isn't what's expected
get_FAT_info: ;just return for now, nonfunctional code
	
	;using ax for words and al for bytes
;	push ax
;	mov al, [fat_header_addr + 36]
;	mov [ebr_drive_number], al
;
;	mov ax, [fat_header_addr + 24]
;	mov [bdb_sectors_per_track], ax 
;
;	mov ax, [fat_header_addr + 26]
;	mov [bdb_head_count], ax 
;
;	mov ax, [fat_header_addr + 22]
;	mov [bdb_sectors_per_fat], ax 
;
;	mov al, [fat_header_addr + 16]
;	mov [bdb_fat_count], al 	
;
;	mov ax, [fat_header_addr + 14]
;	mov [bdb_reserved_sectors], ax 
;
;	mov ax, [fat_header_addr + 11]
;	mov [bdb_bytes_per_sector], ax 	
;
;	mov ax, [fat_header_addr + 17]
;	mov [bdb_dir_entries_count], ax 
;	pop ax
	ret	

;copy of FAT12 headers for now; TODO: reference them from the first sector
bdb_bytes_per_sector:		dw 512			;2 bytes
bdb_reserved_sectors:		dw 16			;2 bytes (reserve 16kb for stage 2)
bdb_fat_count:				db 2			;1 byte
bdb_dir_entries_count:		dw 0E0h			;2 bytes
bdb_sectors_per_fat:		dw 9			;2 bytes
bdb_sectors_per_track:		dw 18			;2 bytes
bdb_head_count:				dw 2			;2 bytes
; Extended Boot Record
ebr_drive_number:			db 0			;1 byte


;#### UTIL FUNCTIONS ####
enter_unreal_mode:
	.start:
		cli ; disable interrupts
   		push ds                ; save real mode
		lgdt [GDT_Descriptor] ; load Start and Size of GDT
		;change last bit of cr0 to 1 (enter protected mode)
		mov eax, cr0
		or eax, 1
		mov cr0, eax
		;jump to protected mode!
		jmp .prot
	.prot:
		mov  bx, 0x10          ; select descriptor 2
		mov  ds, bx            ; 10h = 1000		
		and al,0xFE            ; back to realmode
		mov  cr0, eax          ; by toggling bit again
		jmp .unreal
	.unreal:
		pop ds                 ; get back old segment
		sti
	ret


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

;
;Convert LBA address to CHS address
;https://en.wikipedia.org/wiki/Logical_block_addressing#CHS_conversion
; Params:
;  - ax: LBA address
; Returns: (format expected by BIOS read interrupt)
;  - cx (bits 0-5)  : sector number
;  - cx (bits 6-15) : cylinder number
;  - dh				: head number
lba_to_chs:
	push ax
	push dx

	xor dx, dx	;same as mov dx, 0 but faster and smaller
	div word [bdb_sectors_per_track] 	;puts result in ax and remainder in dx
	inc dx								;dx = (LBA % SectorsPerTrack) + 1
	mov cx, dx							;write to output
	
	xor dx, dx
	div word [bdb_head_count]			
	mov dh, dl							;move head number to high half
	mov ch, al							;ch = lower 8 bits of cyl
	shl ah, 6							;shift left
	or cl, ah							;or extra bits into bottom of cl

	pop ax								;pop dx into ax
	mov dl, al							;restore dl from it
	pop ax								;restore true ax
	ret



;
;Read sector from disk
; Params:
;  - ax: LBA address
;  - cl: number of sectors to read (up to 128)
;  - dl: drive number
;  - es:bx: mem addr to store read data
disk_read:
	push ax
	push bx
	push cx
    push dx
    push di

	push cx			;save CL (number of sectors to read)
	call lba_to_chs
	pop ax			;pop saved CL into AL

	mov ah, 02h

	mov di, 3		;retry count

	.retry:
		pusha			;bios can change anything here
		stc				;set carry flag in case bios doesn't
		int 13h			;if read succeeds, carry flag gets cleared
		jnc .done

		;fail
		popa
		call disk_reset

		dec di
		test di, di
		jnz .retry
	.fail:
		;print message
		mov si, msg_err_read
		call bios_print
		;await key and reboot
		jmp await_and_reboot
	.done:
		popa
		pop di
		pop dx
		pop cx
		pop bx
		pop ax
		ret
;
;Resets disk controller
; Params:
;  - dl: drive number
disk_reset:
	pusha

	mov ah, 0
	stc
	int 13h		;reset disk controller
	jnc .ok
	.err:
		;print message
		mov si, msg_err_read
		call bios_print
		;await key and reboot
		jmp await_and_reboot
	.ok:
		popa
		ret


;#### MAIN ENTRY ####
main:
	mov [fat_header_addr], bx ;read fat header address from stage 1
	call bios_setTextMode ;clear screen

	;print hello message
	mov si, msg_hello
	call bios_print

	call get_FAT_info ;clear screen

	;mov si, msg_prot
	;call bios_print

	;print unreal mode message
	mov si, msg_unreal
	call bios_print

	call await_key

	call enter_unreal_mode

	;call await_key

	;setup stack
	mov ss, ax ;stack segment = 0
	mov sp, 0x7C00 ;stack pointer (grows downwards)

	;print unreal mode message
	mov si, msg_unreal_ok
	call bios_print

	;read from floppy
	;bios sets dl to drive number
	mov [ebr_drive_number], dl

	;read drive params from BIOS
	push es
	mov ah, 08h
	int 13h
	jc await_and_reboot
	pop es
	
	and cl, 0x3F	;remove top 2 bits
	xor ch, ch 		;set ch to 0
	mov [bdb_sectors_per_track], cx ;sector count

	inc dh
	mov [bdb_head_count], dh		;head count

	;read FAT12 root directory
	

	;compute LBA of root directory (reserved + fats * sectors_per_fat)
	mov ax, [bdb_sectors_per_fat] ;load ax
	mov bl, [bdb_fat_count] ;load bx
	xor bh,bh
	mul bx  ;ax = bdb_sectors_per_fat * bdb_fat_count
	add ax, [bdb_reserved_sectors] ;ax += reserved
	push ax ;save to pull into call


	;push si
	;;print debug
	;mov si, msg_dbg
	;call bios_print
	;pop si

	;compute size of FAT12 root directory
	mov ax, [bdb_sectors_per_fat]
	shl ax, 5 ;ax *= 32 (directory entries are 32 bytes long)
	xor dx, dx ;dx = 0
	div word [bdb_bytes_per_sector]	;number of sectors to read, remainder in dx
	

	test dx, dx	;if dx (remainder) !=0, add 1
	jz .after_root_dir
	inc ax	;sector only partially filled with entries
	
	
.after_root_dir:

	;read root directory
	mov cl, al					;number of sectors to read (size of root dir)
	pop ax						;saved from "compute LBA of root directory"
	mov dl, [ebr_drive_number]	;drive number
	mov bx, buffer				;after bootloader
	call disk_read

	;Search loaded root directory for kernel.bin
	xor bx, bx				;directory entry index counter
	mov di, buffer			;iterator

.search_kernel:
	mov si, fname_kernel	;kernel.bin file name in FAT12 format
	mov cx, 11				;kernel.bin name length
	push di
	repe cmpsb				;repe: repeat while equal (zero flag set) OR cx reaches 0. cx decremented each iteration
							;cmpsb: fancy string compare instruction that compares bytes at si to bytes at di
	pop di
	je .found_kernel ;if equal flag is still set, all bytes matched!

	add di, 32 ;go to next directory entry
	inc bx ;increment index counter

	cmp bx, [bdb_dir_entries_count]
	jl .search_kernel	;jump if less than; if out of entries continues
	
	;print error message: kernel.bin not found!
	mov si, msg_err_kfile
	call bios_print
	call await_and_reboot;

.found_kernel:

	push si
	;print kernel found message
	mov si, msg_bin_load
	call bios_print
	pop si

	;di should have address to directory entry
	mov ax, [di + 26] ;first logical cluster (field of directory entry)
	mov [kernel_cluster], ax

	;read FAT (fila allocation table) into memory
	mov ax, [bdb_reserved_sectors] 	;LBA address
	mov bx, buffer					;where to store
	mov cl, [bdb_sectors_per_fat] 	;sectors to read
	mov dl, [ebr_drive_number]		;drive number
	call disk_read					;overwrites previous buffer


	;read kernel and process FAT chain

	mov bx, KERNEL_BUFF_SEGMENT
	mov es, bx	;set extra segment
	mov bx, KERNEL_BUFF_OFFSET

.load_kernel_loop:

	;Read next cluster
	mov ax, [kernel_cluster]

	;TODO: hardcoded, will only work on FDD
	; first cluster = (kernel_cluster-2) * sectors_per_cluster + start_sector
	; start_sector = reserved + fats + root_directory_size = 1 + 18 + 134 = 33
	add ax, 31 + 15 ;add 15 to include all 16 reserved sectors

	;Read block of file
	;ax (LBA address) is the current cluster value
	;bx (where to store) is incremented at the end of the loop
	mov cl, 1					;sectors to read
	mov dl, [ebr_drive_number]	;drive number
	call disk_read

	
	push si
	;print block load message
	mov si, msg_block_load
	call bios_print
	pop si
	
	;move block to higher mem
	push ds
	push es
	push eax
	push cx
	push di
	push esi

		mov cx, 512 ;count to copy
		;move es:di to kernel target location
		mov eax, KERNEL_TARGET_SEGMENT
		mov es, eax
		mov edi, [kernel_byte_count]
		;move ds:si to block to copy
		mov ax, [KERNEL_BUFF_SEGMENT]
		mov ds, ax
		mov esi, 0

		;do move from ds:si to es:di
		rep movsb

	pop esi
	pop di
	pop cx
	pop eax
	pop es
	pop ds

	push si
	;print block load message
	mov si, msg_block_load2
	call bios_print
	pop si

	;compute location of next cluster
	;FAT12 is evil because the cluster length is 12 BITS.
	;so we need to do some evil modulo and shifting because
	;it's not byte aligned...
	mov ax, [kernel_cluster]

	mov cx, 3
	mul cx	;ax *= cx (3)

	mov cx, 2
	div cx	;ax = ax/cx, dx = remainder of ax/cx

	mov si, buffer ;set si to start of buffer. (buffer holds File Allocation Table)
	add si, ax ;offset by ax
	mov ax, [ds:si]	;ax = FAT table entry at index si

	or dx, dx
	jz .even

.odd:
	shr ax, 4 ;shift right 4
	jmp .next_cluster_after

.even:
	and ax, 0x0FFF ;mask

.next_cluster_after:
	cmp ax, 0x0FF8 ;ff8 or more is end of chain (end of FATs for this file)
	jae .read_finish ;jump if above or equal

	;inc iterator
	push ax
		mov ax, [kernel_byte_count]
		add ax, 512
		mov [kernel_byte_count], ax
	pop ax

	mov [kernel_cluster], ax ;set current cluster to next cluster and read more
	jmp .load_kernel_loop

.read_finish:

	push si
	;print block load message
	mov si, msg_bin_done
	call bios_print
	pop si


	push si
	;print block load message
	mov si, msg_prot
	call bios_print
	pop si

	;FAR JUMP TO KERNEL!
	mov dl, [ebr_drive_number] ;put boot device in dl, like bios does

	;setup segment registers
	mov ax, KERNEL_BUFF_SEGMENT
	mov ds, ax
	mov es, ax

	jmp KERNEL_BUFF_SEGMENT:KERNEL_BUFF_OFFSET


	call await_and_reboot
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
msg_unreal: 	db "About to enter unreal mode.", ENDL, 0
msg_unreal_ok: 	db "Entered Unreal mode successfully!", ENDL, "Now searching for KERNEL.BIN...", ENDL, 0
msg_err_read: 	db "Failed to read from disk.", ENDL, 0
msg_err_kfile: 	db "KERNEL.BIN not found!", ENDL, 0
msg_bin_load: 	db "KERNEL.BIN located! Beginning block transfer:", ENDL, 0
msg_block_load:	db "[", 0x01, 0
msg_block_load2:db 0x02, "]", 0
msg_bin_done:	db "...Done! Wonderful work.", ENDL, 0
msg_prot: 		db "About to enter protected mode and pass to Kernel!", ENDL, 0

msg_dbg: 		db "debug!", ENDL, 0
msg_halt: 		db "Halting.", ENDL, 0
msg_continue: 	db "Press any key to continue...", ENDL, 0
msg_rebooting: 	db "Press any key to reboot...", ENDL, 0

fname_kernel: 	db "KERNEL  BIN"

kernel_cluster: dw 0
kernel_byte_count: dw 0
fat_header_addr: dw 0

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


; write ENDRSVD! at the end of the last block for debug purposes. also acts as a size limit guard
times (15*512 - 8)-($-$$) db 0 ;$ = current addr, $$ = start of section
db "ENDRSVD!"

buffer: