// =====================================================================
// ДЭЛГЭЦ 01: НЭВТРЭХ (login_screen.dart)
// ---------------------------------------------------------------------
// Ажилтан кодоо, нууц үгээ оруулж нэвтэрнэ. Эрхээс хамаарч харуулын эсвэл
// менежерийн горим руу шилжинэ (main.dart-ын ValueListenableBuilder).
//
// ДЭЛГЭЦИЙН ЗОХИОМЖ (Figma: 01 · Нэвтрэх):
//   Scaffold (бараан navy дэвсгэр)
//   └─ SafeArea                         ← статус мөр, notch-оос зай авна
//      └─ LayoutBuilder                 ← дэлгэцийн өндрийг мэдэж авна
//         └─ SingleChildScrollView      ← гар (keyboard) гарахад гүйлгэгдэнэ
//            └─ Column
//               ├─ IconChip (лого)  +  "Сахиул"  +  тайлбар     ← дээд хэсэг (hero)
//               └─ Container (цагаан, дээд булан 28 бөөрөнхий)  ← доод "sheet"
//                  └─ Column: гарчиг · TextField(код) · TextField(нууц үг)
//                             · алдааны текст · FilledButton(Нэвтрэх) · туршилтын эрх
//
// АШИГЛАСАН WIDGET-ИЙН СУДАЛГАА:
//   • TextField + TextEditingController — текст оруулах талбар; controller-оор
//     утгыг уншина (_code.text). dispose()-д заавал устгана.
//   • InputDecoration — hint, prefixIcon, suffixIcon, хүрээ (OutlineInputBorder).
//   • obscureText — нууц үгийг •••• болгоно; нүдний товчоор харуулах/нуух.
//   • LayoutBuilder + ConstrainedBox(minHeight) — агуулга бага үед ч доод
//     цагаан хэсэг дэлгэцийн доод хүртэл сунана.
//   • FilledButton.icon — дүрс + текстэй товч. onPressed: null бол идэвхгүй.
//   • setState — _busy, _error өөрчлөгдөхөд дэлгэцийг дахин зурна.
// =====================================================================
import 'package:flutter/material.dart';

import 'package:sahiul_app/bie_daalt/bie_daalt_screen.dart';
import 'package:sahiul_app/data/api.dart';
import 'package:sahiul_app/core/theme.dart';
import 'package:sahiul_app/core/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _code = TextEditingController(); // ажилтны кодын талбар
  final _pass = TextEditingController(); // нууц үгийн талбар
  bool _busy = false; // нэвтэрч байх үед товчийг идэвхгүй болгоно
  bool _hide = true; // нууц үгийг нуух эсэх
  String? _error; // алдааны мессеж (null бол харагдахгүй)

  @override
  void dispose() {
    _code.dispose(); // controller-уудыг санах ойгоос чөлөөлнө
    _pass.dispose();
    super.dispose();
  }

  /// "Нэвтрэх" товч: шалгаад Api.login дуудна. Амжилттай бол main.dart дэлгэцийг солино.
  Future<void> _login() async {
    if (_code.text.trim().isEmpty || _pass.text.isEmpty) {
      setState(() => _error = 'Ажилтны код, нууц үгээ оруулна уу');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await Api.instance.login(_code.text.trim(), _pass.text);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message); // mounted — дэлгэц хаагдаагүй эсэх
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Талбарын нэгдсэн загвар (Figma: Input компонент).
  InputDecoration _deco(String hint, IconData icon, {Widget? suffix}) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: C.text2, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.blue, width: 1.5)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.navy900,
      body: SafeArea(
        bottom: false, // доод цагаан хэсэг дэлгэцийн ирмэг хүртэл
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight),
              child: Column(children: [
                // ---------- Дээд хэсэг: лого, нэр, тайлбар
                const SizedBox(height: 40),
                const IconChip(Icons.verified_user_outlined, bg: C.blue, fg: Colors.white, size: 64, radius: 20),
                const SizedBox(height: 12),
                const Text('Сахиул', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text('Хамгаалалтын ажилтны ирц, ээлж,\nцалингийн мэдээллийн апп',
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: C.invMuted, height: 1.45)),
                ),
                const SizedBox(height: 32),
                // ---------- Доод цагаан "sheet": нэвтрэх маягт
                Container(
                  width: double.infinity, // өргөнөө бүтэн дүүргэнэ
                  constraints: BoxConstraints(minHeight: box.maxHeight * 0.62),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)), // зөвхөн дээд 2 булан
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420), // таблет/вэб дээр хэт өргөн болохгүй
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        const Text('Тавтай морил', style: h1),
                        const SizedBox(height: 4),
                        const Text('Ажилтны код, нууц үгээрээ нэвтэрнэ үү.', style: TextStyle(fontSize: 15, color: C.text2)),
                        const SizedBox(height: 22),
                        const Text('Ажилтны код', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.text2)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _code,
                          textCapitalization: TextCapitalization.characters, // том үсгээр бичигдэнэ
                          textInputAction: TextInputAction.next, // гарын "Next" товч
                          decoration: _deco('SH-0247', Icons.badge_outlined),
                        ),
                        const SizedBox(height: 16),
                        const Text('Нууц үг', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.text2)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _pass,
                          obscureText: _hide,
                          onSubmitted: (_) => _login(), // гарын "Done" дарахад нэвтэрнэ
                          decoration: _deco('••••', Icons.lock_outline,
                              suffix: IconButton(
                                icon: Icon(_hide ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: C.text2),
                                onPressed: () => setState(() => _hide = !_hide),
                              )),
                        ),
                        // collection-if + spread (...): алдаа байвал л 2 widget нэмнэ
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(_error!, style: const TextStyle(color: C.danger, fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _busy ? null : _login,
                          icon: _busy
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.login),
                          label: Text(_busy ? 'Нэвтэрч байна…' : 'Нэвтрэх'),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: C.canvas, borderRadius: BorderRadius.circular(12)),
                          child: const Text(
                            'Туршилтын эрх:\nХаруул — SH-0247 / 1234\nМенежер — M-001 / manager123',
                            style: TextStyle(fontSize: 12, color: C.text2, height: 1.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Бие даалтын 9 үе шат, илтгэл, A3 постер (нэвтрэхгүйгээр үзнэ)
                        TextButton.icon(
                          onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const BieDaaltScreen())),
                          icon: const Icon(Icons.school_outlined),
                          label: const Text('Бие даалтын танилцуулга'),
                        ),
                        const Text('© 2026 Сахиул · v1.0', textAlign: TextAlign.center, style: caption),
                      ]),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
