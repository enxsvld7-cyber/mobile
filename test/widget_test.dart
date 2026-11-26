// =====================================================================
// widget_test.dart — НЭГЖ ТЕСТ (`flutter test` командаар ажиллана)
// Туслах функцууд зөв ажиллаж буйг шалгана: мөнгөний формат, цаг, сар шилжүүлэх.
// test('нэр', () { expect(бодит, хүлээгдэж буй); })
// =====================================================================
import 'package:flutter_test/flutter_test.dart';
import 'package:sahiul_app/bie_daalt/content.dart';
import 'package:sahiul_app/core/widgets.dart';

void main() {
  test('мөнгөн дүнг форматлана', () {
    expect(money(1065275), '1,065,275₮');
    expect(money(0), '0₮');
    expect(money(-284725), '−284,725₮');
  });
  test('минутыг цаг болгоно', () {
    expect(minutesText(725), '12ц 05м');
    expect(minutesText(45), '45 мин');
  });
  test('сар шилжүүлнэ', () {
    expect(shiftMonth('2026-01', -1), '2025-12');
    expect(shiftMonth('2026-12', 1), '2027-01');
  });
  // Бие даалтын шаардлагыг кодоор шалгана (bie_daalt/content.dart)
  test('бие даалт: 9 үе шат, нийт 20 оноо', () {
    expect(stages.length, 9);
    expect(stages.fold<int>(0, (a, st) => a + st.points), 20);
  });
  test('илтгэл: 10-аас дээш слайд, 6-аас доошгүй материал', () {
    expect(slides.length, greaterThan(10));
    expect(references.length, greaterThanOrEqualTo(6));
  });
}
