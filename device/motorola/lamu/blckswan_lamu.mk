$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

PRODUCT_DEVICE := lamu
PRODUCT_NAME := blckswan_lamu
PRODUCT_BRAND := BLCKSWAN
PRODUCT_MODEL := BLCKSWAN OS 42 RED MOON
PRODUCT_MANUFACTURER := BLCKSWAN

PRODUCT_PROPERTY_OVERRIDES += \
    ro.blckswan.version=42 \
    ro.blckswan.codename=Restless \
    ro.blckswan.edition=RED\ MOON \
    ro.soc.manufacturer=BLCKSWAN
