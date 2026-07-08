$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)
$(call inherit-product, device/blckswan/lamu/device.mk)
$(call inherit-product, vendor/blckswan/redmoon/redmoon.mk)

PRODUCT_DEVICE := lamu
PRODUCT_NAME := blckswan_lamu
PRODUCT_BRAND := BLCKSWAN
PRODUCT_MODEL := BLCKSWAN OS 42 RED MOON
PRODUCT_MANUFACTURER := BLCKSWAN

PRODUCT_SYSTEM_PROPERTIES += \
    ro.blckswan.version=42 \
    ro.blckswan.codename=Restless \
    ro.blckswan.edition=RED\ MOON \
    ro.soc.manufacturer=BLCKSWAN
