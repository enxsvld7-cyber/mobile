// =====================================================================
// ДЭЛГЭЦ 08: SOS — ЯАРАЛТАЙ ДУУДЛАГА (sos_screen.dart) — нэмэлт шаардлага №5
// ---------------------------------------------------------------------
// Том улаан товчийг 3 секунд дарж байхад SOS дохио байршилтай хамт илгээгдэнэ
// (санамсаргүй дарагдахаас сэргийлнэ). Хяналтын төв / ахлах руу болон 102, 101,
// 103 руу шууд залгах товчтой.
//
// ДЭЛГЭЦИЙН ЗОХИОМЖ (Figma: 08 · SOS):
//   Scaffold (navy900 дэвсгэр)
//   ├─ AppBar(dark) "Яаралтай дуудлага"
//   └─ ListView
//      ├─ "Тусламж хэрэгтэй юу?" + тайлбар
//      ├─ GestureDetector → AnimatedBuilder → Stack
//      │     ├─ 2 × тунгалаг улаан тойрог (гэрэлтэлт)
//      │     ├─ CircularProgressIndicator(value: 0→1)   ← 3 сек дарах явц
//      │     └─ улаан тойрог: "SOS" + "3 сек дарна уу"
//      ├─ байршлын "pill"
//      └─ Container: ListTile(Хяналтын төв, утас) + Row[ 3 × 102/101/103 ]
//
// АШИГЛАСАН WIDGET-ИЙН СУДАЛГАА:
//   • AnimationController — 0.0→1.0 утгыг заасан хугацаанд (3 сек) өөрчилнө.
//     forward() / reverse() / reset(). vsync-д SingleTickerProviderStateMixin.
//   • AnimatedBuilder — controller өөрчлөгдөх бүрт зөвхөн доорх хэсгийг зурна.
//   • GestureDetector — onTapDown (дарж эхлэх), onTapUp (тавих), onTapCancel.
//   • addStatusListener — анимаци дуусахад (completed) SOS илгээнэ.
//   • ListTile — leading (зүүн дүрс), title, subtitle, trailing (баруун товч)
//     бүхий стандарт мөр.
//   • url_launcher: launchUrl(Uri(scheme: 'tel')) — утасны залгах апп нээнэ.
// =====================================================================
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sahiul_app/data/api.dart';
import 'package:sahiul_app/data/location.dart';
import 'package:sahiul_app/core/theme.dart';
import 'package:sahiul_app/core/widgets.dart';

