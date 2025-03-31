OBJ_DIR?=obj
SRC_DIR?=src

SRC_DIR?=src/kernel

ASM?=nasm
GCC?=i386-elf-gcc
GPPPARAMS?=
ASMPARAMS?=
LDPARAMS?=

objects = 	OBJ_DIR/boot.o \
			obj/helpers/vgaPrint.o \
			obj/kernel.o 

.PHONY: all kernel clean

all: kernel

kernel: $(OBJ_DIR)/kernel.bin

$(OBJ_DIR)/%.o: src/%.cpp
	mkdir -p $(@D)
	$(GCC) $(GPPPARAMS) -o $@ -c $<

$(OBJ_DIR)/%.o: src/%.c
	mkdir -p $(@D)
	$(GCC) $(GPPPARAMS) -o $@ -c $<

$(OBJ_DIR)/%.o: src/%.s
	mkdir -p $(@D)
	$(ASM) $(ASMPARAMS) -o $@ $<

#kernel.bin: linker.ld $(objects)
#	$(GPP) $(LDPARAMS) -T $< -o $@ $(objects)

$(OBJ_DIR)/%.bin: $(SRC_DIR)/%.asm
	mkdir -p $(@D)
	$(ASM) -f bin -o $@ $<

clean:
	rm -rf $(OBJ_DIR)