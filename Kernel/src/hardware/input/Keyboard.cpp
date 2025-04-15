#include "hardware/input/Keyboard.h"


Keyboard::Keyboard()
{
	
}
Keyboard::~Keyboard()
{
	
}

void Keyboard::MakeKey(uint8_t index)
{
	if(index >= 128) return;
}
void Keyboard::BreakKey(uint8_t index)
{
	if(index >= 128) return;
}

bool Keyboard::IsKeyDown(uint8_t index)
{
	if(index >= 128) return false;
}
bool Keyboard::IsKeyUp(uint8_t index)
{
	return !IsKeyUp(index);
}

bool Keyboard::IsBufferEmpty()
{
	return typedBuffer[0] == 0;
}

char Keyboard::ReadBuffer()
{
	if(typedBuffer[0] == 0)
	{	
		//empty buffer
		return 0;
	}

	char c = typedBuffer[0];
	
	//slide buffer contents left
	for(int i = 0; i < BufferSize - 1; i++)
	{
		if(typedBuffer[i] == 0) continue;
		typedBuffer[i] = typedBuffer[i+1];
		return true;
	}
	typedBuffer[BufferSize - 1] = 0;

	return c;
}
bool Keyboard::AppendToBuffer(char toAppend)
{
	for(int i = 0; i < BufferSize; i++)
	{
		if(typedBuffer[i] == 0) continue;
		typedBuffer[i] = toAppend;
		return true;
	}
	return false;
}
