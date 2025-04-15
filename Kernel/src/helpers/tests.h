#pragma once
#include "helpers/vgaPrint.h"
#include "hardware/port_io.h"

void TEST_PRINTING(void)
{
	VGAPrint::SetColors(VGAPrint::VGA_COLOR_LIGHT_CYAN, VGAPrint::VGA_COLOR_BLACK);
	VGAPrint::Write("Testing number printing;\n\n");

	//print hex characters
	VGAPrint::Write("Hex characters:\n  ");
	VGAPrint::SetColors(VGAPrint::VGA_COLOR_GREEN, VGAPrint::VGA_COLOR_BLACK);
	for(uint16_t i = 0; i < 16; i++)
		VGAPrint::WriteHexChar(i);

	//print some bytes
	VGAPrint::SetColors(VGAPrint::VGA_COLOR_LIGHT_CYAN, VGAPrint::VGA_COLOR_BLACK);
	VGAPrint::Write("\nBytes (dec):\n  ");
	VGAPrint::SetColors(VGAPrint::VGA_COLOR_GREEN, VGAPrint::VGA_COLOR_BLACK);
	VGAPrint::WriteByte(0, false); VGAPrint::Write(" ");
	VGAPrint::WriteByte(9, false); VGAPrint::Write(" ");
	VGAPrint::WriteByte(10, false); VGAPrint::Write(" ");
	VGAPrint::WriteByte(32, false); VGAPrint::Write(" ");
	VGAPrint::WriteByte(128, false); VGAPrint::Write(" ");
	VGAPrint::WriteByte(255, false); VGAPrint::Write("\n");

	VGAPrint::SetColors(VGAPrint::VGA_COLOR_LIGHT_CYAN, VGAPrint::VGA_COLOR_BLACK);
	VGAPrint::Write("Bytes (hex):\n  ");
	VGAPrint::SetColors(VGAPrint::VGA_COLOR_GREEN, VGAPrint::VGA_COLOR_BLACK);
	VGAPrint::WriteByte(0, 		true); VGAPrint::Write(" ");
	VGAPrint::WriteByte(9, 		true); VGAPrint::Write(" ");
	VGAPrint::WriteByte(10, 	true); VGAPrint::Write(" ");
	VGAPrint::WriteByte(32, 	true); VGAPrint::Write(" ");
	VGAPrint::WriteByte(128, 	true); VGAPrint::Write(" ");
	VGAPrint::WriteByte(255, 	true); VGAPrint::Write("\n");

	VGAPrint::SetColors(VGAPrint::VGA_COLOR_LIGHT_CYAN, VGAPrint::VGA_COLOR_BLACK);
	VGAPrint::Write("Integers (dec):\n  ");
	VGAPrint::SetColors(VGAPrint::VGA_COLOR_GREEN, VGAPrint::VGA_COLOR_BLACK);
	VGAPrint::WriteInt32(0, 		false); VGAPrint::Write(" ");
	VGAPrint::WriteInt32(INT32_MIN,	false); VGAPrint::Write(" ");
	VGAPrint::WriteInt32(INT32_MAX, 			false); VGAPrint::Write(" ");
	VGAPrint::WriteInt32(32, 		false); VGAPrint::Write(" ");
	VGAPrint::WriteInt32(99, 		false); VGAPrint::Write(" ");
	VGAPrint::WriteInt32(100, 		false); VGAPrint::Write(" ");
	VGAPrint::WriteInt32(999, 		false); VGAPrint::Write(" ");
	VGAPrint::WriteInt32(1000, 		false); VGAPrint::Write(" ");
	VGAPrint::WriteInt32(9999, 		false); VGAPrint::Write(" ");
	VGAPrint::WriteInt32(10000, 		false); VGAPrint::Write("\n");
} 

void TEST_PORTS(void)
{
}