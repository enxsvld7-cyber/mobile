// =====================================================================
// bie_daalt/content.dart — БИЕ ДААЛТЫН АГУУЛГА (зөвхөн өгөгдөл)
// ---------------------------------------------------------------------
// Бие даалтын 9 үе шат (Сэдэв сонголт → Апп ажиллуулах), илтгэлийн слайд,
// A3 постер, ашигласан материалын текстүүдийг НЭГ газар Dart кодоор хадгална.
// Дэлгэцүүд (bie_daalt_screen.dart, slides_screen.dart, poster_screen.dart)
// эндээс уншиж харуулна → текст засах бол зөвхөн энэ файлыг өөрчилнө.
//
// АШИГЛАСАН ОЙЛГОЛТ:
//   • const класс (Stage, WidgetInfo, Slide) — өөрчлөгдөхгүй өгөгдлийн загвар.
//   • const List — компайл үед бэлэн болох жагсаалт (санах ой хэмнэнэ).
// =====================================================================

/// Бие даалтын нэг үе шат (даалгавар шалгах хүснэгтийн нэг мөр).
class Stage {
  const Stage(this.no, this.title, this.week, this.points, this.summary, this.items, {this.files = const []});
  final int no; // дугаар (1–9)
  final String title; // гүйцэтгэх ажил
  final String week; // хугацаа (долоо хоног, ром тоогоор)
  final int points; // оноо
  final String summary; // нэг өгүүлбэр тайлбар
  final List<String> items; // дэлгэрэнгүй агуулга
  final List<String> files; // холбогдох Dart файлууд
}

/// Ашигласан нэг widget-ийн судалгаа.
class WidgetInfo {
  const WidgetInfo(this.name, this.purpose, this.file);
  final String name;
  final String purpose;
  final String file;
}

/// Илтгэлийн нэг слайд.
class Slide {
  const Slide(this.title, this.bullets);
  final String title;
  final List<String> bullets;
}

// ------------------------------------------------------------------ ерөнхий мэдээлэл
const appName = 'Сахиул';
const topic = 'Хамгаалалтын компанийн ажилтны ирц, ээлж, цалингийн мобайл апп';
const course = 'Мобайл програмчлал · Бие даалтын ажил';
const author = 'Оюутан: ____________'; // ← өөрийн нэр, ангиа бичнэ
const teacher = 'Багш: ____________';
const year = '2026 он';

// ------------------------------------------------------------------ аппын шаардлага
const requirements = <String>[
  '1. Ажилчдын ирцийг тооцно — GPS бүс (геофенс) шалгаж ирсэн/явсан цагийг бүртгэнэ, хоцролт, илүү цагийг автоматаар тооцно.',
  '2. Цалин тооцоход хэрэгтэй мэдээлэл гаргана — үндсэн цалин, илүү цаг (×1.5), шөнийн нэмэгдэл (+20%), суутгал, НДШ 11.5%, ХХОАТ 10%.',
  '3. Ээлжийн хуваарь (нэмэлт) — 2 өдөр · 2 шөнө · 2 амралт; ээлж солих/чөлөө хүсэлт илгээх, менежер шийдвэрлэх.',
  '4. Зөрчил мэдээлэх (нэмэлт) — төрөл, яаралтай байдал, тайлбар, байршилтай мэдээлэл менежерт очно.',
  '5. SOS яаралтай дуудлага (нэмэлт) — 3 секунд дарж илгээнэ; 102/101/103 руу шууд залгана.',
];

