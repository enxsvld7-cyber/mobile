// =====================================================================
// ДЭЛГЭЦ 07: ЗӨРЧИЛ МЭДЭЭЛЭХ (incident_screen.dart) — нэмэлт шаардлага №4
// ---------------------------------------------------------------------
// Харуул постод гарсан зөрчил, осол, сэжигтэй үйлдлийг төрөл, яаралтай байдал,
// тайлбар, GPS байршилтай хамт менежер (хяналтын төв) рүү илгээнэ.
//
// ДЭЛГЭЦИЙН ЗОХИОМЖ (Figma: 07 · Зөрчил мэдээлэх):
//   Scaffold
//   ├─ AppBar "Зөрчил мэдээлэх" (‹ буцах автоматаар)
//   └─ ListView
//      ├─ _Label + Wrap[ ChoiceChip × 6 ]           ← Хулгай, Гал түймэр, ... (нэгийг сонгоно)
//      ├─ _Label + SegmentedButton(Бага|Дунд|Өндөр)
//      ├─ _Label + TextField(4 мөр, 500 тэмдэгт)
//      ├─ AppCard: байршлын төлөв (GPS координат, цаг)
//      └─ FilledButton "Мэдээлэх"
//
// АШИГЛАСАН WIDGET-ИЙН СУДАЛГАА:
//   • ChoiceChip — олон сонголтоос нэгийг сонгох "чип". selected, onSelected.
//   • Wrap — чипүүд багтахгүй бол автоматаар дараагийн мөр рүү орно.
//   • SegmentedButton<String> (Material 3) — 2–5 сонголттой хэсэгчилсэн товч.
//     selected нь Set; onSelectionChanged шинэ Set буцаана.
//   • TextField(maxLines, maxLength) — олон мөр, тэмдэгтийн тоолуур (0/500).
//   • Future.then — initState-д GPS-ийг хүлээлгүйгээр авч, ирэхээр setState.
// =====================================================================
import 'package:flutter/material.dart';

import 'package:sahiul_app/data/api.dart';
import 'package:sahiul_app/data/location.dart';
import 'package:sahiul_app/core/theme.dart';
import 'package:sahiul_app/core/widgets.dart';

/// Зөрчил, осол мэдээлэх (нэмэлт шаардлага №4).
class IncidentScreen extends StatefulWidget {
  const IncidentScreen({super.key});
  @override
  State<IncidentScreen> createState() => _IncidentScreenState();
}

class _IncidentScreenState extends State<IncidentScreen> {
  // Зөрчлийн төрлүүд (local_db.dart-ын жагсаалттай ижил байх ёстой)
  static const kinds = ['Хулгай', 'Гал түймэр', 'Зодоон', 'Сэжигтэй этгээд', 'Эвдрэл', 'Бусад'];
  String? _kind; // сонгосон төрөл (null = сонгоогүй)
  String _urgency = 'medium'; // анхдагч — Дунд
  final _desc = TextEditingController();
  LocResult? _loc;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Дэлгэц нээгдэнгүүт байршлыг арын горимд авна
    getLocation().then((r) {
      if (mounted) setState(() => _loc = r);
    });
  }

  @override
  void dispose() {
    _desc.dispose();
    super.dispose();
  }

  /// Шалгаад илгээнэ: төрөл сонгосон, тайлбар 5+ тэмдэгт байх ёстой.
  Future<void> _submit() async {
    if (_kind == null) {
      showMsg(context, 'Зөрчлийн төрлийг сонгоно уу', error: true);
      return;
    }
    if (_desc.text.trim().length < 5) {
      showMsg(context, 'Тайлбараа бичнэ үү', error: true);
      return;
    }
    setState(() => _busy = true);
    try {
      final r = await Api.instance.createIncident({
        'kind': _kind,
        'urgency': _urgency,
        'description': _desc.text.trim(),
        'lat': _loc?.lat,
        'lng': _loc?.lng,
      });
      if (!mounted) return;
      showMsg(context, s(r['message']));
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) showMsg(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final loc = _loc;
    return Scaffold(
      appBar: plainAppBar('Зөрчил мэдээлэх'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          const _Label('Зөрчлийн төрөл'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kinds
                .map((k) => ChoiceChip(
                      label: Text(k),
                      selected: _kind == k,
                      onSelected: (_) => setState(() => _kind = k),
                      selectedColor: C.blue,
                      backgroundColor: Colors.white,
                      showCheckmark: false,
                      labelStyle: TextStyle(color: _kind == k ? Colors.white : C.text, fontWeight: FontWeight.w500),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999), side: BorderSide(color: _kind == k ? C.blue : C.border)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 18),
          const _Label('Яаралтай байдал'),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'low', label: Text('Бага')),
              ButtonSegment(value: 'medium', label: Text('Дунд')),
              ButtonSegment(value: 'high', label: Text('Өндөр')),
            ],
            selected: {_urgency},
            showSelectedIcon: false,
            onSelectionChanged: (v) => setState(() => _urgency = v.first),
          ),
          const SizedBox(height: 18),
          const _Label('Тайлбар'),
          TextField(
            controller: _desc,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Юу болсныг товч бичнэ үү…',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.border)),
            ),
          ),
          const SizedBox(height: 8),
          AppCard(
            child: Row(children: [
              const IconChip(Icons.place_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    loc == null ? 'Байршил тодорхойлж байна…' : (loc.ok ? 'GPS байршил хавсаргана' : 'Байршилгүй илгээнэ'),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: C.text),
                  ),
                  Text(
                    loc?.ok == true
                        ? '${loc!.lat!.toStringAsFixed(5)}, ${loc.lng!.toStringAsFixed(5)} · ${two(now.hour)}:${two(now.minute)}'
                        : (loc?.error ?? ''),
                    style: caption,
                  ),
                ]),
              ),
              if (loc?.ok == true) const Icon(Icons.check_circle, color: C.success),
            ]),
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: _busy ? null : _submit,
            icon: _busy
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send),
            label: const Text('Мэдээлэх'),
          ),
        ],
      ),
    );
  }
}

/// Талбарын саарал гарчиг.
class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.text2)),
      );
}
