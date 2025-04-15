#pragma once
#include <cstdint>

class Keyboard {

	protected:
		const int BufferSize = 32;

	public:
		char typedBuffer[32];

		bool keyStates[128];

		virtual void ProcessScanCode(int scan);
		
		Keyboard();
		~Keyboard();

		void MakeKey(uint8_t index);
		void BreakKey(uint8_t index);

		bool IsKeyDown(uint8_t index);
		bool IsKeyUp(uint8_t index);

		bool IsBufferEmpty();

		char ReadBuffer();

		/// @brief Appends a character to the typing buffer.
		/// @param toAppend Character to append.
		/// @return True if added succesfully, False if buffer is full.
		bool AppendToBuffer(char toAppend);
};