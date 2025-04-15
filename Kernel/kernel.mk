OBJ_DIR?=obj
SRC_DIR?=src

SRC_DIR?=src/kernel

ASM?=nasm
GCC?=i386-elf-gcc
GPPPARAMS?=-ffreestanding -O2 -nostdlib -I$(SRC_DIR) -Wall -Wextra -g
ASMPARAMS?=-f elf
LDPARAMS?=-ffreestanding -O2 -nostdlib -I$(SRC_DIR) -g

objects = 	$(OBJ_DIR)/bootheader.o \
			$(OBJ_DIR)/entry.o \
			$(OBJ_DIR)/kernel.o \
			$(OBJ_DIR)/hardware/gdt/gdt.o \
			$(OBJ_DIR)/hardware/gdt/gdt_helper.o \
			$(OBJ_DIR)/hardware/idt/idt.o \
			$(OBJ_DIR)/hardware/idt/isr_stubs.o \
			$(OBJ_DIR)/helpers/vgaPrint.o \
			$(OBJ_DIR)/hardware/helpers/PIC.o

.PHONY: all kernel clean

all: kernel

kernel: $(OBJ_DIR)/kernel.elf

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp
	mkdir -p $(@D)
	$(GCC) $(GPPPARAMS) -o $@ -c $<

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	mkdir -p $(@D)
	$(GCC) $(GPPPARAMS) -o $@ -c $<

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.asm
	mkdir -p $(@D)
	$(ASM) $(ASMPARAMS) -o $@ $<

$(OBJ_DIR)/kernel.elf: linker.ld $(objects)
	$(GCC) $(LDPARAMS) -T $< -o $@ $(objects)

clean:
	rm -rf $(OBJ_DIR)