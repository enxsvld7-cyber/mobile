// =====================================================================
// ДЭЛГЭЦ 06: ЭЭЛЖИЙН ХУВААРЬ (shifts_screen.dart) — нэмэлт шаардлага №3
// ---------------------------------------------------------------------
// Ойрын 7 хоногийн ээлж (өдөр ☀ / шөнө ☾ / амралт ●), сонгосон өдрийн
// дэлгэрэнгүй (пост, хаяг, хамт гарах, ээлж хүлээлгэх ажилтан), чөлөө хүсэх,
// ээлж солих хүсэлт, дараагийн ээлжүүдийн жагсаалт.
//
// ДЭЛГЭЦИЙН ЗОХИОМЖ (Figma: 06 · Ээлжийн хуваарь):
//   AsyncView → RefreshIndicator → ListView
//   ├─ "Ээлжийн хуваарь" гарчиг
//   ├─ Row[ 7 × Expanded(InkWell(Container)) ]   ← 7 хоногийн өдрийн "pill" (сонгосон = цэнхэр)
//   ├─ Wrap[ _Legend × 3 ]                       ← ☀ Өдөр · ☾ Шөнө · ● Амралт
//   ├─ _detail(сонгосон ээлж) эсвэл "амралтын өдөр" карт
//   │    Wrap[Badge2…] · гарчиг · _info() мөрүүд · Row[ OutlinedButton(Ээлж солих) · FilledButton(Чөлөө хүсэх) ]
//   └─ SectionTitle "Дараагийн ээлжүүд" + AppCard × 4
//
// АШИГЛАСАН WIDGET-ИЙН СУДАЛГАА:
//   • List.generate(7, …) — 7 өдрийн DateTime жагсаалт үүсгэнэ.
//   • Map<String, Json> byDate — огноогоор ээлжийг хурдан олох "толь".
//   • showDialog + AlertDialog — шалтгаан бичүүлэх цонх; Navigator.pop(ctx, true)
//     нь "Илгээх" дарсныг буцаана.
//   • OutlinedButton / FilledButton — хоёрдогч / үндсэн үйлдлийн товч.
//   • late String _selected — initState-д утга оноогдох хувьсагч.
//   • Хувийн (private) StatelessWidget `_Legend` — зөвхөн энэ файлд ашиглана.
// =====================================================================
import 'package:flutter/material.dart';

import 'package:sahiul_app/data/api.dart';
import 'package:sahiul_app/core/theme.dart';
import 'package:sahiul_app/core/widgets.dart';

