#pragma once
#include <cstdint>

#define IDT_MAX_DESCRIPTORS 32

//Represents an IDT Table entry.
typedef struct
{
	uint16_t	isr_addr_low;
	uint16_t	isr_segment;
	uint8_t		reserved;
	uint8_t		attributes;
	uint16_t	isr_addr_high;

}__attribute__((packed)) idt_entry_t;


//Represents a value of the IDT Register.
typedef struct {
	uint16_t	limit;
	uint32_t	base;
} __attribute__((packed)) idtr_t;

extern void* isr_stub_table[];

extern "C" __attribute__((noreturn)) void exception_handler(void);

void idt_set_descriptor(uint8_t vector, void* isr, uint8_t flags);
void idt_init(void);