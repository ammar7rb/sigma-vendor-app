import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';

/// Marketing welcome card shown to merchants whose account is under 14 days
/// old, until they dismiss it (remembered per seller on this device).
class VendorWelcomeBanner extends StatefulWidget {
  final VoidCallback? onAddProduct;
  const VendorWelcomeBanner({super.key, this.onAddProduct});

  @override
  State<VendorWelcomeBanner> createState() => _VendorWelcomeBannerState();
}

class _VendorWelcomeBannerState extends State<VendorWelcomeBanner> {
  bool _dismissed = true;
  String? _loadedFor;

  Future<void> _load(String key) async {
    _loadedFor = key;
    try {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool(key) ?? false;
      if (mounted) setState(() => _dismissed = seen);
    } catch (_) {
      if (mounted) setState(() => _dismissed = false);
    }
  }

  Future<void> _dismiss(String key) async {
    setState(() => _dismissed = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, true);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileController>().userInfoModel;
    final created = DateTime.tryParse(profile?.createdAt ?? '');
    if (profile == null ||
        created == null ||
        DateTime.now().difference(created.toLocal()).inDays >= 14) {
      return const SizedBox.shrink();
    }
    final key = 'sv_welcome_${profile.id}';
    if (_loadedFor != key) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _load(key));
    }
    if (_dismissed) return const SizedBox.shrink();
    String tr(String k) => getTranslated(k, context) ?? k;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
            colors: [Color(0xFF1A428A), Color(0xFF2F6FD6), Color(0xFF47B0E8)]),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('🎉', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text.rich(TextSpan(children: [
                  TextSpan(text: '${tr('vendor_welcome_title')} '),
                  TextSpan(
                      text: tr('vendor_welcome_badge'),
                      style: const TextStyle(
                          backgroundColor: Color(0xFFFFD24D),
                          color: Color(0xFF5A3D00))),
                ]),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(tr('vendor_welcome_text'),
                    style: const TextStyle(color: Colors.white, height: 1.6)),
              ])),
          IconButton(
              tooltip: tr('vendor_welcome_close'),
              onPressed: () => _dismiss(key),
              icon: const Icon(Icons.close, color: Colors.white)),
        ]),
        const SizedBox(height: 12),
        SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1A428A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: widget.onAddProduct,
                child: Text(tr('vendor_welcome_cta'),
                    style: const TextStyle(fontWeight: FontWeight.w800)))),
      ]),
    );
  }
}
