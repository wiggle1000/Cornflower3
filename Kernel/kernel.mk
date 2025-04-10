OBJ_DIR?=obj
SRC_DIR?=src

SRC_DIR?=src/kernel

ASM?=nasm
GCC?=i386-elf-gcc
GPPPARAMS?=-ffreestanding -O2 -nostdlib -Iinclude -Wall -Wextra
ASMPARAMS?=-f elf
LDPARAMS?=-ffreestanding -O2 -nostdlib -Iinclude

objects = 	$(OBJ_DIR)/bootheader.o \
			$(OBJ_DIR)/kernel.o 

.PHONY: all kernel clean

all: kernel

kernel: $(OBJ_DIR)/kernel.elf

$(OBJ_DIR)/%.o: src/%.cpp
	mkdir -p $(@D)
	$(GCC) $(GPPPARAMS) -o $@ -c $<

$(OBJ_DIR)/%.o: src/%.c
	mkdir -p $(@D)
	$(GCC) $(GPPPARAMS) -o $@ -c $<

$(OBJ_DIR)/%.o: src/%.asm
	mkdir -p $(@D)
	$(ASM) $(ASMPARAMS) -o $@ $<

$(OBJ_DIR)/kernel.elf: linker.ld $(objects)
	$(GCC) $(LDPARAMS) -T $< -o $@ $(objects)

clean:
	rm -rf $(OBJ_DIR)