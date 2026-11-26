# Сахиул — Хамгаалалтын компанийн ажилтны ирц, ээлж, цалингийн апп

**Мобайл програмчлал · Бие даалтын ажил** · Бүх зүйл **зөвхөн Flutter / Dart кодоор** хийгдсэн:
апп, бие даалтын танилцуулга, илтгэлийн слайд, A3 постер — бүгд `lib/` дотор.

> Аппыг нээгээд нэвтрэх дэлгэцийн доод талын **«Бие даалтын танилцуулга»** (эсвэл Профайл → Бие даалт)
> дээр дарахад 9 үе шат, **Илтгэл** (12 слайд), **A3 постер** нээгдэнэ.

---

## Даалгавар шалгах хугацаа, оноо

| № | Гүйцэтгэх ажил | 7 хоног | Оноо | Хаана байгаа вэ |
|---|---|:-:|:-:|---|
| 1 | Сэдэв сонголт | V | 1 | [↓ 1](#1-сэдэв-сонголт) · `lib/bie_daalt/content.dart` |
| 2 | Апп-ийн танилцуулга | VI | 1 | [↓ 2](#2-апп-ийн-танилцуулга) |
| 3 | Апп-ийн шаардлага | IX | 3 | [↓ 3](#3-апп-ийн-шаардлага) · `lib/data/local_db.dart` |
| 4 | Дэлгэцийн зохиомж | X | 3 | [↓ 4](#4-дэлгэцийн-зохиомж) · `lib/screens/` (файл бүрийн толгойд widget мод) |
| 5 | Widget-ийн судалгаа | XI | 3 | [↓ 5](#5-бие-даан-судлах-widget-ийн-судалгаа) |
| 6 | Кодчилол | XII | 3 | [↓ 6](#6-кодчилол) · `lib/` |
| 7 | A3 постер | XIII | 2 | `lib/bie_daalt/poster_screen.dart` |
| 8 | Power point танилцуулга | XIII | 1 | `lib/bie_daalt/slides_screen.dart` |
| 9 | Апп-ийг ажиллуулах | XIII | 3 | [↓ 9](#9-апп-ийг-ажиллуулах) |
| | | | **20** | |

---

## 1. Сэдэв сонголт

**Сэдэв:** Хамгаалалтын компанийн ажилтны ирц, ээлж, цалингийн мобайл апп — **«Сахиул»**.
Ганцаараа гүйцэтгэсэн. (Нэр, анги, багшийн нэрийг `lib/bie_daalt/content.dart`-ын `author`, `teacher`-т бичнэ.)

## 2. Апп-ийн танилцуулга

- **Асуудал:** ирцийг цаасаар бүртгэдэг тул хоцролт, илүү цаг, шөнийн цагийг тооцоход алдаа гардаг.
- **Шийдэл:** харуул утсаараа постын бүс (GPS геофенс) дотроос ирцээ бүртгэнэ; апп цалингийн задаргааг автоматаар гаргана.
- **Хэрэглэгч:** *харуул* (ирц, ээлж, цалин, зөрчил, SOS) ба *менежер* (тайлан, дуудлага, хүсэлт).
- **Сервергүй:** бүх өгөгдөл, тооцоо утсан дотор — интернэтгүй ажиллана.

## 3. Апп-ийн шаардлага

| № | Шаардлага | Дэлгэц |
|---|---|---|
| 1 | Ажилчдын ирцийг тооцно (GPS бүс, хоцролт, илүү цаг) | `home_screen` · `check_in_screen` · `attendance_screen` |
| 2 | Цалин тооцоход хэрэгтэй мэдээлэл гаргана | `payroll_screen` · `manager_report_screen` |
| 3 | Ээлжийн хуваарь, солих/чөлөө хүсэлт *(нэмэлт)* | `shifts_screen` · `manager_requests_screen` |
| 4 | Зөрчил мэдээлэх *(нэмэлт)* | `incident_screen` · `manager_alerts_screen` |
| 5 | SOS яаралтай дуудлага *(нэмэлт)* | `sos_screen` · `manager_alerts_screen` |

**Цалингийн тооцоо** (`lib/data/local_db.dart`-ын эхэнд тохируулна):
цагийн хөлс = үндсэн цалин ÷ 168 · илүү цаг ×1.5 · шөнийн (22:00–06:00) +20% · НДШ 11.5% · ХХОАТ 10%.

## 4. Дэлгэцийн зохиомж

| № | Дэлгэц | Файл |
|---|---|---|
| 01 | Нэвтрэх | `lib/screens/auth/login_screen.dart` |
| 02 | Нүүр | `lib/screens/guard/home_screen.dart` |
| 03 | Ирц бүртгэх (GPS) | `lib/screens/guard/check_in_screen.dart` |
| 04 | Ирцийн түүх | `lib/screens/guard/attendance_screen.dart` |
| 05 | Цалингийн мэдээлэл | `lib/screens/guard/payroll_screen.dart` |
| 06 | Ээлжийн хуваарь | `lib/screens/guard/shifts_screen.dart` |
| 07 | Зөрчил мэдээлэх | `lib/screens/guard/incident_screen.dart` |
| 08 | SOS | `lib/screens/guard/sos_screen.dart` |
| 09 | Профайл | `lib/screens/common/profile_screen.dart` |
| 10 | Менежерийн тайлан | `lib/screens/manager/manager_report_screen.dart` |
| 11 | Дуудлага ба зөрчил | `lib/screens/manager/manager_alerts_screen.dart` |
| 12 | Хүсэлт шийдвэрлэх | `lib/screens/manager/manager_requests_screen.dart` |
| 13–15 | Бие даалт · Илтгэл · A3 постер | `lib/bie_daalt/` |

Файл бүрийн толгойд **«ДЭЛГЭЦИЙН ЗОХИОМЖ»** (widget мод) ба **«АШИГЛАСАН WIDGET-ИЙН СУДАЛГАА»** монголоор бичигдсэн.

## 5. Бие даан судлах Widget-ийн судалгаа

| Widget | Юунд ашигласан | Жишээ файл |
|---|---|---|
| `StatelessWidget` / `StatefulWidget` | Төлөвгүй / төлөвтэй дэлгэц, `setState` | бүх дэлгэц |
| `MaterialApp`, `Scaffold`, `AppBar` | Аппын бүрхүүл, дэлгэцийн араг яс | `main.dart` |
| `NavigationBar` | Доод цэс (5 / 4 таб) | `guard_shell.dart`, `manager_shell.dart` |
| `ValueListenableBuilder` | Нэвтрэх/гарахад дэлгэц солих | `main.dart` |
| `FutureBuilder` (`AsyncView`) | Ачаалж / алдаа / бэлэн төлөв | `core/widgets.dart` |
| `ListView`, `RefreshIndicator` | Гүйлгэх жагсаалт, доош татаж шинэчлэх | `home_screen.dart` |
| `Row`, `Column`, `Expanded`, `Wrap` | Зохиомж, тэнцүү хуваалт | бүх дэлгэц |
| `Container` + `BoxDecoration` | Өнгө, бөөрөнхий булан, хүрээ | `core/widgets.dart` |
| `Stack`, `Positioned` | Газрын зураг дээр шошго давхарлах | `check_in_screen.dart` |
| `CustomPaint` / `CustomPainter` | Геофенсийн тойрог зурах | `check_in_screen.dart` |
| `TextField`, `TextEditingController` | Код, нууц үг, тайлбар оруулах | `login_screen.dart` |
| `ChoiceChip`, `SegmentedButton` | Төрөл, яаралтай байдал сонгох | `incident_screen.dart` |
| `AnimationController`, `AnimatedBuilder`, `GestureDetector` | SOS-ийг 3 сек дарж илгээх | `sos_screen.dart` |
| `showDialog`, `AlertDialog`, `SnackBar` | Асуулт, мэдэгдэл | `shifts_screen.dart` |
| `Timer.periodic` | Секунд тутам цаг шинэчлэх | `check_in_screen.dart` |
| `PageView`, `AspectRatio`, `FittedBox`, `InteractiveViewer` | Слайд, A3 постерыг хэмжээгээр нь харуулах | `bie_daalt/` |

## 6. Кодчилол

```
lib/
├── main.dart                 Аппын эхлэл, MaterialApp, эрхээр эхний дэлгэц сонгох
├── core/                     ── ЕРӨНХИЙ
│   ├── theme.dart            Өнгө, текст, товчны загвар
│   └── widgets.dart          Дахин ашиглах widget (AppCard, Badge2, AsyncView…), формат
├── data/                     ── ӨГӨГДӨЛ
│   ├── api.dart              Дэлгэц ↔ өгөгдлийн давхарга (Future буцаана)
│   ├── local_db.dart         Өгөгдөл + ирц, илүү цаг, шөнийн цаг, цалингийн тооцоо
│   └── location.dart         GPS (geolocator)
├── screens/                  ── ДЭЛГЭЦҮҮД
│   ├── auth/                 01 Нэвтрэх
│   ├── guard/                02–08 Харуулын дэлгэцүүд + доод цэс (guard_shell)
│   ├── manager/              10–12 Менежерийн дэлгэцүүд + доод цэс (manager_shell)
│   └── common/               09 Профайл (хоёуланд)
└── bie_daalt/                ── БИЕ ДААЛТ (Dart кодоор)
    ├── content.dart          9 үе шат, шаардлага, widget судалгаа, слайд, ном зүйн текст
    ├── bie_daalt_screen.dart 9 үе шатын жагсаалт ба дэлгэрэнгүй
    ├── slides_screen.dart    Илтгэл: 12 слайд, Times New Roman 18pt, мөр зай 1.5, автомат дугаар
    └── poster_screen.dart    A3 постер (297×420 мм харьцаа)
test/
├── widget_test.dart          Формат, сар шилжүүлэх, 9 үе шат = 20 оноо, слайд ≥ 10, материал ≥ 6
└── bie_daalt_test.dart       Постер, бүх слайд, 9 үе шатын дэлгэц алдаагүй зурагдах
```

Давхарга: **Дэлгэц → `Api` → `LocalDb`**. Жинхэнэ сервер холбох бол зөвхөн `data/api.dart`-ыг өөрчилнө.

## 7. A3 постер

`lib/bie_daalt/poster_screen.dart` — Flutter widget-ээр A3 харьцаагаар (842×1191) зурсан.
Апп → Бие даалт → **A3 постер**. Хэвлэх: Chrome дээр `flutter run -d chrome` → постер нээж **Ctrl+P → A3**, эсвэл дэлгэцийн зураг авна.

## 8. Power point танилцуулга

`lib/bie_daalt/slides_screen.dart` — 12 слайд: нүүр хуудас, агуулга, оршил, зорилго, шаардлага,
загвар, дэлгэцүүд (зураг), widget судалгаа, цалингийн тооцоо (хүснэгт), туршилт, дүгнэлт, ашигласан материал (8).
Times New Roman 18pt, мөр хоорондын зай 1.5, хуудасны дугаар автоматаар. Илтгэх хугацаа 5–10 мин.

## 9. Апп-ийг ажиллуулах

Flutter SDK **3.29+** (`flutter --version`).

- **Windows:** `run_windows.bat` · **macOS / Linux:** `bash run_mac_linux.sh`
- **Гараар:**
  ```bash
  flutter create --org mn.sahiul --project-name sahiul_app .
  ```
  ```bash
  flutter pub get
  ```
  ```bash
  flutter run
  ```
  (`flutter create .` нь анх удаа android/ios хавтсыг гүйцээнэ, `lib/`-ийг дарахгүй.)
- **Тест:** `flutter test`
- **APK:** `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`
- **Вэб:** `flutter run -d chrome` эсвэл `flutter build web`

**Туршилтын эрх:** Харуул `SH-0247` / `1234` (SH-0248…SH-0251) · Менежер `M-001` / `manager123`

<details>
<summary>Линкээр нээгддэг болгох (Render Static Site)</summary>

1. render.com → GitHub-аар нэвтэрнэ → **New + → Blueprint** → энэ repo → **Apply** (`render.yaml`).
2. Анхны build ~5–8 мин. Гарсан `https://….onrender.com` линкийг багшдаа өгнө.
3. Blueprint ашиглахгүй бол: **New + → Static Site** → *Build Command*: `bash ./render-build.sh` · *Publish Directory*: `build/web` · Rewrite `/*` → `/index.html`.
</details>

### Тэмдэглэл
- Апп хаагдахад өгөгдөл анхны жишээ төлөвтөө буцна (`data/local_db.dart`).
- Цалингийн хувь хэмжээ нь жишээ — `data/local_db.dart`-ын эхэнд өөрчилнө.
