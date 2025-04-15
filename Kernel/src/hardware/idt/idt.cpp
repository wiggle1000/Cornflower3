#include "idt.h"

__attribute__((aligned(16)))
static idt_entry_t idt[IDT_MAX_DESCRIPTORS];

static idtr_t idtr;

//keeps track of whether vectors exist
static bool vectors[IDT_MAX_DESCRIPTORS];


const char* INTERRUPT_NAMES[] = 
{
	"Division Error",
	"Debug Trap",
	"NMI",
	"Breakpoint",
	"Overflow",
	"Bound Range Exceeded",
	"Invalid Opcode",
	"FPU Not Available",
	"Double Fault",
	"Coprocessor Segment Overrun",
	"Invalid Task Switch Segment",
	"Segment Not Present",
	"Stack-Segment Fault",
	"General Protection Fault",
	"Page Fault",
	"(Reserved Int. 0x0F)",
	"x87 Floating-Point Exception",
	"Alignment Check",
	"Machine Check",
	"SIMD Floating-Point Exception",
	"Virtualization Exception",
	"Control Protection Exception",
	"(Reserved Int. 0x16)",
	"(Reserved Int. 0x17)",
	"(Reserved Int. 0x18)",
	"(Reserved Int. 0x19)",
	"(Reserved Int. 0x1A)",
	"(Reserved Int. 0x1B)",
	"Hypervisor Injection Exception",
	"VMM Communication Exception",
	"Security Exception",
	"(Reserved Int. 0x1F)",
};

///Used to track double faults
uint8_t lastInterrupt = 0xFF;


/// @brief Default Exception Handler
/// @param vector Passed from interrupt stub, interrupt number.
/// @param address Return address that caused the interrupt.
extern "C" __attribute__((noreturn)) void exception_handler(int8_t vector, int32_t address) {

    VGAPrint::Write("\n");
    VGAPrint::SetColors(VGAPrint::VGA_COLOR_LIGHT_BROWN, VGAPrint::VGA_COLOR_RED);
    VGAPrint::Write("Fault: ");
    if(vector == 0x08) //double fault
    {
        VGAPrint::Write("DOUBLE FAULT (0x08)! (PREV: ");
        if(lastInterrupt < 32)
        {
            VGAPrint::Write(INTERRUPT_NAMES[lastInterrupt]);
        }
        else
        {
            VGAPrint::Write("UNINITIALIZED");
        }
        VGAPrint::Write(" (");
        VGAPrint::WriteByte(lastInterrupt, true);
        VGAPrint::Write("))!");
    }
    else if(vector < 32)
    {
        VGAPrint::Write(INTERRUPT_NAMES[vector]);
        VGAPrint::Write(" (");
        VGAPrint::WriteByte(vector, true);
        VGAPrint::Write(")!");
    }
    else
    {
        VGAPrint::Write("UNKNOWN EXCEPTION (");
        VGAPrint::WriteByte(vector, true);
        VGAPrint::Write(")!");
    }
    VGAPrint::SetColors(VGAPrint::VGA_COLOR_LIGHT_GREY, VGAPrint::VGA_COLOR_RED);
    VGAPrint::Write(" at ");
    VGAPrint::WriteUInt32(address, true);
    VGAPrint::Write("\n");
    VGAPrint::SetColors(VGAPrint::VGA_COLOR_LIGHT_CYAN, VGAPrint::VGA_COLOR_BLACK);
    lastInterrupt = vector;
    while(true)
    {
        __asm__ volatile ("cli");
        __asm__ volatile ("hlt");
    }
}

extern "C" void PIC_interrupt_handler(int8_t vector, int32_t address) {
    VGAPrint::Write("\n");
    VGAPrint::SetColors(VGAPrint::VGA_COLOR_LIGHT_BROWN, VGAPrint::VGA_COLOR_BLUE);
    VGAPrint::Write("PIC Interrupt ");
    VGAPrint::WriteByte(vector, true);
    VGAPrint::Write("!\n");
    VGAPrint::SetColors(VGAPrint::VGA_COLOR_LIGHT_CYAN, VGAPrint::VGA_COLOR_BLACK);
    PIC_sendEOI(vector-32);
}

void idt_set_descriptor(uint8_t vector, void* isr, uint8_t flags)
{
    idt_entry_t* entry = &idt[vector];

    entry->isr_segment   = 0x08; //kernel code selector from GDT
    entry->isr_addr_low  = (uint32_t) isr & 0xFFFF;
    entry->isr_addr_high =  ((uint32_t)isr >> 16) & 0xFFFF;
    entry->attributes    = flags;
    entry->reserved      = 0;
}

void idt_init()
{
    
	VGAPrint::SetColors(VGAPrint::VGA_COLOR_LIGHT_CYAN, VGAPrint::VGA_COLOR_BLACK);
	VGAPrint::Write("Setting up IDT.\n");

    __asm__ volatile ("cli");
    idtr.base = (uintptr_t)&idt[0];
    idtr.limit = (uint16_t)sizeof(idt_entry_t) * IDT_MAX_DESCRIPTORS - 1;
    

    //set up base exceptions
    for (uint8_t vector = 0; vector < 32; vector++)
    {
        //flags:
        //present
        //run in ring 0
        //type 0b1110 (32 bit interrupt gate)
        idt_set_descriptor(vector, isr_stub_table[vector], 0b10001110);
        vectors[vector] = true;
    }
    
    //set up PIC interrupts (mapped to after exceptions)
    for (uint8_t vector = PIC_IRQ_REMAP; vector < PIC_IRQ_REMAP+16; vector++)
    {
        //flags:
        //present
        //run in ring 0
        //type 0b1110 (32 bit interrupt gate)
        idt_set_descriptor(vector, isr_stub_table[vector], 0b10001110);
        vectors[vector] = true;
    }

    __asm__ volatile ("lidt %0" : : "m"(idtr)); //load idt
    __asm__ volatile ("sti");

	VGAPrint::Write(" Base: ");
	VGAPrint::WriteUInt32(idtr.base, true);
	VGAPrint::Write(" | Limit: ");
	VGAPrint::WriteUInt16(idtr.limit, true);
	VGAPrint::Write("\n");
    
	VGAPrint::SetColors(VGAPrint::VGA_COLOR_LIGHT_GREEN, VGAPrint::VGA_COLOR_BLACK);
	VGAPrint::Write("IDT Ok!\n");
}