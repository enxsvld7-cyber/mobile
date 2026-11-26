// =====================================================================
// widgets.dart — ДАХИН АШИГЛАХ WIDGET-ҮҮД БА ТУСЛАХ ФУНКЦУУД
// ---------------------------------------------------------------------
// Олон дэлгэцэд давтагддаг UI хэсгүүдийг (карт, шошго, сар сонгогч, ачаалах
// дэлгэц) нэг удаа бичээд бүх газар ашиглана → код богино, загвар нэгдмэл.
// Энэ нь Figma дээрх "Components" хуудастай дүйцнэ.
//
// АГУУЛГА:
//   JSON туслахууд  : n(), s(), list(), obj()
//   Формат          : money() 1,065,275₮ · hoursText() 12ц · minutesText() 12ц 05м
//   Огноо           : monthLabel(), shiftMonth(), dateLabel() Өнөөдөр/Маргааш
//   Төлөвийн шошго  : Tone (өнгө), attendanceStatus(), requestStatus(), urgencyLabel()
//   Widget-үүд      : Badge2, AppCard, IconChip, SectionTitle, MonthSelector,
//                     AsyncView, plainAppBar
//
// АШИГЛАСАН WIDGET-ИЙН СУДАЛГАА:
//   • Container — хэмжээ, padding, өнгө, булан (BoxDecoration)-тай хайрцаг.
//   • BoxDecoration — дэвсгэр өнгө, borderRadius (бөөрөнхий булан), border (хүрээ).
//   • Row / Column — хүүхдүүдийг хэвтээ / босоо эгнүүлнэ. mainAxisSize.min бол
//     агуулгынхаа хэмжээгээр л зай эзэлнэ.
//   • Material + InkWell — дарахад "долгион" (ripple) эффект гаргана.
//   • FutureBuilder — Future-ийн төлөвөөр (ачаалж/алдаа/бэлэн) өөр UI зурна.
//   • CircularProgressIndicator — эргэлддэг ачааллын тэмдэг.
//   • IconButton.filledTonal — Material 3-ын зөөлөн өнгөтэй дугуй товч.
//   • ScaffoldMessenger + SnackBar — дэлгэцийн доор түр мэдэгдэл.
//   • AppBar — дэлгэцийн дээд гарчиг, буцах товчийг автоматаар нэмнэ.
// =====================================================================
import 'package:flutter/material.dart';

import 'package:sahiul_app/data/api.dart';
import 'package:sahiul_app/core/theme.dart';

// ------------------------------------------------------------ JSON туслахууд
// Map-аас утга аюулгүй уншина: null эсвэл буруу төрөл ирсэн ч апп унахгүй.
num n(dynamic v) => v is num ? v : (num.tryParse('$v') ?? 0); // тоо
String s(dynamic v) => v == null ? '' : v.toString(); // текст
List<Json> list(dynamic v) => // жагсаалт
    v is List ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : <Json>[];
Json obj(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{}; // объект

// ------------------------------------------------------------ формат
/// 1065275 → '1,065,275₮' (мянгатын таслалтай)
String money(dynamic v) {
  final x = n(v).round();
  final neg = x < 0;
  final digits = x.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(','); // 3 оронтой бүлэг бүрийн өмнө таслал
    buf.write(digits[i]);
  }
  return '${neg ? '−' : ''}$buf₮';
}

/// 12.0 → '12ц', 5.8 → '5.8ц'
String hoursText(dynamic h) {
  final v = n(h).toDouble();
  return v == v.roundToDouble() ? '${v.round()}ц' : '${v.toStringAsFixed(1)}ц';
}

/// 725 → '12ц 05м', 45 → '45 мин'
String minutesText(dynamic m) {
  final v = n(m).round();
  final h = v ~/ 60; // бүхэл хуваах
  final mm = v % 60; // үлдэгдэл
  if (h == 0) return '$mm мин';
  return mm == 0 ? '$hц' : '$hц ${mm.toString().padLeft(2, '0')}м';
}

String two(int v) => v.toString().padLeft(2, '0'); // 5 → '05'
String ymOf(DateTime d) => '${d.year}-${two(d.month)}'; // '2026-11'

/// '2026-11' → '2026 оны 11-р сар'
String monthLabel(String ym) {
  final p = ym.split('-');
  return '${p[0]} оны ${int.parse(p[1])}-р сар';
}

/// Сар шилжүүлэх: ('2026-01', -1) → '2025-12'. DateTime нь 0, 13-р сарыг өөрөө засна.
String shiftMonth(String ym, int delta) {
  final p = ym.split('-');
  return ymOf(DateTime(int.parse(p[0]), int.parse(p[1]) + delta, 1));
}

