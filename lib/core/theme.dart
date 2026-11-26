// =====================================================================
// theme.dart — ӨНГӨ, ТЕКСТ, ТОВЧНЫ ЗАГВАР (Figma дизайн системээс)
// ---------------------------------------------------------------------
// Figma дээр тодорхойлсон өнгө (variables), текстийн загвар (text styles)-ыг
// кодонд нэг газар хадгална. Өнгө өөрчлөх бол зөвхөн энд засна.
//
// АШИГЛАСАН WIDGET/КЛАССЫН СУДАЛГАА:
//   • Color(0xFFRRGGBB) — 0xFF = бүрэн тод (alpha), дараагийн 6 тэмдэгт = HEX өнгө.
//   • ThemeData — апп даяарх загвар. useMaterial3: true → Material 3 (шинэ) дизайн.
//   • ColorScheme.fromSeed — нэг үндсэн өнгөнөөс (seed) бүх туслах өнгийг үүсгэнэ.
//   • FilledButtonThemeData / OutlinedButtonThemeData — бүх товчны өндөр (52),
//     булангийн радиус (14), фонтыг нэг дор тохируулна.
//   • TextStyle — фонтын хэмжээ, жин (FontWeight), өнгө.
// =====================================================================
import 'package:flutter/material.dart';

/// Өнгөний палитр (Figma: "Сахиул / Colors").
class C {
  static const navy900 = Color(0xFF0B1B33); // нэвтрэх, SOS дэлгэцийн дэвсгэр
  static const navy800 = Color(0xFF152C52); // онцлох карт (ээлж, цалин)
  static const blue = Color(0xFF2563EB); // үндсэн өнгө (товч, идэвхтэй таб)
  static const blue50 = Color(0xFFEAF1FF); // цайвар цэнхэр дэвсгэр
  static const canvas = Color(0xFFF3F5F9); // дэлгэцийн саарал дэвсгэр
  static const border = Color(0xFFE3E8EF); // хүрээ
  static const cardBorder = Color(0xFFE8ECF2); // картын хүрээ
  static const text = Color(0xFF0F172A); // үндсэн текст
  static const text2 = Color(0xFF64748B); // туслах (бүдэг) текст
  static const invMuted = Color(0xFFA9B8D0); // бараан дэвсгэр дээрх бүдэг текст
  static const success = Color(0xFF12B76A); // амжилт, ирц бүртгэх
  static const successBg = Color(0xFFE7F8EF);
  static const warning = Color(0xFFB54708); // хоцролт
  static const warningBg = Color(0xFFFEF3E2);
  static const sun = Color(0xFFE08A00); // өдрийн ээлжийн нар
  static const danger = Color(0xFFE5383B); // SOS, тасалсан, суутгал
  static const dangerBg = Color(0xFFFDECEC);
  static const night = Color(0xFF6941C6); // шөнийн ээлж
  static const nightBg = Color(0xFFF2EDFD);
}

/// Апп даяарх Material 3 загвар.
ThemeData appTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: C.blue, primary: C.blue, surface: Colors.white);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: C.canvas, // бүх Scaffold-ийн дэвсгэр
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52), // өргөнөө дүүргэсэн, 52px өндөр
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        foregroundColor: C.text,
        side: const BorderSide(color: C.border),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

// Текстийн загварууд (Figma: Heading/H1, H2, H3, Body, Small, Caption)
const TextStyle h1 = TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: C.text, letterSpacing: -0.2);
const TextStyle h2 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: C.text);
const TextStyle h3 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: C.text);
const TextStyle body = TextStyle(fontSize: 15, color: C.text);
const TextStyle small = TextStyle(fontSize: 13, color: C.text2);
const TextStyle caption = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: C.text2);
