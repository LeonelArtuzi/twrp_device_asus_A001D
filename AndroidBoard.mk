A001D_KERNEL_OBJ := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ

# KERNEL_OBJ has one fixed path, and objects from another kernel version would break the build
A001D_KERNEL_STAMP := $(TARGET_OUT_INTERMEDIATES)/.a001d_kernel
ifneq ($(A001D_KERNEL),$(shell cat $(A001D_KERNEL_STAMP) 2>/dev/null))
$(shell rm -rf $(A001D_KERNEL_OBJ); mkdir -p $(TARGET_OUT_INTERMEDIATES); echo $(A001D_KERNEL) > $(A001D_KERNEL_STAMP))
endif

A001D_KERNEL_CHECK := $(TARGET_OUT_INTERMEDIATES)/.a001d_kernel_check
$(A001D_KERNEL_CHECK): $(A001D_KERNEL_OBJ)/arch/arm64/boot/$(BOARD_KERNEL_IMAGE_NAME) device/asus/A001D/check_kernel.sh
	$(hide) device/asus/A001D/check_kernel.sh $(A001D_KERNEL) $(TARGET_KERNEL_SOURCE) $(A001D_KERNEL_OBJ)
	$(hide) touch $@

$(PRODUCT_OUT)/recovery.img: $(A001D_KERNEL_CHECK)
