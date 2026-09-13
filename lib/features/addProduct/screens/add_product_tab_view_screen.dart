import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/add_product_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/edt_product_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/product_general_info_data_model.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_next_screen.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_screen.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_seo_screen.dart';
import 'package:sixvalley_vendor_app/features/addProduct/widgets/add_product_tabbar_widget.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/seller_activation_ticket_screen.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';

class AddProductTabView extends StatefulWidget {
  final Product? product;
  final AddProductModel? addProduct;
  final EditProductModel? editProduct;
  final bool fromHome;
  const AddProductTabView(
      {super.key,
      this.product,
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

    if (widget.product == null) {
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
  Widget build(BuildContext context) {
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
          reason: _eligibilityReason ??
              (getTranslated('seller_product_activation_required', context) ??
                  'Activate your seller account before adding products.'),
          action: _eligibilityAction,
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
    final authController = Provider.of<AuthController>(context, listen: false);
    final activationResponse = await authController.loadActivationStatus();
    if (!mounted) return;

    // Activation is the only account gate. Advertising packages grant paid
    // placements and never block ordinary product creation or publication.
    if (activationResponse.response?.statusCode == 200 &&
        activationResponse.response?.data is Map) {
      final data =
          Map<String, dynamic>.from(activationResponse.response!.data as Map);
      final eligibility =
          Map<String, dynamic>.from(data['eligibility'] as Map? ?? const {});
      final nextStep = eligibility['next_step']?.toString();
      if (nextStep == 'verify_phone' ||
          nextStep == 'await_activation_ticket' ||
          nextStep == 'await_admin_approval') {
        setState(() {
          _eligibilityReason = nextStep == 'verify_phone'
              ? (getTranslated(
                      'seller_product_phone_verification_required', context) ??
                  'Verify your phone before adding products.')
              : (getTranslated('seller_product_activation_required', context) ??
                  'Activate your seller account before adding products.');
          _eligibilityAction = nextStep == 'await_activation_ticket'
              ? 'activation_ticket'
              : 'back';
          _canAddNewProduct = false;
          _eligibilityChecked = true;
        });
        return;
      }
    } else if (authController.getRegistrationReference().isNotEmpty) {
      // Do not let a temporary API failure turn into a bypass of the first gate.
      setState(() {
        _eligibilityReason =
            getTranslated('seller_product_eligibility_unavailable', context) ??
                'We could not verify your eligibility. Please try again.';
        _eligibilityAction = null;
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

  const _AddProductEligibilityBlocked({required this.reason, this.action});

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
              onPressed: () {
                if (action == 'activation_ticket') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const SellerActivationTicketScreen()));
                } else {
                  Navigator.pop(context);
                }
              },
              icon: Icon(action == 'activation_ticket'
                  ? Icons.support_agent_outlined
                  : Icons.inventory_2_outlined),
              label: Text(_actionLabel(context)),
            ),
        ]),
      ),
    );
  }

  String _actionLabel(BuildContext context) {
    return switch (action) {
      'activation_ticket' =>
        getTranslated('complete_seller_activation', context) ??
            'Complete activation',
      _ => getTranslated('back', context) ?? 'Back',
    };
  }
}
