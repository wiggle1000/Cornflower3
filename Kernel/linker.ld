ENTRY(kern_entry)

SECTIONS
{
	. = 1M; /* Load kernel starting at 1MB physical */

	.boot BLOCK(4K) : ALIGN(4K)
	{
		KEEP(*(.multiboot2_header)) /* bring in multiboot 2 header */
	}

	/* Code */
	.text BLOCK(4K) : ALIGN(4K)
	{
		*(.text)
	}

	/* read only data */
	.rodata BLOCK(4K) : ALIGN(4K)
	{
		*(.rodata)
	}

	/* Read-write data (initialized) */
	.data BLOCK(4K) : ALIGN(4K)
	{
		*(.data)
	}
	
	/* Read-write data (uninitialized) and stack */
	.bss BLOCK(4K) : ALIGN(4K)
	{
		*(COMMON)
		*(.bss)
	}
}