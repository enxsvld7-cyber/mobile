// =====================================================================
// location.dart — GPS БАЙРШИЛ АВАХ (geolocator package)
// ---------------------------------------------------------------------
// Ирц бүртгэхдээ ажилтан постын бүс (геофенс) дотор байгаа эсэхийг шалгахад
// утасны байршил хэрэгтэй (шаардлага №1).
//
// АЛХАМ:
//   1) GPS асаалттай эсэх       → Geolocator.isLocationServiceEnabled()
//   2) Зөвшөөрөл шалгах/асуух    → checkPermission() / requestPermission()
//   3) Одоогийн байршил авах      → getCurrentPosition()
// Алдаа гарвал апп унахгүй, LocResult.error-д тайлбар буцаана.
//
// Android: AndroidManifest.xml-д ACCESS_FINE_LOCATION зөвшөөрөл бичсэн.
// =====================================================================
import 'package:geolocator/geolocator.dart';

/// Байршлын үр дүн: амжилттай бол lat/lng, үгүй бол error.
class LocResult {
  const LocResult({this.lat, this.lng, this.accuracy, this.error});
  final double? lat; // өргөрөг
  final double? lng; // уртраг
  final double? accuracy; // нарийвчлал (метр)
  final String? error; // алдааны тайлбар
  bool get ok => lat != null && lng != null;
}

/// GPS байршлыг зөвшөөрөл асууж авна.
Future<LocResult> getLocation() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocResult(error: 'Утасны байршил (GPS) унтраалттай байна');
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission(); // цонх гарч асууна
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      return const LocResult(error: 'Байршлын зөвшөөрөл олгоогүй байна');
    }
    final p = await Geolocator.getCurrentPosition(
      // өндөр нарийвчлал, 20 секундээс удвал болиулна
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 20)),
    );
    return LocResult(lat: p.latitude, lng: p.longitude, accuracy: p.accuracy);
  } catch (_) {
    return const LocResult(error: 'Байршил тодорхойлж чадсангүй');
  }
}

/// Хоёр цэгийн хоорондох зай (метр).
double distanceMeters(double lat1, double lng1, double lat2, double lng2) =>
    Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
