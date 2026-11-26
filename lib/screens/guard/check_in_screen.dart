// =====================================================================
// ДЭЛГЭЦ 03: ИРЦ БҮРТГЭХ / ЯВСАН ЦАГ (check_in_screen.dart) — шаардлага №1
// ---------------------------------------------------------------------
// GPS-ээр байршил авч постын бүс (геофенс, радиус 100м) дотор байгаа эсэхийг
// харуулна, одоогийн цаг, ээлжийн цаг, хоцролтыг тооцож, баталгаажуулах аргыг
// (царай / QR) сонгоод ирсэн эсвэл явсан цагаа бүртгэнэ.
//
// ДЭЛГЭЦИЙН ЗОХИОМЖ (Figma: 03 · Ирц бүртгэх):
//   Scaffold
//   ├─ AppBar: "Ирц бүртгэх" + байршил шинэчлэх товч
//   └─ ListView
//      ├─ Container(200px, цэнхэр) → Stack
//      │    ├─ CustomPaint(_GeofencePainter)   ← зам, бүсийн тойрог, пост, таны цэг
//      │    └─ Positioned: постын нэрийн шошго
//      ├─ _zoneCard()     ← "Та постын бүсэд байна · Зай 18 м" (ногоон/шар)
//      ├─ AppCard: том цаг 07:46, огноо, Row[ Эхлэх · Дуусах · Хоцролт ]
//      ├─ Row[ _methodTile(Царай) · _methodTile(QR) ]   ← сонголт
//      └─ FilledButton: "Ирсэн цаг бүртгэх"
//
// АШИГЛАСАН WIDGET-ИЙН СУДАЛГАА:
//   • Stack + Positioned / Positioned.fill — widget-үүдийг давхарлан байрлуулна
//     (газрын зураг дээр шошго).
//   • CustomPaint + CustomPainter — Canvas дээр өөрөө зурах (тойрог, тэгш өнцөгт).
//     shouldRepaint — утга өөрчлөгдсөн үед л дахин зурна.
//   • Timer.periodic — секунд тутам цагийг шинэчлэх (dispose-д зогсооно!).
//   • InkWell + Container — сонголтын хавтан (сонгосон бол цэнхэр хүрээ).
//   • Navigator.pop(context, true) — дэлгэцийг хааж, үр дүн буцаана.
//   • dart:math (sin, cos, atan2) — таны байрлалыг постоос чиглэл, зайгаар зурах.
// =====================================================================
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:sahiul_app/data/api.dart';
import 'package:sahiul_app/data/location.dart';
import 'package:sahiul_app/core/theme.dart';
import 'package:sahiul_app/core/widgets.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key, this.shift, this.checkOut = false});
  final Json? shift; // нүүр дэлгэцээс ирсэн ээлж (null байж болно)
  final bool checkOut; // true = явсан цаг бүртгэх горим
  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  LocResult? _loc; // GPS үр дүн
  bool _locating = true; // байршил хайж байгаа эсэх
  bool _busy = false; // бүртгэж байгаа эсэх
  String _method = 'face'; // сонгосон баталгаажуулах арга
  DateTime _now = DateTime.now(); // дэлгэц дээрх цаг
  Timer? _timer;

  // ---- Постын мэдээлэл (getter — дуудах бүрт тооцоолно)
  Json get _post => obj(widget.shift?['post']);
  double? get _postLat => _post['lat'] == null ? null : n(_post['lat']).toDouble();
  double? get _postLng => _post['lng'] == null ? null : n(_post['lng']).toDouble();
  double get _radius => _post['radiusM'] == null ? 100 : n(_post['radiusM']).toDouble();

  /// Таны байршлаас пост хүртэлх зай (метр). Мэдээлэл дутуу бол null.
  double? get _distance {
    final l = _loc;
    if (l == null || !l.ok || _postLat == null || _postLng == null) return null;
    return distanceMeters(l.lat!, l.lng!, _postLat!, _postLng!);
  }

  @override
  void initState() {
    super.initState();
    _locate();
    // Секунд тутам цагийг шинэчилнэ
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() {
    _timer?.cancel(); // дэлгэц хаагдахад Timer-ийг заавал зогсооно
    super.dispose();
  }

  Future<void> _locate() async {
    setState(() => _locating = true);
    final r = await getLocation();
    if (mounted) {
      setState(() {
        _loc = r;
        _locating = false;
      });
    }
  }

  /// Ирсэн/явсан цаг бүртгэх.
  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      final l = _loc;
      final res = widget.checkOut
          ? await Api.instance.checkOut(lat: l?.lat, lng: l?.lng)
          : await Api.instance.checkIn(lat: l?.lat, lng: l?.lng, method: _method);
      if (!mounted) return;
      var msg = s(res['message']);
      if (!widget.checkOut && res['inZone'] == false) msg += ' (постын бүсээс гадуур)';
      showMsg(context, msg);
      Navigator.of(context).pop(true); // нүүр дэлгэц рүү буцна → тэнд шинэчлэгдэнэ
    } on ApiException catch (e) {
      if (mounted) showMsg(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shift = widget.shift;
    final dist = _distance;
    final inZone = dist != null && dist <= _radius;
    return Scaffold(
      appBar: plainAppBar(widget.checkOut ? 'Явсан цаг бүртгэх' : 'Ирц бүртгэх', actions: [
        IconButton(tooltip: 'Байршил шинэчлэх', onPressed: _locating ? null : _locate, icon: const Icon(Icons.my_location)),
      ]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          // ---------- Геофенсийн зураглал
          Container(
            height: 200,
            decoration: BoxDecoration(color: C.blue50, borderRadius: BorderRadius.circular(20)),
            child: Stack(children: [
              Positioned.fill(
                child: CustomPaint(painter: _GeofencePainter(radius: _radius, distance: dist, bearing: _bearing())),
              ),
              Positioned(
                left: 12,
                top: 12,
                right: 12,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.shield_outlined, size: 14, color: C.blue),
                      const SizedBox(width: 6),
                      Flexible(
                          child: Text(shift == null ? 'Таны пост' : s(_post['name']),
                              overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          _zoneCard(dist, inZone),
          const SizedBox(height: 14),
          // ---------- Цагийн карт
          AppCard(
            child: Column(children: [
              const Text('Одоогийн цаг', style: caption),
              Text('${two(_now.hour)}:${two(_now.minute)}',
                  style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w700, color: C.text, letterSpacing: -1)),
              Text('${_now.year}.${two(_now.month)}.${two(_now.day)} · ${weekdaysLong[_now.weekday - 1]} гараг', style: small),
              if (shift != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: C.canvas, borderRadius: BorderRadius.circular(12)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    _col('Ээлж эхлэх', s(shift['start']), C.text),
                    _col('Ээлж дуусах', s(shift['end']), C.text),
                    _lateCol(shift),
                  ]),
                ),
              ],
            ]),
          ),
          // ---------- Баталгаажуулах арга (зөвхөн ирэх үед)
          if (!widget.checkOut) ...[
            const SizedBox(height: 16),
            const Text('Баталгаажуулах арга', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.text2)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _methodTile('face', Icons.face_retouching_natural, 'Царай таних')),
              const SizedBox(width: 10),
              Expanded(child: _methodTile('qr', Icons.qr_code_2, 'QR код')),
            ]),
            const SizedBox(height: 6),
            const Text('Сонгосон арга бүртгэлд тэмдэглэгдэнэ (царай/QR уншигчийг дараагийн хувилбарт холбоно).', style: caption),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: widget.checkOut ? C.text : C.success),
            onPressed: _busy || _locating ? null : _submit, // GPS хайж байхад идэвхгүй
            icon: _busy
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(widget.checkOut ? Icons.logout : Icons.login),
            label: Text(widget.checkOut ? 'Явсан цаг бүртгэх' : 'Ирсэн цаг бүртгэх'),
          ),
          const SizedBox(height: 8),
          const Text('Цаг, байршил ирцийн бүртгэлд хадгалагдаж цалин бодоход ашиглагдана.', textAlign: TextAlign.center, style: caption),
        ],
      ),
    );
  }

  /// Постоос таны зүг рүү чиглэл (радиан, хойд зүгээс цагийн зүүний дагуу).
  double? _bearing() {
    final l = _loc;
    if (l == null || !l.ok || _postLat == null || _postLng == null) return null;
    final dy = (l.lat! - _postLat!) * 110540; // 1° өргөрөг ≈ 110.5 км
    final dx = (l.lng! - _postLng!) * 111320 * math.cos(_postLat! * math.pi / 180); // уртраг өргөрөгөөс хамаарна
    return math.atan2(dx, dy);
  }

  /// Бүсийн төлөвийн карт: ачаалж / GPS алга / бүсэд / бүсээс гадуур.
  Widget _zoneCard(double? dist, bool inZone) {
    if (_locating) {
      return const AppCard(
        child: Row(children: [
          SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)),
          SizedBox(width: 14),
          Text('Байршлыг тодорхойлж байна…', style: body),
        ]),
      );
    }
    final l = _loc;
    final String title;
    final String sub;
    final Tone tone;
    if (l == null || !l.ok) {
      title = 'Байршил алга';
      sub = l?.error ?? 'GPS-ээ асаана уу';
      tone = Tone.warning;
    } else if (dist == null) {
      title = 'Байршил тодорхой';
      sub = 'Нарийвчлал ±${(l.accuracy ?? 0).round()} м';
      tone = Tone.info;
    } else if (inZone) {
      title = 'Та постын бүсэд байна';
      sub = 'Зай ${dist.round()} м · GPS нарийвчлал ±${(l.accuracy ?? 0).round()} м';
      tone = Tone.success;
    } else {
      title = 'Постын бүсээс гадуур байна';
      sub = 'Зай ${dist.round()} м · бүсийн радиус ${_radius.round()} м';
      tone = Tone.warning;
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: toneBg(tone), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        IconChip(tone == Tone.success ? Icons.check : Icons.location_searching, bg: toneFg(tone), fg: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: h3),
            const SizedBox(height: 2),
            Text(sub, style: small),
          ]),
        ),
      ]),
    );
  }

  Widget _col(String label, String value, Color color) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: caption),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
      ]);

  /// Хоцролтыг одоогийн цаг ба ээлж эхлэх цагийн зөрүүгээр харуулна (5 мин тэвчинэ).
  Widget _lateCol(Json shift) {
    if (widget.checkOut) return _col('Ирсэн', s(obj(shift['attendance'])['checkIn']), C.text);
    final start = DateTime.tryParse(s(shift['startAt']))?.toLocal();
    if (start == null) return _col('Хоцролт', '—', C.text2);
    final late = _now.difference(start).inMinutes;
    return late > 5 ? _col('Хоцролт', '$late мин', C.warning) : _col('Хоцролт', '0 мин', C.success);
  }

  /// Сонголтын хавтан: сонгосон бол цэнхэр дэвсгэр + хүрээ.
  Widget _methodTile(String value, IconData icon, String label) {
    final sel = _method == value;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _method = value),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: sel ? C.blue50 : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sel ? C.blue : C.border, width: sel ? 1.5 : 1),
        ),
        child: Row(children: [
          Icon(icon, color: sel ? C.blue : C.text2),
          const SizedBox(width: 10),
          Flexible(
              child: Text(label,
                  overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: sel ? C.blue : C.text))),
        ]),
      ),
    );
  }
}

