#pragma once
#include <cstdint>
#include "hardware/input/Keyboard.h"

class PS2Keyboard : public Keyboard {
	public:
		void ProcessScanCode(int scan);
};