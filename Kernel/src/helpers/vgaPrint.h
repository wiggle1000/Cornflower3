#pragma once
#include <stdint.h>

class VGAPrint
{
	public:
		enum vga_color {
			VGA_COLOR_BLACK = 0,
			VGA_COLOR_BLUE = 1,
			VGA_COLOR_GREEN = 2,
			VGA_COLOR_CYAN = 3,
			VGA_COLOR_RED = 4,
			VGA_COLOR_MAGENTA = 5,
			VGA_COLOR_BROWN = 6,
			VGA_COLOR_LIGHT_GREY = 7,
			VGA_COLOR_DARK_GREY = 8,
			VGA_COLOR_LIGHT_BLUE = 9,
			VGA_COLOR_LIGHT_GREEN = 10,
			VGA_COLOR_LIGHT_CYAN = 11,
			VGA_COLOR_LIGHT_RED = 12,
			VGA_COLOR_LIGHT_MAGENTA = 13,
			VGA_COLOR_LIGHT_BROWN = 14,
			VGA_COLOR_WHITE = 15,
		};
	protected:

		static uint16_t termW;
		static uint16_t termH;
		static uint16_t crsX;
		static uint16_t crsY;

		static uint8_t cColor;

		static uint16_t* vga_buffer;

		static inline uint8_t vga_entry_color(enum vga_color fg, enum vga_color bg);
		static inline uint16_t vga_entry(unsigned char uc, uint8_t color);
		static void vga_put(char c, uint8_t color, uint16_t x, uint16_t y);

	public:

		VGAPrint();

		static void do_nl();

		static void WriteChar(char c);

		static void Write(const char* str);
		static void WriteUInt16(uint16_t i, bool hex = false);
		static void WriteInt16(int16_t i, bool hex = false);
		static void WriteUInt32(uint32_t i, bool hex = false);
		static void WriteInt32(int32_t i, bool hex = false);

		/// @brief Writes a Byte to the screen
		/// @param b Byte to be written
		/// @param hex If true, writes the number in 0x00 format, otherwise uses decimal representation
		static void WriteByte(uint8_t i, bool hex = false);

		/// @brief Writes a single hexidecimal digit to the screen
		/// @param index masked with 0x000F (range 0-16)
		static void WriteHexChar(uint8_t index);

		static void Printf(const char* str, ...);

		static void SetTextColor(const vga_color color);
		static void SetBGColor(const vga_color color);
		static void SetColors(const vga_color textColor, const vga_color bgColor);

		static void Clear();

		static void SetCursorPos(uint16_t x, uint16_t y);
};
