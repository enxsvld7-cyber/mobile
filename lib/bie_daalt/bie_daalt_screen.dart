// =====================================================================
// ДЭЛГЭЦ 13: БИЕ ДААЛТ (bie_daalt_screen.dart)
// ---------------------------------------------------------------------
// Бие даалтын 9 үе шатыг (даалгавар шалгах хүснэгт) аппын дотор харуулна.
// Мөр бүр дээр дарахад тухайн үе шатын дэлгэрэнгүй (StageScreen) нээгдэнэ.
// Дээд талын 2 товч: Илтгэл (слайд), A3 постер.
//
// ДЭЛГЭЦИЙН ЗОХИОМЖ:
//   Scaffold
//   ├─ AppBar "Бие даалт"
//   └─ ListView
//      ├─ AppCard (бараан): аппын нэр, сэдэв, нийт оноо
//      ├─ Row: FilledButton(Илтгэл) · OutlinedButton(A3 постер)
//      └─ AppCard × 9: [№] гарчиг · долоо хоног · оноо  → StageScreen
//
// АШИГЛАСАН WIDGET-ИЙН СУДАЛГАА:
//   • Navigator.push + MaterialPageRoute — шинэ дэлгэц стек дээр нээх.
//   • ListView + spread (...) — жагсаалтаас олон widget үүсгэх.
//   • Iterable.fold — оноонуудын нийлбэр (20 оноо).
//   • Table / TableRow — widget-ийн судалгааг хүснэгтээр харуулах.
// =====================================================================
import 'package:flutter/material.dart';

import 'package:sahiul_app/bie_daalt/content.dart';
import 'package:sahiul_app/bie_daalt/poster_screen.dart';
import 'package:sahiul_app/bie_daalt/slides_screen.dart';
import 'package:sahiul_app/core/theme.dart';
import 'package:sahiul_app/core/widgets.dart';

class BieDaaltScreen extends StatelessWidget {
  const BieDaaltScreen({super.key});

  void _open(BuildContext context, Widget page) => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final total = stages.fold<int>(0, (sum, st) => sum + st.points); // 20 оноо
    return Scaffold(
      appBar: plainAppBar('Бие даалт'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          AppCard(
            color: C.navy800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(appName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                const Text(topic, style: TextStyle(fontSize: 14, color: C.invMuted, height: 1.4)),
                const SizedBox(height: 12),
                Text('9 үе шат · нийт $total оноо', style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _open(context, const SlidesScreen()),
                  icon: const Icon(Icons.slideshow),
                  label: const Text('Илтгэл'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _open(context, const PosterScreen()),
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('A3 постер'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SectionTitle('Даалгавар шалгах хугацаа, оноо'),
          for (final st in stages) ...[
            AppCard(
              onTap: () => _open(context, StageScreen(stage: st)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: C.blue50,
                    child: Text('${st.no}', style: const TextStyle(color: C.blue, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(st.title, style: h3), const SizedBox(height: 2), Text('${st.week} долоо хоног', style: small)],
                    ),
                  ),
                  Badge2('${st.points} оноо', Tone.info),
                  const Icon(Icons.chevron_right, color: C.text2),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

/// Нэг үе шатын дэлгэрэнгүй.
class StageScreen extends StatelessWidget {
  const StageScreen({super.key, required this.stage});
  final Stage stage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: plainAppBar('${stage.no}. ${stage.title}'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [Badge2('${stage.week} долоо хоног', Tone.neutral), Badge2('${stage.points} оноо', Tone.info)],
                ),
                const SizedBox(height: 10),
                Text(stage.summary, style: body),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 5-р үе шат: widget-ийн судалгааг хүснэгтээр
          if (stage.no == 5)
            AppCard(padding: const EdgeInsets.all(8), child: _WidgetTable())
          else
            for (final item in stage.items)
              Padding(padding: const EdgeInsets.only(bottom: 8), child: AppCard(child: Text(item, style: body.copyWith(height: 1.45)))),
          if (stage.files.isNotEmpty) ...[
            const SizedBox(height: 8),
            const SectionTitle('Холбогдох файл'),
            Wrap(spacing: 8, runSpacing: 8, children: [for (final f in stage.files) Badge2(f, Tone.neutral)]),
          ],
        ],
      ),
    );
  }
}

class _WidgetTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const head = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.text);
    const cell = TextStyle(fontSize: 12, color: C.text, height: 1.35);
    Widget pad(Widget w) => Padding(padding: const EdgeInsets.all(6), child: w);
    return Table(
      columnWidths: const {0: FlexColumnWidth(1.1), 1: FlexColumnWidth(1.4), 2: FlexColumnWidth(0.9)},
      border: const TableBorder(horizontalInside: BorderSide(color: C.border)),
      children: [
        TableRow(
          children: [pad(const Text('Widget', style: head)), pad(const Text('Юунд', style: head)), pad(const Text('Файл', style: head))],
        ),
        for (final w in widgetStudy)
          TableRow(
            children: [
              pad(Text(w.name, style: cell.copyWith(fontWeight: FontWeight.w600))),
              pad(Text(w.purpose, style: cell)),
              pad(Text(w.file, style: cell.copyWith(color: C.text2))),
            ],
          ),
      ],
    );
  }
}
