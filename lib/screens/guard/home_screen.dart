// =====================================================================
// ДЭЛГЭЦ 02: НҮҮР (home_screen.dart) — шаардлага №1
// ---------------------------------------------------------------------
// Харуулын өдөр тутмын гол дэлгэц: өнөөдрийн ээлж, ирц бүртгэх товч, сарын
// тойм (ажилласан цаг, илүү цаг, хоцролт), үйлчилгээ рүү очих хавтан, SOS.
//
// ДЭЛГЭЦИЙН ЗОХИОМЖ (Figma: 02 · Нүүр):
//   AsyncView (ачаалж / алдаа / бэлэн)
//   └─ RefreshIndicator                  ← доош татахад шинэчилнэ
//      └─ ListView (padding 20)          ← босоо гүйлгэх жагсаалт
//         ├─ _header()      Row[ CircleAvatar(БТ) · Column(мэндчилгээ, нэр) · SOS товч ]
//         ├─ _shiftCard()   Container(navy, radius 20)
//         │                 ├─ Row[ ээлжийн төрөл (pill) · хэдэн минутын дараа ]
//         │                 ├─ Постын нэр, хаяг
//         │                 ├─ Row[ Эхлэх · Дуусах · Хүлээлгэх ]  (тунгалаг дэвсгэр)
//         │                 └─ FilledButton (Ирц бүртгэх / Явсан цаг бүртгэх)
//         ├─ SectionTitle + Row[ 3 × _stat() ]       ← сарын тойм
//         └─ SectionTitle + 2 × Row[ 2 × _tile() ]   ← үйлчилгээ
//
// АШИГЛАСАН WIDGET-ИЙН СУДАЛГАА:
//   • RefreshIndicator — ListView-г доош татахад onRefresh (Future) дуудна.
//   • ListView — олон элементийг босоогоор гүйлгэнэ (дэлгэцэнд багтахгүй үед).
//   • CircleAvatar — дугуй аватар (зураг эсвэл үсэг).
//   • Expanded — Row/Column дотор үлдсэн зайг тэнцүү хуваана (3 стат карт).
//   • Spacer — Row дотор хоосон зайг "түлхэх" уян зай.
//   • FittedBox — текст багтахгүй бол жижигрүүлж багтаана.
//   • Navigator.push + MaterialPageRoute — шинэ дэлгэц нээж, буцахад await дуусна
//     (буцаж ирэхэд өгөгдлийг дахин ачаална).
//   • Color.withValues(alpha:) — өнгийг тунгалаг болгох (0 = бүрэн тунгалаг).
// =====================================================================
import 'package:flutter/material.dart';

