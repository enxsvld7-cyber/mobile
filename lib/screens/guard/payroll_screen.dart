// =====================================================================
// ДЭЛГЭЦ 05: ЦАЛИНГИЙН МЭДЭЭЛЭЛ (payroll_screen.dart) — шаардлага №2
// ---------------------------------------------------------------------
// Ирцийн бүртгэлээс автоматаар тооцсон цалин бодох мэдээлэл (ээлж, нийт цаг,
// илүү цаг, шөнийн цаг, хоцролт, чөлөө) болон цалингийн задаргаа.
//
// ДЭЛГЭЦИЙН ЗОХИОМЖ (Figma: 05 · Цалингийн мэдээлэл):
//   Column
//   ├─ гарчиг + MonthSelector
//   └─ Expanded → AsyncView → ListView
//      ├─ Container(navy): сар · "Урьдчилсан" · Гарт олгох 1,065,275₮ (том)
//      ├─ AppCard "Цалин бодох мэдээлэл": 2 × Row[ 3 × _metric() ]
//      ├─ AppCard "Цалингийн задаргаа": _line() × 6 · Divider · Гарт олгох
//      └─ тайлбар текст
//
// ТООЦООНЫ ТОМЬЁО (local_db.dart → _calcPay):
//   цагийн хөлс   = үндсэн цалин / 168
//   нийт цалин    = үндсэн + илүү(×1.5) + шөнө(+20%) − тасалсан − хоцролт
//   гарт олгох    = нийт − НДШ(11.5%) − ХХОАТ(10%)
//
// АШИГЛАСАН WIDGET-ИЙН СУДАЛГАА:
//   • FittedBox — том мөнгөн дүн жижиг дэлгэцэнд багтахгүй бол жижигрүүлнэ.
//   • Divider — нимгэн хэвтээ зураас (хэсгүүдийг тусгаарлана).
//   • Row + Expanded + Text — зүүн талд нэр, баруун талд дүн (хүснэгт маягтай).
//   • String interpolation '${...}' — тоог текст дотор оруулах.
// =====================================================================
import 'package:flutter/material.dart';

import 'package:sahiul_app/data/api.dart';
import 'package:sahiul_app/core/theme.dart';
import 'package:sahiul_app/core/widgets.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});
  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  String _month = ymOf(DateTime.now());
  Future<Json>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() => _future = Api.instance.payroll(_month));

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Align(alignment: Alignment.centerLeft, child: Text('Цалингийн мэдээлэл', style: h2)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: MonthSelector(
            month: _month,
            onChanged: (m) {
              _month = m;
              _load();
            }),
      ),
      Expanded(
        child: AsyncView<Json>(
          future: _future,
          onRetry: _load,
          builder: (context, data) {
            final sum = obj(data['summary']);
            final pay = obj(data['pay']);
            final rates = obj(pay['rates']);
            final estimated = data['estimated'] == true; // одоогийн сар → урьдчилсан
            final si = (n(rates['socialInsuranceRate']) * 100).toStringAsFixed(1); // 0.115 → '11.5'
            final pit = (n(rates['incomeTaxRate']) * 100).toStringAsFixed(0);
            return RefreshIndicator(
              onRefresh: () async {
                _load();
                await _future;
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                children: [
                  // ---------- Гарт олгох цалингийн бараан карт
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: C.navy800, borderRadius: BorderRadius.circular(20)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(
                            child: Text(monthLabel(_month), style: const TextStyle(color: C.invMuted, fontSize: 13, fontWeight: FontWeight.w600))),
                        if (estimated)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(999)),
                            child: const Text('Урьдчилсан', style: TextStyle(color: Colors.white, fontSize: 11)),
                          ),
                      ]),
                      const SizedBox(height: 10),
                      const Text('Гарт олгох цалин (тооцоолсон)', style: TextStyle(color: C.invMuted, fontSize: 13)),
                      FittedBox(
                        child: Text(money(pay['net']),
                            style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -1)),
                      ),
                      Text('Нийт цалин ${money(pay['gross'])} · цагийн хөлс ${money(pay['hourlyRate'])}',
                          style: const TextStyle(color: C.invMuted, fontSize: 11)),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  // ---------- Цалин бодох мэдээлэл (ирцээс)
                  AppCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      const Text('Цалин бодох мэдээлэл', style: h3),
                      const Text('Ирцийн бүртгэлээс автоматаар тооцсон', style: caption),
                      const SizedBox(height: 12),
                      Row(children: [
                        _metric('Ээлж', '${n(sum['shifts']).round()}', C.text),
                        const SizedBox(width: 8),
                        _metric('Нийт цаг', hoursText(sum['workedHours']), C.text),
                        const SizedBox(width: 8),
                        _metric('Илүү цаг', hoursText(sum['overtimeHours']), C.success),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        _metric('Шөнийн цаг', hoursText(sum['nightHours']), C.night),
                        const SizedBox(width: 8),
                        _metric('Хоцролт', '${n(sum['lateCount']).round()} (${n(sum['lateMin']).round()}м)', C.warning),
                        const SizedBox(width: 8),
                        _metric('Чөлөө/тасалсан', '${n(sum['leave']).round()} / ${n(sum['absent']).round()}', C.blue),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  // ---------- Цалингийн задаргаа
                  AppCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      const Text('Цалингийн задаргаа', style: h3),
                      const SizedBox(height: 6),
                      _line('Үндсэн цалин', 'Сарын норм ${n(rates['normHours']).round()} цаг', money(pay['baseSalary']), C.text),
                      _line('Илүү цагийн нэмэгдэл', '×${n(rates['overtimeRate'])} цагийн хөлс', '+${money(pay['overtimePay'])}', C.success),
                      _line('Шөнийн нэмэгдэл', '22:00–06:00 · +${(n(rates['nightRate']) * 100).round()}%', '+${money(pay['nightPay'])}', C.success),
                      _line('Тасалсан, хоцролтын суутгал', 'Ажиллаагүй цагийн хөлс',
                          '−${money(n(pay['absenceDeduction']) + n(pay['lateDeduction']))}', C.danger),
                      _line('НДШ', '$si%', '−${money(pay['socialInsurance'])}', C.danger),
                      _line('ХХОАТ', '$pit%', '−${money(pay['incomeTax'])}', C.danger),
                      const Divider(height: 20),
                      Row(children: [
                        const Expanded(child: Text('Гарт олгох', style: h3)),
                        Text(money(pay['net']), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: C.text)),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 10),
                  const Text('Хувь хэмжээг байгууллагын журам, хуулийн өөрчлөлтөөр local_db.dart-д өөрчилнө.', style: caption),
                ],
              ),
            );
          },
        ),
      ),
    ]);
  }

  /// Нэг үзүүлэлтийн жижиг хайрцаг (шошго + утга).
  Widget _metric(String label, String value, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: C.canvas, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: caption, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            FittedBox(child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color))),
          ]),
        ),
      );

  /// Задаргааны мөр: [нэр + тайлбар] ......... [дүн]
  Widget _line(String label, String detail, String value, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: C.text)),
              Text(detail, style: caption),
            ]),
          ),
          const SizedBox(width: 12),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color)),
        ]),
      );
}
