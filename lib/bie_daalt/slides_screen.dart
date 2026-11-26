// =====================================================================
// ДЭЛГЭЦ 14: ИЛТГЭЛ / СЛАЙД (slides_screen.dart) — үе шат №8
// ---------------------------------------------------------------------
// PowerPoint-ийн оронд илтгэлийг Flutter-ээр слайд болгон үзүүлнэ.
// Шаардлага: Times New Roman, 18pt, мөр хоорондын зай 1.5, нүүр хуудас,
// агуулга, оршил, зорилго, загвар, зураг, хүснэгт, дүгнэлт, ашигласан
// материал (≥ 6), 10-аас дээш хуудас, хуудасны автомат дугаар.
//
// ДЭЛГЭЦИЙН ЗОХИОМЖ:
//   Scaffold (хар дэвсгэр)
//   ├─ AppBar: "Илтгэл"  +  3 / 12
//   ├─ body: PageView.builder              ← хуруугаар гүйлгэж слайд солих
//   │        └─ Center → AspectRatio(16:9) → FittedBox
//   │           └─ SizedBox(960×540) → _SlideView   ← нэг слайд (тогтмол хэмжээ)
//   └─ bottomNavigationBar: ◀  ●●●○○  ▶
//
// АШИГЛАСАН WIDGET-ИЙН СУДАЛГАА:
//   • PageView + PageController — хуудас хуудсаар гүйлгэх; animateToPage().
//   • AspectRatio — өргөн/өндрийн харьцааг (16:9) хадгална.
//   • FittedBox — 960×540 слайдыг ямар ч дэлгэцэнд багтаан томруулж/жижигрүүлнэ,
//     ингэснээр 18pt фонт бүх төхөөрөмж дээр слайдтай ижил харьцаатай харагдана.
//   • TextStyle(fontFamily, height: 1.5) — фонт ба мөр хоорондын зай.
// =====================================================================
import 'package:flutter/material.dart';

import 'package:sahiul_app/bie_daalt/content.dart';
import 'package:sahiul_app/core/theme.dart';

/// Слайдын фонт: Times New Roman (байхгүй төхөөрөмж дээр serif).
const _serif = 'Times New Roman';
const _fallback = ['Times', 'Liberation Serif', 'serif'];
const _bodyStyle = TextStyle(fontFamily: _serif, fontFamilyFallback: _fallback, fontSize: 18, height: 1.5, color: C.text);
const _titleStyle = TextStyle(
  fontFamily: _serif,
  fontFamilyFallback: _fallback,
  fontSize: 30,
  fontWeight: FontWeight.w700,
  color: C.navy900,
);

class SlidesScreen extends StatefulWidget {
  const SlidesScreen({super.key});
  @override
  State<SlidesScreen> createState() => _SlidesScreenState();
}

class _SlidesScreenState extends State<SlidesScreen> {
  final _ctrl = PageController();
  int _page = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _go(int i) => _ctrl.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        title: const Text('Илтгэл'),
        actions: [Center(child: Padding(padding: const EdgeInsets.only(right: 16), child: Text('${_page + 1} / ${slides.length}')))],
      ),
      body: PageView.builder(
        controller: _ctrl,
        itemCount: slides.length,
        onPageChanged: (i) => setState(() => _page = i),
        itemBuilder:
            (context, i) => Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: FittedBox(child: SizedBox(width: 960, height: 540, child: _SlideView(index: i))),
                ),
              ),
            ),
      ),
      bottomNavigationBar: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(color: Colors.white, onPressed: _page > 0 ? () => _go(_page - 1) : null, icon: const Icon(Icons.chevron_left)),
            for (var i = 0; i < slides.length; i++)
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(shape: BoxShape.circle, color: i == _page ? Colors.white : Colors.white24),
              ),
            IconButton(
              color: Colors.white,
              onPressed: _page < slides.length - 1 ? () => _go(_page + 1) : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}

