import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/add_auction_product_contoller.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/add_auction_product_media_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_ai_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/product_seo_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/seo_setup_widget.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AddAuctionProductSeoScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final bool isLastTab;


  final String Function()? getProductTitle;
  final String Function()? getProductDescription;

  final String? initialMetaTitle;
  final String? initialMetaDescription;
  final String? initialMetaIndex;
  final String? initialMetaNoFollow;
  final String? initialMetaNoArchive;
  final String? initialMetaNoImageIndex;
  final String? initialMetaNoSnippet;
  final String? initialMetaMaxSnippet;
  final String? initialMetaMaxSnippetValue;
  final String? initialMetaMaxVideoPreview;
  final String? initialMetaMaxVideoPreviewValue;
  final String? initialMetaMaxImagePreview;
  final String? initialMetaMaxImagePreviewValue;
  final String? initialMetaImage;

  const AddAuctionProductSeoScreen({
    super.key,
    this.onNext,
    this.isLastTab = false,
    this.getProductTitle,
    this.getProductDescription,
    this.initialMetaTitle,
    this.initialMetaDescription,
    this.initialMetaIndex,
    this.initialMetaNoFollow,
    this.initialMetaNoArchive,
    this.initialMetaNoImageIndex,
    this.initialMetaNoSnippet,
    this.initialMetaMaxSnippet,
    this.initialMetaMaxSnippetValue,
    this.initialMetaMaxVideoPreview,
    this.initialMetaMaxVideoPreviewValue,
    this.initialMetaMaxImagePreview,
    this.initialMetaMaxImagePreviewValue,
    this.initialMetaImage,
  });

  @override
  AddAuctionProductSeoScreenState createState() => AddAuctionProductSeoScreenState();
}

