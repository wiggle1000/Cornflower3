#pragma once
#include <cstdint>

class Keyboard {

	protected:
		const int BufferSize = 32;

	public:
		uint8_t typedBuffer[32];

		bool keyStates[128];

		virtual void ProcessScanCode(uint8_t scan);
		virtual void InitializeDevice();

		/// @brief Sets keyboard lights
		/// @param lightMask Bit 0: ScrollLock, Bit 1: NumLock, Bit 2: CapsLock
		virtual void SetLights(uint8_t lightMask);
		
		Keyboard();
		~Keyboard();

		void MakeKey(uint8_t index);
		void BreakKey(uint8_t index);

		bool IsKeyDown(uint8_t index);
		bool IsKeyUp(uint8_t index);
		

		bool IsBufferEmpty();

		uint8_t ReadBuffer();

		/// @brief Appends a keycode to the typing buffer.
		/// @param toAppend Keycode to append.
		/// @return True if added succesfully, False if buffer is full.
		bool AppendToBuffer(uint8_t toAppend);
		
		///IBM Key Number -> char [0=lower, 1=upper]
		const char KEYCODE_TO_QWERTY[128][2]
		{
			{'`','~'},{'1','!'},{'2','@'},{'3','#'},{'4','$'},{'5','%'},{'6','^'},{'7','&'},{'8','*'},{'9','('},{'0',')'},{'-','_'},{'=','+'},{0x01,0x01},{'\b','\b'},
			{'\t','\t'},{'q','Q'},{'w','W'},{'e','E'},{'r','R'},{'t','T'},{'y','Y'},{'u','U'},{'i','I'},{'o','O'},{'p','P'},{'[','{'},{']','}'},{'|','\\'},{0x01,0x01},
			{'\0','\0'},{'a','A'},{'s','S'},{'d','D'},{'f','F'},{'g','G'},{'h','H'},{'j','J'},{'k','K'},{'l','L'},{';',':'},{'\'','"'},{0x01,0x01},{'\n','\n'},
			{'\0','\0'},{0x01,0x01},{'z','Z'},{'x','X'},{'c','C'},{'v','V'},{'b','B'},{'n','N'},{'m','M'},{',','<'},{'.','>'},{'/','?'},{0x01,0x01},{'\0','\0'},
			{'\0','\0'},{0x01,0x01},{'\0','\0'},{' ',' '},{'\0','\0'},{0x01,0x01},{'\0','\0'},
			{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},
			{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},
			{'\0','\0'},{'7','7'},{'4','4'},{'1','1'},{'\0','\0'},
			{'/','/'},{'8','8'},{'5','5'},{'2','2'},{'0','0'},
			{'*','*'},{'9','9'},{'6','6'},{'3','3'},{'.','.'},
			{'-','-'},{'+','+'},{'\0','\0'},{'\n','\n'},{'\0','\0'},
			{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},
			{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},{'\0','\0'},
			{'\0','\0'},{'\0','\0'},{'\0','\0'}
		};
};