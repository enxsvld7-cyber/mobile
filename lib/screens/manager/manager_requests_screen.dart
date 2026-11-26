// =====================================================================
// ДЭЛГЭЦ 12: ХҮСЭЛТ ШИЙДВЭРЛЭХ (manager_requests_screen.dart) — шаардлага №3
// ---------------------------------------------------------------------
// Харуулуудын чөлөө / ээлж солих хүсэлтийг зөвшөөрөх эсвэл татгалзах.
// Батлагдсан чөлөө ирцийн бүртгэлд "Чөлөөтэй" гэж тусч, тасалсанд тооцогдохгүй.
//
// ДЭЛГЭЦИЙН ЗОХИОМЖ:
//   AsyncView → RefreshIndicator → ListView
//   └─ AppCard × N
//        Column[ Row(нэр · төрөл · Badge2) · ээлжийн огноо/цаг/пост · шалтгаан
//                · (хүлээгдэж буй бол) Row[ OutlinedButton Татгалзах · FilledButton Зөвшөөрөх ] ]
//
// АШИГЛАСАН WIDGET-ИЙН СУДАЛГАА:
//   • OutlinedButton.styleFrom(foregroundColor: улаан) — сөрөг үйлдлийг ялгах.
//   • Size.fromHeight(44) — өргөнөө дүүргэсэн, 44px өндөр товч.
// =====================================================================
import 'package:flutter/material.dart';

import 'package:sahiul_app/data/api.dart';
import 'package:sahiul_app/core/theme.dart';
import 'package:sahiul_app/core/widgets.dart';

/// Чөлөө, ээлж солих хүсэлтүүдийг шийдвэрлэх (менежер).
class ManagerRequestsScreen extends StatefulWidget {
  const ManagerRequestsScreen({super.key});
  @override
  State<ManagerRequestsScreen> createState() => _ManagerRequestsScreenState();
}

class _ManagerRequestsScreenState extends State<ManagerRequestsScreen> {
  Future<Json>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() => _future = Api.instance.managerRequests());

  /// 'approved' эсвэл 'rejected' төлөв оноож жагсаалтыг шинэчилнэ.
  Future<void> _decide(int id, String status) async {
    try {
      final r = await Api.instance.decideRequest(id, status);
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
        final reqs = list(data['requests']);
        return RefreshIndicator(
          onRefresh: () async {
            _load();
            await _future;
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Text('Хүсэлтүүд', style: h2),
              const SizedBox(height: 14),
              if (reqs.isEmpty) const AppCard(child: Text('Хүсэлт алга', style: small)),
              ...reqs.map((r) {
                final (label, tone) = requestStatus(s(r['status']));
                final sh = obj(r['shift']);
                final user = obj(r['user']);
                final pending = r['status'] == 'pending'; // зөвхөн хүлээгдэж буйд товч гарна
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Row(children: [
                        Expanded(
                          child: Text('${s(user['name'])} · ${r['kind'] == 'leave' ? 'Чөлөө' : 'Ээлж солих'}', style: h3),
                        ),
                        Badge2(label, tone),
                      ]),
                      const SizedBox(height: 4),
                      Text(
                        '${s(sh['date'])} (${s(sh['weekday'])}) · ${s(sh['start'])}–${s(sh['end'])} · ${s(sh['post'])}',
                        style: small,
                      ),
                      if (s(r['reason']).isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Шалтгаан: ${s(r['reason'])}', style: body),
                      ],
                      if (pending) ...[
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44), foregroundColor: C.danger),
                              onPressed: () => _decide(n(r['id']).toInt(), 'rejected'),
                              child: const Text('Татгалзах'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44), backgroundColor: C.success),
                              onPressed: () => _decide(n(r['id']).toInt(), 'approved'),
                              child: const Text('Зөвшөөрөх'),
                            ),
                          ),
                        ]),
                      ],
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