// ------------------------------------------------------------------ дэлгэцүүд
const screens = <String>[
  '01 · Нэвтрэх — screens/auth/login_screen.dart',
  '02 · Нүүр — screens/guard/home_screen.dart',
  '03 · Ирц бүртгэх (GPS) — screens/guard/check_in_screen.dart',
  '04 · Ирцийн түүх — screens/guard/attendance_screen.dart',
  '05 · Цалингийн мэдээлэл — screens/guard/payroll_screen.dart',
  '06 · Ээлжийн хуваарь — screens/guard/shifts_screen.dart',
  '07 · Зөрчил мэдээлэх — screens/guard/incident_screen.dart',
  '08 · SOS — screens/guard/sos_screen.dart',
  '09 · Профайл — screens/common/profile_screen.dart',
  '10 · Менежерийн тайлан — screens/manager/manager_report_screen.dart',
  '11 · Дуудлага ба зөрчил — screens/manager/manager_alerts_screen.dart',
  '12 · Хүсэлт шийдвэрлэх — screens/manager/manager_requests_screen.dart',
];

// ------------------------------------------------------------------ widget-ийн судалгаа
const widgetStudy = <WidgetInfo>[
  WidgetInfo('StatelessWidget / StatefulWidget', 'Төлөвгүй / төлөвтэй дэлгэц, setState() дуудахад дахин зурна', 'бүх дэлгэц'),
  WidgetInfo('MaterialApp, Scaffold, AppBar', 'Аппын бүрхүүл, дэлгэцийн араг яс, гарчиг', 'main.dart'),
  WidgetInfo('NavigationBar', 'Доод цэс: харуул 5 таб, менежер 4 таб', 'guard_shell.dart'),
  WidgetInfo('ValueListenableBuilder', 'Нэвтрэх/гарахад эхний дэлгэцийг солих', 'main.dart'),
  WidgetInfo('FutureBuilder (AsyncView)', 'Ачаалж байна / алдаа / бэлэн гэсэн 3 төлөв', 'core/widgets.dart'),
  WidgetInfo('ListView, RefreshIndicator', 'Гүйлгэх жагсаалт, доош татаж шинэчлэх', 'home_screen.dart'),
  WidgetInfo('Row, Column, Expanded, Wrap', 'Хэвтээ/босоо зохиомж, тэнцүү хуваалт', 'бүх дэлгэц'),
  WidgetInfo('Container + BoxDecoration', 'Өнгө, бөөрөнхий булан, хүрээ, сүүдэр', 'core/widgets.dart'),
  WidgetInfo('Stack, Positioned', 'Газрын зураг дээр шошго давхарлах', 'check_in_screen.dart'),
  WidgetInfo('CustomPaint / CustomPainter', 'Геофенсийн тойрог, зургийг Canvas дээр зурах', 'check_in_screen.dart'),
  WidgetInfo('TextField, TextEditingController', 'Код, нууц үг, тайлбар оруулах', 'login_screen.dart'),
  WidgetInfo('ChoiceChip, SegmentedButton', 'Зөрчлийн төрөл, яаралтай байдал сонгох', 'incident_screen.dart'),
  WidgetInfo('AnimationController, AnimatedBuilder, GestureDetector', 'SOS товчийг 3 сек дарахад дүүрэх анимаци', 'sos_screen.dart'),
  WidgetInfo('showDialog, AlertDialog, SnackBar', 'Баталгаажуулах асуулт, түр мэдэгдэл', 'shifts_screen.dart'),
  WidgetInfo('Timer.periodic', 'Секунд тутам цагийг шинэчлэх', 'check_in_screen.dart'),
  WidgetInfo('PageView, AspectRatio, FittedBox', 'Илтгэлийн слайд, A3 постерыг хэмжээгээр нь харуулах', 'bie_daalt/'),
];

// ------------------------------------------------------------------ ашигласан материал (≥ 6)
const references = <String>[
  '1. Flutter баримт бичиг — https://docs.flutter.dev',
  '2. Dart хэлний баримт бичиг — https://dart.dev/guides',
  '3. Flutter Widget каталог — https://docs.flutter.dev/ui/widgets',
  '4. Material Design 3 — https://m3.material.io',
  '5. geolocator package — https://pub.dev/packages/geolocator',
  '6. url_launcher package — https://pub.dev/packages/url_launcher',
  '7. Монгол Улсын Хөдөлмөрийн тухай хууль (2021) — илүү цаг, шөнийн цагийн нэмэгдэл',
  '8. Э. Windmill, "Flutter in Action", Manning, 2020',
];

