// =====================================================================
// local_db.dart — АППЫН ДОТООД ӨГӨГДӨЛ БА ТООЦООНЫ ЛОГИК
// ---------------------------------------------------------------------
// Апп сервергүй ажиллах тул бүх өгөгдөл (пост, ажилтан, ээлж, ирц, хүсэлт,
// зөрчил, SOS) энд санах ойд (RAM) хадгалагдана. Апп хаагдахад анхны жишээ
// өгөгдөл рүү буцна.
//
// ГОЛ ЛОГИК (шаардлага №1, №2):
//   _evaluate()     — нэг ээлжийн ирцийг үнэлнэ: ажилласан, хоцорсон, илүү,
//                     шөнийн (22:00–06:00) минут, төлөв (хэвийн/хоцорсон/...)
//   _summarize()    — сарын нэгтгэл (ирсэн, хоцорсон, тасалсан, нийт цаг)
//   _calcPay()      — цалингийн задаргаа:
//                     цагийн хөлс = үндсэн цалин / 168
//                     илүү цаг   = илүү цаг × цагийн хөлс × 1.5
//                     шөнийн     = шөнийн цаг × цагийн хөлс × 0.2
//                     суутгал    = тасалсан + хоцорсон цагийн хөлс
//                     НДШ 11.5%, ХХОАТ 10% (жишээ хувь — журмаар өөрчилнө)
//   handle()        — Api-аас ирсэн хүсэлтийг ('GET /home' г.м.) боловсруулна.
//
// АШИГЛАСАН ОЙЛГОЛТ:
//   • Private класс (_Post, _User...) — зөвхөн энэ файлд харагдана.
//   • List.where / map / fold — жагсаалтыг шүүх, хувиргах, нэгтгэх.
//   • Record ({days, sum, pay}) — функцээс олон утга нэг дор буцаах (Dart 3).
//   • switch (case бүр өөрийн {} блоктой) — хүсэлтийн замаар салаалах.
// =====================================================================
import 'dart:math' as math;

import 'package:sahiul_app/data/api.dart' show ApiException, Json;

class _Post {
  _Post(this.id, this.name, this.address, this.lat, this.lng, this.radius);
  final int id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final int radius;
}

class _User {
  _User(this.id, this.code, this.name, this.role, this.password, this.baseSalary, this.postId, [this.phone]);
  final int id;
  final String code;
  final String name;
  final String role;
  final String password;
  final int baseSalary;
  final int postId;
  final String? phone;
}

class _Shift {
  _Shift(this.id, this.userId, this.postId, this.kind, this.start, this.end);
  final int id;
  final int userId;
  final int postId;
  final String kind;
  final DateTime start;
  DateTime end;
}

class _Att {
  _Att(this.id, this.userId, this.shiftId, this.inAt, this.lat, this.lng, this.dist, this.inZone, this.method, [this.outAt]);
  final int id;
  final int userId;
  final int shiftId;
  final DateTime inAt;
  final double? lat;
  final double? lng;
  final int? dist;
  final bool inZone;
  final String method;
  DateTime? outAt;
}

class _Req {
  _Req(this.id, this.userId, this.kind, this.shiftId, this.reason, this.status, this.createdAt);
  final int id;
  final int userId;
  final String kind;
  final int shiftId;
  final String reason;
  String status;
  final DateTime createdAt;
}

class _Inc {
  _Inc(this.id, this.userId, this.postId, this.kind, this.urgency, this.description, this.lat, this.lng, this.status, this.createdAt);
  final int id;
  final int userId;
  final int? postId;
  final String kind;
  final String urgency;
  final String description;
  final double? lat;
  final double? lng;
  String status;
  final DateTime createdAt;
}

class _Sos {
  _Sos(this.id, this.userId, this.lat, this.lng, this.status, this.createdAt);
  final int id;
  final int userId;
  final double? lat;
  final double? lng;
  String status;
  final DateTime createdAt;
}

/// Апп доторх "өгөгдлийн сан". LocalDb.instance-аар ганц хуулбар ашиглана.
class LocalDb {
  LocalDb._() {
    _seed();
  }
  static LocalDb? _inst;
  static LocalDb get instance => _inst ??= LocalDb._();
  static void reset() => _inst = LocalDb._();

