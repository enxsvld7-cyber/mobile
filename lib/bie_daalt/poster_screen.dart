// =====================================================================
// ДЭЛГЭЦ 15: A3 ПОСТЕР (poster_screen.dart) — үе шат №7
// ---------------------------------------------------------------------
// Постерыг зураг засварлагчаар биш, Flutter widget-ээр зурсан.
// A3 цаас = 297 × 420 мм → 842 × 1191 логик цэг (72 dpi). FittedBox нь
// постерыг дэлгэцэнд багтаан харуулна; хэвлэхдээ дэлгэцийн зураг (screenshot)
// авч эсвэл Chrome дээр Ctrl+P → A3 сонгоно.
//
// ДЭЛГЭЦИЙН ЗОХИОМЖ:
//   Scaffold
//   └─ InteractiveViewer                     ← 2 хуруугаар томруулж харах
//      └─ Center → AspectRatio(297/420) → FittedBox
//         └─ SizedBox(842×1191) → Column
//            ├─ _Header      : лого, нэр, сэдэв
//            ├─ Row: _Block(Асуудал) · _Block(Шийдэл)
//            ├─ _Block(Шаардлага)
//            ├─ _Block(Дэлгэцүүд) — Wrap × 12 шошго
//            ├─ Row: _Block(Цалингийн тооцоо) · _Block(Технологи)
//            └─ _Footer      : оюутан, багш, он
//
// АШИГЛАСАН WIDGET-ИЙН СУДАЛГАА:
//   • InteractiveViewer — pinch-zoom, чирж харах.
//   • AspectRatio + FittedBox — тогтмол A3 хэмжээг ямар ч дэлгэцэнд багтаах.
//   • LinearGradient — толгой хэсгийн өнгө шилжилт.
//   • Wrap — шошгуудыг мөр дүүрвэл дараагийн мөрөнд ороох.
// =====================================================================
import 'package:flutter/material.dart';

import 'package:sahiul_app/bie_daalt/content.dart';
import 'package:sahiul_app/core/theme.dart';

class PosterScreen extends StatelessWidget {
  const PosterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE3EC),
      appBar: AppBar(title: const Text('A3 постер'), backgroundColor: const Color(0xFFDDE3EC)),
      body: InteractiveViewer(
        maxScale: 5,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: AspectRatio(aspectRatio: 297 / 420, child: FittedBox(child: SizedBox(width: 842, height: 1191, child: _Poster()))),
          ),
        ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(36, 20, 36, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _Block('Асуудал', Icons.report_problem_outlined, C.danger, [
                            'Ирцийг цаасаар бүртгэдэг',
                            'Хоцролт, илүү цагийг гараар тооцдог',
                            'Яаралтай үед мэдээлэл удаан очдог',
                          ]),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _Block('Шийдэл', Icons.lightbulb_outline, C.success, [
                            'GPS бүс доторх ирц бүртгэл',
                            'Цалингийн автомат задаргаа',
                            'SOS товч, зөрчил мэдээлэх',
                          ]),
                        ),
                      ],
                    ),
                  ),
                  const _Block('Шаардлага', Icons.checklist, C.blue, requirements, dense: true),
                  _screensBlock(),
                  const IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _Block('Цалингийн тооцоо', Icons.calculate_outlined, C.night, [
                            'Цагийн хөлс = цалин ÷ 168',
                            'Илүү цаг × 1.5',
                            'Шөнийн цаг × 0.2 нэмэгдэл',
                            'НДШ 11.5% · ХХОАТ 10%',
                          ]),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _Block('Технологи', Icons.code, C.sun, [
                            'Flutter 3 · Dart 3',
                            'Material 3 дизайн',
                            'geolocator (GPS)',
                            'url_launcher (залгах)',
                          ]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _footer(),
        ],
      ),
    );
  }

  Widget _header() => Container(
    padding: const EdgeInsets.fromLTRB(40, 32, 40, 26),
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [C.navy900, C.navy800, C.blue], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    child: Row(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(color: C.blue, borderRadius: BorderRadius.circular(28)),
          child: const Icon(Icons.verified_user_outlined, size: 64, color: Colors.white),
        ),
        const SizedBox(width: 28),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(appName, style: TextStyle(fontSize: 64, fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
              SizedBox(height: 10),
              Text(topic, style: TextStyle(fontSize: 22, color: C.invMuted, height: 1.3)),
              SizedBox(height: 8),
              Text(course, style: TextStyle(fontSize: 16, color: Colors.white70)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _screensBlock() => _Frame(
    title: 'Дэлгэцүүд (12)',
    icon: Icons.phone_iphone,
    color: C.blue,
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final sc in screens)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: C.blue50, borderRadius: BorderRadius.circular(999)),
            child: Text(sc.split(' — ').first, style: const TextStyle(fontSize: 15, color: C.blue, fontWeight: FontWeight.w600)),
          ),
      ],
    ),
  );

  Widget _footer() => Container(
    color: C.canvas,
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
    child: const Row(
      children: [
        Expanded(child: Text('$author   ·   $teacher', style: TextStyle(fontSize: 16, color: C.text))),
        Text(year, style: TextStyle(fontSize: 16, color: C.text2)),
      ],
    ),
  );
}

/// Гарчигтай, хүрээтэй хайрцаг.
class _Frame extends StatelessWidget {
  const _Frame({required this.title, required this.icon, required this.color, required this.child});
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: C.cardBorder, width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// Цэгтэй жагсаалттай хайрцаг.
class _Block extends StatelessWidget {
  const _Block(this.title, this.icon, this.color, this.lines, {this.dense = false});
  final String title;
  final IconData icon;
  final Color color;
  final List<String> lines;
  final bool dense;
  @override
  Widget build(BuildContext context) {
    return _Frame(
      title: title,
      icon: icon,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final l in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(dense ? l : '•  $l', style: TextStyle(fontSize: dense ? 14 : 17, color: C.text, height: 1.3)),
            ),
        ],
      ),
    );
  }
}
