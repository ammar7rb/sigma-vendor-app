import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/features/product_details/screens/product_details_screen.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_tab_view_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/widgets/vendor_finance_ui.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';

Future<void> openSavedAdvertisement(
    BuildContext context, Map<String, dynamic> data,
    {bool edit = false}) async {
  final response = await VendorWorkspace.instance.client
      .get('${AppConstants.productDetails}${data['id']}');
  final product = Product.fromJson(Map<String, dynamic>.from(response.data));
  if (!context.mounted) return;
  await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => edit
              ? AddProductTabView(product: product, fromHome: false)
              : ProductDetailsScreen(productModel: product)));
}

class SavedAdvertisementTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onReturn;
  const SavedAdvertisementTile(
      {super.key, required this.data, required this.onReturn});
  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final workspace = data['vendor_workspace'] as Map? ?? {};
    Future<void> open({bool edit = false}) async {
      try {
        await openSavedAdvertisement(context, data, edit: edit);
        if (context.mounted) onReturn();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(financeError(context, e))));
        }
      }
    }

    return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (data['thumbnail_url'] != null)
                      Padding(
                          padding: const EdgeInsetsDirectional.only(end: 14),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ImageFiltered(
                                  enabled:
                                      workspace['advertising_visible'] == false,
                                  imageFilter:
                                      ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                  child: Image.network(
                                      '${data['thumbnail_url']}',
                                      width: 72,
                                      height: 72,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox(
                                              width: 72,
                                              height: 72,
                                              child: Icon(
                                                  Icons.image_outlined)))))),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('${data['name']}',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(financeMoney(context, data['unit_price'])),
                          VendorProductViews(data: data),
                          if (workspace['legacy_exempt'] == true)
                            Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                    ar
                                        ? 'إعلان قديم مستثنى'
                                        : 'Legacy exempt advertisement',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary))),
                        ])),
                  ]),
                  const SizedBox(height: 16),
                  Wrap(spacing: 10, runSpacing: 8, children: [
                    OutlinedButton.icon(
                        onPressed: () => open(),
                        icon: const Icon(Icons.visibility_outlined),
                        label: Text(ar ? 'عرض الإعلان' : 'View advertisement')),
                    FilledButton.icon(
                        onPressed: () => open(edit: true),
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(ar ? 'تعديل' : 'Edit')),
                  ]),
                  if (workspace['advertising_visible'] == false)
                    Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                            ar
                                ? 'الإعلان غير متاح للعملاء. جدّد الاشتراك.'
                                : 'Advertisement hidden. Assign a valid space or renew your subscription.',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error))),
                ])));
  }
}

class VendorProductViews extends StatelessWidget {
  final Map<String, dynamic> data;
  const VendorProductViews({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final additions = int.tryParse('${data['administrative_view_additions']}') ?? 0;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${ar ? 'عدد المشاهدات' : 'View count'}: ${data['product_view_count'] ?? 0}'),
      if (additions > 0)
        Text('${ar ? 'منها إضافات إدارية' : 'Including administrative additions'}: $additions',
            style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}
