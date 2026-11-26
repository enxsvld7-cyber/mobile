// =====================================================================
// bie_daalt_test.dart — постер, слайд, бие даалтын дэлгэц overflow-гүй
// зурагдаж буйг шалгана (`flutter test`).
// =====================================================================
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahiul_app/bie_daalt/bie_daalt_screen.dart';
import 'package:sahiul_app/bie_daalt/content.dart';
import 'package:sahiul_app/bie_daalt/poster_screen.dart';
import 'package:sahiul_app/bie_daalt/slides_screen.dart';

Future<void> _pump(WidgetTester t, Widget w, Size size) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: w));
  await t.pumpAndSettle();
}

/// Тестийн "кубик" фонтын оронд Flutter SDK доторх жинхэнэ Roboto-г ачаална
/// → текстийн өргөн бодит төхөөрөмжтэй ойролцоо болж overflow-г зөв шалгана.
Future<void> _loadFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) return;
  final dir = '$root/bin/cache/artifacts/material_fonts';
  for (final family in ['Roboto', 'Times New Roman']) {
    final loader = FontLoader(family);
    for (final f in ['Roboto-Regular.ttf', 'Roboto-Medium.ttf', 'Roboto-Bold.ttf', 'Roboto-Italic.ttf']) {
      final file = File('$dir/$f');
      if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
    }
    await loader.load();
  }
}

void main() {
  setUpAll(_loadFonts);
  testWidgets('A3 постер зурагдана', (t) async {
    await _pump(t, const PosterScreen(), const Size(900, 1300));
    expect(find.text(appName), findsWidgets);
  });

  testWidgets('бүх слайд зурагдана', (t) async {
    await _pump(t, const SlidesScreen(), const Size(1000, 700));
    for (var i = 1; i < slides.length; i++) {
      await t.tap(find.byIcon(Icons.chevron_right));
      await t.pumpAndSettle();
      expect(find.text('${i + 1} / ${slides.length}'), findsOneWidget);
    }
  });

  testWidgets('9 үе шат бүр нээгдэнэ', (t) async {
    await _pump(t, const BieDaaltScreen(), const Size(430, 900));
    for (final st in stages) {
      await t.pumpWidget(MaterialApp(home: StageScreen(stage: st)));
      await t.pumpAndSettle();
      expect(find.text('${st.no}. ${st.title}'), findsOneWidget);
    }
  });
}