const weekdaysLong = ['Даваа', 'Мягмар', 'Лхагва', 'Пүрэв', 'Баасан', 'Бямба', 'Ням'];

/// 'YYYY-MM-DD' → 'Өнөөдөр' / 'Маргааш' / 'Өчигдөр' / 'Баасан, 11.27'
String dateLabel(String ymd) {
  final d = DateTime.tryParse(ymd);
  if (d == null) return ymd;
  final now = DateTime.now();
  final diff = DateTime(d.year, d.month, d.day).difference(DateTime(now.year, now.month, now.day)).inDays;
  if (diff == 0) return 'Өнөөдөр';
  if (diff == 1) return 'Маргааш';
  if (diff == -1) return 'Өчигдөр';
  return '${weekdaysLong[d.weekday - 1]}, ${two(d.month)}.${two(d.day)}';
}

/// Цагаас хамаарсан мэндчилгээ.
String greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Өглөөний мэнд,';
  if (h < 18) return 'Өдрийн мэнд,';
  return 'Оройн мэнд,';
}

/// 'Б.Тэмүүлэн' → 'БТ' (аватарт)
String initials(String name) {
  final parts = name.replaceAll('.', ' ').split(' ').where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
}

/// Дэлгэцийн доор түр мэдэгдэл (SnackBar). error=true бол улаан.
void showMsg(BuildContext context, String text, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar() // өмнөх мэдэгдлийг хаана
    ..showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: error ? C.danger : C.text,
      behavior: SnackBarBehavior.floating, // доод ирмэгээс дээш "хөвсөн"
    ));
}

// ------------------------------------------------------------ төлөвийн өнгө (Tone)
/// Шошгоны өнгөний төрөл (Figma: Badge компонентын Type variant).
enum Tone { success, warning, danger, info, night, neutral }

// switch expression (Dart 3) — enum бүрт өнгө буцаана.
Color toneBg(Tone t) => switch (t) {
      Tone.success => C.successBg,
      Tone.warning => C.warningBg,
      Tone.danger => C.dangerBg,
      Tone.info => C.blue50,
      Tone.night => C.nightBg,
      Tone.neutral => C.canvas,
    };
Color toneFg(Tone t) => switch (t) {
      Tone.success => C.success,
      Tone.warning => C.warning,
      Tone.danger => C.danger,
      Tone.info => C.blue,
      Tone.night => C.night,
      Tone.neutral => C.text2,
    };

/// Ирцийн төлөвийг (status) шошгоны текст + өнгө болгоно. Record (String, Tone) буцаана.
(String, Tone) attendanceStatus(Json d) {
  switch (s(d['status'])) {
    case 'normal':
      return ('Хэвийн', Tone.success);
    case 'late':
      return ('Хоцорсон ${n(d['lateMin']).round()}м', Tone.warning);
    case 'overtime':
      return ('Илүү ${minutesText(d['overtimeMin'])}', Tone.info);
    case 'absent':
      return ('Тасалсан', Tone.danger);
    case 'leave':
      return ('Чөлөөтэй', Tone.neutral);
    case 'active':
      return ('Ажиллаж байна', Tone.info);
    case 'not_checked_in':
      return ('Ирээгүй', Tone.warning);
    default:
      return ('Удахгүй', Tone.neutral);
  }
}

(String, Tone) requestStatus(String status) => switch (status) {
      'approved' => ('Зөвшөөрсөн', Tone.success),
      'rejected' => ('Татгалзсан', Tone.danger),
      _ => ('Хүлээгдэж буй', Tone.warning),
    };

(String, Tone) urgencyLabel(String u) => switch (u) {
      'high' => ('Өндөр', Tone.danger),
      'medium' => ('Дунд', Tone.warning),
      _ => ('Бага', Tone.neutral),
    };

// ------------------------------------------------------------ Badge2 (шошго)
/// Жижиг "pill" шошго: ● Хэвийн. Нэр нь Material-ын Badge widget-тэй давхцахгүйн тулд Badge2.
/// Зохиомж: Container(өнгөт, бөөрөнхий) → Row[ цэг(Container circle), Text ]
class Badge2 extends StatelessWidget {
  const Badge2(this.label, this.tone, {super.key});
  final String label;
  final Tone tone;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: toneBg(tone), borderRadius: BorderRadius.circular(999)), // 999 = бүрэн бөөрөнхий
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: toneFg(tone), shape: BoxShape.circle)),
        const SizedBox(width: 6), // SizedBox — хоосон зай үүсгэх хамгийн энгийн арга
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: toneFg(tone))),
      ]),
    );
  }
}

