import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
// ignore: implementation_imports
import 'package:file_picker/src/platform/file_picker_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/dio/dio_client.dart';
import 'package:sixvalley_vendor_app/di_container.dart' as di;
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_tab_view_screen.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/vendor_fulfillment_view.dart';
import 'package:sixvalley_vendor_app/localization/app_localization.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'vendor_fulfillment_phase56_test.dart' show FulfillmentApiFixture;
import 'seller_order_phase3_widget_test.dart' show LoadedLocale;

class ProofPickerFixture extends FilePickerPlatform {
  final String name;
  final int size;
  List<String>? extensions;
  ProofPickerFixture(this.name, {this.size = 20});
  @override
  Future<FilePickerResult?> pickFiles(
      {String? dialogTitle,
      String? initialDirectory,
      FileType type = FileType.any,
      List<String>? allowedExtensions,
      Function(FilePickerStatus)? onFileLoading,
      int compressionQuality = 0,
      bool allowMultiple = false,
      bool withData = false,
      bool withReadStream = false,
      bool lockParentWindow = false,
      bool readSequential = false,
      bool cancelUploadOnWindowBlur = true}) async {
    extensions = allowedExtensions;
    return FilePickerResult([
      PlatformFile(
          name: name,
          size: size,
          readStream: Stream<List<int>>.value([37, 80, 68, 70]))
    ]);
  }
}

class PendingProductApiFixture extends FulfillmentApiFixture {
  bool checked = false;
  PendingProductApiFixture(super.prefs);
  @override
  Future<Response> get(String uri,
      {Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken,
      ProgressCallback? onReceiveProgress}) async {
    checked = uri == '/api/v3/seller/packages';
    return Response(
        requestOptions: RequestOptions(path: uri),
        statusCode: 200,
        data: {'product_creation_allowed': false});
  }
}

void main() {
  late FulfillmentApiFixture api;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await di.sl.reset();
    api = FulfillmentApiFixture(await SharedPreferences.getInstance());
    di.sl.registerSingleton<DioClient>(api);
  });
  tearDown(() async => di.sl.reset());

  Widget view(Map<String, dynamic> portion) => MaterialApp(
          home: Scaffold(
              body: VendorFulfillmentView(order: {
        'id': 42,
        'order_details': [],
        'fulfillment_eligibility': {
          'portion_actions_enabled': true,
          'has_restrictions': false,
          'details_locked': false,
          'portions': [portion]
        }
      }, onRefresh: () async {})));

  for (final extension in ['pdf', 'mp4']) {
    testWidgets(
        'portion delivery can upload $extension with server-compatible extensions',
        (tester) async {
      final old = FilePickerPlatform.instance;
      final picker = ProofPickerFixture('proof.$extension');
      FilePickerPlatform.instance = picker;
      addTearDown(() => FilePickerPlatform.instance = old);
      await tester.pumpWidget(view({
        'id': 3,
        'status': 'shipping',
        'amount': 160,
        'actions': [],
        'delivery_proof_required': true
      }));
      await tester.ensureVisible(find.text('إرفاق إثبات التسليم لهذا الجزء'));
      await tester.tap(find.text('إرفاق إثبات التسليم لهذا الجزء'));
      await tester.pumpAndSettle();
      expect(
          picker.extensions, containsAll(['pdf', 'mp4', 'jpg', 'png', 'webp']));
      expect(api.submissions.single['path'],
          '/api/v3/seller/fulfillment-requests/3/delivery-proof');
      final form = api.submissions.single['data'] as FormData;
      expect(form.files.single.value.filename, 'proof.$extension');
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('proof larger than ten MB is refused before upload',
      (tester) async {
    final old = FilePickerPlatform.instance;
    FilePickerPlatform.instance =
        ProofPickerFixture('large.mp4', size: 11 * 1024 * 1024);
    addTearDown(() => FilePickerPlatform.instance = old);
    await tester.pumpWidget(view({
      'id': 3,
      'status': 'shipping',
      'amount': 160,
      'actions': [],
      'delivery_proof_required': true
    }));
    await tester.ensureVisible(find.text('إرفاق إثبات التسليم لهذا الجزء'));
    await tester.tap(find.text('إرفاق إثبات التسليم لهذا الجزء'));
    await tester.pumpAndSettle();
    expect(api.submissions, isEmpty);
    expect(find.textContaining('10 ميجابايت'), findsOneWidget);
  });
  for (final mode in ['fixed', 'percentage']) {
    testWidgets('cancellation describes $mode calculation accurately',
        (tester) async {
      await tester.pumpWidget(view({
        'id': 3,
        'status': 'accepted',
        'amount': 160,
        'actions': ['cancel'],
        'cancellation_preview': {
          'mode': mode,
          'assessed_amount': '10.00',
          'percentage': 10,
          'revision': 2
        }
      }));
      await tester.ensureVisible(find.text('إلغاء بعد القبول'));
      await tester.tap(find.text('إلغاء بعد القبول'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(
          find.textContaining(
              mode == 'fixed' ? 'مبلغ ثابت بالجنيه' : 'النسبة 10٪'),
          findsOneWidget);
      if (mode == 'fixed') expect(find.textContaining('النسبة'), findsNothing);
      expect(api.submissions, isEmpty);
    });
  }
  testWidgets(
      'ordinary product entry checks activation without requiring a paid package',
      (tester) async {
    await di.sl.reset();
    final pending =
        PendingProductApiFixture(await SharedPreferences.getInstance());
    di.sl.registerSingleton<DioClient>(pending);
    final locale = AppLocalization(const Locale('ar'));
    await tester.runAsync(locale.load);
    final theme = ThemeController(sharedPreferences: null);
    addTearDown(theme.dispose);
    await tester.pumpWidget(ChangeNotifierProvider<ThemeController>.value(
        value: theme,
        child: MaterialApp(
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar')],
            localizationsDelegates: [
              LoadedLocale(locale),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            home: const AddProductTabView(fromHome: false))));
    await tester.pumpAndSettle();
    expect(pending.checked, isTrue);
    expect(find.textContaining('يلزم تفعيل حساب التاجر'), findsOneWidget);
    expect(find.textContaining('يلزم اشتراك سارٍ'), findsNothing);
    expect(pending.submissions, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
