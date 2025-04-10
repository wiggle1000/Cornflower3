#include "helpers/vgaPrint.h"

extern "C" void main(void) 
{
	VGAPrint::SetColors(VGAPrint::VGA_COLOR_LIGHT_CYAN, VGAPrint::VGA_COLOR_BLACK);
	VGAPrint::Clear();
	VGAPrint::Write("Hello!!!\n");

	while (true)
	{
		/* code */
	}
	
}