  // Цалингийн тохиргоо (сервертэй ижил)
  static const normHours = 168;
  static const overtimeRate = 1.5;
  static const nightRate = 0.2;
  static const siRate = 0.115;
  static const pitRate = 0.1;
  static const graceMin = 5;
  static const overtimeMinMin = 15;
  static const _wdShort = ['Да', 'Мя', 'Лх', 'Пү', 'Ба', 'Бя', 'Ня'];
  static const _wdLong = ['Даваа', 'Мягмар', 'Лхагва', 'Пүрэв', 'Баасан', 'Бямба', 'Ням'];
  static const _kinds = ['Хулгай', 'Гал түймэр', 'Зодоон', 'Сэжигтэй этгээд', 'Эвдрэл', 'Бусад'];
  static const _emergency = [
    {'name': 'Цагдаа', 'number': '102'},
    {'name': 'Гал команд', 'number': '101'},
    {'name': 'Түргэн тусламж', 'number': '103'},
  ];

  final posts = <_Post>[];
  final users = <_User>[];
  final shifts = <_Shift>[];
  final atts = <_Att>[];
  final reqs = <_Req>[];
  final incs = <_Inc>[];
  final sos = <_Sos>[];
  int _seq = 1000;
  int _next() => ++_seq;

  // ------------------------------------------------------------------ жишээ өгөгдөл
  // 3 пост, 1 менежер, 5 харуул. Ээлж: 2 өдөр · 2 шөнө · 2 амралт гэсэн 6 хоногийн
  // давталт, өнөөдрөөс 45 хоногийн өмнөөс 21 хоногийн дараа хүртэл.
  // Өнгөрсөн ээлжүүдэд санамсаргүй (гэхдээ давтагдахуйц, seed=20261126) ирц үүсгэнэ:
  // ~3% тасалсан, ~10% хоцорсон, ~18% илүү цаг.
  void _seed() {
    posts.addAll([
      _Post(1, 'Номин Тауэр · Хаалга №2', 'Чингисийн өргөн чөлөө 15, СБД', 47.9139, 106.9170, 100),
      _Post(2, 'Шангри-Ла молл · Зогсоол', 'Олимпийн гудамж 19, СБД', 47.9136, 106.9234, 120),
      _Post(3, 'Их Дэлгүүр · Үүд', 'Энхтайваны өргөн чөлөө 44, СБД', 47.9175, 106.9113, 100),
    ]);
    users.add(_User(1, 'M-001', 'Г.Болд', 'manager', 'manager123', 2500000, 1, '9911-0001'));
    final guards = [
      ['SH-0247', 'Б.Тэмүүлэн', 1200000, 1, 0],
      ['SH-0248', 'Д.Анужин', 1200000, 1, 2],
      ['SH-0249', 'Г.Батбаяр', 1300000, 2, 1],
      ['SH-0250', 'С.Номин', 1200000, 3, 3],
      ['SH-0251', 'Э.Түвшин', 1250000, 2, 4],
    ];
    for (var i = 0; i < guards.length; i++) {
      final g = guards[i];
      users.add(_User(2 + i, g[0] as String, g[1] as String, 'guard', '1234', g[2] as int, g[3] as int));
    }
    const pattern = ['day', 'day', 'night', 'night', 'off', 'off'];
    final now = DateTime.now();
    final rnd = math.Random(20261126);
    for (var gi = 0; gi < guards.length; gi++) {
      final user = users[gi + 1];
      final offset = guards[gi][4] as int;
      for (var d = -45; d <= 21; d++) {
        final kind = pattern[((d + offset) % 6 + 6) % 6];
        if (kind == 'off') continue;
        final start = DateTime(now.year, now.month, now.day + d, kind == 'day' ? 8 : 20);
        final end = start.add(const Duration(hours: 12));
        final sh = _Shift(_next(), user.id, user.postId, kind, start, end);
        shifts.add(sh);
        if (end.isAfter(now) || (gi == 0 && d == 0)) continue;
        final r = rnd.nextDouble();
        if (r < 0.03) continue; // тасалсан
        if (gi == 3 && d == -9) {
          reqs.add(_Req(_next(), user.id, 'leave', sh.id, 'Гэр бүлийн шалтгаан', 'approved', start.subtract(const Duration(days: 2))));
          continue;
        }
        final lateBy = r < 0.13 ? 8 + rnd.nextInt(18) : -rnd.nextInt(10);
        final otBy = rnd.nextDouble() < 0.18 ? 30 + rnd.nextInt(70) : -3 + rnd.nextInt(10);
        final p = _post(user.postId);
        atts.add(_Att(_next(), user.id, sh.id, start.add(Duration(minutes: lateBy)), p.lat + 0.0001, p.lng + 0.0001, 14, true,
            rnd.nextDouble() < 0.7 ? 'face' : 'qr', end.add(Duration(minutes: otBy))));
      }
    }
    final future = shifts.where((s) => s.userId == 3 && s.start.isAfter(now)).skip(3);
    if (future.isNotEmpty) reqs.add(_Req(_next(), 3, 'leave', future.first.id, 'Эмнэлэгт үзүүлэх', 'pending', now));
    incs.add(_Inc(_next(), 4, 2, 'Сэжигтэй этгээд', 'medium',
        'Зогсоолын B хэсэгт 2 хүн удаан хугацаанд машинуудыг шагайж явсан. Камерын бичлэгт тэмдэглэв.', 47.9136, 106.9234, 'open',
        now.subtract(const Duration(days: 1))));
    incs.add(_Inc(_next(), 2, 1, 'Эвдрэл', 'low', 'Хойд хаалганы гэрэл асахгүй байна.', 47.9139, 106.9170, 'resolved',
        now.subtract(const Duration(days: 6))));
    sos.add(_Sos(_next(), 5, 47.9175, 106.9113, 'resolved', now.subtract(const Duration(days: 12))));
  }

