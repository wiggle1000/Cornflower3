#include "PIC.h"


void PIC_sendEOI(uint8_t irq)
{
	if(irq >= 8)
		out8(PIC2_CMD_ADDR,PIC_EOI);
	
	out8(PIC1_CMD_ADDR,PIC_EOI);
}

void PIC_remap(int offset1, int offset2)
{
	out8(PIC1_CMD_ADDR, ICW1_INIT | ICW1_ICW4);  // starts the initialization sequence (in cascade mode)
	io_wait();
	out8(PIC2_CMD_ADDR, ICW1_INIT | ICW1_ICW4);
	io_wait();
	out8(PIC1_DATA_ADDR, offset1);                 // ICW2: Master PIC vector offset
	io_wait();
	out8(PIC1_DATA_ADDR, offset2);                 // ICW2: Slave PIC vector offset
	io_wait();
	out8(PIC1_DATA_ADDR, 4);                       // ICW3: tell Master PIC that there is a slave PIC at IRQ2 (0000 0100)
	io_wait();
	out8(PIC2_DATA_ADDR, 2);                       // ICW3: tell Slave PIC its cascade identity (0000 0010)
	io_wait();
	
	out8(PIC1_DATA_ADDR, ICW4_8086);               // ICW4: have the PICs use 8086 mode (and not 8080 mode)
	io_wait();
	out8(PIC2_DATA_ADDR, ICW4_8086);
	io_wait();

	// Unmask both PICs.
	out8(PIC1_DATA_ADDR, 0);
	out8(PIC2_DATA_ADDR, 0);
}

void PIC_init()
{
	VGAPrint::SetColors(VGAPrint::VGA_COLOR_LIGHT_CYAN, VGAPrint::VGA_COLOR_BLACK);
	VGAPrint::Write("Remapping PIC.\n");
	PIC_remap(PIC_IRQ_REMAP, PIC_IRQ_REMAP+8);
	VGAPrint::SetColors(VGAPrint::VGA_COLOR_LIGHT_GREEN, VGAPrint::VGA_COLOR_BLACK);
	VGAPrint::Write("PIC Ok!\n");
}