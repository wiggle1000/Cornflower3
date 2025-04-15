#include "hardware/input/PS2Keyboard.h"


void PS2Keyboard::InitializeDevice()
{
}

void PS2Keyboard::SetLights(uint8_t lightMask)
{
	out8(0xED, lightMask);
}

void PS2Keyboard::ProcessScanCode(uint8_t scan)
{
	//if E0 or F0, set flag and return
	if(scan == 0xE0) { isE0 = true; return; }
	if(scan == 0xF0) { isReleasing = true; return; }

	//get keycode
	if(isE0)	keycode = SCANCODE_TO_KEYCODE_E0[scan];
	else		keycode = SCANCODE_TO_KEYCODE[scan];
	
	//check and process keycode
	if(keycode != 0x00)
	{
		if(isReleasing)	BreakKey(keycode);
		else			MakeKey(keycode);

		isReleasing = false;
		isE0 = false;
	}
}