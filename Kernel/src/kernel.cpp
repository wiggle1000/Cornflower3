#include "helpers/vgaPrint.h"
#include "tests.h"
#include "gdt.h"
#include "idt.h"
#include "helpers/PIC.h"

extern "C" void main(void) 
{
	VGAPrint::SetColors(VGAPrint::VGA_COLOR_LIGHT_CYAN, VGAPrint::VGA_COLOR_BLACK);
	VGAPrint::Clear();
	VGAPrint::Write("Hello from Cornflower Kernel!\n");
	VGAPrint::Write("About to begin system initialization.\n");

	
	//TEST_PRINTING();
	
	gdt_init();
	PIC_init();
	idt_init();
	
	VGAPrint::SetColors(VGAPrint::VGA_COLOR_LIGHT_CYAN, VGAPrint::VGA_COLOR_BLACK);
	VGAPrint::Write("Uh...\n");

	int i = 0;
	while (true)
	{
		VGAPrint::Write(".");
		io_wait();
		/* code */
	}
	
}