/// Геофенсийн зураг: Canvas дээр зам, бүсийн тойрог, пост (улаан), таныг (цэнхэр) зурна.
/// Масштаб: бүс болон таны зай хоёулаа багтахаар автоматаар тохирно.
class _GeofencePainter extends CustomPainter {
  _GeofencePainter({required this.radius, required this.distance, required this.bearing});
  final double radius; // бүсийн радиус (м)
  final double? distance; // таны зай (м)
  final double? bearing; // чиглэл (радиан)

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2 + 10); // пост = төв
    // Зам (цагаан тэгш өнцөгтүүд)
    final road = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, c.dy + 12, size.width, 18), road);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.62, 0, 14, size.height), road);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.2, 0, 9, size.height), road);
    // Масштаб: метр → пиксел
    final maxR = math.min(size.width, size.height) / 2 - 18;
    final span = math.max(radius * 1.4, (distance ?? 0) * 1.15);
    final scale = maxR / span;
    final zoneR = radius * scale;
    // Бүсийн тойрог (тунгалаг дүүргэлт + хүрээ)
    canvas.drawCircle(c, zoneR, Paint()..color = C.blue.withValues(alpha: 0.12));
    canvas.drawCircle(
        c,
        zoneR,
        Paint()
          ..color = C.blue.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
    // Пост (улаан цэг, цагаан хүрээ)
    canvas.drawCircle(c, 7, Paint()..color = C.danger);
    canvas.drawCircle(
        c,
        7,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
    // Таны байрлал: чиглэл (sin/cos) × зай
    if (distance != null && bearing != null) {
      final d = distance! * scale;
      final p = Offset(c.dx + d * math.sin(bearing!), c.dy - d * math.cos(bearing!));
      canvas.drawCircle(p, 16, Paint()..color = C.blue.withValues(alpha: 0.22)); // гэрэлтэлт
      canvas.drawCircle(p, 8, Paint()..color = C.blue);
      canvas.drawCircle(
          p,
          8,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3);
    }
  }

  @override
  bool shouldRepaint(covariant _GeofencePainter old) => old.radius != radius || old.distance != distance || old.bearing != bearing;
}
