#!/usr/bin/env bash
set -euxo pipefail
STOCK_URL="${1:?stock URL required}"
rm -rf stock_probe
mkdir -p stock_probe/unpacked
curl -L "$STOCK_URL" -o stock_probe/stock.zip
unzip -oq stock_probe/stock.zip -d stock_probe/unpacked || true
find stock_probe/unpacked -type f | sort | tee stock_probe/files.txt
find stock_probe/unpacked -type f \( -iname 'payload.bin' -o -iname 'super.img' -o -iname 'product.img' -o -iname '*product*' -o -iname '*super*' \) | tee stock_probe/important.txt
