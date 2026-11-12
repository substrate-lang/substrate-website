#!/bin/sh
# Renders social/card.html to assets/og.png at 1200×630 with the dev shell's Chromium, or the browser CHROME names.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
out="$(cd "$here/.." && pwd)/assets/og.png"
"${CHROME:-chromium}" --headless --disable-gpu --hide-scrollbars --force-device-scale-factor=1 --window-size=1200,630 \
  --virtual-time-budget=3000 --screenshot="$out" "file://$here/card.html" 2>/dev/null
echo "wrote $out"
