#pragma once
#include <cstdint>
#include "hardware/input/Keyboard.h"
#include "hardware/port_io.h"

class PS2Keyboard : public Keyboard {
	public:
		void ProcessScanCode(uint8_t scan) override;
		void InitializeDevice() override;

		/// @brief Sets keyboard lights
		/// @param lightMask Bit 0: ScrollLock, Bit 1: NumLock, Bit 2: CapsLock
		void SetLights(uint8_t lightMask) override;

		#define NONE 0
		///IBM Set 2 "Make" scancodes
		const uint8_t SCANCODE_TO_KEYCODE[256]
		{
		//  0	  1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
			NONE,  120, NONE,  116,  114,  112,  113,  123, NONE,  121,  119,  117,  115,   16,    1, NONE,	// 0
			NONE,   60,   44, NONE,   58,   17,    2, NONE, NONE, NONE,   46,   32,   31,   18,    3, NONE,	// 1
			NONE,   48,   47,   33,   19,    5,    4, NONE, NONE,   61,   49,   34,   21,   20,    6, NONE,	// 2
			NONE,   51,   50,   36,   35,   22,    7, NONE, NONE, NONE,   52,   37,   23,    8,    9, NONE,	// 3
			NONE,   53,   38,   24,   25,   11,   10, NONE, NONE,   54,   55,   39,   40,   26,   12, NONE,	// 4
			NONE, NONE,   41, NONE,   27,   13, NONE, NONE,   30,   57,   43,   28, NONE,   29, NONE, NONE,	// 5
			NONE, NONE, NONE, NONE, NONE, NONE,   15, NONE, NONE,   93, NONE,   92,   91, NONE, NONE, NONE,	// 6
			  70,  104,   98,   97,  102,   96,  110,   90,  122,  106,  103,  105,  100,  101,  125, NONE,	// 7
			NONE, NONE, NONE,  118, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,	// 8
			NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,	// 9
			NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,	// A
			NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,	// B
			NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,	// C
			NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,	// D
			NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,	// E
			NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,	// F
		};
		//Notice: the proper make/break codes for PrintScreen are E0,12,E0,7C/E0,F0,7C,E0,F0,12
		//  but here I just treat it as E0,7C/E0,F0,7C, and treat E0,12/E0,F0,12 as an invalid key
		const uint8_t SCANCODE_TO_KEYCODE_E0[256]
		{
		//  0	  1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
			NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,	// 0
			NONE,   62, NONE, NONE,   64, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,	// 1
			NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,	// 2
			NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,	// 3
			NONE, NONE, NONE, NONE, NONE, NONE, NONE,   89, NONE, NONE,   95, NONE, NONE, NONE, NONE, NONE,	// 4
			NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,  108, NONE, NONE, NONE, NONE, NONE,	// 5
			NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,   81, NONE,   79,   80, NONE, NONE, NONE,	// 6
			  75,   76,   84, NONE, NONE,   83, NONE, NONE, NONE, NONE,   86, NONE,  124,   85, NONE, NONE,	// 7
			NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,	// 8
			NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,	// 9
			NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,	// A
			NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,	// B
			NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,	// C
			NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,	// D
			NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,	// E
			NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE, NONE,	// F
		};
		#undef NONE

	private:
		bool isE0 = false;
		bool isReleasing = false;
		uint8_t keycode = 0x00;
};