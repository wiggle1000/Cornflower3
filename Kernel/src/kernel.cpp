#include "helpers/vgaPrint.h"
#include "tests.h"
#include "gdt.h"
#include "idt.h"

extern "C" void main(void) 
{
	VGAPrint::SetColors(VGAPrint::VGA_COLOR_LIGHT_CYAN, VGAPrint::VGA_COLOR_BLACK);
	VGAPrint::Clear();
	VGAPrint::Write("Hello from Cornflower Kernel!\n");
	VGAPrint::Write("About to begin system initialization.\n");

	
	//TEST_PRINTING();
	
	VGAPrint::Write("Setting up GDT.\n");
	gdt_init();
	VGAPrint::Write("Setting up IDT.\n");
	//idt_init();

	while (true)
	{
		/* code */
	}
	
}