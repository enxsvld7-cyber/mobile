#!/usr/bin/env bash
# =====================================================================
# Render дээр ажиллах build: Flutter SDK татаж, вэб хувилбарыг build/web-д гаргана.
# =====================================================================
set -euo pipefail
cd "$(dirname "$0")"

FLUTTER_DIR="${FLUTTER_DIR:-$HOME/flutter}"
if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  echo "==> Flutter SDK (stable) татаж байна"
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi
export PATH="$FLUTTER_DIR/bin:$PATH"
flutter config --no-analytics >/dev/null 2>&1 || true
flutter --version

echo "==> Package татаж байна"
flutter pub get

echo "==> Вэб хувилбар build хийж байна"
flutter build web --release

echo "==> Бэлэн: build/web"
ls -la build/web | head
