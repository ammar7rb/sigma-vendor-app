import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/features/profile/screens/vendor_inbox_screen.dart';
import 'package:sixvalley_vendor_app/features/profile/widgets/vendor_navigation_actions.dart';
import 'package:sixvalley_vendor_app/localization/app_localization.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/theme/light_theme.dart';
import 'seller_order_phase3_widget_test.dart' show LoadedLocale;

void main() {
  testWidgets(
      'Arabic navigation fits phone and desktop and preserves count colors',
      (tester) async {
    final locale = AppLocalization(const Locale('ar'));
    await tester.runAsync(() async => locale.load());
    final theme = ThemeController(sharedPreferences: null);
    addTearDown(theme.dispose);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final workspace = VendorWorkspace.instance;
    addTearDown(workspace.stop);
    workspace.counts['messages'] = 1;
    workspace.counts['notifications'] = 2;
    for (final size in [const Size(360, 800), const Size(1280, 900)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(ChangeNotifierProvider<ThemeController>.value(
          value: theme,
          child: MaterialApp(
            theme: light,
            locale: const Locale('ar'),
            localizationsDelegates: [
              LoadedLocale(locale),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            home: Scaffold(
                appBar: AppBar(
                    title: const Text('الحساب والملف الشخصي'),
                    actions: const [VendorNavigationActions()])),
          )));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('+1'), findsOneWidget);
      expect(find.text('+2'), findsOneWidget);
      expect(find.byIcon(Icons.add_box_outlined), findsOneWidget);
      expect(find.byIcon(Icons.mail_outline), findsOneWidget);
    }
  });

  testWidgets(
      'Messages are incoming only and opening them does not acknowledge records',
      (tester) async {
    final locale = AppLocalization(const Locale('ar'));
    await tester.runAsync(() async => locale.load());
    final theme = ThemeController(sharedPreferences: null);
    addTearDown(theme.dispose);
    final workspace = VendorWorkspace.instance;
    addTearDown(workspace.stop);
    workspace.counts['messages'] = 1;
    workspace.inbox = {
      'messages': [
        {
          'kind': 'message',
          'id': 1,
          'title': 'رسالة الإدارة',
          'body': 'راجع بيانات المتجر',
          'unread': true,
          'created_at': '',
          'attachments': []
        }
      ],
      'threads':[{'id':1,'title':'رسالة الإدارة','body':'راجع بيانات المتجر','unread_count':1}],
      'notifications': []
    };
    await tester.pumpWidget(ChangeNotifierProvider<ThemeController>.value(
        value: theme,
        child: MaterialApp(
          theme: light,
          locale: const Locale('ar'),
          localizationsDelegates: [
            LoadedLocale(locale),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate
          ],
          home: const VendorInboxScreen(messages: true),
        )));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('راجع بيانات المتجر'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byIcon(Icons.send), findsNothing);
    expect(workspace.counts['messages'], 1);
    expect((workspace.inbox!['messages'] as List).single['unread'], true);
    expect(find.byIcon(Icons.add_box_outlined), findsOneWidget);
  });
}
