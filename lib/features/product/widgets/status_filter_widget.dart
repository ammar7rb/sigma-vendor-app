import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import '../../../main.dart';

class StatusFilterWidget extends StatefulWidget {
  final Function(int index) onFilterChanged;
  const StatusFilterWidget({super.key, required this.onFilterChanged});

  @override
  State<StatusFilterWidget> createState() => _StatusFilterWidgetState();
}

class _StatusFilterWidgetState extends State<StatusFilterWidget> {
  int _selectedIndex = 0;

  // Keep only the states that are actionable and clear to the seller. Internal
  // administration workflow names are deliberately not exposed in the UI.
  final List<String> _filterList = [
    'all',
    'approved_published',
    'submitted',
    'rejected'
  ];

  ProductController productController =
      Provider.of<ProductController>(Get.context!, listen: false);

  void _callApi(String status) {
    productController.getSellerProductList(
      Provider.of<ProfileController>(context, listen: false).userId.toString(),
      1,
      Provider.of<LocalizationController>(context, listen: false)
                  .locale
                  .languageCode ==
              'US'
          ? 'en'
          : Provider.of<LocalizationController>(context, listen: false)
              .locale
              .countryCode!
              .toLowerCase(),
      '',
      filterSearchModel: productController.filterModel.copyWith(
        reload: true,
        isApproved: status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(
        builder: (context, controller, _) => Container(
              color: Theme.of(context).cardColor,
              height: 40,
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filterList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  bool isSelected = _selectedIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(
                        right: Dimensions.paddingSizeSmall),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        _callApi(_filterList[index]);
                      },
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusExtraLarge),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeExtraLarge),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context)
                                  .hintColor
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                              Dimensions.radiusExtraLarge),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${getTranslated(_labelKey(_filterList[index]), context) ?? _filterList[index]}${_statusCount(controller, _filterList[index])}',
                          style: isSelected
                              ? robotoBold.copyWith(
                                  color: Colors.white,
                                  fontSize: Dimensions.fontSizeDefault)
                              : robotoRegular.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color
                                      ?.withValues(alpha: 0.7),
                                  fontSize: Dimensions.fontSizeDefault),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ));
  }

  String _statusCount(ProductController controller, String status) {
    if (status == 'all') {
      return ' (${controller.sellerProductModel?.totalSize ?? 0})';
    }
    return ' (${controller.sellerProductModel?.reviewStatusCounts?[status] ?? 0})';
  }

  String _labelKey(String status) => switch (status) {
        'approved_published' => 'visible_to_customers',
        'submitted' => 'submitted_hidden',
        'rejected' => 'needs_update',
        _ => 'all',
      };
}
