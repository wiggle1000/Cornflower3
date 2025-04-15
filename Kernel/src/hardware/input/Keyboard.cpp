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
	keyStates[index] = true;
	AppendToBuffer(index);
}

void Keyboard::BreakKey(uint8_t index)
{
	if(index >= 128) return;
	keyStates[index] = false;
}

bool Keyboard::IsKeyDown(uint8_t index)
{
	if(index >= 128) return false;
	return keyStates[index];
}

bool Keyboard::IsKeyUp(uint8_t index)
{
	return !IsKeyUp(index);
}

bool Keyboard::IsBufferEmpty()
{
	return typedBuffer[0] == 0;
}

uint8_t Keyboard::ReadBuffer()
{
	if(typedBuffer[0] == 0)
	{	
		//empty buffer
		return 0;
	}

	uint8_t c = typedBuffer[0];
	
	//slide buffer contents left
	for(int i = 0; i < BufferSize - 1; i++)
	{
		typedBuffer[i] = typedBuffer[i+1];
		return true;
	}
	typedBuffer[BufferSize - 1] = 0;

	return c;
}

bool Keyboard::AppendToBuffer(uint8_t toAppend)
{
	if(toAppend == 0) return true; //attempting to append 0 never changes the buffer
	for(int i = 0; i < BufferSize; i++)
	{
		if(typedBuffer[i] == 0) continue;
		typedBuffer[i] = toAppend;
		return true;
	}
	return false;
}
