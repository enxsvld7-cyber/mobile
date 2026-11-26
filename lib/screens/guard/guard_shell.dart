// =====================================================================
// ХАРУУЛЫН ҮНДСЭН БҮРХҮҮЛ (guard_shell.dart) — доод цэстэй 5 таб
// ---------------------------------------------------------------------
// ДЭЛГЭЦИЙН ЗОХИОМЖ:
//   Scaffold
//   ├─ body: SafeArea → pages[_index]          ← сонгосон табын дэлгэц
//   └─ bottomNavigationBar: NavigationBar      ← Нүүр · Ирц · Хуваарь · Цалин · Профайл
//
// АШИГЛАСАН WIDGET-ИЙН СУДАЛГАА:
//   • Scaffold — Material дэлгэцийн "араг яс": body, appBar, bottomNavigationBar,
//     floatingActionButton зэрэг байрыг бэлдэнэ.
//   • NavigationBar (Material 3) — доод навигаци. selectedIndex = идэвхтэй таб,
//     onDestinationSelected = дарсан табын индекс.
//   • NavigationDestination — нэг таб: icon (энгийн), selectedIcon (идэвхтэй), label.
//   • SafeArea — утасны notch, статус мөрөөр агуулга далдлагдахаас хамгаална.
// Тэмдэглэл: табыг солих бүрт дэлгэц шинээр үүсч өгөгдлөө дахин ачаална
// (IndexedStack ашиглавал төлөв хадгална, гэхдээ өгөгдөл хуучирна).
// =====================================================================
import 'package:flutter/material.dart';

import 'package:sahiul_app/core/theme.dart';
import 'package:sahiul_app/screens/guard/attendance_screen.dart';
import 'package:sahiul_app/screens/guard/home_screen.dart';
import 'package:sahiul_app/screens/guard/payroll_screen.dart';
import 'package:sahiul_app/screens/common/profile_screen.dart';
import 'package:sahiul_app/screens/guard/shifts_screen.dart';

class GuardShell extends StatefulWidget {
  const GuardShell({super.key});
  @override
  State<GuardShell> createState() => _GuardShellState();
}

class _GuardShellState extends State<GuardShell> {
  int _index = 0; // идэвхтэй табын дугаар (0 = Нүүр)

  /// Таб солих. HomeScreen-д ч дамжуулна (үйлчилгээний хавтан дарахад таб солигдоно).
  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(onOpenTab: _go), // 0
      const AttendanceScreen(), // 1
      const ShiftsScreen(), // 2
      const PayrollScreen(), // 3
      const ProfileScreen(), // 4
    ];
    return Scaffold(
      body: SafeArea(bottom: false, child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _go,
        backgroundColor: Colors.white,
        indicatorColor: C.blue50, // идэвхтэй табын дүрсний ард цайвар "капсул"
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: C.blue), label: 'Нүүр'),
          NavigationDestination(icon: Icon(Icons.schedule_outlined), selectedIcon: Icon(Icons.schedule, color: C.blue), label: 'Ирц'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month, color: C.blue), label: 'Хуваарь'),
          NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet, color: C.blue),
              label: 'Цалин'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: C.blue), label: 'Профайл'),
        ],
      ),
    );
  }
}
