import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/filter_model.dart';
import 'package:sixvalley_vendor_app/helper/debounce_helper.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_search_field_widget.dart';
import 'package:sixvalley_vendor_app/features/product/widgets/product_widget.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';

class ProductListMenuScreen extends StatefulWidget {
  final bool fromNotification;
  final bool fromDashboard;
  const ProductListMenuScreen({
    super.key,
    this.fromNotification = false,
    this.fromDashboard = false,
  });
  @override
  State<ProductListMenuScreen> createState() => _ProductListMenuScreenState();
}

class _ProductListMenuScreenState extends State<ProductListMenuScreen> {
  final DebounceHelper _debounce = DebounceHelper(milliseconds: 500);
  TextEditingController searchController = TextEditingController();
  int? userId;

  void _getBrandList() {
    String languageCode =
        Provider.of<LocalizationController>(context, listen: false)
                    .locale
                    .countryCode ==
                'US'
            ? 'en'
            : Provider.of<LocalizationController>(context, listen: false)
                .locale
                .countryCode!
                .toLowerCase();
    Provider.of<ProductController>(Get.context!, listen: false)
        .getBrandList(Get.context!, languageCode);
  }

  @override
  void initState() {
    userId = Provider.of<ProfileController>(context, listen: false).userId;
    Provider.of<ProductController>(context, listen: false).clearFilterData();
    _getBrandList();
    super.initState();
  }

  @override
  void dispose() {
    _debounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (widget.fromDashboard) {
          return;
        } else if (widget.fromNotification) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (BuildContext context) => const DashboardScreen(),
              ),
              (route) => false);
        } else {
          if (!didPop) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: CustomAppBarWidget(
          title: getTranslated('product_list', context),
          isBackButtonExist: !widget.fromDashboard,
          onBackPressed: () {
            if (widget.fromDashboard) {
              return;
            } else if (widget.fromNotification) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          const DashboardScreen()),
                  (route) => false);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<ProductController>(
                builder: (context, controller, _) => Container(
                      margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppDesign.brandGradient,
                        borderRadius:
                            BorderRadius.circular(AppDesign.radiusLarge),
                        boxShadow:
                            AppDesign.softShadow(Theme.of(context).brightness),
                      ),
                      child: Row(children: [
                        const Icon(Icons.inventory_2_outlined,
                            color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(
                                  getTranslated('seller_products_overview',
                                          context) ??
                                      '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800)),
                              Text(
                                  getTranslated('seller_products_overview_hint',
                                          context) ??
                                      '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: Colors.white
                                              .withValues(alpha: .82))),
                            ])),
                        Text('${controller.sellerProductModel?.totalSize ?? 0}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900)),
                      ]),
                    )),
            SizedBox(
                height: 68,
                child: Consumer<ProductController>(
                    builder: (context, productController, _) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeMedium,
                        vertical: Dimensions.paddingSizeExtraSmall),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomSearchFieldWidget(
                            controller: searchController,
                            hint: getTranslated(
                                'search_by_product_name', context),
                            prefix: Images.iconsSearch,
                            iconPressed: () => () {},
                            onSubmit: (text) => () {},
                            onChanged: (value) => _debounce.run(() async {
                              productController.getSellerProductList(
                                userId.toString(),
                                1,
                                'en',
                                value,
                                filterSearchModel: FilterModel(reload: true),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  );
                })),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Expanded(
                child: ProductViewWidget(
              sellerId: userId,
              fromNotification: widget.fromNotification,
              keyboardHeight: MediaQuery.of(context).viewInsets.bottom,
            ))
          ],
        ),
      ),
    );
  }
}
