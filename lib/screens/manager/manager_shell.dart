// =====================================================================
// МЕНЕЖЕРИЙН ҮНДСЭН БҮРХҮҮЛ (manager_shell.dart) — доод цэстэй 4 таб
// ---------------------------------------------------------------------
// ДЭЛГЭЦИЙН ЗОХИОМЖ:
//   Scaffold
//   ├─ body: SafeArea → pages[_index]
//   └─ NavigationBar: Тайлан · Дуудлага · Хүсэлт · Профайл
//
// АШИГЛАСАН WIDGET-ИЙН СУДАЛГАА:
//   • const pages — бүх дэлгэц const constructor-той тул нэг удаа үүсгэнэ.
//   • NavigationBar / NavigationDestination — guard_shell.dart-ын тайлбарыг үзнэ үү.
// =====================================================================
import 'package:flutter/material.dart';

import 'package:sahiul_app/core/theme.dart';
import 'package:sahiul_app/screens/manager/manager_alerts_screen.dart';
import 'package:sahiul_app/screens/manager/manager_report_screen.dart';
import 'package:sahiul_app/screens/manager/manager_requests_screen.dart';
import 'package:sahiul_app/screens/common/profile_screen.dart';

/// Менежерийн горим: тайлан, дуудлага, хүсэлт, профайл.
class ManagerShell extends StatefulWidget {
  const ManagerShell({super.key});
  @override
  State<ManagerShell> createState() => _ManagerShellState();
}

class _ManagerShellState extends State<ManagerShell> {
  int _index = 0; // идэвхтэй таб
  @override
  Widget build(BuildContext context) {
    const pages = <Widget>[ManagerReportScreen(), ManagerAlertsScreen(), ManagerRequestsScreen(), ProfileScreen()];
    return Scaffold(
      body: SafeArea(bottom: false, child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        indicatorColor: C.blue50,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart, color: C.blue), label: 'Тайлан'),
          NavigationDestination(
              icon: Icon(Icons.notifications_active_outlined), selectedIcon: Icon(Icons.notifications_active, color: C.blue), label: 'Дуудлага'),
          NavigationDestination(icon: Icon(Icons.inbox_outlined), selectedIcon: Icon(Icons.inbox, color: C.blue), label: 'Хүсэлт'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: C.blue), label: 'Профайл'),
        ],
      ),
    );
  }
}
