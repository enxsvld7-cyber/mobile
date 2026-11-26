// =====================================================================
// ДЭЛГЭЦ 04: ИРЦИЙН ТҮҮХ (attendance_screen.dart) — шаардлага №1
// ---------------------------------------------------------------------
// Сонгосон сарын ирцийн нэгтгэл (ирсэн, хоцорсон, тасалсан, чөлөөтэй), нийт
// ажилласан цагийг нормтой харьцуулсан зураас, өдөр бүрийн бүртгэлийн жагсаалт.
//
// ДЭЛГЭЦИЙН ЗОХИОМЖ (Figma: 04 · Ирцийн түүх):
//   Column
//   ├─ "Ирцийн түүх" гарчиг
//   ├─ MonthSelector               ‹ 2026 оны 11-р сар ›
//   └─ Expanded → AsyncView → RefreshIndicator → ListView
//      ├─ Row[ 4 × _box() ]        14 Ирсэн · 2 Хоцорсон · 0 Тасалсан · 1 Чөлөөтэй
//      ├─ AppCard: нийт цаг / норм + ClipRRect(Row[Expanded(flex)…]) зураас + тайлбар
//      └─ SectionTitle + _row() × N   ← [26 Пү] 07:46 → 20:00 · 12ц 05м · ●Хэвийн
//
// АШИГЛАСАН WIDGET-ИЙН СУДАЛГАА:
//   • Column + Expanded — дээд хэсэг тогтмол, доод жагсаалт үлдсэн өндрийг эзэлнэ.
//   • Expanded(flex: N) — Row доторх хэсгүүдийг харьцаагаар (үндсэн : илүү : үлдсэн)
//     хуваах → энгийн "progress bar".
//   • ClipRRect — хүүхдийг бөөрөнхий булангаар тайрна.
//   • Wrap — багтахгүй бол дараагийн мөр рүү ороох (тайлбарын цэгүүд).
//   • Spread оператор (...days.map) — жагсаалтыг children руу задлан нэмнэ.
//   • Record destructuring: final (label, tone) = attendanceStatus(d);
// =====================================================================
import 'package:flutter/material.dart';

import 'package:sahiul_app/data/api.dart';
import 'package:sahiul_app/core/theme.dart';
import 'package:sahiul_app/core/widgets.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _month = ymOf(DateTime.now()); // одоогийн сар
  Future<Json>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() => _future = Api.instance.attendance(_month));

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Align(alignment: Alignment.centerLeft, child: Text('Ирцийн түүх', style: h2)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: MonthSelector(
            month: _month,
            onChanged: (m) {
              _month = m; // сар солигдоход дахин ачаална
              _load();
            }),
      ),
      Expanded(
        child: AsyncView<Json>(
          future: _future,
          onRetry: _load,
          builder: (context, data) {
            final sum = obj(data['summary']);
            final days = list(data['days']);
            final worked = n(sum['workedHours']).toDouble();
            final ot = n(sum['overtimeHours']).toDouble();
            final norm = n(sum['normHours']).toDouble();
            final total = [worked, norm, 1.0].reduce((a, b) => a > b ? a : b); // зураасны бүтэн урт
            return RefreshIndicator(
              onRefresh: () async {
                _load();
                await _future;
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                children: [
                  // ---------- 4 тоон хайрцаг
                  Row(children: [
                    _box('${n(sum['present']).round()}', 'Ирсэн', C.success),
                    const SizedBox(width: 8),
                    _box('${n(sum['late']).round()}', 'Хоцорсон', C.warning),
                    const SizedBox(width: 8),
                    _box('${n(sum['absent']).round()}', 'Тасалсан', C.danger),
                    const SizedBox(width: 8),
                    _box('${n(sum['leave']).round()}', 'Чөлөөтэй', C.blue),
                  ]),
                  const SizedBox(height: 14),
                  // ---------- Нийт цаг ба зураас
                  AppCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Row(children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Нийт ажилласан цаг', style: small),
                            Text('${hoursText(worked)}  /  норм ${hoursText(norm)}', style: h2),
                          ]),
                        ),
                        if (worked >= norm && norm > 0) const Badge2('Норм биелсэн', Tone.success),
                      ]),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          height: 10,
                          child: Row(children: [
                            // flex нь бүхэл тоо байх ёстой тул ×100
                            Expanded(flex: ((worked - ot).clamp(0, total) * 100).round(), child: Container(color: C.blue)),
                            if (ot > 0) Expanded(flex: (ot * 100).round(), child: Container(color: C.success)),
                            Expanded(flex: ((total - worked).clamp(0, total) * 100).round() + 1, child: Container(color: C.canvas)),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(spacing: 14, runSpacing: 6, children: [
                        _legend(C.blue, 'Үндсэн ${hoursText(worked - ot)}'),
                        _legend(C.success, 'Илүү цаг ${hoursText(ot)}'),
                        _legend(C.night, 'Шөнийн ${hoursText(sum['nightHours'])}'),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 18),
                  const SectionTitle('Өдрийн бүртгэл'),
                  if (days.isEmpty)
                    const AppCard(child: Text('Энэ сард бүртгэл алга', style: small))
                  else
                    ...days.map((d) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _row(d))),
                ],
              ),
            );
          },
        ),
      ),
    ]);
  }

  /// Тоо + шошготой жижиг хайрцаг (Expanded — 4 нь тэнцүү өргөнтэй).
  Widget _box(String v, String l, Color c) => Expanded(
        child: AppCard(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(children: [
            Text(v, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: c)),
            const SizedBox(height: 2),
            Text(l, style: caption, maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
      );

  Widget _legend(Color c, String t) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(t, style: caption),
      ]);

  /// Нэг өдрийн мөр (Figma: Attendance Row компонент).
  Widget _row(Json d) {
    final (label, tone) = attendanceStatus(d); // record задлах
    final date = s(d['date']);
    final day = date.length >= 10 ? int.parse(date.substring(8, 10)).toString() : date;
    final night = d['kind'] == 'night';
    final inT = d['checkIn'] == null ? '—' : s(d['checkIn']);
    final outT = d['checkOut'] == null ? (d['status'] == 'active' ? '…' : '—') : s(d['checkOut']);
    final worked = n(d['workedMin']);
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        // Огнооны хайрцаг (шөнийн ээлж бол ягаан)
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(color: night ? C.nightBg : C.canvas, borderRadius: BorderRadius.circular(12)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(day, style: h2),
            Text(s(d['weekday']), style: caption),
          ]),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$inT → $outT', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: C.text)),
            const SizedBox(height: 2),
            Text('${night ? 'Шөнө · ' : ''}${worked > 0 ? minutesText(worked) : s(d['post'])}',
                style: small, maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
        const SizedBox(width: 8),
        Badge2(label, tone),
      ]),
    );
  }
}