/// Ээлжийн хуваарь (нэмэлт шаардлага №3).
class ShiftsScreen extends StatefulWidget {
  const ShiftsScreen({super.key});
  @override
  State<ShiftsScreen> createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends State<ShiftsScreen> {
  Future<Json>? _future;
  late String _selected; // сонгосон өдөр 'YYYY-MM-DD' (анхдагч — өнөөдөр)

  @override
  void initState() {
    super.initState();
    final t = DateTime.now();
    _selected = '${t.year}-${two(t.month)}-${two(t.day)}';
    _load();
  }

  void _load() => setState(() => _future = Api.instance.shifts(days: 14));

  /// Чөлөө ('leave') эсвэл ээлж солих ('swap') хүсэлт: шалтгаан асуугаад илгээнэ.
  Future<void> _request(Json shift, String kind) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(kind == 'leave' ? 'Чөлөө хүсэх' : 'Ээлж солих хүсэлт'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${dateLabel(s(shift['date']))} · ${s(shift['start'])}–${s(shift['end'])}', style: small),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Шалтгаан', border: OutlineInputBorder()),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Болих')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Илгээх')),
        ],
      ),
    );
    final reason = ctrl.text.trim();
    ctrl.dispose();
    if (ok != true || !mounted) return;
    try {
      final r = await Api.instance.createRequest(kind, n(shift['id']).toInt(), reason);
      if (!mounted) return;
      showMsg(context, s(r['message']));
      _load();
    } on ApiException catch (e) {
      if (mounted) showMsg(context, e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AsyncView<Json>(
      future: _future,
      onRetry: _load,
      builder: (context, data) {
        final shifts = list(data['shifts']);
        // Огноо → ээлж (нэг өдөр нэг ээлж)
        final byDate = <String, Json>{};
        for (final sh in shifts) {
          byDate.putIfAbsent(s(sh['date']), () => sh);
        }
        final today = DateTime.now();
        final days = List.generate(7, (i) => DateTime(today.year, today.month, today.day + i));
        final selectedShift = byDate[_selected];
        final upcoming = shifts.where((sh) => s(sh['date']).compareTo(_selected) > 0).take(4).toList();
        return RefreshIndicator(
          onRefresh: () async {
            _load();
            await _future;
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Text('Ээлжийн хуваарь', style: h2),
              const SizedBox(height: 12),
              // ---------- 7 хоногийн өдрийн сонголт
              Row(
                children: days.map((d) {
                  final key = '${d.year}-${two(d.month)}-${two(d.day)}';
                  final sh = byDate[key];
                  final sel = key == _selected;
                  final kind = s(sh?['kind']);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => setState(() => _selected = key),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: sel ? C.blue : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: sel ? C.blue : C.cardBorder),
                          ),
                          child: Column(children: [
                            Text(['Да', 'Мя', 'Лх', 'Пү', 'Ба', 'Бя', 'Ня'][d.weekday - 1],
                                style: TextStyle(fontSize: 11, color: sel ? Colors.white : C.text2)),
                            const SizedBox(height: 2),
                            Text('${d.day}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: sel ? Colors.white : C.text)),
                            const SizedBox(height: 4),
                            kind.isEmpty
                                ? Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(color: sel ? Colors.white : C.border, shape: BoxShape.circle))
                                : Icon(kind == 'night' ? Icons.nightlight_round : Icons.wb_sunny_outlined,
                                    size: 14, color: sel ? Colors.white : (kind == 'night' ? C.night : C.sun)),
                          ]),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              const Wrap(spacing: 14, runSpacing: 4, children: [
                _Legend(Icons.wb_sunny_outlined, C.sun, 'Өдөр 08:00–20:00'),
                _Legend(Icons.nightlight_round, C.night, 'Шөнө 20:00–08:00'),
                _Legend(Icons.circle, C.border, 'Амралт'),
              ]),
              const SizedBox(height: 16),
              if (selectedShift == null)
                AppCard(
                  child: Row(children: [
                    const IconChip(Icons.weekend_outlined, bg: C.canvas, fg: C.text2),
                    const SizedBox(width: 12),
                    Expanded(child: Text('${dateLabel(_selected)} — амралтын өдөр', style: h3)),
                  ]),
                )
              else
                _detail(selectedShift),
              if (upcoming.isNotEmpty) ...[
                const SizedBox(height: 20),
                const SectionTitle('Дараагийн ээлжүүд'),
                ...upcoming.map((sh) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        onTap: () => setState(() => _selected = s(sh['date'])),
                        child: Row(children: [
                          sh['kind'] == 'night'
                              ? const IconChip(Icons.nightlight_round, bg: C.nightBg, fg: C.night, size: 44, radius: 12)
                              : const IconChip(Icons.wb_sunny_outlined, bg: C.warningBg, fg: C.sun, size: 44, radius: 12),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('${dateLabel(s(sh['date']))} · ${sh['kind'] == 'night' ? 'Шөнийн' : 'Өдрийн'} ээлж',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: C.text)),
                              Text('${s(sh['start'])} – ${s(sh['end'])} · ${s(obj(sh['post'])['name'])}',
                                  style: small, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ]),
                          ),
                          const Icon(Icons.chevron_right, color: C.text2),
                        ]),
                      ),
                    )),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Сонгосон ээлжийн дэлгэрэнгүй карт. Ирээдүйн ээлж бол хүсэлтийн товчнууд гарна.
  Widget _detail(Json sh) {
    final night = sh['kind'] == 'night';
    final post = obj(sh['post']);
    final partners = (sh['partners'] is List) ? (sh['partners'] as List).map((e) => '$e').toList() : <String>[];
    final reqs = list(sh['requests']);
    final future = DateTime.tryParse(s(sh['startAt']))?.isAfter(DateTime.now()) ?? false;
    final hasPending = reqs.any((r) => r['status'] == 'pending'); // хүлээгдэж буй хүсэлт байвал дахин илгээхгүй
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Wrap(spacing: 8, runSpacing: 6, children: [
          Badge2('${dateLabel(s(sh['date']))} · ${s(sh['weekday'])}', Tone.info),
          if (sh['attendance'] != null) const Badge2('Ирц бүртгэсэн', Tone.success),
          ...reqs.map((r) {
            final (label, tone) = requestStatus(s(r['status']));
            return Badge2('${r['kind'] == 'leave' ? 'Чөлөө' : 'Солих'}: $label', tone);
          }),
        ]),
        const SizedBox(height: 12),
        Text('${night ? 'Шөнийн' : 'Өдрийн'} ээлж · ${s(sh['start'])} – ${s(sh['end'])}', style: h2),
        const SizedBox(height: 12),
        _info(Icons.place_outlined, s(post['name'])),
        if (s(post['address']).isNotEmpty) _info(Icons.map_outlined, s(post['address'])),
        if (partners.isNotEmpty) _info(Icons.groups_outlined, 'Хамт: ${partners.join(', ')}'),
        if (s(sh['handover']).isNotEmpty) _info(Icons.swap_horiz, 'Ээлж хүлээлгэх: ${s(sh['handover'])}'),
        if (future && !hasPending) ...[
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _request(sh, 'swap'),
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Ээлж солих'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: C.blue50, foregroundColor: C.blue),
                onPressed: () => _request(sh, 'leave'),
                icon: const Icon(Icons.event_busy),
                label: const Text('Чөлөө хүсэх'),
              ),
            ),
          ]),
        ],
      ]),
    );
  }

  /// Дүрс + текст мөр (пост, хаяг, хамт гарах...).
  Widget _info(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Icon(icon, size: 18, color: C.text2),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: body)),
        ]),
      );
}

/// Тайлбарын нэг элемент: дүрс + текст.
class _Legend extends StatelessWidget {
  const _Legend(this.icon, this.color, this.text);
  final IconData icon;
  final Color color;
  final String text;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: icon == Icons.circle ? 8 : 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: caption),
      ]);
}
