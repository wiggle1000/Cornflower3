#pragma once
#include <cstdint>
#include "hardware/port_io.h"
#include "helpers/vgaPrint.h"

#define PIC1_BASE_ADDR	0x20
#define PIC2_BASE_ADDR	0xA0
#define PIC1_CMD_ADDR	PIC1_BASE_ADDR
#define PIC1_DATA_ADDR	(PIC1_BASE_ADDR+1)
#define PIC2_CMD_ADDR	PIC2_BASE_ADDR
#define PIC2_DATA_ADDR	(PIC2_BASE_ADDR+1)


//end of interrupt
#define PIC_EOI			0x20

//TODO: fully read reference: https://pdos.csail.mit.edu/6.828/2010/readings/hardware/8259A.pdf

#define ICW1_ICW4		0x01		/* Indicates that ICW4 will be present */
#define ICW1_SINGLE		0x02		/* Single (cascade) mode */
#define ICW1_INTERVAL4	0x04		/* Call address interval 4 (8) */
#define ICW1_LEVEL		0x08		/* Level triggered (edge) mode */
#define ICW1_INIT		0x10		/* Initialization - required! */

#define ICW4_8086		0x01		/* 8086/88 (MCS-80/85) mode */
#define ICW4_AUTO		0x02		/* Auto (normal) EOI */
#define ICW4_BUF_SLAVE	0x08		/* Buffered mode/slave */
#define ICW4_BUF_MASTER	0x0C		/* Buffered mode/master */
#define ICW4_SFNM		0x10		/* Special fully nested (not) */

#define PIC_IRQ_REMAP 32

extern void PIC_init(void);
extern void PIC_sendEOI(uint8_t irq);