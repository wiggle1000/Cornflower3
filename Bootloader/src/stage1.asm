org 0x7C00 ;bootloader gets loaded here by BIOS
bits 16 ;starts in real mode

;CR;LF
%define ENDL 0x0D, 0x0A

;#### FAT12 HEADER ####
FAT_HEADER:
jmp short start
nop
bdb_oem:					db "MSWIN4.1"	;8 bytes
bdb_bytes_per_sector:		dw 512			;2 bytes
bdb_sectors_per_cluster:	db 1			;1 byte
bdb_reserved_sectors:		dw 16			;2 bytes (reserve 16kb for stage 2)
bdb_fat_count:				db 2			;1 byte
bdb_dir_entries_count:		dw 0E0h			;2 bytes
bdb_total_sectors:			dw 2880			;2 bytes (1.44MB/512)
bdb_media_descriptor_type:	db 0F0h			;2 bytes (3.5" floppy)
bdb_sectors_per_fat:		dw 9			;2 bytes
bdb_sectors_per_track:		dw 18			;2 bytes
bdb_head_count:				dw 2			;2 bytes
bdb_hidden_sector_count:	dd 0			;4 bytes
bdb_large_sector_count:		dd 0			;4 bytes
; Extended Boot Record
ebr_drive_number:			db 0			;1 byte
ebr_reserved:				db 0			;1 byte
ebr_signature:				db 28h			;1 byte (signature, must be 0x28 or 0x29)
ebr_volume_id:				db 78h, 56h, 34h, 12h	;4 bytes, serial #
ebr_colume_label:			db 'Cornflower ';11 bytes, MUST be padded with spaces
ebr_system_id:				db 'FAT12   '	;8 bytes, MUST be padded with spaces


;#### MAIN ENTRY ####
start:

	;setup data segments
	xor ax, ax ;same as mov ax, 0 but faster and smaller
	mov ds, ax ;data segment = 0
	mov es, ax ;extra segment = 0

	;setup stack
	mov ss, ax ;stack segment = 0
	mov sp, 0x7C00 ;stack pointer (grows downwards)

	;make sure we are at 0000:7C00 instead of 7C00:0000 (BIOS might do this)
	push es
	push word .after
	retf
.after:

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

	
.read_kernel:

	;di should have address to directory entry
	mov ax, [di + 26] ;first logical cluster (field of directory entry)
	mov [kernel_cluster], ax

	;Read stage2
	;  - ax: LBA address
	;  - cl: number of sectors to read (up to 128)
	;  - dl: drive number
	;  - es:bx: mem addr to store read data
	mov ax, STAGE2_START
	mov cl, 15	;sectors to read
	mov dl, [ebr_drive_number]		;drive number
	
	mov bx, STAGE2_LOAD_SEGMENT
	mov es, bx	;set extra segment
	mov bx, STAGE2_LOAD_OFFSET

	call disk_read

.read_finish:

	mov si, msg_done
	call bios_print

	;FAR JUMP TO KERNEL!
	mov dl, [ebr_drive_number] ;put boot device in dl, like bios does
	mov bx, FAT_HEADER ;put address of fat header in bx

	;setup segment registers
	mov ax, STAGE2_LOAD_SEGMENT
	mov ds, ax
	mov es, ax

	jmp STAGE2_LOAD_SEGMENT:STAGE2_LOAD_OFFSET


	call await_and_reboot
halt:
	;print message
	mov si, msg_halt
	call bios_print
	.haltLoop: ;in case hlt gets resumed by nmi
		cli
		hlt
		jmp .haltLoop


;#### UTIL FUNCTIONS ####

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

await_and_reboot:
	mov si, msg_rebooting
	call bios_print
	mov ah, 0
	int 16h		;await keypress
	ret
	jmp 0FFFFh:0	;jump to beginning of bios

;#### DISK FUNCTIONS ####

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


;#### STRINGS ####
msg_halt: 		db "Halt.", ENDL, 0
msg_done: 		db "Stage2 Loaded! Passing control.", ENDL, 0
msg_err_read: 	db "Can't read boot drive!", ENDL, 0
msg_rebooting: 	db "Press any key...", ENDL, 0

STAGE2_LOAD_SEGMENT	equ 0x1000
STAGE2_LOAD_OFFSET	equ 0
STAGE2_START	equ 0x1 ;in BLOCKS!!

;#### VARS ####
kernel_cluster: dw 0

;last two bytes of first sector must be 0xAA55 to be detected as bootable
times 510-($-$$) db 0 ;$ = current addr, $$ = start of section
dw 0xAA55 ;2 bytes