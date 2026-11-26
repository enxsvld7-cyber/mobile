// =====================================================================
// ДЭЛГЭЦ 10: МЕНЕЖЕРИЙН ТАЙЛАН (manager_report_screen.dart) — шаардлага №2
// ---------------------------------------------------------------------
// Бүх ажилтны сарын ирц, илүү цаг, хоцролт, гарт олгох цалингийн нэгтгэл ба
// Excel-д оруулах CSV тайлан (нягтлан бодогчид цалин бодоход хэрэгтэй мэдээлэл).
//
// ДЭЛГЭЦИЙН ЗОХИОМЖ (Figma: 09 · Менежерийн тайлан):
//   Column
//   ├─ Row[ гарчиг · Badge2(Менежер) ] + MonthSelector
//   └─ Expanded → AsyncView → ListView
//      ├─ 2 × Row[ 2 × _stat() ]   ← Нийт ажилтан · Одоо ээлжинд · Хоцролт · Илүү цаг
//      ├─ Wrap[ Badge2 ]            ← Идэвхтэй SOS / Нээлттэй зөрчил / Хүлээгдэж буй хүсэлт
//      ├─ AppCard: хүснэгт — толгой Row + мөр бүр Row[ Expanded(flex 5/2/2/2) ]
//      └─ FilledButton "Excel (CSV) хуулах"
//
// АШИГЛАСАН WIDGET-ИЙН СУДАЛГАА:
//   • Expanded(flex: 5 / 2 / 2 / 2) — Row-г баганын харьцаагаар хувааж хүснэгт хийх.
//   • TextAlign.right — тоон баганыг баруун тийш тэгшлэх.
//   • Clipboard.setData (flutter/services) — CSV текстийг хуулж, Excel/Sheets-д
//     Ctrl+V хийхэд багана болж орно.
// =====================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sahiul_app/data/api.dart';
import 'package:sahiul_app/core/theme.dart';
import 'package:sahiul_app/core/widgets.dart';

/// Менежерийн ирц, цалингийн нэгтгэл + Excel (CSV) татах (шаардлага №2).
class ManagerReportScreen extends StatefulWidget {
  const ManagerReportScreen({super.key});
  @override
  State<ManagerReportScreen> createState() => _ManagerReportScreenState();
}

class _ManagerReportScreenState extends State<ManagerReportScreen> {
  String _month = ymOf(DateTime.now());
  Future<Json>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() => _future = Api.instance.managerOverview(_month));

  /// CSV тайланг санах ой руу (clipboard) хуулна → Excel-д paste хийхэд хүснэгт болно.
  Future<void> _download() async {
    await Clipboard.setData(ClipboardData(text: Api.instance.payrollCsv(_month)));
    if (mounted) showMsg(context, 'Тайлан хуулагдлаа — Excel/Google Sheets-д paste (Ctrl+V) хийнэ үү');
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(children: [
          Expanded(child: Text('Ирц ба цалингийн тайлан', style: h2)),
          Badge2('Менежер', Tone.night),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: MonthSelector(month: _month, onChanged: (m) {
          _month = m;
          _load();
        }),
      ),
      Expanded(
        child: AsyncView<Json>(
          future: _future,
          onRetry: _load,
          builder: (context, data) {
            final t = obj(data['totals']);
            final emps = list(data['employees']);
            return RefreshIndicator(
              onRefresh: () async {
                _load();
                await _future;
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                children: [
                  Row(children: [
                    _stat(Icons.groups_outlined, '${n(t['employees']).round()}', 'Нийт ажилтан', C.blue50, C.blue),
                    const SizedBox(width: 12),
                    _stat(Icons.how_to_reg_outlined, '${n(t['onDutyNow']).round()}/${n(t['scheduledNow']).round()}', 'Одоо ээлжинд',
                        C.successBg, C.success),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    _stat(Icons.warning_amber_rounded, '${n(t['lateCount']).round()}', 'Хоцролт (сар)', C.warningBg, C.warning),
                    const SizedBox(width: 12),
                    _stat(Icons.trending_up, hoursText(t['overtimeHours']), 'Нийт илүү цаг', C.nightBg, C.night),
                  ]),
                  const SizedBox(height: 12),
                  if (n(t['activeSos']) > 0 || n(t['openIncidents']) > 0 || n(t['pendingRequests']) > 0)
                    Wrap(spacing: 8, runSpacing: 6, children: [
                      if (n(t['activeSos']) > 0) Badge2('Идэвхтэй SOS: ${n(t['activeSos']).round()}', Tone.danger),
                      if (n(t['openIncidents']) > 0) Badge2('Нээлттэй зөрчил: ${n(t['openIncidents']).round()}', Tone.warning),
                      if (n(t['pendingRequests']) > 0) Badge2('Хүлээгдэж буй хүсэлт: ${n(t['pendingRequests']).round()}', Tone.info),
                    ]),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Row(children: [
                        const Expanded(child: Text('Ажилтнуудын нэгтгэл', style: h3)),
                        Text('Гарт олгох нийт ${money(t['payrollNet'])}', style: caption),
                      ]),
                      const SizedBox(height: 10),
                      const Row(children: [
                        Expanded(flex: 5, child: Text('Ажилтан', style: caption)),
                        Expanded(flex: 2, child: Text('Цаг', textAlign: TextAlign.right, style: caption)),
                        Expanded(flex: 2, child: Text('Илүү', textAlign: TextAlign.right, style: caption)),
                        Expanded(flex: 2, child: Text('Хоцр.', textAlign: TextAlign.right, style: caption)),
                      ]),
                      const Divider(height: 16),
                      ...emps.map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(children: [
                              Expanded(
                                flex: 5,
                                child: Row(children: [
                                  CircleAvatar(
                                      radius: 16,
                                      backgroundColor: C.blue50,
                                      child: Text(initials(s(e['name'])),
                                          style: const TextStyle(fontSize: 11, color: C.blue, fontWeight: FontWeight.w600))),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(s(e['name']),
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: C.text),
                                          overflow: TextOverflow.ellipsis),
                                      Text('${s(e['post'])} · ${money(e['net'])}', style: caption, overflow: TextOverflow.ellipsis),
                                    ]),
                                  ),
                                ]),
                              ),
                              Expanded(flex: 2, child: Text(hoursText(e['workedHours']), textAlign: TextAlign.right, style: body)),
                              Expanded(
                                  flex: 2,
                                  child: Text(hoursText(e['overtimeHours']),
                                      textAlign: TextAlign.right,
                                      style: TextStyle(fontSize: 15, color: n(e['overtimeHours']) > 0 ? C.success : C.text2))),
                              Expanded(
                                  flex: 2,
                                  child: Text('${n(e['lateCount']).round()}',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(fontSize: 15, color: n(e['lateCount']) >= 3 ? C.warning : C.text))),
                            ]),
                          )),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(onPressed: _download, icon: const Icon(Icons.download), label: const Text('Excel-д хуулах (тайлан)')),
                  const SizedBox(height: 8),
                  const Text('Хуулсан тайланг Excel, Google Sheets-д paste хийнэ. Нягтлан бодогчид илгээхэд бэлэн.',
                      style: caption, textAlign: TextAlign.center),
                ],
              ),
            );
          },
        ),
      ),
    ]);
  }

  Widget _stat(IconData icon, String value, String label, Color bg, Color fg) => Expanded(
        child: AppCard(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            IconChip(icon, bg: bg, fg: fg, size: 40, radius: 12),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                FittedBox(child: Text(value, style: h2)),
                Text(label, style: small, maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
          ]),
        ),
      );
}
