OUT_DIR=out
BUILD_DIR=build
FILESYSTEM_DIR=Filesystem

.PHONY: all floppy bootloader kernel clean always run debug

#### FLOPPY ####

floppy: $(OUT_DIR)/Boot_Floppy.img

$(OUT_DIR)/Boot_Floppy.img: $(BUILD_DIR)/kernel.elf
	# vvvvvvvvvvvvvvvv FLOPPY vvvvvvvvvvvvvvvv
	echo "Creating Boot Floppy at $(OUT_DIR)/Boot_Floppy.img"
	rm -rf $(BUILD_DIR)/fsRoot
	rm -rf $(OUT_DIR)/Boot_Floppy.img
	cp $(FILESYSTEM_DIR) $(BUILD_DIR)/fsRoot -r
	cp $(BUILD_DIR)/kernel.elf $(BUILD_DIR)/fsRoot/system
#create grub image that is annoyingly not properly formatted
	grub-mkimage -p /system -C auto -o $(BUILD_DIR)/grub_boot.img -O i386-pc part_msdos fat configfile multiboot2 normal biosdisk
#create floppy image full of 0s
	dd if=/dev/zero of="$(OUT_DIR)/Boot_Floppy.img" bs=512 count=2880
#insert grub boot sector
	dd if=/usr/lib/grub/i386-pc/boot.img of="$(OUT_DIR)/Boot_Floppy.img" conv=notrunc
#insert generated grub image
	dd if="$(BUILD_DIR)/grub_boot.img" of="$(OUT_DIR)/Boot_Floppy.img" conv=notrunc seek=1
#format image
	mformat -i "$(OUT_DIR)/Boot_Floppy.img" -kR 298 ::
#insert filesystem
	for file in $(BUILD_DIR)/fsRoot/*; do \
		mcopy -i $(OUT_DIR)/Boot_Floppy.img "$$file" ::/ -bs ;\
	done
	mlabel -i $(OUT_DIR)/Boot_Floppy.img -N 12345678 ::Cornflower
	# ^^^^^^^^^^^^^^^^END FLOPPY^^^^^^^^^^^^^^^^


#### KERNEL ####

kernel: $(BUILD_DIR)/kernel.elf

$(BUILD_DIR)/kernel.elf: always
	$(MAKE) -C ./Kernel -f kernel.mk
	cp ./Kernel/obj/kernel.elf $(BUILD_DIR)

#### RUN ####

run: $(OUT_DIR)/Boot_Floppy.img
	run_qemu

#### DEBUG ####

debug: $(OUT_DIR)/Boot_Floppy.img
	bochs -f bochs_config

#### CLEAN ####
clean:
	$(MAKE) -C ./Kernel -f kernel.mk clean
	rm -rf $(OUT_DIR)
	rm -rf $(BUILD_DIR)

#### ALWAYS ####

always:
	mkdir -p $(OUT_DIR)
	mkdir -p $(BUILD_DIR)