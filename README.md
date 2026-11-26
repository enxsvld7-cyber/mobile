# Сахиул — Хамгаалалтын компанийн апп (Flutter / Dart)

Мобайл програмчлалын бие даалт. **Цэвэр Flutter код** — сервер, интернэт шаардлагагүй, бүх өгөгдөл ба тооцоо утсан дотор. Файл бүрийн толгойд **дэлгэцийн зохиомж** (widget мод) болон **ашигласан widget-ийн судалгаа**, кодын дунд мөр бүрийн **тайлбар** монголоор comment хэлбэрээр бичигдсэн.

## Ажиллуулах

Flutter SDK **3.29 буюу түүнээс шинэ** суусан байх (`flutter --version`).

- **Windows:** `run_windows.bat` дээр давхар дарна.
- **macOS / Linux:** `bash run_mac_linux.sh`
- **Гараар:**
  ```bash
  flutter create --org mn.sahiul --project-name sahiul_app .   # анх удаа: android/ios/web хавтас үүсгэнэ (lib/-ийг дарахгүй)
  flutter pub get
  flutter run                                                  # утас, эмулятор, Chrome сонгоно
  ```
- **APK:** `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`
- **Вэб (локал):** `flutter run -d chrome` эсвэл `flutter build web` → `build/web`

**Нэвтрэх эрх:** Харуул `SH-0247` / `1234` (SH-0248…SH-0251 ч болно) · Менежер `M-001` / `manager123`

## Линкээр (вэб) нээгддэг болгох — Render Static Site

Апп цэвэр Flutter тул Render дээр **Static Site** болж байршина: үнэгүй, унтдаггүй, линк дээр дармагц шууд нээгдэнэ. Компьютерийн хөтөч дээр утасны хэмжээтэй хүрээнд голлож харагдана.

1. **GitHub:** github.com → **New repository** (нэр: `sahiul-app`, Public) → **uploading an existing file** → энэ хавтасны **доторх бүх файл, хавтсыг** чирж оруулна → **Commit changes**.
2. **Render:** render.com → **Get Started** → GitHub-аараа нэвтэрнэ (карт хэрэггүй).
3. Render → **New +** → **Blueprint** → `sahiul-app` repo-г сонгоно → **Apply**.
4. Анхны build ~5–8 минут (Flutter татаж, вэб хувилбар бүтээнэ). Дуусахад **https://sahiul-app.onrender.com** маягийн линк гарна — энэ линкийг багшдаа өгнө.
5. Кодоо засаад GitHub-д дахин оруулахад Render автоматаар шинэчилнэ.

**Render дээр build алдаа гарвал (нөөц арга):** компьютер дээрээ `flutter build web` хийгээд гарсан `build/web` хавтсыг `public` нэрээр repo-ийн үндэс рүү хуулж GitHub-д оруулна. Render-ийн тохиргоонд *Build Command*: `echo ok`, *Publish Directory*: `public` болгоно.

Хэрэв Blueprint ашиглахгүй бол: **New + → Static Site** → repo → *Build Command*: `bash ./render-build.sh` · *Publish Directory*: `build/web` → Advanced → **Rewrite** `/*` → `/index.html`.

## Шаардлага ба дэлгэцүүд

| № | Шаардлага | Дэлгэц (lib/screens) |
|---|---|---|
| 1 | Ажилчдын ирцийг тооцно | `home_screen` · `check_in_screen` (GPS бүс, хоцролт) · `attendance_screen` |
| 2 | Цалин тооцоход хэрэгтэй мэдээлэл гаргана | `payroll_screen` (задаргаа) · `manager_report_screen` (нэгтгэл + Excel) |
| 3 | Ээлжийн хуваарь *(нэмэлт)* | `shifts_screen` · `manager_requests_screen` |
| 4 | Зөрчил мэдээлэх *(нэмэлт)* | `incident_screen` · `manager_alerts_screen` |
| 5 | SOS яаралтай дуудлага *(нэмэлт)* | `sos_screen` · `manager_alerts_screen` |

## Кодын бүтэц

```
lib/
├── main.dart          Аппын эхлэл, MaterialApp, нэвтэрсэн эрхээр дэлгэц сонгох
├── theme.dart         Figma-гийн өнгө, текстийн загвар, товчны theme
├── widgets.dart       Дахин ашиглах widget-үүд (AppCard, Badge2, MonthSelector, AsyncView…)
├── api.dart           Дэлгэц ↔ өгөгдлийн давхарга (Future буцаана)
├── local_db.dart      Өгөгдөл + ирц, илүү цаг, шөнийн цаг, цалингийн тооцоо
├── location.dart      GPS (geolocator)
└── screens/           13 дэлгэц (файл бүрийн толгойд зохиомж + widget судалгаа)
```

## Widget-ийн судалгааны товч хүснэгт

| Widget | Юунд ашигласан | Жишээ файл |
|---|---|---|
| `StatelessWidget` / `StatefulWidget` | Төлөвгүй / төлөвтэй дэлгэц, `setState` | бүх дэлгэц |
| `MaterialApp`, `Scaffold`, `AppBar` | Аппын бүрхүүл, дэлгэцийн араг яс | `main.dart`, бүх дэлгэц |
| `NavigationBar` | Доод цэс (5 / 4 таб) | `guard_shell.dart`, `manager_shell.dart` |
| `ValueListenableBuilder` | Нэвтрэх/гарахад дэлгэц солих | `main.dart` |
| `FutureBuilder` (`AsyncView`) | Ачаалж / алдаа / бэлэн төлөв | `widgets.dart` |
| `ListView`, `RefreshIndicator` | Гүйлгэх жагсаалт, доош татаж шинэчлэх | `home_screen.dart` |
| `Row`, `Column`, `Expanded`, `Wrap` | Зохиомж, тэнцүү хуваалт, мөр ороох | бүх дэлгэц |
| `Container` + `BoxDecoration` | Өнгө, бөөрөнхий булан, хүрээ | `widgets.dart` |
| `Stack`, `Positioned` | Давхарлан байрлуулах (газрын зураг дээр шошго) | `check_in_screen.dart` |
| `CustomPaint` / `CustomPainter` | Геофенсийн тойрог зурах | `check_in_screen.dart` |
| `TextField`, `TextEditingController` | Код, нууц үг, тайлбар оруулах | `login_screen.dart`, `incident_screen.dart` |
| `ChoiceChip`, `SegmentedButton` | Төрөл, яаралтай байдал сонгох | `incident_screen.dart` |
| `AnimationController`, `AnimatedBuilder`, `GestureDetector` | SOS-ийг 3 сек дарж илгээх | `sos_screen.dart` |
| `showDialog`, `AlertDialog`, `SnackBar` | Асуулт, мэдэгдэл | `shifts_screen.dart`, `widgets.dart` |
| `Timer.periodic` | Секунд тутам цаг шинэчлэх | `check_in_screen.dart` |

## Тэмдэглэл

- Апп хаагдахад өгөгдөл анхны жишээ төлөвтөө буцна (`local_db.dart`).
- Цалингийн хувь хэмжээ (норм 168ц, илүү цаг ×1.5, шөнө +20%, НДШ 11.5%, ХХОАТ 10%) нь жишээ — `local_db.dart`-ын эхэнд өөрчилнө.
- Царай таних / QR одоогоор сонгосон аргыг л тэмдэглэнэ.
