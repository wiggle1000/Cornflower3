#pragma once
#include <cstdint>
#include "helpers/vgaPrint.h"

#define NUM_GDT_ENTRIES 5


//Represents a GDT Table entry.
typedef struct
{
	uint16_t	limit1;
	uint16_t	base1;
	uint8_t		base2;
	uint8_t		access;
	uint8_t		flags_and_limit2;
	uint8_t		base3;

}__attribute__((packed)) gdt_segment_descriptor_t;

//Represents a value of the GDT Register.
typedef struct {
	uint16_t	limit;
	uint32_t	base;
} __attribute__((packed)) gdtr_t;

void gdt_init(void);
void gdt_set_descriptor(uint8_t index, uint32_t base, uint32_t limit, uint8_t flags, uint8_t access);