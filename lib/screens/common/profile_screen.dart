// =====================================================================
// ДЭЛГЭЦ 09: ПРОФАЙЛ (profile_screen.dart) — харуул, менежер хоёуланд
// ---------------------------------------------------------------------
// Хэрэглэгчийн мэдээлэл, ахлах ажилтан руу залгах, миний илгээсэн хүсэлт,
// зөрчлийн мэдээллүүд, (менежерт) жишээ өгөгдлийг шинэчлэх, гарах товч.
//
// ДЭЛГЭЦИЙН ЗОХИОМЖ:
//   AsyncView<List<Json>> (3 хүсэлтийг зэрэг: me, requests, incidents)
//   └─ ListView
//      ├─ AppCard: CircleAvatar + нэр, код, эрх, пост
//      ├─ (харуул) AppCard(ListTile): ахлах ажилтан + утасны товч
//      ├─ (харуул) "Миний хүсэлтүүд" — AppCard × N + Badge2(төлөв)
//      ├─ (харуул) "Миний мэдээлсэн зөрчил" — AppCard × N
//      ├─ (менежер) OutlinedButton "Жишээ өгөгдлийг шинэчлэх"
//      └─ FilledButton "Гарах" (улаан)
//
// АШИГЛАСАН WIDGET-ИЙН СУДАЛГАА:
//   • Future.wait([...]) — хэд хэдэн Future-ийг зэрэг ажиллуулж, бүгд дуусахыг хүлээнэ.
//   • ListTile — leading/title/subtitle/trailing бүтэцтэй стандарт мөр.
//   • Iterable.take(6) — эхний 6 элементийг л харуулна.
//   • AlertDialog — баталгаажуулах асуулт ("Шинэчлэх үү?").
// =====================================================================
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sahiul_app/bie_daalt/bie_daalt_screen.dart';
import 'package:sahiul_app/data/api.dart';
import 'package:sahiul_app/core/theme.dart';
import 'package:sahiul_app/core/widgets.dart';

/// Профайл: хэрэглэгч, холбоо барих, миний хүсэлт/мэдээллүүд, гарах.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<List<Json>>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final api = Api.instance;
    setState(() {
      _future = Future.wait<Json>([
        api.me(), // хэрэглэгч, пост, холбоо барих
        api.isManager ? Future.value(<String, dynamic>{'requests': []}) : api.myRequests(),
        api.isManager ? Future.value(<String, dynamic>{'incidents': []}) : api.myIncidents(),
      ]);
    });
  }

  /// Менежер: бүх өгөгдлийг анхны жишээ төлөвт оруулаад гарна.
  Future<void> _demoReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Жишээ өгөгдлийг шинэчлэх үү?'),
        content: const Text('Бүх ирц, хүсэлт, зөрчлийн бүртгэл устаж, анхны жишээ өгөгдөл дахин үүснэ.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Болих')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Шинэчлэх')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      final r = await Api.instance.demoReset();
      if (mounted) showMsg(context, s(r['message']));
      await Api.instance.logout();
    } on ApiException catch (e) {
      if (mounted) showMsg(context, e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AsyncView<List<Json>>(
      future: _future,
      onRetry: _load,
      builder: (context, res) {
        final me = res[0];
        final user = obj(me['user']);
        final post = obj(me['post']);
        final sup = obj(obj(me['contacts'])['supervisor']);
        final reqs = list(res[1]['requests']);
        final incs = list(res[2]['incidents']);
        final manager = user['role'] == 'manager';
        return RefreshIndicator(
          onRefresh: () async {
            _load();
            await _future;
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Text('Профайл', style: h2),
              const SizedBox(height: 12),
              AppCard(
                child: Row(children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: C.blue50,
                    child: Text(initials(s(user['name'])), style: const TextStyle(color: C.blue, fontWeight: FontWeight.w700, fontSize: 18)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s(user['name']), style: h2),
                      Text('${s(user['code'])} · ${manager ? 'Менежер' : 'Харуул'}', style: small),
                      if (s(post['name']).isNotEmpty) Text(s(post['name']), style: small),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              AppCard(
                onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const BieDaaltScreen())),
                child: const Row(children: [
                  IconChip(Icons.school_outlined),
                  SizedBox(width: 12),
                  Expanded(child: Text('Бие даалт: 9 үе шат, илтгэл, A3 постер', style: h3)),
                  Icon(Icons.chevron_right, color: C.text2),
                ]),
              ),
              if (!manager) ...[
                const SizedBox(height: 12),
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: const IconChip(Icons.support_agent),
                    title: Text(s(sup['name']).isEmpty ? 'Ахлах ажилтан' : s(sup['name'])),
                    subtitle: Text('Ахлах ажилтан · ${s(sup['phone'])}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.call, color: C.success),
                      onPressed: () => launchUrl(Uri(scheme: 'tel', path: s(sup['phone']).replaceAll(RegExp(r'[^0-9+]'), ''))),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const SectionTitle('Миний хүсэлтүүд'),
                if (reqs.isEmpty) const AppCard(child: Text('Хүсэлт алга', style: small)),
                ...reqs.take(6).map((r) {
                  final (label, tone) = requestStatus(s(r['status']));
                  final sh = obj(r['shift']);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(r['kind'] == 'leave' ? 'Чөлөө хүсэлт' : 'Ээлж солих', style: h3),
                            Text('${s(sh['date'])} · ${s(sh['start'])}–${s(sh['end'])}${s(r['reason']).isEmpty ? '' : ' · ${s(r['reason'])}'}',
                                style: small, maxLines: 2, overflow: TextOverflow.ellipsis),
                          ]),
                        ),
                        Badge2(label, tone),
                      ]),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                const SectionTitle('Миний мэдээлсэн зөрчил'),
                if (incs.isEmpty) const AppCard(child: Text('Мэдээлэл алга', style: small)),
                ...incs.take(5).map((i) {
                  final (label, tone) = urgencyLabel(s(i['urgency']));
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(s(i['kind']), style: h3),
                            Text('${s(i['date'])} ${s(i['time'])} · ${i['status'] == 'resolved' ? 'Шийдвэрлэсэн' : 'Нээлттэй'}', style: small),
                          ]),
                        ),
                        Badge2(label, tone),
                      ]),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 18),
              // Өгөгдөл хаана хадгалагдаж буйг харуулах мэдээллийн мөр
              const AppCard(
                padding: EdgeInsets.all(12),
                child: Row(children: [
                  Icon(Icons.storage_outlined, color: C.text2, size: 20),
                  SizedBox(width: 10),
                  Expanded(child: Text('Өгөгдөл утсан дотор (апп хаагдахад анхны жишээ рүү буцна)', style: small)),
                ]),
              ),
              if (manager) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(onPressed: _demoReset, icon: const Icon(Icons.restart_alt), label: const Text('Жишээ өгөгдлийг шинэчлэх')),
              ],
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: C.dangerBg, foregroundColor: C.danger),
                onPressed: () => Api.instance.logout(),
                icon: const Icon(Icons.logout),
                label: const Text('Гарах'),
              ),
            ],
          ),
        );
      },
    );
  }
}
