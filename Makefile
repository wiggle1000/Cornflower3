OUT_DIR=out
BUILD_DIR=build

.PHONY: all floppy bootloader kernel clean always run debug

#### FLOPPY ####

floppy: $(OUT_DIR)/Boot_Floppy.img

$(OUT_DIR)/Boot_Floppy.img: $(BUILD_DIR)/stage1.bin $(BUILD_DIR)/stage2.bin $(BUILD_DIR)/kernel.bin
	echo "Creating Boot Floppy at $(OUT_DIR)/Boot_Floppy.img"
#	Create unformatted floppy image
	dd if=/dev/zero of=$(OUT_DIR)/Boot_Floppy.img bs=512 count=2880
#	Format to FAT12 with 16 reserved sectors
	mkfs.fat -F 12 -R 16 -n "FAT12" $(OUT_DIR)/Boot_Floppy.img
#	Copy in stage 1 bootloader without truncating
	dd if=$(BUILD_DIR)/stage1.bin of=$(OUT_DIR)/Boot_Floppy.img conv=notrunc
#	Copy in stage 2 bootloader without truncating, skipping bootloader
	dd if=$(BUILD_DIR)/stage2.bin of=$(OUT_DIR)/Boot_Floppy.img conv=notrunc seek=512
#	Insert stage2.bin
# 	mcopy -i $(OUT_DIR)/Boot_Floppy.img $(BUILD_DIR)/stage2.bin "::STAGE2.bin"
#	Insert kernel.bin
	mcopy -i $(OUT_DIR)/Boot_Floppy.img $(BUILD_DIR)/kernel.bin "::kernel.bin"


#### BOOTLOADER ####

bootloader: $(BUILD_DIR)/stage1.bin $(BUILD_DIR)/stage2.bin

$(BUILD_DIR)/stage1.bin $(BUILD_DIR)/stage2.bin: always
	$(MAKE) -C ./Bootloader -f bootloader.mk
	cp ./Bootloader/obj/stage1.bin $(BUILD_DIR)
	cp ./Bootloader/obj/stage2.bin $(BUILD_DIR)

#### KERNEL ####

kernel: $(OBJ_DIR)/kernel.bin

$(BUILD_DIR)/kernel.bin: always
	$(MAKE) -C ./Kernel -f kernel.mk
	cp ./Kernel/obj/kernel.bin $(BUILD_DIR)

#### RUN ####

run: $(OUT_DIR)/Boot_Floppy.img
	qemu-system-i386 -device adlib -debugcon stdio -drive file=$(OUT_DIR)/Boot_Floppy.img,index=0,if=floppy,format=raw -D ./qemu.log -d cpu_reset

#### DEBUG ####

debug: $(OUT_DIR)/Boot_Floppy.img
	bochs -f bochs_config

#### CLEAN ####
clean:
	$(MAKE) -C ./Bootloader -f bootloader.mk clean
	$(MAKE) -C ./Kernel -f kernel.mk clean
	rm -rf $(OUT_DIR)
	rm -rf $(BUILD_DIR)

#### ALWAYS ####

always:
	mkdir -p $(OUT_DIR)
	mkdir -p $(BUILD_DIR)