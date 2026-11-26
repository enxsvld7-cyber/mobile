#!/usr/bin/env bash
# ==================================================================
#  Сахиул апп — macOS / Linux дээр ажиллуулах:  bash run_mac_linux.sh
#  1) Анх удаа бол платформын файлуудыг (android/ios/web...) үүсгэнэ
#  2) flutter pub get   3) flutter run
# ==================================================================
set -e
cd "$(dirname "$0")"
command -v flutter >/dev/null || { echo "Flutter олдсонгүй: https://docs.flutter.dev/get-started/install"; exit 1; }
if [ ! -f android/app/build.gradle.kts ] && [ ! -f android/app/build.gradle ]; then
  echo "[1/3] Платформын файлуудыг үүсгэж байна..."
  flutter create --org mn.sahiul --project-name sahiul_app .
fi
echo "[2/3] Package татаж байна..."
flutter pub get
echo "[3/3] Ажиллуулж байна..."
flutter run
