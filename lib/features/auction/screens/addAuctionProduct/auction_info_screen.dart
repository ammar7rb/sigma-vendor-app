import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_tax_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/tax_vat_model.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_ai_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_product_model.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/add_auction_info_widget.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:textfield_tags/textfield_tags.dart';

class AuctionInfoScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final AuctionProduct? auctionProduct;
  final bool isRelaunch;
  final String Function()? getProductTitle;
  final String Function()? getProductDescription;

  const AuctionInfoScreen({
    super.key,
    this.onBack,
    this.onNext,
    this.auctionProduct,
    this.isRelaunch = false,
    this.getProductTitle,
    this.getProductDescription,
  });

  @override
  AuctionInfoScreenState createState() => AuctionInfoScreenState();
}

class AuctionInfoScreenState extends State<AuctionInfoScreen> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController? _tabController;
  final List<String> _dummyLanguages = ['English', 'Arabic'];

  final TextEditingController startPriceController = TextEditingController();
  final TextEditingController minimumIncrementController = TextEditingController();
  final TextEditingController maximumDecrementController = TextEditingController();
  final TextfieldTagsController auctionTagsController = TextfieldTagsController();

  List<TaxVatModel> selectedVatTaxes = [];
  DateTime? selectedStartTime;
  DateTime? selectedEndTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _dummyLanguages.length, initialIndex: 0, vsync: this);
    if (widget.auctionProduct != null) {
      startPriceController.text = widget.auctionProduct!.startingPrice?.toString() ?? '';
      minimumIncrementController.text = widget.auctionProduct!.minimumIncrementAmount?.toString() ?? '';
      maximumDecrementController.text = widget.auctionProduct!.maximumDecrementAmount?.toString() ?? '';

      if (!widget.isRelaunch) {
        try {
          if (widget.auctionProduct!.startTime != null && widget.auctionProduct!.startTime!.isNotEmpty) {
            selectedStartTime = DateTime.tryParse(widget.auctionProduct!.startTime!)?.toLocal();
          }
          if (widget.auctionProduct!.endTime != null && widget.auctionProduct!.endTime!.isNotEmpty) {
            selectedEndTime = DateTime.tryParse(widget.auctionProduct!.endTime!)?.toLocal();
          }
        } catch (e) {}
      }

      if (widget.auctionProduct?.taxVats != null) {
        AddProductTaxController taxController = Provider.of<AddProductTaxController>(context, listen: false);


        for(TaxVats taxVat in widget.auctionProduct!.taxVats ?? []) {
          for(TaxVatModel tax in taxController.taxVatList) {
            if(tax.id == taxVat.taxId) {
              taxController.addToSelectedTaxList(tax);
              selectedVatTaxes.add(tax);
            }
          }
        }

      }


    }

    _loadData();
  }

  // Image-driven auto-fill: when the user generated from an image on the
  // General Info tab, [requestTypeImage] stays true until the SEO tab consumes
  // it. This tab is built lazily on first navigation, so on open it generates
  // the auction info (start price / increments / tax / times) and applies it —
  // mirroring how the product Variations tab auto-fills.
  Future<void> _loadData() async {
    final aiController = Provider.of<AuctionAiController>(context, listen: false);
    if (!aiController.requestTypeImage) return;

    final String title = widget.getProductTitle?.call() ?? '';
    final String description = widget.getProductDescription?.call() ?? '';
    if (title.trim().isEmpty) return;

    await aiController.generateAuctionInfoSetup(
      title: title.trim(),
      description: description.trim(),
      langCode: _currentLangCode,
    );
    _applyAuctionInfoResult();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    startPriceController.dispose();
    minimumIncrementController.dispose();
    maximumDecrementController.dispose();
    auctionTagsController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  String get _currentLangCode {
    final locController = Provider.of<LocalizationController>(context, listen: false);
    return locController.locale.countryCode == 'US' ? 'en' : locController.locale.countryCode!.toLowerCase();
  }

  void generateAuctionInfoFromAi() => _onAuctionInfoAiTap();

  void _onAuctionInfoAiTap() {
    final title = widget.getProductTitle?.call() ?? '';
    final description = widget.getProductDescription?.call() ?? '';

    if (title.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('product_name_required', context) ?? 'Please enter a product name first', context);
      return;
    }
    if (description.trim().isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_input_all_des', context) ?? 'Please enter a description first', context);
      return;
    }

    Provider.of<AuctionAiController>(context, listen: false).generateAuctionInfoSetup(
      title: title.trim(),
      description: description.trim(),
      langCode: _currentLangCode,
    ).then((_) => _applyAuctionInfoResult());
  }

  void _applyAuctionInfoResult() {
    final aiController = Provider.of<AuctionAiController>(context, listen: false);
    final data = aiController.auctionInfoModel?.data?.auctionInfoData;
    if (data == null) return;

    // Apply AI-suggested search tags into the tag field (controller notifies the field).
    final List<String> aiTags = data.tags
        ?? (data.tagsCsv?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList())
        ?? const [];
    auctionTagsController.clearTags();
    for (final t in aiTags) {
      auctionTagsController.addTag = t;
    }

    setState(() {
      if (data.startingPrice != null) {
        startPriceController.text = data.startingPrice.toString();
      }
      if (data.minimumIncrementAmount != null) {
        minimumIncrementController.text = data.minimumIncrementAmount.toString();
      }
      if (data.maximumDecrementAmount != null) {
        maximumDecrementController.text = data.maximumDecrementAmount.toString();
      }
      if (data.startTime != null && data.startTime!.isNotEmpty) {
        selectedStartTime = DateTime.tryParse(data.startTime!)?.toLocal();
      }
      if (data.endTime != null && data.endTime!.isNotEmpty) {
        selectedEndTime = DateTime.tryParse(data.endTime!)?.toLocal();
      }
    });

    // Apply tax selections from taxIds
    if (data.taxIds != null && data.taxIds!.isNotEmpty) {
      final taxController = Provider.of<AddProductTaxController>(context, listen: false);
      // Clear existing selections
      while (taxController.selectedTaxList.isNotEmpty) {
        taxController.removeToSelectedTaxList(taxController.selectedTaxList.last, taxController.selectedTaxList.length - 1);
      }
      for (final id in data.taxIds!) {
        for (final tax in taxController.taxVatList) {
          if (tax.id == id && !taxController.isSelected(tax)) {
            taxController.addToSelectedTaxList(tax);
          }
        }
      }
      setState(() => selectedVatTaxes = taxController.selectedTaxList);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final bool aiEnabled = Provider.of<SplashController>(context, listen: false).configModel?.isAiFeatureActive == 1;

    return Consumer<AuctionAiController>(
      builder: (context, aiController, _) {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Expanded(
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AddAuctionInfoWidget(
                    startPriceController: startPriceController,
                    minimumIncrementController: minimumIncrementController,
                    maximumDecrementController: maximumDecrementController,
                    startTime: selectedStartTime,
                    endTime: selectedEndTime,
                    tagsController: auctionTagsController,
                    initialTags: widget.auctionProduct?.auctionTags ?? const [],
                    isAiGenerating: aiController.auctionInfoLoading,
                    onAiTap: aiEnabled ? _onAuctionInfoAiTap : null,
                    onVatTaxChanged: (List<TaxVatModel> values) {
                      setState(() => selectedVatTaxes = values);
                    },
                    onStartTimeChanged: (value) {
                      setState(() => selectedStartTime = value);
                    },
                    onEndTimeChanged: (value) {
                      setState(() => selectedEndTime = value);
                    },
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Colors.grey[200]!, spreadRadius: 0.5, blurRadius: 0.3)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: InkWell(
                      onTap: widget.onBack,
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).hintColor.withValues(alpha: 0.30),
                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                        ),
                        child: Center(
                          child: Text(getTranslated('go_back', context) ?? "",
                            style: titilliumBold.copyWith(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: InkWell(
                      onTap: widget.onNext,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                        ),
                        child: Center(
                          child: Text(getTranslated('next', context) ?? "",
                            style: titilliumBold.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),


              ],
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}

