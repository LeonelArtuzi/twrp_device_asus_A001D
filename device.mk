A001D_KERNEL ?= 3.18

PRODUCT_SHIPPING_API_LEVEL := 27

PRODUCT_COPY_FILES += \
    device/asus/A001D/init/init.recovery.qcom.$(A001D_KERNEL).rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.qcom.rc