/// Нэг слайд (960×540 логик хэмжээ).
class _SlideView extends StatelessWidget {
  const _SlideView({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final slide = slides[index];
    final isCover = index == 0;
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // зүүн талын өнгөт зураас
          Positioned(left: 0, top: 0, bottom: 0, child: Container(width: 14, color: C.blue)),
          Padding(padding: const EdgeInsets.fromLTRB(60, 40, 60, 50), child: isCover ? _cover(slide) : _content(slide, index)),
          // хуудасны автомат дугаар
          Positioned(right: 28, bottom: 16, child: Text('${index + 1}', style: _bodyStyle.copyWith(fontSize: 14, color: C.text2))),
        ],
      ),
    );
  }

  /// Нүүр хуудас (стандарт): аппын нэр, сэдэв, хичээл, оюутан, багш, он.
  Widget _cover(Slide s) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.verified_user, size: 64, color: C.blue),
      const SizedBox(height: 12),
      Text(s.title, style: _titleStyle.copyWith(fontSize: 44)),
      const SizedBox(height: 8),
      Text(s.bullets[0], textAlign: TextAlign.center, style: _bodyStyle.copyWith(fontSize: 22)),
      const SizedBox(height: 28),
      for (final line in s.bullets.skip(1)) Text(line, style: _bodyStyle),
    ],
  );

  Widget _content(Slide s, int i) {
    // "Цалингийн тооцоо" слайд дээр хүснэгт, "Дэлгэцүүд" дээр зураг (дүрс) харуулна
    final hasTable = s.title == 'Цалингийн тооцоо';
    final hasPicture = s.title == 'Дэлгэцүүд';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.title, style: _titleStyle),
        const SizedBox(height: 6),
        Container(height: 3, width: 80, color: C.blue),
        const SizedBox(height: 18),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final b in s.bullets) Text('•  $b', style: s.bullets.length > 8 ? _bodyStyle.copyWith(fontSize: 15) : _bodyStyle),
                  ],
                ),
              ),
              if (hasTable) ...[const SizedBox(width: 24), SizedBox(width: 300, child: _payTable())],
              if (hasPicture) ...[const SizedBox(width: 24), _phonePicture()],
            ],
          ),
        ),
        if (hasTable || hasPicture)
          Text(
            hasTable ? 'Хүснэгт 1. Цалингийн жишээ тооцоо' : 'Зураг 1. Аппын дэлгэцийн бүтэц',
            style: _bodyStyle.copyWith(fontSize: 14, fontStyle: FontStyle.italic, color: C.text2),
          ),
      ],
    );
  }

  /// Хүснэгт: 1,200,000₮ үндсэн цалинтай харуулын жишээ.
  Widget _payTable() {
    const rows = [
      ['Үзүүлэлт', 'Дүн'],
      ['Үндсэн цалин', '1,200,000₮'],
      ['Цагийн хөлс (÷168)', '7,143₮'],
      ['Илүү цаг 8ц ×1.5', '85,714₮'],
      ['Шөнийн 48ц ×0.2', '68,571₮'],
      ['НДШ 11.5%', '−155,743₮'],
    ];
    return Table(
      border: TableBorder.all(color: C.border),
      children: [
        for (var r = 0; r < rows.length; r++)
          TableRow(
            decoration: BoxDecoration(color: r == 0 ? C.blue50 : Colors.white),
            children: [
              for (final c in rows[r])
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(c, style: _bodyStyle.copyWith(fontSize: 15, fontWeight: r == 0 ? FontWeight.w700 : null)),
                ),
            ],
          ),
      ],
    );
  }

  /// "Зураг": утасны хүрээ доторх энгийн дэлгэцийн схем.
  Widget _phonePicture() => Container(
    width: 170,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: C.navy900, borderRadius: BorderRadius.circular(22)),
    child: Container(
      decoration: BoxDecoration(color: C.canvas, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Container(height: 46, decoration: BoxDecoration(color: C.navy800, borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 8),
          Container(height: 36, decoration: BoxDecoration(color: C.success, borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 8),
          for (var i = 0; i < 3; i++) ...[
            Container(height: 26, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
            const SizedBox(height: 6),
          ],
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.home, size: 16, color: C.blue),
              Icon(Icons.schedule, size: 16, color: C.text2),
              Icon(Icons.calendar_month, size: 16, color: C.text2),
              Icon(Icons.person, size: 16, color: C.text2),
            ],
          ),
        ],
      ),
    ),
  );
}
