import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/ai/widgets/genertate_count_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/add_auction_product_contoller.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/add_auction_product_media_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_product_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_ai_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_product_model.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/addAuctionProduct/add_auction_product_screen.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/addAuctionProduct/add_auction_product_seo_screen.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/addAuctionProduct/auction_info_screen.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/auction_list_screen.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/auction_request_list_screen.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import '../../../../main.dart';

enum AddAuctionFromPage { auctionList, auctionRequest, biddingDetails }

class AddAuctionProductTabView extends StatefulWidget {
  final AddAuctionFromPage? fromPage;
  final AuctionProduct? auctionProduct;
  final bool isRelaunch;
  const AddAuctionProductTabView({super.key, this.fromPage, this.auctionProduct, this.isRelaunch = false});

  @override
  State<AddAuctionProductTabView> createState() => _AddAuctionProductTabViewState();
}

class _AddAuctionProductTabViewState extends State<AddAuctionProductTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final GlobalKey<AuctionInfoScreenState> _auctionInfoKey = GlobalKey<AuctionInfoScreenState>();
  final GlobalKey<AddAuctionProductScreenState> _generalInfoKey = GlobalKey<AddAuctionProductScreenState>();
  final GlobalKey<AddAuctionProductSeoScreenState> _seoKey = GlobalKey<AddAuctionProductSeoScreenState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging || _tabController.index != 1) return;

    final aiController = Provider.of<AuctionAiController>(context, listen: false);
    if (!aiController.autoFillAuctionInfoPending) return;

    aiController.consumeAutoFillAuctionInfoPending();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _auctionInfoKey.currentState?.generateAuctionInfoFromAi();
    });
  }

  void _onGeneralInfoNext() {
    final controller = Provider.of<AddAuctionProductController>(context, listen: false);
    final imageController = Provider.of<AddAuctionProductMediaController>(context, listen: false);
    final state = _generalInfoKey.currentState;

    if (state == null) return;

    final bool isValid = controller.validateGeneralInfo(
      context,
      nameController: state.titleControllerList,
      descriptionController: state.descriptionControllerList,
      selectedProductType: state.selectedProductType,
      selectedCategory: state.selectedCategory,
      selectedBrand: state.selectedBrand,
      selectedItemCondition: state.selectedItemCondition,
      shippingFeeController: state.shippingFeeController,
      returnPolicyController: state.returnPolicyController,
      thumbnailFile: imageController.thumbnailFile,
      additionalImages: imageController.productImages,
      auctionProduct: widget.auctionProduct,
      videoLinkController: state.videoLinkController,
      videoUploadType: state.videoUploadType,
    );

    if (isValid) {
      _tabController.animateTo(1);
    }
  }

  void _onAuctionInfoNext() {
    final controller = Provider.of<AddAuctionProductController>(context, listen: false);
    final state = _auctionInfoKey.currentState;

    if (state == null) return;

    final bool isValid = controller.validateAuctionInfo(
      context,
      startPriceController: state.startPriceController,
      minimumIncrementController: state.minimumIncrementController,
      maximumDecrementController: state.maximumDecrementController,
      selectedVatTaxRate: state.selectedVatTaxes,
      startTime: state.selectedStartTime,
      endTime: state.selectedEndTime,
    );

    if (isValid) {
      _tabController.animateTo(2);
    }
  }

  Widget _destinationPage() {
    switch (widget.fromPage) {
      case AddAuctionFromPage.auctionRequest:
      case AddAuctionFromPage.biddingDetails:
        return const AuctionRequestListScreen(fromNotification: true);
      case AddAuctionFromPage.auctionList:
      default:
        return const AuctionListScreen(fromNotification: true);
    }
  }

  void _onSubmit()  async {
    final controller = Provider.of<AddAuctionProductController>(context, listen: false);
    if (controller.isLoading) return;

    final imageController = Provider.of<AddAuctionProductMediaController>(context, listen: false);

    final generalState = _generalInfoKey.currentState;
    final auctionState = _auctionInfoKey.currentState;
    final seoState = _seoKey.currentState;

    if (generalState == null) {
      _tabController.animateTo(0);
      return;
    }

    if (auctionState == null) {
      _tabController.animateTo(1);
      return;
    }

    final isGeneralValid = controller.validateGeneralInfo(
      context,
      nameController: generalState.titleControllerList,
      descriptionController: generalState.descriptionControllerList,
      selectedProductType: generalState.selectedProductType,
      selectedCategory: generalState.selectedCategory,
      selectedBrand: generalState.selectedBrand,
      selectedItemCondition: generalState.selectedItemCondition,
      shippingFeeController: generalState.shippingFeeController,
      returnPolicyController: generalState.returnPolicyController,
      thumbnailFile: imageController.thumbnailFile,
      additionalImages: imageController.productImages,
      auctionProduct: widget.auctionProduct,
      videoLinkController: generalState.videoLinkController,
      videoUploadType: generalState.videoUploadType,
    );

    if (!isGeneralValid) {
      _tabController.animateTo(0);
      return;
    }

    final isAuctionValid = controller.validateAuctionInfo(
      context,
      startPriceController: auctionState.startPriceController,
      minimumIncrementController: auctionState.minimumIncrementController,
      maximumDecrementController: auctionState.maximumDecrementController,
      selectedVatTaxRate: auctionState.selectedVatTaxes,
      startTime: auctionState.selectedStartTime,
      endTime: auctionState.selectedEndTime,
    );

    if (!isAuctionValid) {
      _tabController.animateTo(1);
      return;
    }

    // All valid — proceed with submission

    final auctionController = Provider.of<AddAuctionProductController>(context, listen: false);

    // Read SEO values from controller (kept in sync by the SEO screen)
    String? metaIndex = auctionController.seoMetaIndex;
    String? metaNoFollow = auctionController.seoMetaNoFollow ?? '0';
    String? metaNoImageIndex = auctionController.seoMetaNoImageIndex ?? '0';
    String? metaNoArchive = auctionController.seoMetaNoArchive ?? '0';
    String? metaNoSnippet = auctionController.seoMetaNoSnippet ?? '0';

    String? metaMaxSnippet = auctionController.seoMetaMaxSnippet ?? '0';
    String? metaMaxSnippetValue = auctionController.seoMetaMaxSnippetValue;

    String? metaMaxVideoPreview = auctionController.seoMetaMaxVideoPreview ?? '0';
    String? metaMaxVideoPreviewValue = auctionController.seoMetaMaxVideoPreviewValue;

    String? metaMaxImagePreview = auctionController.seoMetaMaxImagePreview ?? '0';
    String? metaMaxImagePreviewValue = auctionController.seoMetaMaxImagePreviewValue;

    String? metaImage = auctionController.seoMetaImage;

    final splashProvider = Provider.of<SplashController>(context, listen: false);
    final String? currentCurrencyCode = splashProvider.myCurrency?.code;

    List<String> languageList = [];
    final splashConfig = splashProvider.configModel;
    if(splashConfig?.languageList != null && splashConfig!.languageList!.isNotEmpty){
      for(final lan in splashConfig.languageList!) {
        languageList.add(lan.code ?? '');
      }
    } else {
      languageList = ['en'];
    }

    // Collect search tags as a comma-separated string for the store/update endpoint.
    final List<String> tagList = auctionState.auctionTagsController.getTags ?? const [];
    final String? tagsCsv = tagList.isEmpty ? null : tagList.join(', ');

    ApiResponse? response = await controller.addAuctionProduct(
      context,
      nameController: generalState.titleControllerList,
      descriptionController: generalState.descriptionControllerList,
      selectedCategory: generalState.selectedCategory,
      selectedBrand: generalState.selectedBrand,
      selectedProductType: generalState.selectedProductType,
      shippingFeeController: generalState.shippingFeeController,
      returnPolicyController: generalState.returnPolicyController,
      videoLinkController: generalState.videoLinkController,
      videoUploadType: generalState.videoUploadType,
      startPriceController: auctionState.startPriceController,
      minimumIncrementController: auctionState.minimumIncrementController,
      maximumDecrementController: auctionState.maximumDecrementController,
      selectedItemCondition: generalState.selectedItemCondition,
      selectedVatTax: auctionState.selectedVatTaxes,
      startTime: auctionState.selectedStartTime,
      endTime: auctionState.selectedEndTime,
      metaTitleController: seoState?.metaTitleController ?? TextEditingController(),
      metaDescriptionController: seoState?.metaDescriptionController ?? TextEditingController(),
      languageList: languageList,

      metaIndex: metaIndex,
      metaNoFollow: metaNoFollow,
      metaNoImageIndex: metaNoImageIndex,
      metaNoArchive: metaNoArchive,
      metaNoSnippet: metaNoSnippet,
      metaMaxSnippet: metaMaxSnippet,
      metaMaxSnippetValue: metaMaxSnippetValue,
      metaMaxVideoPreview: metaMaxVideoPreview,
      metaMaxVideoPreviewValue: metaMaxVideoPreviewValue,
      metaMaxImagePreview: metaMaxImagePreview,
      metaMaxImagePreviewValue: metaMaxImagePreviewValue,
      metaImage: metaImage,
      update: widget.auctionProduct != null,
      auctionId: widget.auctionProduct?.id,
      currentCurrencyCode: currentCurrencyCode,
      tags: tagsCsv,
      isRelaunch: widget.isRelaunch,
    );


    if (response != null && response.response?.statusCode == 200) {
      Navigator.pushAndRemoveUntil(
        Get.context!,
        MaterialPageRoute(builder: (_) => _destinationPage()),
        (route) => false,
      );
    }




  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        centerTitle: false,
        title: widget.isRelaunch
            ? (getTranslated('relaunch_auction', context) ?? 'Relaunch Auction')
            : (getTranslated('add_auction_product', context) ?? ""),
        widget: GeneratesLeftCount(isAuction: true),

        isFilter: true,
        isAction: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
            height: 60,
            child: AddProductTitleBar(
              tabController: _tabController,
              tabs: [
                Tab(text: getTranslated('general_info', context) ?? 'General Info'),
                Tab(text: getTranslated('auction_info', context) ?? 'Auction Info'),
                Tab(text: getTranslated('seo', context) ?? 'SEO'),
              ],
            ),
          ),

          Flexible(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                AddAuctionProductScreen(
                  key: _generalInfoKey,
                  onNext: _onGeneralInfoNext,
                  auctionProduct: widget.auctionProduct,
                ),

                AuctionInfoScreen(
                  key: _auctionInfoKey,
                  onBack: () => _tabController.animateTo(0),
                  onNext: _onAuctionInfoNext,
                  auctionProduct: widget.auctionProduct,
                  isRelaunch: widget.isRelaunch,
                  getProductTitle: () => _generalInfoKey.currentState?.titleControllerList[0].text ?? '',
                  getProductDescription: () => _generalInfoKey.currentState?.descriptionControllerList[0].text ?? '',

                ),

                AddAuctionProductSeoScreen(
                  key: _seoKey,
                  isLastTab: true,

                  getProductTitle: () => _generalInfoKey.currentState?.titleControllerList[0].text ?? '',
                  getProductDescription: () => _generalInfoKey.currentState?.descriptionControllerList[0].text ?? '',

                  initialMetaTitle: widget.auctionProduct?.seoInfo?.title ??  '',
                  initialMetaDescription: widget.auctionProduct?.seoInfo?.description ?? '',

                  initialMetaIndex: widget.auctionProduct?.seoInfo?.index,
                  initialMetaNoFollow: widget.auctionProduct?.seoInfo?.noFollow,
                  initialMetaNoImageIndex: widget.auctionProduct?.seoInfo?.noImageIndex,
                  initialMetaNoArchive: widget.auctionProduct?.seoInfo?.noArchive,
                  initialMetaNoSnippet: widget.auctionProduct?.seoInfo?.noSnippet,
                  initialMetaMaxSnippet: widget.auctionProduct?.seoInfo?.maxSnippet,
                  initialMetaMaxSnippetValue: widget.auctionProduct?.seoInfo?.maxSnippetValue,
                  initialMetaMaxVideoPreview: widget.auctionProduct?.seoInfo?.maxVideoPreview,
                  initialMetaMaxVideoPreviewValue: widget.auctionProduct?.seoInfo?.maxVideoPreviewValue,
                  initialMetaMaxImagePreview: widget.auctionProduct?.seoInfo?.maxImagePreview,
                  initialMetaMaxImagePreviewValue: widget.auctionProduct?.seoInfo?.maxImagePreviewValue,
                  initialMetaImage: (widget.auctionProduct?.seoInfo?.imageFullUrl?.path ?? '').isNotEmpty
                      ? widget.auctionProduct!.seoInfo!.imageFullUrl!.path
                      : widget.auctionProduct?.metaImageFullUrl?.path,
                   onNext: _onSubmit,
                ),



              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddProductTitleBar extends StatelessWidget {
  final TabController tabController;
  final List<Tab> tabs;

  const AddProductTitleBar({
    super.key,
    required this.tabController,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TabBar(
        labelPadding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        controller: tabController,
        tabs: tabs,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).primaryColor,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.zero,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(color: Theme.of(context).primaryColor),
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
