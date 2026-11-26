@echo off
REM ==================================================================
REM  Сахиул апп — Windows дээр НЭГ ДАРЖ ажиллуулах
REM  1) Анх удаа бол android/ios/windows/web платформын файлуудыг үүсгэнэ
REM  2) Package-уудыг татна (flutter pub get)
REM  3) Холбогдсон утас / эмулятор / Chrome дээр ажиллуулна
REM  Шаардлага: Flutter SDK 3.29+ суусан, PATH-д flutter байх
REM ==================================================================
chcp 65001 >nul
cd /d "%~dp0"
where flutter >nul 2>nul || (echo Flutter олдсонгүй. https://docs.flutter.dev/get-started/install & pause & exit /b 1)
if not exist "android\app\build.gradle.kts" if not exist "android\app\build.gradle" (
  echo [1/3] Платформын файлуудыг үүсгэж байна...
  call flutter create --org mn.sahiul --project-name sahiul_app .
)
echo [2/3] Package татаж байна...
call flutter pub get
echo [3/3] Ажиллуулж байна... (төхөөрөмж сонгоно уу)
call flutter run
pause
