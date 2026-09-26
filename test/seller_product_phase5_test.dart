import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('phase five seller product labels are localized', () {
    final ar =
        jsonDecode(File('assets/language/ar.json').readAsStringSync()) as Map;
    final en =
        jsonDecode(File('assets/language/en.json').readAsStringSync()) as Map;
    const keys = [
      'seller_product_price_stock',
      'seller_product_review_submit',
      'seller_product_review_hint',
      'seller_product_category_admin_hint',
      'seller_product_package_price',
      'seller_product_individual_price',
      'seller_product_measurement_unit_optional',
      'seller_products_overview',
      'seller_product_save',
    ];
    for (final key in keys) {
      expect(ar[key], matches(RegExp(r'[\u0600-\u06ff]')), reason: key);
      expect(en[key], isNotEmpty, reason: key);
    }
  });

  test('seller product form submits Arabic content with neutral legacy fields',
      () {
    final screen = File(
      'lib/features/addProduct/screens/add_product_seo_screen.dart',
    ).readAsStringSync();
    expect(
      screen,
      matches(RegExp(
        r"_addProduct!\.languageList\s*=\s*\[\s*'ar'\s*\]",
        multiLine: true,
      )),
    );
    for (final assignment in {
      'discount': '0',
      'discountType': "'percent'",
      'productType': "'physical'",
      'shippingCost': '0',
    }.entries) {
      expect(
        screen,
        matches(RegExp(
          '_product!\\.${assignment.key}\\s*=\\s*${assignment.value}',
          multiLine: true,
        )),
        reason: assignment.key,
      );
    }
  });

  test('seller product list hides administration workflow statuses', () {
    final list = File(
      'lib/features/product/screens/product_list_screen.dart',
    ).readAsStringSync();
    final card = File(
      'lib/features/product/widgets/product_widget.dart',
    ).readAsStringSync();
    expect(list, isNot(contains('StatusFilterWidget')));
    expect(card, contains("isActive ? 'active' : 'inactive'"));
    expect(card, isNot(contains("getTranslated('submitted_hidden'")));
    expect(card, isNot(contains("getTranslated('needs_update'")));
  });

  test('backend keeps approval internal while seller product starts active',
      () {
    final backend = File(
      'E:/xampp/htdocs/ba/app/Http/Controllers/RestAPI/v3/seller/ProductController.php',
    ).readAsStringSync();
    expect(backend, contains("'request_status' => 0"));
    expect(backend, contains("'status' => 1"));
    expect(backend, contains('SellerProductReviewService::SUBMITTED'));
    expect(backend, contains('resolveSellerBrandId'));
    expect(backend, contains("'unit' => 'nullable|string|max:50'"));
    expect(backend, contains(r'$submittedImageCount < 5'));
  });

  test('product details expose active toggle and restock action', () {
    final details = File(
      'lib/features/product_details/screens/product_details_screen.dart',
    ).readAsStringSync();
    expect(details, matches(RegExp(r'Switch\(\s*value:\s*isActive')));
    expect(details, contains('_openRestockDialog'));
    expect(details, contains('LimitedStockQuantityUpdateDialogWidget'));
    expect(details, contains('updateProductQuantity'));
  });

  test(
      'seller media, generated code, package and optional unit rules are wired',
      () {
    final general = File(
      'lib/features/addProduct/screens/add_product_screen.dart',
    ).readAsStringSync();
    final pricing = File(
      'lib/features/addProduct/screens/add_product_next_screen.dart',
    ).readAsStringSync();
    final validation = File(
      'lib/features/addProduct/controllers/add_product_controller.dart',
    ).readAsStringSync();
    expect(general, contains("'upload_thumbnail'"));
    expect(general, contains("'additional_product_images'"));
    expect(general, isNot(contains("'seller_product_category_admin_hint'")));
    expect(general, contains("'enter_brand_name_if_not_listed'"));
    expect(general, contains('_generateSKU()'));
    expect(general, contains("'seller_product_sale_unit_\$value'"));
    expect(general, matches(RegExp(r"==\s*'package'")));
    expect(pricing, contains("'seller_product_package_price'"));
    expect(validation, contains('productImageCount < 5'));
    expect(validation, isNot(contains("getTranslated('select_a_unit'")));
  });
}
