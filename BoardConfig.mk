DEVICE_PATH := device/asus/A001D

# Selects the kernel built from source: A001D_KERNEL=3.18, 4.9 or 6.19 in the environment
A001D_KERNEL ?= 4.9

TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := cortex-a53

TARGET_BOARD_PLATFORM := msm8953
TARGET_BOOTLOADER_BOARD_NAME := msm8953
TARGET_NO_BOOTLOADER := true
TARGET_USES_64_BIT_BINDER := true

# Boot image: same layout and version fields as the stock boot.img
BOARD_KERNEL_IMAGE_NAME := Image.gz-dtb
ifeq ($(A001D_KERNEL),3.18)
TARGET_KERNEL_SOURCE := kernel/asus/a001d-3.18
TARGET_KERNEL_CONFIG := A001D_defconfig
# Needs GCC, which android-11 removed: see the local manifest in the README
KERNEL_TOOLCHAIN := $(shell pwd)/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9-gcc/bin
else ifeq ($(A001D_KERNEL),4.9)
TARGET_KERNEL_SOURCE := kernel/asus/msm8953-4.9
TARGET_KERNEL_CONFIG := a001d_twrp_defconfig
TARGET_KERNEL_CLANG_COMPILE := true
TARGET_KERNEL_CLANG_VERSION := r383902
else ifeq ($(A001D_KERNEL),6.19)
TARGET_KERNEL_SOURCE := kernel/asus/msm8953-6.19
TARGET_KERNEL_CONFIG := a001d_twrp_defconfig
# The tree has no compiler new enough for 6.19: needs the host package gcc-aarch64-linux-gnu
TARGET_KERNEL_CROSS_COMPILE_PREFIX := /usr/bin/aarch64-linux-gnu-
# kernel.mk exports the host include paths, which break arm_neon.h in the cross compiler
TARGET_KERNEL_ADDITIONAL_FLAGS := CPATH=
else
$(error A001D_KERNEL must be 3.18, 4.9 or 6.19)
endif
BOARD_KERNEL_BASE := 0x80000000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_RAMDISK_OFFSET := 0x01000000
BOARD_KERNEL_TAGS_OFFSET := 0x00000100
BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_MKBOOTIMG_ARGS += --header_version 1 --os_version 9.0.0 --os_patch_level 2020-06
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET) --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)

BOARD_KERNEL_CMDLINE := androidboot.hardware=qcom androidboot.selinux=permissive loop.max_part=7 buildvariant=eng
ifeq ($(A001D_KERNEL),6.19)
BOARD_KERNEL_CMDLINE += androidboot.bootdevice=7824900.mmc androidboot.usbconfigfs=true panic=5
else
BOARD_KERNEL_CMDLINE += console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 msm_rtb.filter=0x237 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 androidboot.bootdevice=7824900.sdhci earlycon=msm_hsl_uart,0x78af000 firmware_class.path=/vendor/firmware_mnt/image
endif

# Partitions: non-A/B, no dynamic partitions, /system is not system-as-root
BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
# The boot dump is 64 MiB. Confirm recovery with "fastboot getvar partition-size:recovery" before flashing.
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 67108864
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_SYSTEMIMAGE_PARTITION_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
TARGET_COPY_OUT_VENDOR := vendor
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery.fstab
BOARD_SUPPRESS_SECURE_ERASE := true

# Display: 1080x2280, notch at the top
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TW_THEME := portrait_hdpi
# Stock notch is 27.06 dp tall (config_mainBuiltInDisplayCutout) at 480 dpi: 81.2 px
TW_Y_OFFSET := 82
TW_H_OFFSET := -82
TW_DEFAULT_BRIGHTNESS := 120
ifeq ($(A001D_KERNEL),6.19)
TW_BRIGHTNESS_PATH := "/sys/class/backlight/backlight/brightness"
TW_MAX_BRIGHTNESS := 4095
TW_CUSTOM_BATTERY_PATH := "/sys/class/power_supply/qcom-battery"
else
TW_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
TW_MAX_BRIGHTNESS := 255
endif

# TWRP
TW_EXTRA_LANGUAGES := true
TW_INPUT_BLACKLIST := "hbtp_vm"
TW_INCLUDE_NTFS_3G := true
TW_USE_TOOLBOX := true
TW_EXCLUDE_APEX := true
TARGET_RECOVERY_QCOM_RTC_FIX := true
TWRP_INCLUDE_LOGCAT := true
TARGET_USES_LOGD := true

# /data decryption is not enabled yet: the FDE blobs must come from this phone.
