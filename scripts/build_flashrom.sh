#!/usr/bin/env bash
set -euxo pipefail

STOCK_URL="${1:-}"
[ -n "$STOCK_URL" ] || { echo "Missing stock_url workflow input"; exit 1; }

sudo apt update
sudo apt install -y unzip zip curl python3 python3-pip e2fsprogs android-sdk-libsparse-utils erofs-utils file rsync protobuf-compiler tar

python3 -m pip install --user --break-system-packages payload-dumper || true
export PATH="$HOME/.local/bin:$PATH"

rm -rf work out mnt tree
mkdir -p work out mnt tree

fetch_stock_archive() {
  local url="$1"

  if [[ "$url" =~ \.part\.[0-9]+$ ]]; then
    local base="${url%.part.*}"
    local part_url
    local n=0

    while true; do
      printf -v suffix "%03d" "$n"
      part_url="${base}.part.${suffix}"
      if curl -fsIL "$part_url" >/dev/null; then
        echo "Downloading multipart chunk: $part_url"
        curl -fL "$part_url" -o "work/stock.part.${suffix}"
        n=$((n + 1))
      else
        break
      fi
    done

    [ "$n" -gt 0 ] || { echo "No multipart chunks found for $url"; exit 1; }
    cat work/stock.part.* > work/stock.zip
    return 0
  fi

  local target="work/stock.bin"
  case "$url" in
    *.zip) target="work/stock.zip" ;;
    *.tar.gz|*.tgz) target="work/stock.tar.gz" ;;
  esac

  curl -fL "$url" -o "$target"
}

unpack_stock_archive() {
  mkdir -p work/stock

  if [ -f work/stock.zip ]; then
    unzip -oq work/stock.zip -d work/stock
    return 0
  fi

  if [ -f work/stock.tar.gz ]; then
    tar -xzf work/stock.tar.gz -C work/stock
    return 0
  fi

  echo "Unsupported stock archive format"
  ls -lah work
  exit 1
}

fetch_stock_archive "$STOCK_URL"
unpack_stock_archive

echo "===== STOCK CONTENT ====="
find work/stock -maxdepth 4 -type f | sort | tee work/stock_files.txt

PRODUCT="$(find work/stock -type f \( -iname 'product.img' -o -iname 'product.img_sparsechunk.*' -o -iname 'product_*.img' \) | head -1 || true)"

if [ -z "$PRODUCT" ]; then
  PAYLOAD="$(find work/stock -type f -iname 'payload.bin' | head -1 || true)"
  if [ -n "$PAYLOAD" ]; then
    echo "===== PAYLOAD FOUND: $PAYLOAD ====="
    mkdir -p work/payload_out
    payload-dumper --partitions product --out work/payload_out "$PAYLOAD" || payload_dumper --partitions product --out work/payload_out "$PAYLOAD"
    PRODUCT="$(find work/payload_out -type f -iname 'product.img' | head -1 || true)"
  fi
fi

if [ -z "$PRODUCT" ]; then
  echo "===== NO PRODUCT FOUND ====="
  find work/stock -type f | sort
  exit 1
fi

echo "PRODUCT=$PRODUCT"
cp app/build/outputs/apk/debug/app-debug.apk work/BlckswanAbout.apk

if file "$PRODUCT" | grep -qi sparse; then
  simg2img "$PRODUCT" work/product.raw.img
else
  cp "$PRODUCT" work/product.raw.img
fi

FS="$(file work/product.raw.img)"
echo "FS=$FS"

if echo "$FS" | grep -qi erofs; then
  sudo mount -o loop,ro work/product.raw.img mnt
  rsync -a mnt/ tree/
  sudo umount mnt
  mkdir -p tree/app/BlckswanAbout tree/media
  cp work/BlckswanAbout.apk tree/app/BlckswanAbout/BlckswanAbout.apk
  cat >> tree/build.prop <<'PROP'

ro.blckswan.version=42
ro.blckswan.codename=Restless
ro.blckswan.edition=RED MOON
ro.soc.manufacturer=BLCKSWAN
PROP
  mkfs.erofs -zlz4hc out/product.img tree
else
  sudo e2fsck -fy work/product.raw.img || true
  sudo resize2fs work/product.raw.img 4096M || true
  sudo mount -o loop,rw work/product.raw.img mnt
  sudo mkdir -p mnt/app/BlckswanAbout mnt/media
  sudo cp work/BlckswanAbout.apk mnt/app/BlckswanAbout/BlckswanAbout.apk
  echo "" | sudo tee -a mnt/build.prop
  echo "ro.blckswan.version=42" | sudo tee -a mnt/build.prop
  echo "ro.blckswan.codename=Restless" | sudo tee -a mnt/build.prop
  echo "ro.blckswan.edition=RED MOON" | sudo tee -a mnt/build.prop
  echo "ro.soc.manufacturer=BLCKSWAN" | sudo tee -a mnt/build.prop
  sudo umount mnt
  e2fsck -fy work/product.raw.img || true
  img2simg work/product.raw.img out/product.img
fi

cat > out/flash_redmoon_fastbootd.sh <<'FLASH'
#!/usr/bin/env bash
set -eux
adb reboot fastboot
fastboot flash product product.img
fastboot reboot
FLASH
chmod +x out/flash_redmoon_fastbootd.sh

cat > out/README_FLASH.txt <<'TXT'
BLCKSWAN OS 42 RED MOON flashable product ROM.

Flash:
adb reboot fastboot
fastboot flash product product.img
fastboot reboot
TXT

cd out
zip -r BLCKSWAN_OS42_RED_MOON_FASTBOOTD.zip product.img flash_redmoon_fastbootd.sh README_FLASH.txt
sha256sum BLCKSWAN_OS42_RED_MOON_FASTBOOTD.zip > BLCKSWAN_OS42_RED_MOON_FASTBOOTD.zip.sha256
