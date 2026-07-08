# BLCKSWAN OS 42 RED MOON FlashROM

This repository builds a **fastbootd-flashable `product.img`** derived from stock firmware and injects a small `BLCKSWAN OS 42 RED MOON` APK plus custom `build.prop` markers.

## What it does

The pipeline:
1. builds a tiny Android APK (`:app:assembleDebug`)
2. downloads stock firmware
3. extracts `product.img` directly or from `payload.bin`
4. mounts or unpacks the image
5. injects the APK and custom properties
6. repacks a flashable `product.img`
7. emits a ZIP that can be flashed in **fastbootd**

## Repository structure

- `app/` — minimal Android APK injected into the ROM
- `scripts/build_flashrom.sh` — image extraction, patching, and repack logic
- `.github/workflows/build.yml` — GitHub Actions workflow entrypoint

## Inputs

The GitHub Actions workflow supports either:
- a direct stock firmware URL, or
- a GitHub release repository URL to search for matching firmware assets

## Current constraints

- The ROM build depends on a valid stock firmware package.
- Multipart firmware archives (`stock.zip.part.000`, `.001`, …) must be reassembled before unpacking.
- Flashing is intended for **fastbootd**, not classic bootloader fastboot.

## Local build

### APK only

You need:
- Java 17+
- Gradle 8.10.2+
- Android SDK Platform 35

Then run:

```bash
./gradlew :app:assembleDebug
```

### Full FlashROM build

```bash
./gradlew :app:assembleDebug
bash scripts/build_flashrom.sh "https://example.com/stock.zip"
```

If the input points to `stock.zip.part.000`, the script will fetch all matching parts automatically and concatenate them.

## Output

The final artifact is:

- `out/BLCKSWAN_OS42_RED_MOON_FASTBOOTD.zip`

with:
- `product.img`
- `flash_redmoon_fastbootd.sh`
- `README_FLASH.txt`