// ------------------------------------------------------------ AppCard (карт)
/// Цагаан, бөөрөнхий булантай, нимгэн хүрээтэй карт. onTap өгвөл дарагдана.
/// Material (дэвсгэр) + InkWell (ripple) + Container (padding, хүрээ) гэсэн 3 давхар.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color = Colors.white, this.onTap});
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final VoidCallback? onTap; // null бол дарагдахгүй
  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16), // ripple булангаас гарахгүй
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color == Colors.white ? C.cardBorder : Colors.transparent),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ IconChip
/// Өнгөт дэвсгэртэй дүрс тэмдэг (жишээ: цэнхэр дугуй доторх цаг).
class IconChip extends StatelessWidget {
  const IconChip(this.icon, {super.key, this.bg = C.blue50, this.fg = C.blue, this.size = 40, this.radius});
  final IconData icon;
  final Color bg;
  final Color fg;
  final double size;
  final double? radius; // null бол дугуй (size/2)
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(radius ?? size / 2)),
      child: Icon(icon, color: fg, size: size * 0.52), // Icon — Material Icons фонтоос дүрс
    );
  }
}

// ------------------------------------------------------------ SectionTitle
/// Хэсгийн гарчиг + баруун талд нэмэлт (жишээ: "Энэ сарын тойм ........ 11-р сар").
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: Row(children: [
        Expanded(child: Text(title, style: h3)), // Expanded — үлдсэн бүх өргөнийг эзэлнэ
        if (trailing != null) trailing!, // collection-if: нөхцөлтэй хүүхэд
      ]),
    );
  }
}

// ------------------------------------------------------------ MonthSelector
/// ‹ 2026 оны 11-р сар › — сар солих. Ирээдүйн сар руу шилжихгүй.
class MonthSelector extends StatelessWidget {
  const MonthSelector({super.key, required this.month, required this.onChanged});
  final String month;
  final ValueChanged<String> onChanged; // эцэг widget-д шинэ сарыг дамжуулна (callback)
  @override
  Widget build(BuildContext context) {
    final canNext = month.compareTo(ymOf(DateTime.now())) < 0;
    return AppCard(
      padding: const EdgeInsets.all(6),
      child: Row(children: [
        IconButton.filledTonal(onPressed: () => onChanged(shiftMonth(month, -1)), icon: const Icon(Icons.chevron_left)),
        Expanded(child: Text(monthLabel(month), textAlign: TextAlign.center, style: h3)),
        // onPressed: null → товч идэвхгүй (саарал)
        IconButton.filledTonal(onPressed: canNext ? () => onChanged(shiftMonth(month, 1)) : null, icon: const Icon(Icons.chevron_right)),
      ]),
    );
  }
}

// ------------------------------------------------------------ AsyncView
/// Future-ийн 3 төлөвийг нэг загвараар харуулна:
///   ачаалж байна → CircularProgressIndicator
///   алдаа        → дүрс + мессеж + "Дахин оролдох" товч
///   бэлэн        → builder(context, data)
/// Generic <T> — ямар ч төрлийн өгөгдөлд ашиглана.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({super.key, required this.future, required this.builder, required this.onRetry});
  final Future<T>? future;
  final Widget Function(BuildContext, T) builder;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(),
                SizedBox(height: 14),
                Text('Ачаалж байна…', style: small),
              ]),
            ),
          );
        }
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline, size: 40, color: C.text2),
                const SizedBox(height: 12),
                Text('${snap.error}', textAlign: TextAlign.center, style: body),
                const SizedBox(height: 16),
                SizedBox(width: 200, child: FilledButton(onPressed: onRetry, child: const Text('Дахин оролдох'))),
              ]),
            ),
          );
        }
        return builder(context, snap.data as T);
      },
    );
  }
}

/// Энгийн AppBar (саарал дэвсгэр, сүүдэргүй). dark=true бол бараан (SOS дэлгэц).
PreferredSizeWidget plainAppBar(String title, {List<Widget>? actions, bool dark = false}) {
  return AppBar(
    title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: dark ? Colors.white : C.text)),
    backgroundColor: dark ? C.navy900 : C.canvas,
    foregroundColor: dark ? Colors.white : C.text, // буцах сумны өнгө
    surfaceTintColor: Colors.transparent, // Material 3-ын гүйлгэхэд өнгө солигдохыг болиулна
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    actions: actions, // баруун талын товчнууд
  );
}
