// =====================================================================
// main.dart — АППЫН ЭХЛЭЛ
// ---------------------------------------------------------------------
// Апп ажиллахад хамгийн түрүүнд main() функц дуудагдана. Энд:
//   1) runApp() — widget модны үндсийг (SahiulApp) дэлгэцэнд зурна.
//   2) MaterialApp — Material Design загвар, theme, навигацийг тохируулна.
//   3) Нэвтэрсэн эсэхээс хамаарч эхний дэлгэцийг сонгоно:
//        нэвтрээгүй → LoginScreen
//        харуул     → GuardShell (доод цэстэй 5 таб)
//        менежер    → ManagerShell (доод цэстэй 4 таб)
//
// WIDGET МОД (зохиомж):
//   SahiulApp (StatefulWidget)
//   └─ MaterialApp
//      └─ ValueListenableBuilder<int>   ← нэвтрэх/гарах бүрт дахин зурна
//         └─ LoginScreen | GuardShell | ManagerShell
//
// АШИГЛАСАН WIDGET-ИЙН СУДАЛГАА:
//   • StatelessWidget — дотроо өөрчлөгдөх төлөвгүй widget. build() нь зөвхөн
//     гаднаас ирсэн өгөгдлөөр UI зурна.
//   • StatefulWidget — өөрийн төлөвтэй (State) widget. setState() дуудахад
//     build() дахин ажиллаж дэлгэц шинэчлэгдэнэ. initState/dispose амьдралын
//     мөчлөгтэй.
//   • MaterialApp — аппын үндсэн бүрхүүл: theme, title, Navigator (дэлгэц
//     хооронд шилжих стек), SnackBar-ийн ScaffoldMessenger-ийг агуулна.
//   • ValueListenableBuilder — ValueNotifier-ийн утга өөрчлөгдөхийг "сонсож",
//     зөвхөн өөрийн доорх хэсгийг дахин зурна (setState-ээс хэмнэлттэй).
//   • GlobalKey<NavigatorState> — Navigator-т widget модны гаднаас хандах түлхүүр.
//   • MaterialApp.builder + MediaQuery — вэб хөтөч (компьютер) дээр өргөн дэлгэцэнд
//     аппыг утасны хэмжээтэй (430px) "хүрээ" дотор голлуулж харуулна.
// =====================================================================
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:sahiul_app/data/api.dart';
import 'package:sahiul_app/screens/guard/guard_shell.dart';
import 'package:sahiul_app/screens/auth/login_screen.dart';
import 'package:sahiul_app/screens/manager/manager_shell.dart';
import 'package:sahiul_app/core/theme.dart';

/// Navigator-т хаанаас ч хандах түлхүүр (гарах үед нээлттэй дэлгэцүүдийг хаахад).
final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  // Flutter engine-ийг plugin (GPS, url_launcher) ашиглахаас өмнө бэлтгэнэ.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SahiulApp()); // widget модны үндэс
}

class SahiulApp extends StatefulWidget {
  const SahiulApp({super.key});
  @override
  State<SahiulApp> createState() => _SahiulAppState();
}

class _SahiulAppState extends State<SahiulApp> {
  /// Нэвтрэх/гарах үед дуудагдана: стек дээрх бүх дэлгэцийг хааж эхний дэлгэц рүү буцна.
  void _onSession() => navigatorKey.currentState?.popUntil((route) => route.isFirst);

  @override
  void initState() {
    super.initState(); // State үүсэхэд нэг удаа ажиллана
    Api.instance.session.addListener(_onSession); // нэвтрэлтийн өөрчлөлтийг сонсоно
  }

  @override
  void dispose() {
    Api.instance.session.removeListener(_onSession); // санах ой алдагдахаас сэргийлнэ
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Сахиул',
      debugShowCheckedModeBanner: false, // баруун дээд "DEBUG" туузыг нууна
      theme: appTheme(), // theme.dart — өнгө, товчны загвар
      navigatorKey: navigatorKey,
      // Компьютерийн хөтөч дээр (өргөн > 600px) аппыг утас шиг голд харуулна
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        if (mq.size.width <= 600 || child == null) return child ?? const SizedBox();
        final frame = Size(430, math.min(mq.size.height - 32, 900));
        return ColoredBox(
          color: const Color(0xFFDDE3EC), // хүрээний гаднах саарал дэвсгэр
          child: Center(
            child: Container(
              width: frame.width,
              height: frame.height,
              clipBehavior: Clip.antiAlias, // хүүхдийг бөөрөнхий булангаар тайрна
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 30, offset: Offset(0, 12))],
              ),
              // Доторх дэлгэцүүд өөрсдийгөө 430px өргөн гэж "мэдэх"-ийн тулд MediaQuery-г дарж өгнө
              child: MediaQuery(data: mq.copyWith(size: frame, padding: EdgeInsets.zero, viewPadding: EdgeInsets.zero), child: child),
            ),
          ),
        );
      },
      home: ValueListenableBuilder<int>(
        valueListenable: Api.instance.session, // нэвтрэх/гарах бүрт утга нь өснө
        builder: (context, _, __) {
          final api = Api.instance;
          if (api.user == null) return const LoginScreen(); // нэвтрээгүй
          return api.isManager ? const ManagerShell() : const GuardShell(); // эрхээр нь
        },
      ),
    );
  }
}