// ------------------------------------------------------------------ 9 ҮЕ ШАТ (даалгавар шалгах хүснэгт)
const stages = <Stage>[
  Stage(1, 'Сэдэв сонголт', 'V', 1, 'Сэдвээ сонгож Moodle-р илгээсэн.', [
    'Сэдэв: $topic.',
    'Аппын нэр: $appName.',
    'Ганцаараа хийнэ. 5-р долоо хоногт багтаана (хоцорвол −5 оноо).',
  ]),
  Stage(
    2,
    'Апп-ийн танилцуулга',
    'VI',
    1,
    'Апп ямар асуудлыг шийдэх, хэн ашиглах вэ.',
    [
      'Асуудал: хамгаалалтын компанид ирцийг цаасаар бүртгэдэг тул хоцролт, илүү цаг, шөнийн цагийг тооцоход алдаа гардаг.',
      'Шийдэл: харуул утсаараа постын бүс дотроос (GPS) ирцээ бүртгэнэ; апп цалингийн задаргааг автоматаар гаргана.',
      'Хэрэглэгч: харуул (ирц, ээлж, цалин, зөрчил, SOS) ба менежер (тайлан, дуудлага, хүсэлт).',
      'Сервергүй: бүх өгөгдөл, тооцоо утсан дотор (data/local_db.dart) — интернэтгүй ажиллана.',
    ],
    files: ['lib/main.dart', 'lib/data/local_db.dart'],
  ),
  Stage(
    3,
    'Апп-ийн шаардлага',
    'IX',
    3,
    'Үндсэн 2 + нэмэлт 3 шаардлага.',
    requirements,
    files: ['lib/data/local_db.dart', 'lib/data/api.dart'],
  ),
  Stage(4, 'Дэлгэцийн зохиомж', 'X', 3, '12 дэлгэц. Файл бүрийн толгойд widget мод бичигдсэн.', screens, files: ['lib/screens/']),
  Stage(
    5,
    'Бие даан судлах Widget-ийн судалгаа',
    'XI',
    3,
    '16 бүлэг widget-ийг судалж хэрэглэсэн.',
    [],
    files: ['lib/bie_daalt/content.dart'],
  ),
  Stage(
    6,
    'Кодчилол',
    'XII',
    3,
    'Цэвэр Flutter / Dart. Давхаргатай бүтэц.',
    [
      'lib/main.dart — аппын эхлэл, эрхээр дэлгэц сонгох',
      'lib/core/ — theme.dart (өнгө, фонт), widgets.dart (дахин ашиглах widget)',
      'lib/data/ — api.dart (дэлгэц ↔ өгөгдөл), local_db.dart (тооцоо), location.dart (GPS)',
      'lib/screens/auth · guard · manager · common — 12 дэлгэц',
      'lib/bie_daalt/ — бие даалтын танилцуулга, илтгэл, A3 постер (Dart код)',
      'test/widget_test.dart — нэгж тест (flutter test)',
    ],
    files: ['lib/'],
  ),
  Stage(
    7,
    'A3 постер',
    'XIII',
    2,
    'Постерыг Flutter widget-ээр A3 (297×420 мм) харьцаагаар зурсан.',
    [
      'Аппын нэр, сэдэв, асуудал, шийдэл, шаардлага, дэлгэцүүд, технологи, QR/линк.',
      'Аппын “Бие даалт → A3 постер” хэсгээс нээж, дэлгэцийн зураг авч хэвлэнэ.',
    ],
    files: ['lib/bie_daalt/poster_screen.dart'],
  ),
  Stage(
    8,
    'Power point танилцуулга',
    'XIII',
    1,
    '12 слайд, Times New Roman 18pt, мөр хоорондын зай 1.5, автомат дугаар.',
    [
      'Нүүр хуудас · Агуулга · Оршил · Зорилго · Загвар · Зураг · Хүснэгт · Дүгнэлт · Ашигласан материал.',
      'Аппын “Бие даалт → Илтгэл” хэсэгт слайдаар үзүүлнэ (5–10 минут).',
    ],
    files: ['lib/bie_daalt/slides_screen.dart'],
  ),
  Stage(
    9,
    'Апп-ийг ажиллуулах',
    'XIII',
    3,
    'Утас, эмулятор эсвэл Chrome дээр ажиллуулж үзүүлнэ.',
    [
      'flutter pub get',
      'flutter run   (эсвэл flutter run -d chrome)',
      'flutter build apk --release → build/app/outputs/flutter-apk/app-release.apk',
      'Харуул: SH-0247 / 1234 · Менежер: M-001 / manager123',
    ],
    files: ['README.md'],
  ),
];