class AddAuctionProductSeoScreenState extends State<AddAuctionProductSeoScreen> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController? _tabController;
  final TextEditingController metaTitleController = TextEditingController();
  final TextEditingController metaDescriptionController = TextEditingController();

  // New dynamic meta fields
  String? metaIndex = 'index';
  bool metaNoFollow = false;
  bool metaNoArchive = false;
  bool metaNoImageIndex = false;
  bool metaNoSnippet = false;

  bool metaMaxSnippet = false;
  final TextEditingController metaMaxSnippetValueController = TextEditingController();

  bool metaMaxVideoPreview = false;
  final TextEditingController metaMaxVideoPreviewValueController = TextEditingController();

  bool metaMaxImagePreview = false;
  String metaMaxImagePreviewValue = '2';

  @override
  void initState() {
    super.initState();

    final languages = Provider.of<SplashController>(context, listen: false).configModel?.languageList ?? [];
    _tabController = TabController(
      length: languages.isNotEmpty ? languages.length : 1,
      initialIndex: 0,
      vsync: this,
    );
    _loadData();

    // Sync controllers to AddAuctionProductController so parent can read values reliably
    final auctionController = Provider.of<AddAuctionProductController>(context, listen: false);

    // Prefill initial meta values if passed (title/description)
    if (widget.initialMetaTitle != null && widget.initialMetaTitle!.isNotEmpty) {
      metaTitleController.text = widget.initialMetaTitle!;
      auctionController.updateSeoFields(metaTitle: widget.initialMetaTitle);
    }
    if (widget.initialMetaDescription != null && widget.initialMetaDescription!.isNotEmpty) {
      metaDescriptionController.text = widget.initialMetaDescription!;
      auctionController.updateSeoFields(metaDescription: widget.initialMetaDescription);
    }

    // Prefill dynamic meta values from constructor if provided
    if (widget.initialMetaIndex != null) {
      metaIndex = widget.initialMetaIndex;
      auctionController.updateSeoFields(metaIndex: widget.initialMetaIndex);
    }

    if (widget.initialMetaNoFollow != null) {
      // Accept 'nofollow', '1', or 'true' as indicators the flag is active
      metaNoFollow = widget.initialMetaNoFollow == 'nofollow' || widget.initialMetaNoFollow == '1' || widget.initialMetaNoFollow?.toLowerCase() == 'true';
      // Normalize to 'nofollow' when active, otherwise '0'
      auctionController.updateSeoFields(metaNoFollow: metaNoFollow ? 'nofollow' : '0');
    }

    if (widget.initialMetaNoArchive != null) {
      // Accept 'noarchive', '1', or 'true' as indicators the flag is active
      metaNoArchive = widget.initialMetaNoArchive == '1' || widget.initialMetaNoArchive == 'noarchive' || widget.initialMetaNoArchive?.toLowerCase() == 'true';
      // Normalize to '1' when active, otherwise '0'
      auctionController.updateSeoFields(metaNoArchive: metaNoArchive ? '1' : '0');
    }

    if (widget.initialMetaNoImageIndex != null) {
      // Accept 'noimageindex', '1', or 'true' as active
      metaNoImageIndex = widget.initialMetaNoImageIndex == '1' || widget.initialMetaNoImageIndex == 'noimageindex' || widget.initialMetaNoImageIndex?.toLowerCase() == 'true';
      auctionController.updateSeoFields(metaNoImageIndex: metaNoImageIndex ? '1' : '0');
    }

    if (widget.initialMetaNoSnippet != null) {
      // Accept 'nosnippet', '1', or 'true' as active
      metaNoSnippet = widget.initialMetaNoSnippet == '1' || widget.initialMetaNoSnippet == 'nosnippet' || widget.initialMetaNoSnippet?.toLowerCase() == 'true';
      auctionController.updateSeoFields(metaNoSnippet: metaNoSnippet ? '1' : '0');
    }

    if (widget.initialMetaMaxSnippet != null) {
      metaMaxSnippet = widget.initialMetaMaxSnippet == '1' || widget.initialMetaMaxSnippet?.toLowerCase() == 'true';
      auctionController.updateSeoFields(metaMaxSnippet: metaMaxSnippet ? '1' : '0');
    }

    if (widget.initialMetaMaxSnippetValue != null) {
      metaMaxSnippetValueController.text = widget.initialMetaMaxSnippetValue!;
      auctionController.updateSeoFields(metaMaxSnippetValue: widget.initialMetaMaxSnippetValue);
    }

    if (widget.initialMetaMaxVideoPreview != null) {
      metaMaxVideoPreview = widget.initialMetaMaxVideoPreview == '1' || widget.initialMetaMaxVideoPreview?.toLowerCase() == 'true';
      auctionController.updateSeoFields(metaMaxVideoPreview: metaMaxVideoPreview ? '1' : '0');
    }

    if (widget.initialMetaMaxVideoPreviewValue != null) {
      metaMaxVideoPreviewValueController.text = widget.initialMetaMaxVideoPreviewValue!;
      auctionController.updateSeoFields(metaMaxVideoPreviewValue: widget.initialMetaMaxVideoPreviewValue);
    }

    if (widget.initialMetaMaxImagePreview != null) {
      metaMaxImagePreview = widget.initialMetaMaxImagePreview == '1' || widget.initialMetaMaxImagePreview?.toLowerCase() == 'true';
      auctionController.updateSeoFields(metaMaxImagePreview: metaMaxImagePreview ? '1' : '0');
    }

    if (widget.initialMetaMaxImagePreviewValue != null) {
      final stored = widget.initialMetaMaxImagePreviewValue ?? '';
      metaMaxImagePreviewValue = ['0', '1', '2'].contains(stored) ? stored : '2';
      auctionController.updateSeoFields(metaMaxImagePreviewValue: metaMaxImagePreviewValue);
    }

    if (widget.initialMetaImage != null) {
      // We don't directly set any image widget here (mediaController handles files), but forward the existing image url to the controller
      auctionController.updateSeoFields(metaImage: widget.initialMetaImage);
    }

    // Listeners for title/description and value controllers
    metaTitleController.addListener(() {
      auctionController.updateSeoFields(metaTitle: metaTitleController.text);
    });
    metaDescriptionController.addListener(() {
      auctionController.updateSeoFields(metaDescription: metaDescriptionController.text);
    });
    metaMaxSnippetValueController.addListener(() {
      auctionController.updateSeoFields(metaMaxSnippetValue: metaMaxSnippetValueController.text);
    });
    metaMaxVideoPreviewValueController.addListener(() {
      auctionController.updateSeoFields(metaMaxVideoPreviewValue: metaMaxVideoPreviewValueController.text);
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    metaTitleController.dispose();
    metaDescriptionController.dispose();
    metaMaxSnippetValueController.dispose();
    metaMaxVideoPreviewValueController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;


  Future<void> _loadData() async {
    final aiController = Provider.of<AuctionAiController>(context, listen: false);

    final title = widget.getProductTitle?.call() ?? '';
    final description = widget.getProductDescription?.call() ?? '';

    if (aiController.requestTypeImage) {
      await aiController.generateMetaSeoSetup(
        title: title,
        description: description,
        seoTitleController: metaTitleController,
        seoDescriptionController: metaDescriptionController,
        formInit: true,
      );
      _applyAiSeoFields(aiController);
    }
    aiController.setRequestType(false, willUpdate: false);
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    final mediaController = Provider.of<AddAuctionProductMediaController>(context);
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

                      ProductSeoWidget(
                        nameController: metaTitleController,
                        descriptionController: metaDescriptionController,
                        image: mediaController.metaImageFile,
                        existingImageUrl: mediaController.existingMetaImageUrl,
                        onImagePick: mediaController.pickMetaImage,
                        onImageRemove: mediaController.removeMetaImage,
                        onRemoveExistingImage: mediaController.clearExistingMetaImage,
                        isAiGenerating: aiController.metaSeoLoading,
                        onAiTap: aiEnabled ? _onSeoAiTap : null,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      SeoSetupWidget(
                        onAiTap: aiEnabled ? _onSeoAiTap : null,
                        isAiGenerating: aiController.metaSeoLoading,

                        // pass dynamic values and callbacks
                        metaIndex: metaIndex,
                        onMetaIndexChanged: (val) {
                          setState(() => metaIndex = val);
                          Provider.of<AddAuctionProductController>(context, listen: false).updateSeoFields(metaIndex: val);
                        },
                        metaNoFollow: metaNoFollow,
                        onMetaNoFollowChanged: (val) {
                          setState(() => metaNoFollow = val == true);
                          Provider.of<AddAuctionProductController>(context, listen: false).updateSeoFields(metaNoFollow: val == true ? 'nofollow' : '0');
                        },
                        metaNoArchive: metaNoArchive,
                        onMetaNoArchiveChanged: (val) {
                          setState(() => metaNoArchive = val == true);
                          Provider.of<AddAuctionProductController>(context, listen: false).updateSeoFields(metaNoArchive: val == true ? '1' : '0');
                        },
                        metaNoImageIndex: metaNoImageIndex,
                        onMetaNoImageIndexChanged: (val) {
                          setState(() => metaNoImageIndex = val == true);
                          Provider.of<AddAuctionProductController>(context, listen: false).updateSeoFields(metaNoImageIndex: val == true ? '1' : '0');
                        },
                        metaNoSnippet: metaNoSnippet,
                        onMetaNoSnippetChanged: (val) {
                          setState(() => metaNoSnippet = val == true);
                          Provider.of<AddAuctionProductController>(context, listen: false).updateSeoFields(metaNoSnippet: val == true ? '1' : '0');
                        },

                        metaMaxSnippet: metaMaxSnippet,
                        onMetaMaxSnippetChanged: (val) {
                          setState(() => metaMaxSnippet = val);
                          Provider.of<AddAuctionProductController>(context, listen: false).updateSeoFields(metaMaxSnippet: val ? '1' : '0');
                        },
                        metaMaxSnippetValueController: metaMaxSnippetValueController,

                        metaMaxVideoPreview: metaMaxVideoPreview,
                        onMetaMaxVideoPreviewChanged: (val) {
                          setState(() => metaMaxVideoPreview = val);
                          Provider.of<AddAuctionProductController>(context, listen: false).updateSeoFields(metaMaxVideoPreview: val ? '1' : '0');
                        },
                        metaMaxVideoPreviewValueController: metaMaxVideoPreviewValueController,

                        metaMaxImagePreview: metaMaxImagePreview,
                        onMetaMaxImagePreviewChanged: (val) {
                          setState(() => metaMaxImagePreview = val);
                          Provider.of<AddAuctionProductController>(context, listen: false).updateSeoFields(metaMaxImagePreview: val ? '1' : '0');
                        },
                        metaMaxImagePreviewValue: metaMaxImagePreviewValue,
                        onMetaMaxImagePreviewValueChanged: (val) {
                          if (val != null) {
                            setState(() => metaMaxImagePreviewValue = val);
                            Provider.of<AddAuctionProductController>(context, listen: false).updateSeoFields(metaMaxImagePreviewValue: val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              Consumer2<ThemeController, AddAuctionProductController>(
                builder: (context, themeController, auctionController, _) {
                  return Container(
                    padding:
                    const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[
                          themeController.darkTheme ? 800 : 200]!,
                          spreadRadius: 0.5,
                          blurRadius: 0.3,
                        ),
                      ],
                    ),
                    child: aiController.addProductMetaScreenLoading
                        ? Container(
                      width: double.infinity,
                      height: 50,
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.30),
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              getTranslated('ai_is_generating_product_details', context) ?? 'AI is generating product details…',
                              style: robotoMedium.copyWith(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(
                              width: Dimensions.paddingSizeExtraSmall),
                          Shimmer.fromColors(
                            baseColor: Theme.of(context).hintColor.withValues(alpha: 0.18),
                            highlightColor: Theme.of(context).hintColor.withValues(alpha: 0.06),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                Text(
                                  getTranslated('generating', context) ?? 'Generating…',
                                  style: robotoBold.copyWith(color: Theme.of(context).primaryColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ) : SizedBox(
                      height: 50,
                      child: InkWell(
                        onTap: auctionController.isLoading ? null : widget.onNext,
                        child: Container(
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            color: auctionController.isLoading
                                ? Theme.of(context).primaryColor.withValues(alpha: 0.6)
                                : Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(
                                Dimensions.paddingSizeExtraSmall),
                          ),
                          child: Center(
                            child: auctionController.isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).cardColor),
                                    ),
                                  )
                                : Text(
                                    widget.isLastTab ? getTranslated('submit', context) ?? 'Submit' : getTranslated('next', context) ?? 'Next',
                                    style: titilliumBold.copyWith(color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _applyAiSeoFields(AuctionAiController aiController) {
    final seoData = aiController.metaSeoInfo?.data?.data;
    if (seoData == null) return;

    final auctionController = Provider.of<AddAuctionProductController>(context, listen: false);

    setState(() {
      if (seoData.metaIndex != null && seoData.metaIndex!.isNotEmpty) {
        metaIndex = seoData.metaIndex;
        auctionController.updateSeoFields(metaIndex: seoData.metaIndex);
      }

      if (seoData.metaNoFollow != null) {
        metaNoFollow = seoData.metaNoFollow == 1;
        auctionController.updateSeoFields(metaNoFollow: metaNoFollow ? 'nofollow' : '0');
      }

      if (seoData.metaNoArchive != null) {
        metaNoArchive = seoData.metaNoArchive == 1;
        auctionController.updateSeoFields(metaNoArchive: metaNoArchive ? '1' : '0');
      }

      if (seoData.metaNoImageIndex != null) {
        metaNoImageIndex = seoData.metaNoImageIndex == 1;
        auctionController.updateSeoFields(metaNoImageIndex: metaNoImageIndex ? '1' : '0');
      }

      if (seoData.metaNoSnippet != null) {
        metaNoSnippet = seoData.metaNoSnippet == 1;
        auctionController.updateSeoFields(metaNoSnippet: metaNoSnippet ? '1' : '0');
      }

      if (seoData.metaMaxSnippet != null) {
        metaMaxSnippet = seoData.metaMaxSnippet == 1;
        auctionController.updateSeoFields(metaMaxSnippet: metaMaxSnippet ? '1' : '0');
      }

      if (seoData.metaMaxSnippetValue != null) {
        metaMaxSnippetValueController.text = seoData.metaMaxSnippetValue.toString();
        auctionController.updateSeoFields(metaMaxSnippetValue: seoData.metaMaxSnippetValue.toString());
      }

      if (seoData.metaMaxVideoPreview != null) {
        metaMaxVideoPreview = seoData.metaMaxVideoPreview == 1;
        auctionController.updateSeoFields(metaMaxVideoPreview: metaMaxVideoPreview ? '1' : '0');
      }

      if (seoData.metaMaxVideoPreviewValue != null) {
        metaMaxVideoPreviewValueController.text = seoData.metaMaxVideoPreviewValue.toString();
        auctionController.updateSeoFields(metaMaxVideoPreviewValue: seoData.metaMaxVideoPreviewValue.toString());
      }

      if (seoData.metaMaxImagePreview != null) {
        metaMaxImagePreview = seoData.metaMaxImagePreview == 1;
        auctionController.updateSeoFields(metaMaxImagePreview: metaMaxImagePreview ? '1' : '0');
      }

      if (seoData.metaMaxImagePreviewValue != null && seoData.metaMaxImagePreviewValue!.isNotEmpty) {
        final aiVal = seoData.metaMaxImagePreviewValue!;
        metaMaxImagePreviewValue = ['0', '1', '2'].contains(aiVal) ? aiVal : '2';
        auctionController.updateSeoFields(metaMaxImagePreviewValue: metaMaxImagePreviewValue);
      }
    });
  }

  Future<void> _onSeoAiTap() async {
    final title = widget.getProductTitle?.call() ?? '';
    final description = widget.getProductDescription?.call() ?? '';

    if (title.isEmpty) {
      showCustomSnackBarWidget(getTranslated('product_name_required', context) ?? 'Please enter a product name first', context);
      return;
    }
    if (description.isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_input_all_des', context) ?? 'Please enter a product description first', context);
      return;
    }

    final aiController = Provider.of<AuctionAiController>(context, listen: false);
    await aiController.generateMetaSeoSetup(
      title: title,
      description: description,
      seoTitleController: metaTitleController,
      seoDescriptionController: metaDescriptionController,
    );
    _applyAiSeoFields(aiController);
  }

}