import 'package:sahiul_app/data/api.dart';
import 'package:sahiul_app/core/theme.dart';
import 'package:sahiul_app/core/widgets.dart';
import 'package:sahiul_app/screens/guard/check_in_screen.dart';
import 'package:sahiul_app/screens/guard/incident_screen.dart';
import 'package:sahiul_app/screens/guard/sos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onOpenTab});

  /// Хавтан дарахад GuardShell-ийн табыг солих callback (2 = Хуваарь, 3 = Цалин, 1 = Ирц).
  final ValueChanged<int> onOpenTab;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<Json>? _future; // ачаалж буй өгөгдөл (FutureBuilder сонсоно)

  @override
  void initState() {
    super.initState();
    _load(); // дэлгэц нээгдэнгүүт өгөгдөл ачаална
  }

  void _load() => setState(() => _future = Api.instance.home());

  /// Дэд дэлгэц нээгээд, хаагдахад нүүрийг шинэчилнэ (жишээ: ирц бүртгэсний дараа).
  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute<bool>(builder: (_) => screen));
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return AsyncView<Json>(
      future: _future,
      onRetry: _load,
      builder: (context, data) {
        final user = obj(data['user']);
        final shift = data['shift'] == null ? null : obj(data['shift']); // ээлж байхгүй байж болно
        final month = obj(data['month']);
        final adhoc = data['demoMode'] == true; // ээлжгүй үед ч ирц бүртгэхийг зөвшөөрөх
        return RefreshIndicator(
          onRefresh: () async {
            _load();
            await _future;
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _header(s(user['name'])),
              const SizedBox(height: 16),
              _shiftCard(shift, adhoc),
              const SizedBox(height: 20),
              // ---------- Сарын тойм: 3 тэнцүү карт
              SectionTitle('Энэ сарын тойм',
                  trailing: Text(monthLabel(s(month['month']).isEmpty ? ymOf(DateTime.now()) : s(month['month'])),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.blue))),
              Row(children: [
                Expanded(child: _stat(Icons.schedule, hoursText(month['workedHours']), 'Ажилласан', C.blue50, C.blue)),
                const SizedBox(width: 10),
                Expanded(child: _stat(Icons.trending_up, hoursText(month['overtimeHours']), 'Илүү цаг', C.successBg, C.success)),
                const SizedBox(width: 10),
                Expanded(child: _stat(Icons.warning_amber_rounded, '${n(month['lateCount']).round()} удаа', 'Хоцролт', C.warningBg, C.warning)),
              ]),
              const SizedBox(height: 20),
              // ---------- Үйлчилгээ: 2×2 хавтан
              const SectionTitle('Үйлчилгээ'),
              Row(children: [
                Expanded(child: _tile(Icons.calendar_month_outlined, 'Ээлжийн хуваарь', 'Ойрын ээлжүүд', C.blue50, C.blue, () => widget.onOpenTab(2))),
                const SizedBox(width: 12),
                Expanded(
                    child: _tile(Icons.report_gmailerrorred, 'Зөрчил мэдээлэх', 'Осол, сэжиг', C.dangerBg, C.danger,
                        () => _open(const IncidentScreen()))),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _tile(Icons.account_balance_wallet_outlined, 'Цалингийн мэдээлэл', 'Цаг, нэмэгдэл', C.successBg, C.success,
                        () => widget.onOpenTab(3))),
                const SizedBox(width: 12),
                Expanded(child: _tile(Icons.history, 'Ирцийн түүх', 'Сарын бүртгэл', C.nightBg, C.night, () => widget.onOpenTab(1))),
              ]),
            ],
          ),
        );
      },
    );
  }

  /// Дээд мөр: аватар + мэндчилгээ + нэр + SOS товч.
  Widget _header(String name) {
    return Row(children: [
      CircleAvatar(
        radius: 22,
        backgroundColor: C.blue50,
        child: Text(initials(name), style: const TextStyle(color: C.blue, fontWeight: FontWeight.w600)),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(greeting(), style: small),
          Text(name, style: h2, overflow: TextOverflow.ellipsis), // урт нэрийг "..." болгоно
        ]),
      ),
      FilledButton.icon(
        onPressed: () => _open(const SosScreen()),
        style: FilledButton.styleFrom(
          backgroundColor: C.danger,
          minimumSize: const Size(0, 40), // theme-ийн бүтэн өргөнийг дарж жижиг товч болгоно
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        icon: const Icon(Icons.emergency_share, size: 18),
        label: const Text('SOS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ),
    ]);
  }

  /// Өнөөдрийн (эсвэл дараагийн) ээлжийн бараан карт ба ирцийн товч.
  Widget _shiftCard(Json? shift, bool adhoc) {
    if (shift == null) {
      // Ойрын ээлж алга — гэхдээ туршилтад ирц бүртгэх боломж үлдээнэ
      return AppCard(
        color: C.navy800,
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Ойрын хугацаанд ээлж алга', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Хуваарь шинэчлэгдвэл энд харагдана.', style: TextStyle(color: C.invMuted, fontSize: 13)),
          if (adhoc) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: C.success),
              onPressed: () => _open(const CheckInScreen(shift: null)),
              icon: const Icon(Icons.face_retouching_natural),
              label: const Text('Ирц бүртгэх'),
            ),
          ],
        ]),
      );
    }
    final post = obj(shift['post']);
    final att = shift['attendance'] == null ? null : obj(shift['attendance']); // бүртгэсэн ирц
    final isNight = shift['kind'] == 'night';
    final canIn = shift['canCheckIn'] == true || (adhoc && att == null);
    final canOut = shift['canCheckOut'] == true;
    final startsIn = n(shift['startsInMin']).round(); // эхлэх хүртэл минут
    String hint;
    if (att != null) {
      hint = 'Ажиллаж байна · ${s(att['checkIn'])}-аас';
    } else if (startsIn > 0) {
      hint = startsIn >= 60 ? '${startsIn ~/ 60} цаг ${startsIn % 60} мин дараа' : '$startsIn мин дараа эхэлнэ';
    } else {
      hint = 'Ээлж эхэлсэн';
    }
    // Record: (гарчиг, утга) — хүлээлгэх ажилтан байвал түүнийг, үгүй бол үргэлжлэх хугацааг
    final third = s(shift['handover']).isNotEmpty ? ('Хүлээлгэх', s(shift['handover'])) : ('Үргэлжлэх', '12 цаг');
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: C.navy800, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          // Ээлжийн төрлийн "pill" (тунгалаг цагаан дэвсгэр)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(999)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(isNight ? Icons.nightlight_round : Icons.wb_sunny_outlined, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text('${dateLabel(s(shift['date']))} · ${isNight ? 'Шөнийн' : 'Өдрийн'} ээлж',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
            ]),
          ),
          const Spacer(),
          Flexible(child: Text(hint, textAlign: TextAlign.right, style: const TextStyle(color: C.invMuted, fontSize: 11))),
        ]),
        const SizedBox(height: 12),
        Text(s(post['name']), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        if (s(post['address']).isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(children: [
              const Icon(Icons.place_outlined, size: 14, color: C.invMuted),
              const SizedBox(width: 4),
              Expanded(child: Text(s(post['address']), style: const TextStyle(color: C.invMuted, fontSize: 13))),
            ]),
          ),
        const SizedBox(height: 12),
        // Цагийн 3 багана — MainAxisAlignment.spaceBetween: зүүн, төв, баруун ирмэгт тараана
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _timeCol('Эхлэх', s(shift['start'])),
            _timeCol('Дуусах', s(shift['end'])),
            _timeCol(third.$1, third.$2), // record-ийн 1, 2-р утга
          ]),
        ),
        const SizedBox(height: 12),
        // Ирц бүртгэсэн бол "Явсан цаг", үгүй бол "Ирц бүртгэх"
        if (canOut)
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: C.text),
            onPressed: () => _open(CheckInScreen(shift: shift, checkOut: true)),
            icon: const Icon(Icons.logout),
            label: const Text('Явсан цаг бүртгэх'),
          )
        else
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: C.success, disabledBackgroundColor: Colors.white.withValues(alpha: 0.12)),
            onPressed: canIn ? () => _open(CheckInScreen(shift: shift)) : null,
            icon: const Icon(Icons.face_retouching_natural),
            label: Text(canIn ? 'Ирц бүртгэх' : 'Ээлж эхлэхээс 2 цагийн өмнө нээгдэнэ'),
          ),
      ]),
    );
  }

  /// Шошго + том цаг (Эхлэх 08:00).
  Widget _timeCol(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: C.invMuted, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ]);

  /// Сарын тоймын карт (Figma: Stat Card компонент).
  Widget _stat(IconData icon, String value, String label, Color bg, Color fg) => AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IconChip(icon, bg: bg, fg: fg, size: 32, radius: 10),
          const SizedBox(height: 10),
          FittedBox(child: Text(value, style: h2)),
          const SizedBox(height: 2),
          Text(label, style: small, maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      );

  /// Үйлчилгээний хавтан (Figma: Quick Tile компонент) — дарахад onTap.
  Widget _tile(IconData icon, String title, String sub, Color bg, Color fg, VoidCallback onTap) => AppCard(
        padding: const EdgeInsets.all(12),
        onTap: onTap,
        child: Row(children: [
          IconChip(icon, bg: bg, fg: fg, size: 40, radius: 12),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.text)),
              const SizedBox(height: 2),
              Text(sub, style: caption, maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
        ]),
      );
}
