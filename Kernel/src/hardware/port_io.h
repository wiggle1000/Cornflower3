#pragma once
#include <cstdint>

static inline void out8(uint16_t port, uint8_t value)
{
	__asm__ volatile ("outb %1, %0" : : "dN" (port), "a" (value));
};

static inline void out16(uint16_t port, uint16_t value)
{
	__asm__ volatile ("outw %1, %0" : : "dN" (port), "a" (value));
};

static inline void out32(uint16_t port, uint32_t value)
{
	__asm__ volatile ("outl %1, %0" : : "dN" (port), "a" (value));
};


static inline uint8_t in8(uint16_t port)
{
	uint8_t value;
	__asm__ volatile ("inb %1, %0" : "=a"(value) : "dN" (port) : "memory");
	return value;
};

static inline uint16_t in16(uint16_t port)
{
	uint16_t value;
	__asm__ volatile ("inw %1, %0" : "=a"(value) : "dN" (port) : "memory");
	return value;
};

static inline uint32_t in32(uint16_t port)
{
	uint32_t value;
	__asm__ volatile ("inl %1, %0" : "=a"(value) : "dN" (port) : "memory");
	return value;
};

static inline void io_wait()
{
	out8(0x80, 0);
};