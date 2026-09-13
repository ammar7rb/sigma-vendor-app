import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/features/language/screens/change_language_screen.dart';
import 'package:sixvalley_vendor_app/features/profile/widgets/theme_changer_widget.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
          title: getTranslated('settings', context), isBackButtonExist: true),
      body: ListView(padding: AppDesign.pagePadding, children: [
        Text(
            getTranslated('vendor_app_preferences', context) ??
                'Application preferences',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        TitleButton(
          icon: Icons.language_outlined,
          title: getTranslated('choose_language', context),
          subtitle: getTranslated('vendor_languages_hint', context),
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ChooseLanguageScreen())),
        ),
        const SizedBox(height: 10),
        const ThemeChangerWidget(),
      ]),
    );
  }
}

class TitleButton extends StatelessWidget {
  final IconData icon;
  final String? title;
  final String? subtitle;
  final Function onTap;
  const TitleButton(
      {super.key,
      required this.icon,
      required this.title,
      this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(AppDesign.radiusMedium)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, color: Theme.of(context).primaryColor)),
        title: Text(title ?? '',
            style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap as void Function()?,
      ),
    );
  }
}
