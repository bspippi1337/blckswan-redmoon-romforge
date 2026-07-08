PRODUCT_SOONG_NAMESPACES += \
    device/blckswan/lamu \
    vendor/blckswan/redmoon

PRODUCT_COPY_FILES += \
    vendor/blckswan/redmoon/system.prop:$(TARGET_COPY_OUT_PRODUCT)/etc/blckswan/system.prop
