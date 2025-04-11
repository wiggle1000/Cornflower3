#include "helpers/vgaPrint.h"

inline uint8_t VGAPrint::vga_entry_color(enum vga_color fg, enum vga_color bg) 
{
	return fg | bg << 4;
}
inline uint16_t VGAPrint::vga_entry(unsigned char uc, uint8_t color) 
{
	return (uint16_t) uc | (uint16_t) color << 8;
}
void VGAPrint::vga_put(char c, uint8_t color, uint16_t x, uint16_t y)
{
	const uint16_t index = y * termW + x;
	vga_buffer[index] = vga_entry(c, color);
	
}

uint16_t* VGAPrint::vga_buffer = (uint16_t*) 0xB8000;
uint16_t VGAPrint::termW = 80;
uint16_t VGAPrint::termH = 25;
uint16_t VGAPrint::crsX = 0;
uint16_t VGAPrint::crsY = 0;
uint8_t VGAPrint::cColor = 0x08;

VGAPrint::VGAPrint()
{}

void VGAPrint::do_nl()
{
	crsX = 0;
	crsY++;
	if(crsY >= termH)
	{
		crsY--;
		//scoot every line up one and empty last line
		for(uint16_t i = 0; i < termW * termH; i++)
		{
			if(i < termH * termW - termW) //get entry on next line
				vga_buffer[i] = vga_buffer[i + termW];
			else //last line
				vga_buffer[i] = vga_entry(' ', cColor);
		}
	}
}

void VGAPrint::WriteChar(char c)
{
	//newline
	if(c == '\n')
	{
		do_nl();
		return;
	}
	//write char
	vga_put(c, cColor, crsX, crsY);
	crsX++;

	if(crsX >= termW)
	{
		do_nl();
	}
}

void VGAPrint::WriteHexChar(uint8_t index)
{
	if((index & 0x0F) > 9)
	{
		VGAPrint::WriteChar('A' + (index & 0x0F) - 10);
	}
	else
	{
		VGAPrint::WriteChar('0' + (index & 0x0F));
	}
}

void VGAPrint::Write(const char* str)
{
	for(int i = 0; str[i] != '\0'; i++)
	{
		WriteChar(str[i]);
	}
}

void VGAPrint::WriteByte(uint8_t b, bool hex)
{
	if(hex)
	{
		WriteChar('0');
		WriteChar('x');
		for(int i = 1; i >= 0; i--)
		{
			WriteHexChar(b>>(i*4));
		}
	}
	else
	{
		if(b >= 100)
		{
			WriteChar('0' + ((b%1000)/100));
		}
		if(b >= 10)
		{
			WriteChar('0' + ((b%100)/10));
		}
		WriteChar('0' + (b%10));
	}
}
void VGAPrint::WriteUInt32(uint32_t b, bool hex)
{
	if(hex)
	{
		WriteChar('0');
		WriteChar('x');
		for(int i = 7; i >= 0; i--)
		{
			WriteHexChar(b>>(i*4));
		}
	}
	else
	{
		//max 10 digits
		for(unsigned int digit = 10; digit > 0; digit--)
		{
			if(b >= (10^(digit-1)) )
			{
				WriteChar('0' + ((b%(10^(digit)))/(10^(digit-1))));
			}
		}
		WriteChar('0' + (b%10));
	}
}
void VGAPrint::WriteInt32(int32_t b, bool hex)
{
	if(hex)
	{
		WriteChar('0');
		WriteChar('x');
		for(int i = 7; i >= 0; i--)
		{
			WriteHexChar(b>>(i*4));
		}
	}
	else
	{
		if(b < 0)
		{
			WriteChar('-');
			//max 10 digits
			for(int digit = 10; digit > 0; digit--)
			{
				if((-b) >= (10^(digit-1)) )
				{
					WriteChar('0' + (((-b)%(10^(digit)))/(10^(digit-1))));
				}
			}
			WriteChar('0' + ((-b)%10));
		}
		else
		{
			//max 10 digits
			for(int digit = 10; digit > 0; digit--)
			{
				if(b >= (10^(digit-1)) )
				{
					WriteChar('0' + ((b%(10^(digit)))/(10^(digit-1))));
				}
			}
			WriteChar('0' + (b%10));
		}
	}
}

void VGAPrint::WriteUInt16(uint16_t b, bool hex)
{
	if(hex)
	{
		WriteChar('0');
		WriteChar('x');
		for(int i = 3; i >= 0; i--)
		{
			WriteHexChar((b>>(i*4)) & 0x0F);
		}
	}
	else
	{
		//max 5 digits
		for(unsigned int digit = 5; digit > 0; digit--)
		{
			if(b >= (10^(digit-1)) )
			{
				WriteChar('0' + ((b%(10^(digit)))/(10^(digit-1))));
			}
		}
		WriteChar('0' + (b%10));
	}
}

void VGAPrint::SetTextColor(const vga_color color)
{
	cColor = vga_entry_color(color, (vga_color)( (cColor & 0xF0) >> 4 ));
}
void VGAPrint::SetBGColor(const vga_color color)
{
	cColor = vga_entry_color(color, (vga_color)( cColor & 0x0F ));
}
void VGAPrint::SetColors(const vga_color textColor, const vga_color bgColor)
{
	cColor = vga_entry_color(textColor, bgColor);
}

void VGAPrint::Clear()
{
	for(uint16_t i = 0; i < termW * termH; i++)
	{
		vga_buffer[i] = vga_entry(' ', cColor);
	}
	crsX = 0;
	crsY = 0;
}

void VGAPrint::SetCursorPos(uint16_t x, uint16_t y)
{
	if(x >= termW) x = termW-1;
	if(y >= termH) y = termH-1;
	crsX = x;
	crsY = y;
}