OBJ_DIR?=./obj/
SRC_DIR?=./src/
ASM?=nasm

.PHONE: all stage1 stage2 clean

all: stage1 stage2

stage1: $(OBJ_DIR)/stage1.bin
stage2: $(OBJ_DIR)/stage2.bin

$(OBJ_DIR)/%.bin: $(SRC_DIR)/%.asm
	mkdir -p $(@D)
	$(ASM) -f bin -o $@ $<

clean:
	rm -rf $(OBJ_DIR)