/// SOS яаралтай дуудлага (нэмэлт шаардлага №5). Товчийг 3 секунд дарж байж илгээнэ.
class SosScreen extends StatefulWidget {
  const SosScreen({super.key});
  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> with SingleTickerProviderStateMixin {
  // 3 секундын «дарж байх» анимаци; дуусахад _onHold → _send()
  late final AnimationController _hold =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))..addStatusListener(_onHold);
  LocResult? _loc;
  Json? _me;
  bool _sending = false;
  String? _sentAt;

  @override
  void initState() {
    super.initState();
    getLocation().then((r) {
      if (mounted) setState(() => _loc = r);
    });
    Api.instance.me().then((m) {
      if (mounted) setState(() => _me = m);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _hold.dispose();
    super.dispose();
  }

  /// Анимаци бүрэн дуусвал (3 сек дарсан) SOS илгээнэ.
  void _onHold(AnimationStatus st) {
    if (st == AnimationStatus.completed) _send();
  }

  /// SOS дохиог байршилтай илгээнэ.
  Future<void> _send() async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      final r = await Api.instance.sos(lat: _loc?.lat, lng: _loc?.lng);
      final now = DateTime.now();
      if (!mounted) return;
      setState(() => _sentAt = '${two(now.hour)}:${two(now.minute)}');
      showMsg(context, s(r['message']));
    } on ApiException catch (e) {
      if (mounted) showMsg(context, e.message, error: true);
    } finally {
      if (mounted) {
        _hold.reset();
        setState(() => _sending = false);
      }
    }
  }

  /// Утасны дугаар руу залгах (tel:102). Боломжгүй бол дугаарыг харуулна.
  Future<void> _call(String number) async {
    final ok = await launchUrl(Uri(scheme: 'tel', path: number.replaceAll(RegExp(r'[^0-9+]'), '')));
    if (!ok && mounted) showMsg(context, '$number дугаар руу залгана уу');
  }

  @override
  Widget build(BuildContext context) {
    final contacts = obj(_me?['contacts']);
    final sup = obj(contacts['supervisor']);
    final emergency = list(contacts['emergency']);
    final em = emergency.isEmpty
        ? <Json>[
            {'name': 'Цагдаа', 'number': '102'},
            {'name': 'Гал команд', 'number': '101'},
            {'name': 'Түргэн тусламж', 'number': '103'},
          ]
        : emergency;
    final post = obj(_me?['post']);
    final loc = _loc;
    return Scaffold(
      backgroundColor: C.navy900,
      appBar: plainAppBar('Яаралтай дуудлага', dark: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const Text('Тусламж хэрэгтэй юу?',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text(
            'SOS товчийг 3 секунд дарж байхад таны байршил ахлах ажилтан болон хяналтын төвд шууд илгээгдэнэ.',
            textAlign: TextAlign.center,
            style: TextStyle(color: C.invMuted, fontSize: 15, height: 1.45),
          ),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTapDown: (_) => _hold.forward(), // дарж эхэлмэгц явц эхэлнэ
              onTapUp: (_) {
                // эрт тавьвал явц буцна (илгээхгүй)
                if (_hold.status != AnimationStatus.completed) _hold.reverse();
              },
              onTapCancel: () {
                if (_hold.status != AnimationStatus.completed) _hold.reverse();
              },
              child: AnimatedBuilder(
                animation: _hold,
                builder: (context, _) => SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(alignment: Alignment.center, children: [
                    Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: C.danger.withValues(alpha: 0.10))),
                    Container(
                        width: 196,
                        height: 196,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: C.danger.withValues(alpha: 0.18))),
                    SizedBox(
                      width: 168,
                      height: 168,
                      child: CircularProgressIndicator(
                          value: _hold.value, strokeWidth: 6, color: Colors.white, backgroundColor: Colors.transparent),
                    ),
                    Container(
                      width: 152,
                      height: 152,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: C.danger),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        _sending
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('SOS', style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(_sentAt != null ? 'Илгээсэн · $_sentAt' : '3 сек дарна уу',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11)),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.place_outlined, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    loc == null
                        ? 'Байршил тодорхойлж байна…'
                        : loc.ok
                            ? '${s(post['name']).isEmpty ? 'Байршил' : s(post['name'])} · ±${(loc.accuracy ?? 0).round()} м'
                            : (loc.error ?? 'Байршилгүй'),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              ListTile(
                leading: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.1), child: const Icon(Icons.shield_outlined, color: Colors.white)),
                title: const Text('Хяналтын төв / ахлах', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                subtitle: Text('${s(sup['name']).isEmpty ? 'Ахлах ажилтан' : s(sup['name'])} · ${s(sup['phone'])}',
                    style: const TextStyle(color: C.invMuted)),
                trailing: IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: C.success),
                  onPressed: s(sup['phone']).isEmpty ? null : () => _call(s(sup['phone'])),
                  icon: const Icon(Icons.call, color: Colors.white),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: em
                    .map((e) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Material(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => _call(s(e['number'])),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Column(children: [
                                    Text(s(e['number']),
                                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text(s(e['name']),
                                        style: const TextStyle(color: C.invMuted, fontSize: 11), overflow: TextOverflow.ellipsis),
                                  ]),
                                ),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          const Text('Хуурамч дуудлага хийхгүй байхыг анхаарна уу.', textAlign: TextAlign.center, style: TextStyle(color: C.invMuted, fontSize: 11)),
        ],
      ),
    );
  }
}
