extern exception_handler
extern PIC_interrupt_handler

%macro isr_define 1
isr_stub_%+%1:
	push dword [esp-4]
	push word %1
	call exception_handler
	add esp, 2 + 4
	iret
%endmacro

%macro isr_define_err 1
isr_stub_%+%1:
	push dword [esp-4]
	push word %1
	call exception_handler
	add esp, 2 + 4
	iret
%endmacro

%macro isr_define_pic 1
isr_stub_%+%1:
	push dword [esp-4]
	push word %1
	call PIC_interrupt_handler
	add esp, 2 + 4
	iret
%endmacro

isr_define		0
isr_define		1
isr_define		2
isr_define		3
isr_define		4
isr_define		5
isr_define		6
isr_define		7
isr_define_err	8
isr_define		9
isr_define_err	10
isr_define_err	11
isr_define_err	12
isr_define_err	13
isr_define_err	14
isr_define		15
isr_define		16
isr_define_err	17
isr_define		18
isr_define		19
isr_define		20
isr_define		21
isr_define		22
isr_define		23
isr_define		24
isr_define		25
isr_define		26
isr_define		27
isr_define		28
isr_define		29
isr_define_err	30
isr_define		31

isr_define_pic	32
isr_define_pic	33
isr_define_pic	34
isr_define_pic	35
isr_define_pic	36
isr_define_pic	37
isr_define_pic	38
isr_define_pic	39

isr_define_pic	40
isr_define_pic	41
isr_define_pic	42
isr_define_pic	43
isr_define_pic	44
isr_define_pic	45
isr_define_pic	46
isr_define_pic	47

global isr_stub_table
isr_stub_table:
%assign i 0
%rep    32+16
    dd isr_stub_%+i
	%assign i i+1
%endrep
