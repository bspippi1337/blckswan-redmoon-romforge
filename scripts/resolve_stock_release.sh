#!/usr/bin/env bash
set -euo pipefail
RELEASE_REPO_URL="${1:-https://github.com/bspippi1337/BLCKSWAN_OS42_BUILDER}"
ASSET_REGEX="${2:-(RETEU|XT2521|lamu|VVTA|firmware|stock|payload|super|product|BUILDER).*\.(zip|tgz|tar\.gz)$}"
RELEASE_REPO="$(echo "$RELEASE_REPO_URL" | sed -E 's#https://github.com/##; s#/$##')"

echo "RELEASE_REPO=$RELEASE_REPO"
gh api "repos/$RELEASE_REPO/releases" \
  | jq -r '.[] as $r | $r.assets[] | [.size,.name,.browser_download_url] | @tsv' \
  | grep -Eiv 'RED.?MOON|MAGISK|FASTBOOTD|blckswan_payload' \
  | grep -Ei "$ASSET_REGEX" \
  | sort -nr \
  | tee /tmp/blckswan_stock_candidates.txt

STOCK_URL="$(head -1 /tmp/blckswan_stock_candidates.txt | cut -f3-)"
test -n "$STOCK_URL"
echo "$STOCK_URL"
