Things stage ONE does:

- Contain FAT12 partition for booting from floppy
- Set up stack for bootloader
- Read stage 2 bootloader from floppy filesystem (max size 64k for now)
- Jump to stage 2 bootloader as quickly as possible (outside of limited first sector)

Things stage TWO does:

- Contain multiboot header
- Set stack up again in case we're coming from a bootloader that doesn't do that
- create structure of properties and info from BIOS
- Read kernel from floppy filesystem (fix filesize limit with newfound breathing room)
- Set up GDT
- Enter 32-bit protected mode
- jump to kernel!