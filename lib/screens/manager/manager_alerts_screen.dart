// =====================================================================
// ДЭЛГЭЦ 11: ДУУДЛАГА БА ЗӨРЧИЛ (manager_alerts_screen.dart) — шаардлага №4, №5
// ---------------------------------------------------------------------
// Харуулуудын илгээсэн SOS дуудлага (идэвхтэй нь улаан, дээр) болон зөрчлийн
// мэдээллийг менежер харж, "Хаах" / "Шийдвэрлэсэн" гэж тэмдэглэнэ.
//
// ДЭЛГЭЦИЙН ЗОХИОМЖ:
//   AsyncView → RefreshIndicator → ListView
//   ├─ SectionTitle "SOS дуудлага" + AppCard × N   Row[ IconChip · нэр/цаг/байршил · товч ]
//   └─ SectionTitle "Зөрчлийн мэдээлэл" + AppCard × N
//        Column[ Row(төрөл · Badge2 яаралтай) · тайлбар · хэн/хаана/хэзээ · TextButton ]
//
// АШИГЛАСАН WIDGET-ИЙН СУДАЛГАА:
//   • TextButton / TextButton.icon — хүрээгүй, хөнгөн үйлдлийн товч.
//   • Align(centerRight) — товчийг баруун тийш шахна.
//   • Future<Json> Function() параметр (_act) — давтагдах try/catch кодыг нэгтгэнэ.
// =====================================================================
import 'package:flutter/material.dart';

import 'package:sahiul_app/data/api.dart';
import 'package:sahiul_app/core/theme.dart';
import 'package:sahiul_app/core/widgets.dart';

/// SOS дуудлага, зөрчлийн мэдээллүүд (менежер).
class ManagerAlertsScreen extends StatefulWidget {
  const ManagerAlertsScreen({super.key});
  @override
  State<ManagerAlertsScreen> createState() => _ManagerAlertsScreenState();
}

class _ManagerAlertsScreenState extends State<ManagerAlertsScreen> {
  Future<Json>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() => _future = Api.instance.managerAlerts());

  /// Үйлдэл гүйцэтгээд мессеж харуулж, жагсаалтыг шинэчилнэ.
  Future<void> _act(Future<Json> Function() fn) async {
    try {
      final r = await fn();
      if (mounted) showMsg(context, s(r['message']));
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
        final sos = list(data['sos']);
        final incs = list(data['incidents']);
        return RefreshIndicator(
          onRefresh: () async {
            _load();
            await _future;
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Text('Дуудлага ба зөрчил', style: h2),
              const SizedBox(height: 14),
              const SectionTitle('SOS дуудлага'),
              if (sos.isEmpty) const AppCard(child: Text('SOS дуудлага алга', style: small)),
              ...sos.map((a) {
                final active = a['status'] == 'active'; // идэвхтэй SOS → улаан карт
                final hasLoc = a['lat'] != null;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    color: active ? C.dangerBg : Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      IconChip(Icons.emergency_share, bg: active ? C.danger : C.canvas, fg: active ? Colors.white : C.text2),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${s(a['user'])} · ${s(a['post'])}', style: h3),
                          Text(
                            '${s(a['date'])} ${s(a['time'])}${hasLoc ? ' · ${n(a['lat']).toStringAsFixed(4)}, ${n(a['lng']).toStringAsFixed(4)}' : ''}',
                            style: small,
                          ),
                        ]),
                      ),
                      active
                          ? FilledButton(
                              style: FilledButton.styleFrom(minimumSize: const Size(0, 40), backgroundColor: C.danger),
                              onPressed: () => _act(() => Api.instance.resolveSos(n(a['id']).toInt())),
                              child: const Text('Хаах'),
                            )
                          : const Badge2('Хаагдсан', Tone.neutral),
                    ]),
                  ),
                );
              }),
              const SizedBox(height: 16),
              const SectionTitle('Зөрчлийн мэдээлэл'),
              if (incs.isEmpty) const AppCard(child: Text('Мэдээлэл алга', style: small)),
              ...incs.map((i) {
                final (label, tone) = urgencyLabel(s(i['urgency']));
                final open = i['status'] == 'open';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(s(i['kind']), style: h3)),
                        Badge2(label, tone),
                      ]),
                      const SizedBox(height: 4),
                      Text(s(i['description']), style: body),
                      const SizedBox(height: 6),
                      Text('${s(i['user'])} · ${s(i['post'])} · ${s(i['date'])} ${s(i['time'])}', style: caption),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: open
                            ? TextButton.icon(
                                onPressed: () => _act(() => Api.instance.setIncidentStatus(n(i['id']).toInt(), 'resolved')),
                                icon: const Icon(Icons.check),
                                label: const Text('Шийдвэрлэсэн'),
                              )
                            : TextButton(
                                onPressed: () => _act(() => Api.instance.setIncidentStatus(n(i['id']).toInt(), 'open')),
                                child: const Text('Дахин нээх'),
                              ),
                      ),
                    ]),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
