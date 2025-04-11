#include "idt.h"

__attribute__((aligned(16)))
static idt_entry_t idt[256];

static idtr_t idtr;

//keeps track of whether vectors exist
static bool vectors[IDT_MAX_DESCRIPTORS];

extern "C" __attribute__((noreturn)) void exception_handler() {
    while(true)
    {
        __asm__ volatile ("cli");
        __asm__ volatile ("hlt");
    }
}

void idt_set_descriptor(uint8_t vector, void* isr, uint8_t flags)
{
    idt_entry_t* entry = &idt[vector];

    entry->isr_segment   = 0x08; //kernel code selector from GDT
    entry->isr_addr_low  = (uint32_t) isr & 0xFFFF;
    entry->isr_addr_high = (uint32_t) isr >> 16;
    entry->attributes    = flags;
    entry->reserved      = 0;
}

void idt_init()
{
    __asm__ volatile ("cli");
    idtr.base = (uintptr_t)&idt[0];
    idtr.limit = (uint16_t)sizeof(idt_entry_t) * IDT_MAX_DESCRIPTORS - 1;

    for (uint8_t vector = 0; vector < 32; vector++)
    {
        //flags:
        //present
        //run in ring 0
        //type 0b1110 (32 bit interrupt gate)
        idt_set_descriptor(vector, isr_stub_table[vector], 0x8E);
        vectors[vector] = true;
    }
    __asm__ volatile ("lidt %0" : : "m"(idtr)); //load idt
    __asm__ volatile ("sti");
}