// ------------------------------------------------------------------ ИЛТГЭЛИЙН СЛАЙД (≥ 10)
const slides = <Slide>[
  Slide(appName, [topic, course, author, teacher, year]), // нүүр хуудас
  Slide('Агуулга', [
    'Оршил',
    'Зорилго',
    'Шаардлага',
    'Загвар (архитектур)',
    'Дэлгэцүүд',
    'Widget-ийн судалгаа',
    'Цалингийн тооцоо',
    'Дүгнэлт',
    'Ашигласан материал',
  ]),
  Slide('Оршил', [
    'Хамгаалалтын компанид харуулууд олон постод ээлжээр ажилладаг.',
    'Ирцийг цаасаар бүртгэдэг тул хоцролт, илүү цаг, шөнийн цагийг тооцоход алдаа гардаг.',
    'Иймд ирц, ээлж, цалинг нэг дор харуулах мобайл апп хэрэгтэй.',
  ]),
  Slide('Зорилго', [
    'Харуул постын бүс дотроос GPS-ээр ирцээ бүртгэх.',
    'Цалингийн задаргааг ажилтан өөрөө харах.',
    'Менежер сарын нэгтгэл тайлан, SOS, зөрчлийг хянах.',
  ]),
  Slide('Шаардлага', requirements),
  Slide('Загвар (архитектур)', [
    'Дэлгэц (screens/) → Api (data/api.dart) → LocalDb (data/local_db.dart)',
    'core/theme.dart — өнгө, фонт; core/widgets.dart — нийтлэг widget',
    'Сервер холбох бол зөвхөн api.dart-ыг солиход хангалттай.',
  ]),
  Slide('Дэлгэцүүд', screens),
  Slide('Widget-ийн судалгаа', [
    'StatefulWidget + setState · FutureBuilder',
    'NavigationBar · ListView · RefreshIndicator',
    'Stack + CustomPaint (геофенс) · AnimationController (SOS)',
    'TextField · ChoiceChip · SegmentedButton · AlertDialog',
  ]),
  Slide('Цалингийн тооцоо', [
    'Цагийн хөлс = үндсэн цалин ÷ 168',
    'Илүү цаг = цаг × цагийн хөлс × 1.5',
    'Шөнийн нэмэгдэл (22:00–06:00) = цаг × цагийн хөлс × 0.2',
    'Суутгал: тасалсан/хоцорсон цаг, НДШ 11.5%, ХХОАТ 10%',
  ]),
  Slide('Туршилт', [
    'Нэгж тест: мөнгөний формат, цаг, сар шилжүүлэх (flutter test).',
    'Android утас, Chrome хөтөч дээр ажиллуулж шалгасан.',
    'Туршилтын эрх: SH-0247 / 1234 · M-001 / manager123',
  ]),
  Slide('Дүгнэлт', [
    'Flutter / Dart ашиглан 12 дэлгэцтэй, сервергүй ажилладаг апп бүтээв.',
    'Ирц, цалингийн тооцоог автоматжуулснаар алдааг бууруулна.',
    'Цаашид: жинхэнэ сервер, царай таних, push мэдэгдэл нэмэх.',
  ]),
  Slide('Ашигласан материал', references),
];
