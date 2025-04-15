#include "gdt.h"

__attribute__((aligned(16)))
static gdt_segment_descriptor_t gdt[NUM_GDT_ENTRIES];

static gdtr_t gdtr;

extern "C" void jump_into_GDT(uint16_t limit, uint32_t base);

void gdt_init()
{
    __asm__ volatile ("cli");
    gdtr.base = (uintptr_t)&gdt[0];
    gdtr.limit = (uint16_t)(sizeof(gdt_segment_descriptor_t) * NUM_GDT_ENTRIES - 1);

	VGAPrint::SetColors(VGAPrint::VGA_COLOR_LIGHT_CYAN, VGAPrint::VGA_COLOR_BLACK);
	VGAPrint::Write("Setting up GDT.\n");

	VGAPrint::SetColors(VGAPrint::VGA_COLOR_BLUE, VGAPrint::VGA_COLOR_BLACK);
	VGAPrint::Write(" NULL  - ");
	gdt_set_descriptor(0, 0, 0, 0, 0); //null descriptor
	VGAPrint::Write(" KCode - ");
	gdt_set_descriptor(1, 0, 0xFFFFF, 0b1100, 0x9A); //kernel mode code
	VGAPrint::Write(" KData - ");
	gdt_set_descriptor(2, 0, 0xFFFFF, 0b1100, 0x92); //kernel mode data
	VGAPrint::Write(" UCode - ");
	gdt_set_descriptor(3, 0, 0xFFFFF, 0b1100, 0xFA); //user mode code
	VGAPrint::Write(" UData - ");
	gdt_set_descriptor(4, 0, 0xFFFFF, 0b1100, 0xF2); //user mode data
	
	jump_into_GDT(gdtr.limit, gdtr.base);

    __asm__ volatile ("sti");

	
	VGAPrint::SetColors(VGAPrint::VGA_COLOR_LIGHT_GREEN, VGAPrint::VGA_COLOR_BLACK);
	VGAPrint::Write("GDT Ok!\n");
}

void gdt_set_descriptor(uint8_t index, uint32_t base, uint32_t limit, uint8_t flags, uint8_t access)
{
    gdt_segment_descriptor_t* entry = &gdt[index];

    entry->base1 = base & 0xFFFF;
    entry->base2 = (base>>16) & 0xFF;
    entry->base3 = (base>>24) & 0xFF;
	
    entry->limit1 = limit & 0xFFFF;
    entry->flags_and_limit2 = (limit>>16) & 0x0F;

	entry->flags_and_limit2 |= (flags<<4) & 0xF0;

	entry->access = access;
	
	VGAPrint::Write("Base:   ");
	VGAPrint::WriteUInt16(entry->base1, true);
	VGAPrint::Write(" ");
	VGAPrint::WriteByte(entry->base2, true);
	VGAPrint::Write(" ");
	VGAPrint::WriteByte(entry->base3, true);
	VGAPrint::Write(" | Limit:  ");
	VGAPrint::WriteUInt16(entry->limit1, true);
	VGAPrint::Write(" ");
	VGAPrint::WriteByte(entry->flags_and_limit2, true);
	VGAPrint::Write(" (+Flags) | Access: ");
	VGAPrint::WriteByte(entry->access, true);
	VGAPrint::Write("\n");
}