  // ------------------------------------------------------------------ туслах функцууд
  // Огноо/цагийг 'YYYY-MM-DD', 'HH:MM' текст болгох, зай бодох (haversine),
  // шөнийн цагийн давхцал тоолох.
  _Post _post(int id) => posts.firstWhere((p) => p.id == id);
  _User? _userById(int id) {
    for (final u in users) {
      if (u.id == id) return u;
    }
    return null;
  }

  _Att? _attOf(int shiftId) {
    for (final a in atts) {
      if (a.shiftId == shiftId) return a;
    }
    return null;
  }

  static String _two(int v) => v.toString().padLeft(2, '0');
  static String _date(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';
  static String _time(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';
  static String _ym(DateTime d) => '${d.year}-${_two(d.month)}';
  static double _hours(int min) => (min / 60 * 10).round() / 10;

  /// Haversine томьёо — дэлхийн гадаргуу дээрх хоёр цэгийн зай (метр).
  static int _distance(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371000.0;
    double rad(double x) => x * math.pi / 180;
    final dLat = rad(lat2 - lat1);
    final dLng = rad(lng2 - lng1);
    final a = math.pow(math.sin(dLat / 2), 2) + math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.pow(math.sin(dLng / 2), 2);
    return (2 * r * math.asin(math.sqrt(a))).round();
  }

  /// [a, b) хугацаа шөнийн цонхтой (22:00–06:00) давхцах минут.
  static int _nightMinutes(DateTime a, DateTime b) {
    if (!b.isAfter(a)) return 0;
    var total = 0;
    var day = DateTime(a.year, a.month, a.day - 1);
    while (day.isBefore(b)) {
      final ws = DateTime(day.year, day.month, day.day, 22);
      final we = DateTime(day.year, day.month, day.day + 1, 6);
      final s = a.isAfter(ws) ? a : ws;
      final e = b.isBefore(we) ? b : we;
      if (e.isAfter(s)) total += e.difference(s).inMinutes;
      day = DateTime(day.year, day.month, day.day + 1);
    }
    return total;
  }

  bool _onLeave(int shiftId) => reqs.any((r) => r.shiftId == shiftId && r.kind == 'leave' && r.status == 'approved');

  /// Нэг ээлжийн ирцийг үнэлнэ (хоцролт > 5 мин, илүү цаг ≥ 15 мин бол тооцно).
  Json _evaluate(_Shift s, DateTime now) {
    final att = _attOf(s.id);
    final r = <String, dynamic>{
      'shiftId': s.id,
      'date': _date(s.start),
      'weekday': _wdShort[s.start.weekday - 1],
      'kind': s.kind,
      'post': _post(s.postId).name,
      'start': _time(s.start),
      'end': _time(s.end),
      'checkIn': att == null ? null : _time(att.inAt),
      'checkOut': att?.outAt == null ? null : _time(att!.outAt!),
      'inZone': att?.inZone,
      'method': att?.method,
      'scheduledMin': s.end.difference(s.start).inMinutes,
      'workedMin': 0,
      'lateMin': 0,
      'overtimeMin': 0,
      'nightMin': 0,
      'missingCheckout': false,
      'status': 'upcoming',
    };
    if (_onLeave(s.id)) return r..['status'] = 'leave';
    if (att == null) {
      r['status'] = !s.end.isAfter(now) ? 'absent' : (!s.start.isAfter(now) ? 'not_checked_in' : 'upcoming');
      return r;
    }
    var outAt = att.outAt;
    var active = false;
    if (outAt == null) {
      if (!s.end.isAfter(now)) {
        outAt = s.end;
        r['missingCheckout'] = true;
      } else {
        outAt = now;
        active = true;
      }
    }
    final worked = math.max(0, outAt.difference(att.inAt).inMinutes);
    final late = att.inAt.difference(s.start).inMinutes;
    final ot = outAt.difference(s.end).inMinutes;
    r['workedMin'] = worked;
    r['lateMin'] = late > graceMin ? late : 0;
    r['overtimeMin'] = ot >= overtimeMinMin ? ot : 0;
    r['nightMin'] = _nightMinutes(att.inAt, outAt);
    r['status'] = active
        ? 'active'
        : (r['lateMin'] as int) > 0
            ? 'late'
            : (r['overtimeMin'] as int) > 0
                ? 'overtime'
                : 'normal';
    return r;
  }

  /// Сарын нэгтгэл: ирсэн, хоцорсон, тасалсан, чөлөө, нийт/илүү/шөнийн минут.
  static Map<String, int> _summarize(List<Json> days) {
    final s = {'shifts': days.length, 'present': 0, 'late': 0, 'absent': 0, 'leave': 0, 'upcoming': 0,
      'workedMin': 0, 'overtimeMin': 0, 'nightMin': 0, 'lateMin': 0, 'scheduledMin': 0};
    for (final d in days) {
      final st = d['status'] as String;
      if (const ['normal', 'late', 'overtime', 'active'].contains(st)) s['present'] = s['present']! + 1;
      if ((d['lateMin'] as int) > 0) s['late'] = s['late']! + 1;
      if (st == 'absent') s['absent'] = s['absent']! + 1;
      if (st == 'leave') s['leave'] = s['leave']! + 1;
      if (st == 'upcoming' || st == 'not_checked_in') s['upcoming'] = s['upcoming']! + 1;
      for (final k in ['workedMin', 'overtimeMin', 'nightMin', 'lateMin']) {
        s[k] = s[k]! + (d[k] as int);
      }
      if (st != 'leave') s['scheduledMin'] = s['scheduledMin']! + (d['scheduledMin'] as int);
    }
    return s;
  }

  /// Цалингийн задаргаа (дээрх томьёогоор).
  static Json _calcPay(int base, Map<String, int> sum, List<Json> days) {
    final hourly = base / normHours;
    double h(int m) => m / 60;
    final absentMin = days.where((d) => d['status'] == 'absent').fold<int>(0, (a, d) => a + (d['scheduledMin'] as int));
    final overtimePay = (h(sum['overtimeMin']!) * hourly * overtimeRate).round();
    final nightPay = (h(sum['nightMin']!) * hourly * nightRate).round();
    final absenceDeduction = (h(absentMin) * hourly).round();
    final lateDeduction = (h(sum['lateMin']!) * hourly).round();
    final gross = math.max(0, base + overtimePay + nightPay - absenceDeduction - lateDeduction);
    final si = (gross * siRate).round();
    final pit = ((gross - si) * pitRate).round();
    return {
      'baseSalary': base, 'hourlyRate': hourly.round(), 'overtimePay': overtimePay, 'nightPay': nightPay,
      'absenceDeduction': absenceDeduction, 'lateDeduction': lateDeduction, 'gross': gross, 'socialInsurance': si,
      'incomeTax': pit, 'net': gross - si - pit,
      'rates': {'normHours': normHours, 'overtimeRate': overtimeRate, 'nightRate': nightRate,
        'socialInsuranceRate': siRate, 'incomeTaxRate': pitRate},
    };
  }

  /// Нэг ажилтны сарын ирц + цалин.
  ({List<Json> days, Map<String, int> sum, Json pay}) _report(_User u, String ym, DateTime now) {
    final p = ym.split('-');
    final start = DateTime(int.parse(p[0]), int.parse(p[1]), 1);
    final end = DateTime(int.parse(p[0]), int.parse(p[1]) + 1, 1);
    final list = shifts
        .where((s) => s.userId == u.id && !s.start.isBefore(start) && s.start.isBefore(end) && !s.start.isAfter(now))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    final days = list.map((s) => _evaluate(s, now)).toList();
    final sum = _summarize(days);
    return (days: days, sum: sum, pay: _calcPay(u.baseSalary, sum, days));
  }

  /// Тухайн ээлжтэй давхцаж ижил постод гарах бусад ажилтан.
  List<String> _partners(_Shift s) => shifts
      .where((o) => o.postId == s.postId && o.userId != s.userId && o.start.isBefore(s.end) && o.end.isAfter(s.start))
      .map((o) => _userById(o.userId)!.name)
      .toSet()
      .toList();

  /// Ээлж хүлээлгэж өгөх ажилтан (энэ ээлж дуусахад ±30 минутад эхлэх ээлж).
  String? _handover(_Shift s) {
    for (final o in shifts) {
      if (o.postId == s.postId && o.userId != s.userId && o.start.difference(s.end).inMinutes.abs() <= 30) {
        return _userById(o.userId)?.name;
      }
    }
    return null;
  }

  Json _shiftDto(_Shift s) {
    final p = _post(s.postId);
    final a = _attOf(s.id);
    return {
      'id': s.id, 'kind': s.kind, 'date': _date(s.start), 'weekday': _wdLong[s.start.weekday - 1],
      'weekdayShort': _wdShort[s.start.weekday - 1], 'start': _time(s.start), 'end': _time(s.end),
      'startAt': s.start.toIso8601String(), 'endAt': s.end.toIso8601String(),
      'post': {'id': p.id, 'name': p.name, 'address': p.address, 'lat': p.lat, 'lng': p.lng, 'radiusM': p.radius},
      'attendance': a == null
          ? null
          : {'id': a.id, 'checkIn': _time(a.inAt), 'checkOut': a.outAt == null ? null : _time(a.outAt!),
              'inZone': a.inZone, 'distanceM': a.dist, 'method': a.method},
    };
  }

  Json _publicUser(_User u) =>
      {'id': u.id, 'code': u.code, 'name': u.name, 'role': u.role, 'baseSalary': u.baseSalary, 'phone': u.phone, 'postId': u.postId};

  _Att? _openAtt(int userId) {
    for (final a in atts.reversed) {
      if (a.userId == userId && a.outAt == null) return a;
    }
    return null;
  }

  Json _reqDto(_Req r) {
    final u = _userById(r.userId)!;
    _Shift? s;
    for (final x in shifts) {
      if (x.id == r.shiftId) s = x;
    }
    return {
      'id': r.id, 'kind': r.kind, 'status': r.status, 'reason': r.reason, 'createdAt': r.createdAt.toIso8601String(),
      'user': {'name': u.name, 'code': u.code},
      'shift': s == null
          ? null
          : {'kind': s.kind, 'date': _date(s.start), 'weekday': _wdShort[s.start.weekday - 1], 'start': _time(s.start),
              'end': _time(s.end), 'post': _post(s.postId).name},
    };
  }

  Json _incDto(_Inc i) => {
        'id': i.id, 'kind': i.kind, 'urgency': i.urgency, 'description': i.description, 'status': i.status,
        'lat': i.lat, 'lng': i.lng, 'createdAt': i.createdAt.toIso8601String(), 'date': _date(i.createdAt),
        'time': _time(i.createdAt), 'user': _userById(i.userId)?.name, 'post': i.postId == null ? null : _post(i.postId!).name,
      };

  static double? _num(dynamic v) => v is num ? v.toDouble() : (v == null ? null : double.tryParse('$v'));

  // ------------------------------------------------------------------ хүсэлт боловсруулах
  // method + path-аар (жишээ: 'POST /attendance/check-in') салаалж, Json буцаана.
  // token-оос нэвтэрсэн хэрэглэгчийг олно ('demo-2' → id 2).
  Json handle(String method, String path, Json? body, Map<String, String>? query, String? token) {
    final now = DateTime.now();
    final b = body ?? <String, dynamic>{};
    final qm = query?['month'];
    final month = (qm != null && RegExp(r'^\d{4}-\d{2}$').hasMatch(qm)) ? qm : _ym(now);

    if (method == 'POST' && path == '/auth/login') {
      final code = '${b['code'] ?? ''}'.trim().toUpperCase();
      final pass = '${b['password'] ?? ''}';
      if (code.isEmpty || pass.isEmpty) throw ApiException('Ажилтны код, нууц үгээ оруулна уу', 400);
      _User? u;
      for (final x in users) {
        if (x.code == code && x.password == pass) u = x;
      }
      if (u == null) throw ApiException('Код эсвэл нууц үг буруу байна', 401);
      return {'token': 'demo-${u.id}', 'user': _publicUser(u)};
    }

    final uid = int.tryParse((token ?? '').replaceFirst('demo-', ''));
    final me = uid == null ? null : _userById(uid);
    if (me == null) throw ApiException('Нэвтрэх шаардлагатай', 401);
    if (path.startsWith('/manager/') && me.role != 'manager') throw ApiException('Зөвхөн менежерт зориулсан', 403);
    final seg = path.split('/');

    switch ('$method $path') {
      case 'GET /me': {
          final sup = users.firstWhere((u) => u.role == 'manager');
          final p = _post(me.postId);
          return {
            'user': _publicUser(me),
            'post': {'id': p.id, 'name': p.name, 'address': p.address, 'lat': p.lat, 'lng': p.lng, 'radius_m': p.radius},
            'contacts': {'supervisor': {'name': sup.name, 'phone': sup.phone}, 'emergency': _emergency},
            'demoMode': true,
          };

      }
      case 'GET /home': {
          _Shift? cur;
          final open = _openAtt(me.id);
          if (open != null) cur = shifts.firstWhere((s) => s.id == open.shiftId);
          if (cur == null) {
            final cand = shifts.where((s) => s.userId == me.id && _attOf(s.id) == null && s.end.isAfter(now)).toList()
              ..sort((a, b) => a.start.compareTo(b.start));
            if (cand.isNotEmpty) cur = cand.first;
          }
          Json? shift;
          if (cur != null) {
            final startsIn = cur.start.difference(now).inMinutes;
            shift = _shiftDto(cur)
              ..['partners'] = _partners(cur)
              ..['handover'] = _handover(cur)
              ..['startsInMin'] = startsIn
              ..['canCheckIn'] = open == null && startsIn <= 120
              ..['canCheckOut'] = open != null;
          }
          final rep = _report(me, _ym(now), now);
          return {
            'user': _publicUser(me), 'shift': shift, 'now': now.toIso8601String(), 'demoMode': true,
            'month': {'month': _ym(now), 'workedHours': _hours(rep.sum['workedMin']!), 'overtimeHours': _hours(rep.sum['overtimeMin']!),
              'lateCount': rep.sum['late'], 'absent': rep.sum['absent']},
          };

      }
      case 'POST /attendance/check-in': {
          if (_openAtt(me.id) != null) throw ApiException('Та ирцээ аль хэдийн бүртгэсэн байна. Эхлээд явсан цагаа бүртгэнэ үү', 409);
          final cand = shifts
              .where((s) => s.userId == me.id && _attOf(s.id) == null && s.end.isAfter(now) && !s.start.isAfter(now.add(const Duration(hours: 2))))
              .toList()
            ..sort((a, b) => a.start.compareTo(b.start));
          _Shift shift;
          if (cand.isNotEmpty) {
            shift = cand.first;
          } else {
            final start = DateTime(now.year, now.month, now.day, now.hour, now.minute - now.minute % 5);
            shift = _Shift(_next(), me.id, me.postId, now.hour >= 6 && now.hour < 18 ? 'day' : 'night', start,
                start.add(const Duration(hours: 12)));
            shifts.add(shift);
          }
          final lat = _num(b['lat']);
          final lng = _num(b['lng']);
          final p = _post(shift.postId);
          final dist = (lat != null && lng != null) ? _distance(lat, lng, p.lat, p.lng) : null;
          final inZone = dist != null && dist <= p.radius;
          final method = const ['face', 'qr', 'gps'].contains(b['method']) ? b['method'] as String : 'gps';
          atts.add(_Att(_next(), me.id, shift.id, now, lat, lng, dist, inZone, method));
          final ev = _evaluate(shift, now);
          final late = ev['lateMin'] as int;
          return {
            'message': late > 0 ? 'Ирц бүртгэгдлээ · $late мин хоцорсон' : 'Ирц бүртгэгдлээ',
            'shift': _shiftDto(shift), 'lateMin': late, 'inZone': inZone, 'distanceM': dist,
          };

      }
      case 'POST /attendance/check-out': {
          final att = _openAtt(me.id);
          if (att == null) throw ApiException('Бүртгэлтэй ирц алга. Эхлээд ирсэн цагаа бүртгэнэ үү', 400);
          att.outAt = now;
          final worked = now.difference(att.inAt).inMinutes;
          return {'message': 'Явсан цаг бүртгэгдлээ · ${_hours(worked)} цаг ажилласан', 'workedMin': worked};

      }
      case 'GET /attendance': {
          final rep = _report(me, month, now);
          final s = rep.sum;
          return {
            'month': month,
            'summary': {...s, 'workedHours': _hours(s['workedMin']!), 'overtimeHours': _hours(s['overtimeMin']!),
              'nightHours': _hours(s['nightMin']!), 'scheduledHours': _hours(s['scheduledMin']!), 'normHours': normHours},
            'days': rep.days.reversed.toList(),
          };

      }
      case 'GET /payroll': {
          final rep = _report(me, month, now);
          final s = rep.sum;
          return {
            'month': month, 'estimated': month.compareTo(_ym(now)) >= 0,
            'summary': {'shifts': s['present'], 'workedHours': _hours(s['workedMin']!), 'overtimeHours': _hours(s['overtimeMin']!),
              'nightHours': _hours(s['nightMin']!), 'lateCount': s['late'], 'lateMin': s['lateMin'], 'absent': s['absent'], 'leave': s['leave']},
            'pay': rep.pay,
          };

      }
      case 'GET /shifts': {
          final from = DateTime(now.year, now.month, now.day);
          final to = from.add(Duration(days: int.tryParse(query?['days'] ?? '') ?? 14));
          final list = shifts.where((s) => s.userId == me.id && !s.start.isBefore(from) && s.start.isBefore(to)).toList()
            ..sort((a, b) => a.start.compareTo(b.start));
          return {
            'from': _date(from),
            'shifts': list
                .map((s) => _shiftDto(s)
                  ..['partners'] = _partners(s)
                  ..['handover'] = _handover(s)
                  ..['requests'] = reqs.where((r) => r.shiftId == s.id).map((r) => {'kind': r.kind, 'status': r.status}).toList())
                .toList(),
          };

      }
      case 'POST /requests': {
          final kind = b['kind'];
          if (kind != 'leave' && kind != 'swap') throw ApiException('Хүсэлтийн төрөл буруу', 400);
          final sid = (b['shiftId'] is num) ? (b['shiftId'] as num).toInt() : -1;
          final matches = shifts.where((s) => s.id == sid && s.userId == me.id);
          if (matches.isEmpty) throw ApiException('Ээлж олдсонгүй', 400);
          if (!matches.first.start.isAfter(now)) throw ApiException('Эхэлсэн ээлжид хүсэлт гаргах боломжгүй', 400);
          if (reqs.any((r) => r.shiftId == sid && r.kind == kind && r.status == 'pending')) {
            throw ApiException('Энэ ээлжид хүсэлт аль хэдийн илгээсэн байна', 409);
          }
          reqs.add(_Req(_next(), me.id, kind as String, sid, '${b['reason'] ?? ''}'.trim(), 'pending', now));
          return {'message': kind == 'leave' ? 'Чөлөөний хүсэлт илгээгдлээ' : 'Ээлж солих хүсэлт илгээгдлээ'};

      }
      case 'GET /requests': {
          final mine = reqs.where((r) => r.userId == me.id).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return {'requests': mine.map(_reqDto).toList()};

      }
      case 'POST /incidents': {
          final kind = '${b['kind'] ?? ''}';
          final urgency = '${b['urgency'] ?? ''}';
          final desc = '${b['description'] ?? ''}'.trim();
          if (!_kinds.contains(kind)) throw ApiException('Зөрчлийн төрлийг сонгоно уу', 400);
          if (!const ['low', 'medium', 'high'].contains(urgency)) throw ApiException('Яаралтай байдлыг сонгоно уу', 400);
          if (desc.length < 5) throw ApiException('Тайлбараа бичнэ үү', 400);
          incs.add(_Inc(_next(), me.id, me.postId, kind, urgency, desc, _num(b['lat']), _num(b['lng']), 'open', now));
          return {'message': 'Зөрчлийн мэдээлэл хяналтын төвд илгээгдлээ'};

      }
      case 'GET /incidents': {
          final mine = incs.where((i) => i.userId == me.id).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return {'incidents': mine.map(_incDto).toList()};

      }
      case 'POST /sos': {
          sos.add(_Sos(_next(), me.id, _num(b['lat']), _num(b['lng']), 'active', now));
          return {'message': 'SOS дохио илгээгдлээ. Хяналтын төв таны байршлыг харж байна', 'emergency': _emergency};

      }
      case 'GET /manager/overview': {
          final guards = users.where((u) => u.role == 'guard').toList();
          final emps = guards.map((u) {
            final rep = _report(u, month, now);
            final s = rep.sum;
            return <String, dynamic>{
              'id': u.id, 'code': u.code, 'name': u.name, 'post': _post(u.postId).name, 'shifts': s['present'],
              'workedHours': _hours(s['workedMin']!), 'overtimeHours': _hours(s['overtimeMin']!), 'nightHours': _hours(s['nightMin']!),
              'lateCount': s['late'], 'absent': s['absent'], 'leave': s['leave'], 'gross': rep.pay['gross'], 'net': rep.pay['net'],
            };
          }).toList();
          final soon = now.add(const Duration(hours: 2));
          final active = shifts.where((s) => !s.start.isAfter(soon) && s.end.isAfter(now)).toList();
          return {
            'month': month,
            'totals': {
              'employees': guards.length,
              'onDutyNow': active.where((s) => _attOf(s.id) != null).length,
              'scheduledNow': active.length,
              'lateCount': emps.fold<int>(0, (a, e) => a + (e['lateCount'] as int)),
              'overtimeHours': (emps.fold<double>(0, (a, e) => a + (e['overtimeHours'] as double)) * 10).round() / 10,
              'payrollNet': emps.fold<int>(0, (a, e) => a + (e['net'] as int)),
              'openIncidents': incs.where((i) => i.status == 'open').length,
              'activeSos': sos.where((x) => x.status == 'active').length,
              'pendingRequests': reqs.where((r) => r.status == 'pending').length,
            },
            'employees': emps,
          };

      }
      case 'GET /manager/alerts': {
          final list = [...sos]..sort((a, b) {
              final byStatus = (b.status == 'active' ? 1 : 0) - (a.status == 'active' ? 1 : 0);
              return byStatus != 0 ? byStatus : b.createdAt.compareTo(a.createdAt);
            });
          final allInc = [...incs]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return {
            'sos': list.map((a) {
              final u = _userById(a.userId)!;
              return {'id': a.id, 'status': a.status, 'lat': a.lat, 'lng': a.lng, 'user': u.name, 'code': u.code,
                'post': _post(u.postId).name, 'date': _date(a.createdAt), 'time': _time(a.createdAt)};
            }).toList(),
            'incidents': allInc.map(_incDto).toList(),
          };

      }
      case 'GET /manager/requests': {
          final all = [...reqs]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return {'requests': all.map(_reqDto).toList()};

      }
      case 'POST /manager/demo-reset': {
          reset();
          return {'message': 'Жишээ өгөгдлийг дахин үүсгэлээ. Дахин нэвтэрнэ үү'};
      }
    }

    // PATCH /manager/{sos|incidents|requests}/:id
    if (method == 'PATCH' && seg.length == 4 && seg[1] == 'manager') {
      final id = int.tryParse(seg[3]) ?? -1;
      switch (seg[2]) {
        case 'sos': {
          for (final a in sos) {
            if (a.id == id) {
              a.status = 'resolved';
              return {'message': 'SOS дуудлагыг хаалаа'};
            }
          }
        }
        case 'incidents': {
          for (final i in incs) {
            if (i.id == id) {
              i.status = b['status'] == 'open' ? 'open' : 'resolved';
              return {'message': i.status == 'resolved' ? 'Шийдвэрлэсэн гэж тэмдэглэлээ' : 'Дахин нээлээ'};
            }
          }
        }
        case 'requests': {
          final st = b['status'];
          if (st != 'approved' && st != 'rejected') throw ApiException('Төлөв буруу', 400);
          for (final r in reqs) {
            if (r.id == id && r.status == 'pending') {
              r.status = st as String;
              return {'message': st == 'approved' ? 'Хүсэлтийг зөвшөөрлөө' : 'Хүсэлтийг татгалзлаа'};
            }
          }
        }
      }
      throw ApiException('Олдсонгүй', 404);
    }
    throw ApiException('Хаяг олдсонгүй', 404);
  }

  /// Менежерийн цалингийн тайлан. Баганыг TAB (\t)-аар тусгаарласан тул Excel /
  /// Google Sheets-д paste хийхэд шууд баган баганаар орно.
  String payrollCsv(String month) {
    final now = DateTime.now();
    final rows = <String>[
      ['Код', 'Нэр', 'Пост', 'Ажилласан ээлж', 'Ажилласан цаг', 'Илүү цаг', 'Шөнийн цаг', 'Хоцролт (удаа)', 'Тасалсан', 'Чөлөө',
        'Нийт цалин', 'НДШ', 'ХХОАТ', 'Гарт олгох'].join('\t'),
    ];
    for (final u in users.where((u) => u.role == 'guard')) {
      final rep = _report(u, month, now);
      final s = rep.sum;
      final p = rep.pay;
      rows.add([u.code, u.name, _post(u.postId).name, s['present'], _hours(s['workedMin']!), _hours(s['overtimeMin']!),
        _hours(s['nightMin']!), s['late'], s['absent'], s['leave'], p['gross'], p['socialInsurance'], p['incomeTax'], p['net']].join('\t'));
    }
    return rows.join('\n');
  }
}
