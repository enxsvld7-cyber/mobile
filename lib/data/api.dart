// =====================================================================
// api.dart — ӨГӨГДЛИЙН ДАВХАРГА (дэлгэцүүд ба өгөгдлийн хооронд)
// ---------------------------------------------------------------------
// Дэлгэцүүд өгөгдлийг шууд биш, энэ Api классаар дамжуулж авна:
//     Дэлгэц  →  Api.instance.home()  →  LocalDb (local_db.dart)
// Ингэснээр ирээдүйд жинхэнэ сервер (REST API) холбоход зөвхөн энэ файлыг
// өөрчлөхөд хангалттай, дэлгэцүүд хэвээр үлдэнэ (separation of concerns).
//
// АШИГЛАСАН ОЙЛГОЛТ:
//   • Singleton (Api.instance) — апп даяар ганц хуулбар.
//   • Future / async / await — өгөгдөл "дараа ирэх" ажиллагаа. UI гацахгүй.
//   • ValueNotifier<int> — нэвтрэх/гарах үйл явдлыг main.dart-д мэдэгдэнэ.
//   • Exception (ApiException) — алдааны мессежийг дэлгэцэд харуулахад.
// =====================================================================
import 'package:flutter/foundation.dart';

import 'package:sahiul_app/data/local_db.dart';

/// JSON маягийн өгөгдөл: түлхүүр (String) → утга (ямар ч төрөл).
typedef Json = Map<String, dynamic>;

/// Алдаа: [message] нь хэрэглэгчид харуулах монгол текст, [status] нь код (401 г.м.).
class ApiException implements Exception {
  ApiException(this.message, [this.status = 0]);
  final String message;
  final int status;
  @override
  String toString() => message;
}

class Api {
  Api._(); // private constructor — гаднаас `Api()` гэж үүсгэхгүй
  static final Api instance = Api._(); // ганц хуулбар (singleton)

  String? token; // нэвтэрсэн хэрэглэгчийн түлхүүр
  Json? user; // нэвтэрсэн хэрэглэгчийн мэдээлэл (нэр, эрх...)

  /// Нэвтрэх/гарах бүрт утга нь нэмэгдэнэ → main.dart дахь ValueListenableBuilder дахин зурна.
  final ValueNotifier<int> session = ValueNotifier<int>(0);

  bool get isManager => user?['role'] == 'manager';

  /// Бүх хүсэлт энд ирнэ. Жинхэнэ сервер шиг бага зэрэг хүлээлгээд (250мс)
  /// LocalDb-оос хариу авна. Алдаа гарвал ApiException шиднэ.
  Future<Json> _send(String method, String path, {Json? body, Map<String, String>? query}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250)); // ачааллын индикатор харагдахын тулд
    try {
      return LocalDb.instance.handle(method, path, body, query, token);
    } on ApiException catch (e) {
      if (e.status == 401 && path != '/auth/login') await logout(); // эрх дууссан бол гаргана
      rethrow;
    }
  }

  // ---------------------------------------------------------------- нэвтрэлт
  Future<void> login(String code, String password) async {
    final data = await _send('POST', '/auth/login', body: {'code': code, 'password': password});
    token = data['token'] as String;
    user = data['user'] as Json;
    session.value++; // → эхний дэлгэц GuardShell/ManagerShell болж солигдоно
  }

  Future<void> logout() async {
    token = null;
    user = null;
    session.value++; // → LoginScreen руу буцна
  }

  // ---------------------------------------------------------------- харуулын функцууд
  Future<Json> me() => _send('GET', '/me');
  Future<Json> home() => _send('GET', '/home');
  Future<Json> checkIn({double? lat, double? lng, required String method}) =>
      _send('POST', '/attendance/check-in', body: {'lat': lat, 'lng': lng, 'method': method});
  Future<Json> checkOut({double? lat, double? lng}) => _send('POST', '/attendance/check-out', body: {'lat': lat, 'lng': lng});
  Future<Json> attendance(String month) => _send('GET', '/attendance', query: {'month': month});
  Future<Json> payroll(String month) => _send('GET', '/payroll', query: {'month': month});
  Future<Json> shifts({int days = 14}) => _send('GET', '/shifts', query: {'days': '$days'});
  Future<Json> createRequest(String kind, int shiftId, String reason) =>
      _send('POST', '/requests', body: {'kind': kind, 'shiftId': shiftId, 'reason': reason});
  Future<Json> myRequests() => _send('GET', '/requests');
  Future<Json> createIncident(Json body) => _send('POST', '/incidents', body: body);
  Future<Json> myIncidents() => _send('GET', '/incidents');
  Future<Json> sos({double? lat, double? lng}) => _send('POST', '/sos', body: {'lat': lat, 'lng': lng});

  // ---------------------------------------------------------------- менежерийн функцууд
  Future<Json> managerOverview(String month) => _send('GET', '/manager/overview', query: {'month': month});
  Future<Json> managerAlerts() => _send('GET', '/manager/alerts');
  Future<Json> resolveSos(int id) => _send('PATCH', '/manager/sos/$id');
  Future<Json> setIncidentStatus(int id, String status) => _send('PATCH', '/manager/incidents/$id', body: {'status': status});
  Future<Json> managerRequests() => _send('GET', '/manager/requests');
  Future<Json> decideRequest(int id, String status) => _send('PATCH', '/manager/requests/$id', body: {'status': status});
  Future<Json> demoReset() => _send('POST', '/manager/demo-reset');

  /// Цалингийн тайланг CSV текстээр (Excel-д paste хийх).
  String payrollCsv(String month) => LocalDb.instance.payrollCsv(month);
}
