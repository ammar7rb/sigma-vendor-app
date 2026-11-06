import 'package:sixvalley_vendor_app/features/product/screens/product_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/features/seller_package/screens/seller_package_screen.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/add_product_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/edt_product_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/product_general_info_data_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_next_screen.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_screen.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_seo_screen.dart';
import 'package:sixvalley_vendor_app/features/addProduct/widgets/add_product_tabbar_widget.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';

class AddProductTabView extends StatefulWidget {
  final Product? product;
  final int? slotId;
  final String? slotReservationToken;
  final int? extraAdSubscriptionId;
  final double? extraAdPrice;
  final String? extraAdRequestKey;
  final AddProductModel? addProduct;
  final EditProductModel? editProduct;
  final bool fromHome;
  const AddProductTabView(
      {super.key,
      this.product,
      this.slotId,
      this.slotReservationToken,
      this.extraAdSubscriptionId,
      this.extraAdPrice,
      this.extraAdRequestKey,
      this.addProduct,
      this.editProduct,
      required this.fromHome});

  @override
  State<AddProductTabView> createState() => _AddProductTabViewState();
}

class _AddProductTabViewState extends State<AddProductTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<AddProductScreenState> _firstTabKey =
      GlobalKey<AddProductScreenState>();
  final GlobalKey<AddProductNextScreenState> _secondTabKey =
      GlobalKey<AddProductNextScreenState>();

  ProductGeneralInfoData? productGeneralInfoData;
  ProductCombinedData? productCombinedData;
  bool _eligibilityChecked = false;
  bool _canAddNewProduct = true;
  String? _eligibilityReason;
  String? _eligibilityAction;

  List<Tab> _productTabs(BuildContext context) => <Tab>[
        Tab(text: getTranslated('general_info', context)),
        Tab(text: getTranslated('seller_product_price_stock', context)),
        Tab(text: getTranslated('seller_product_review_submit', context)),
      ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    if (widget.product == null &&
        (widget.slotId != null || widget.extraAdRequestKey != null)) {
      // Every new-product entry point reaches this screen, so the check cannot be bypassed from another menu.
      Future.microtask(_checkNewProductEligibility);
    } else {
      _eligibilityChecked = true;
    }

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && _tabController.index > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _fetchDataFromFirstTab();
          _fetchDataFromSecondTab();
        });
      }
    });
  }

  void _fetchDataFromFirstTab() {
    ProductGeneralInfoData? latestData =
        _firstTabKey.currentState?.getCurrentFormData();
    setState(() {
      productGeneralInfoData = latestData;
    });
  }

  void _fetchDataFromSecondTab() {
    ProductCombinedData? data =
        _secondTabKey.currentState?.getCurrentFormData();
    setState(() {
      productCombinedData = data;
    });
  }

  void _navigateToTab(int index) {
    if (index == 1) {
      _fetchDataFromFirstTab();
    }

    _tabController.animateTo(index);
  }

  @override
  void dispose() {
    if (widget.product == null && widget.slotId != null) {
      VendorWorkspace.instance.client.post(
          '/api/v3/seller/packages/slots/${widget.slotId}/cancel-reservation',
          data: {
            'reservation_token': widget.slotReservationToken
          }).then<void>((_) {}, onError: (Object error, StackTrace stack) {});
    }
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.product == null &&
        widget.slotId == null &&
        widget.extraAdRequestKey == null) {
      return const ProductListMenuScreen(showAdvertisingSlots: true);
    }
    final productTabs = _productTabs(context);
    if (widget.product == null && !_eligibilityChecked) {
      return Scaffold(
        appBar: CustomAppBarWidget(
            centerTitle: false, title: getTranslated('add_product', context)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.product == null && !_canAddNewProduct) {
      return Scaffold(
        appBar: CustomAppBarWidget(
            centerTitle: false, title: getTranslated('add_product', context)),
        body: _AddProductEligibilityBlocked(
          reason:
              _eligibilityReason ?? 'تعذر إضافة المنتج. راجع متطلبات الإعلان.',
          action: _eligibilityAction,
          onRetry: _checkNewProductEligibility,
        ),
      );
    }

    return DefaultTabController(
      length: productTabs.length,
      child: Scaffold(
        appBar: CustomAppBarWidget(
          centerTitle: false,
          title: widget.product != null
              ? getTranslated('update_product', context)
              : getTranslated('add_product', context),
          onBackPressed: () {
            Navigator.of(context).pop();
          },
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall),
              height: 60,
              child: AddProductTitleBar(tabController: _tabController),
            ),
            Flexible(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  AddProductScreen(
                      product: widget.product,
                      addProduct: widget.addProduct,
                      fromHome: widget.fromHome,
                      onTabChanged: _navigateToTab,
                      key: _firstTabKey),
                  AddProductNextScreen(
                    key: _secondTabKey,
                    detailsBuilder: (context) =>
                        _firstTabKey.currentState
                            ?.buildProductDetails(context) ??
                        const SizedBox.shrink(),
                    generalInfoReader: () =>
                        _firstTabKey.currentState?.getCurrentFormData(),
                    categoryId: productGeneralInfoData?.categoryId,
                    subCategoryId: productGeneralInfoData?.subCategoryId,
                    subSubCategoryId: productGeneralInfoData?.subSubCategoryId,
                    brandId: productGeneralInfoData?.brandId,
                    brandName: productGeneralInfoData?.brandName,
                    unit: productGeneralInfoData?.unit,
                    product: widget.product,
                    addProduct: productGeneralInfoData?.addProduct,
                    title: productGeneralInfoData?.title,
                    description: productGeneralInfoData?.description,
                    onTabChanged: _navigateToTab,
                  ),
                  AddProductSeoScreen(
                    slotId: widget.slotId,
                    slotReservationToken: widget.slotReservationToken,
                    extraAdSubscriptionId: widget.extraAdSubscriptionId,
                    extraAdPrice: widget.extraAdPrice,
                    extraAdRequestKey: widget.extraAdRequestKey,
                    unitPrice: productCombinedData?.unitPrice,
                    tax: productCombinedData?.tax,
                    unit: productCombinedData?.unit,
                    categoryId: productCombinedData?.categoryId,
                    subCategoryId: productCombinedData?.subCategoryId,
                    subSubCategoryId: productCombinedData?.subSubCategoryId,
                    brandyId: productCombinedData?.brandId,
                    brandName: productCombinedData?.brandName,
                    discount: productCombinedData?.discount,
                    currentStock: productCombinedData?.currentStock,
                    minimumOrderQuantity:
                        productCombinedData?.minimumOrderQuantity,
                    shippingCost: productCombinedData?.shippingCost,
                    product: widget.product,
                    addProduct: productCombinedData?.addProduct,
                    title: productCombinedData?.title,
                    description: productCombinedData?.description,
                    onTabChanged: _navigateToTab,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _checkNewProductEligibility() async {
    try {
      final response =
          await VendorWorkspace.instance.client.get('/api/v3/seller/packages');
      if (!mounted) return;
      if (response.data['product_creation_allowed'] != true) {
        setState(() {
          _eligibilityReason =
              Localizations.localeOf(context).languageCode == 'ar'
                  ? 'يلزم اشتراك سارٍ لإنشاء منتجات جديدة.'
                  : 'An active subscription is required to create products.';
          _eligibilityAction = 'packages';
          _canAddNewProduct = false;
          _eligibilityChecked = true;
        });
        return;
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _eligibilityReason =
            getTranslated('seller_product_eligibility_unavailable', context);
        _eligibilityAction = 'back';
        _canAddNewProduct = false;
        _eligibilityChecked = true;
      });
      return;
    }
    setState(() {
      _eligibilityReason = null;
      _eligibilityAction = null;
      _canAddNewProduct = true;
      _eligibilityChecked = true;
    });
  }
}

class _AddProductEligibilityBlocked extends StatelessWidget {
  final String reason;
  final String? action;
  final VoidCallback? onRetry;

  const _AddProductEligibilityBlocked(
      {required this.reason, this.action, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.lock_outline,
              size: 40, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text(reason, textAlign: TextAlign.center),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          if (action != null)
            OutlinedButton.icon(
              onPressed: () async {
                if (action == 'packages') {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SellerPackageScreen()));
                  if (context.mounted) onRetry?.call();
                } else {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.inventory_2_outlined),
              label: Text(_actionLabel(context)),
            ),
        ]),
      ),
    );
  }

  String _actionLabel(BuildContext context) {
    return switch (action) {
      'packages' => Localizations.localeOf(context).languageCode == 'ar'
          ? 'اختيار باقة'
          : 'Choose a package',
      _ => getTranslated('back', context) ?? 'Back',
    };
  }
}
