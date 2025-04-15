#pragma once
#include <cstdint>
#include "helpers/vgaPrint.h"
#include "hardware/PIC.h"
#include "hardware/port_io.h"

#define IDT_MAX_DESCRIPTORS 128

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

extern const char* INTERRUPT_NAMES[];

extern void* isr_stub_table[];

extern uint8_t lastInterrupt;

extern "C" __attribute__((noreturn)) void exception_handler(int8_t vector, int32_t address);
extern "C" void PIC_interrupt_handler(int8_t vector, int32_t address);

void idt_set_descriptor(uint8_t vector, void* isr, uint8_t flags);
void idt_init(void);