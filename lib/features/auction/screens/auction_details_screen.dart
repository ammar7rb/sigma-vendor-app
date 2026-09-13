import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/confirmation_dialog_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_dialog_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_product_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_product_details_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_product_model.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/addAuctionProduct/add_auction_product_tab_view.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/bidding_details_screen.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_action_sheet_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_button_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_duration_card_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_product_card_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_status_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_tab_bar_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_details_shimmer_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_timeline_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/info_section_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/note_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/product_seo_meta_data_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/product_video_card_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_product_details_widget.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';

class AuctionDetailsScreen extends StatefulWidget {
  final bool fromNotification;
  final int auctionId;
  final AuctionProduct? auctionProduct;
  static int? activeAuctionId;
  const AuctionDetailsScreen({super.key, this.fromNotification= false, required this.auctionId, this.auctionProduct});

  @override
  State<AuctionDetailsScreen> createState() => _AuctionDetailsScreenState();
}

class _AuctionDetailsScreenState extends State<AuctionDetailsScreen> {
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    AuctionDetailsScreen.activeAuctionId = widget.auctionId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuctionProductController>(context, listen: false).getAuctionProductDetails(widget.auctionId, reload: true, auctionStatus: widget.auctionProduct?.auctionStatus ?? '');
    });
  }

  @override
  void dispose() {
    AuctionDetailsScreen.activeAuctionId = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auctionController = Provider.of<AuctionProductController>(context);
    final detailsProduct = auctionController.auctionProductDetailsModel?.product;
    final String auctionIdText = '${detailsProduct?.id ?? widget.auctionProduct?.id ?? ''}';
    final bool isPurchaseComplete = AuctionStatus.fromString(detailsProduct?.auctionStatus ?? '') == AuctionStatus.purchaseComplete;
    final bool isUpcoming = AuctionStatus.fromString(detailsProduct?.auctionStatus ?? '') == AuctionStatus.upcoming;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if(widget.fromNotification) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (BuildContext context) => const DashboardScreen(),
          ), (route) => false);
        } else {
          if(!didPop) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: CustomAppBarWidget(
          title: selectedTab == 0
              ? (getTranslated('auction_details', context) ?? "")
              : '${getTranslated('auction_id', context)} #$auctionIdText',
          onBackPressed: () {
            if(widget.fromNotification) {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const DashboardScreen()), (route) => false);
            } else {
              Navigator.of(context).pop();
            }
          },
          isAction: isPurchaseComplete || isUpcoming,
          isFilter: isPurchaseComplete || isUpcoming,
          widget: isPurchaseComplete
            ? GestureDetector(
              onTap: auctionController.isInvoiceLoading || detailsProduct?.id == null
                ? null : () => auctionController.getAuctionInvoice(detailsProduct!.id!),
              child: auctionController.isInvoiceLoading
                ? const SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2))
                : const CustomAssetImageWidget(Images.downloadInvoice, height: 30, width: 30))
            : isUpcoming
              ? _buildToggleStatusWidget(context, auctionController, detailsProduct)
              : null),

          bottomNavigationBar: selectedTab == 0 && auctionController.auctionProductDetailsModel?.product != null
            && (AuctionStatus.fromString(detailsProduct?.approvalStatus ?? '') == AuctionStatus.pending
               || AuctionStatus.fromString(detailsProduct?.approvalStatus ?? '') == AuctionStatus.rejected
               || AuctionStatus.fromString(detailsProduct?.auctionStatus ?? '').isCanceled)
          ? Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSize),
            height: 65,
            child: AuctionStatus.fromString(detailsProduct?.auctionStatus ?? '') == AuctionStatus.unsold
              ? ActionButtonWidget(
                  isDeleting: auctionController.isDeleting,
                  onDelete: detailsProduct == null ? null : () => _showDeleteConfirmationDialog(detailsProduct.id!),
                  onRelaunch: detailsProduct == null ? null : () => _navigateToRelaunch(detailsProduct),
                )
              : AuctionStatus.fromString(detailsProduct?.auctionStatus ?? '').isCanceled
                ? ActionButtonWidget(
                    isDeleting: auctionController.isDeleting,
                    onDelete: detailsProduct == null ? null : () => _showDeleteConfirmationDialog(detailsProduct.id!),
                    onEdit: detailsProduct == null ? null : () => _navigateToEdit(detailsProduct),
                    editLabel: getTranslated('edit', context),
                  )
                : ActionButtonWidget(
                    isDeleting: auctionController.isDeleting,
                    showDelete: AuctionStatus.fromString(detailsProduct?.approvalStatus ?? '') != AuctionStatus.pending,
                    onDelete: detailsProduct == null ? null : () => _showDeleteConfirmationDialog(detailsProduct.id!),
                    onEdit: detailsProduct == null ? null : () => _navigateToEdit(detailsProduct),
                    editLabel: AuctionStatus.fromString(detailsProduct?.approvalStatus ?? '') == AuctionStatus.pending
                        ? getTranslated('edit', context)
                        : null,
                  ),
          ) : const SizedBox(),


        body: RefreshIndicator(
          onRefresh: () async {
            final controller = Provider.of<AuctionProductController>(context, listen: false);
            await controller.getAuctionProductDetails(
              widget.auctionId,
              reload: true, auctionStatus: widget.auctionProduct?.auctionStatus ?? '',
            );
            if (selectedTab == 1) {
              final productId = controller.auctionProductDetailsModel?.product?.id;
              if (productId != null) {
                controller.getBidList(productId, 1);
              }
            }
          },
          child: Column(
            children: [
              if(AuctionStatus.fromString(detailsProduct?.auctionStatus ?? '') == AuctionStatus.live
              || AuctionStatus.fromString(detailsProduct?.auctionStatus ?? '') == AuctionStatus.complete
              || AuctionStatus.fromString(detailsProduct?.auctionStatus ?? '') == AuctionStatus.readyToClaim
              || AuctionStatus.fromString(detailsProduct?.deliveryStatus ?? '') == AuctionStatus.readyToDelivery
              || AuctionStatus.fromString(detailsProduct?.auctionStatus ?? '') == AuctionStatus.purchaseComplete
              || AuctionStatus.fromString(detailsProduct?.auctionStatus ?? '') == AuctionStatus.unsold
              || AuctionStatus.fromString(detailsProduct?.auctionStatus ?? '') == AuctionStatus.delivered
              || AuctionStatus.fromString(detailsProduct?.auctionStatus ?? '') == AuctionStatus.onTheWay
              )...[
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AuctionTabBarWidget(
                    selectedIndex: selectedTab,
                    tabs: [
                      getTranslated('product_details', context) ?? "",
                      getTranslated('bidding_details', context) ?? "",
                    ],
                    onTabChanged: (index) {
                      setState(() {
                        selectedTab = index;
                      });
                    },
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
              ],

              Expanded(
                child: selectedTab == 0
                  ? (auctionController.isDetailsLoading
                    ? const AuctionDetailsProductShimmer()
                    : ProductDetailsTab(detailsProduct: detailsProduct))
                    : BiddingDetailsScreen(
                        fromNotification: widget.fromNotification,
                        detailsProduct: detailsProduct,
                        auctionProduct: widget.auctionProduct,
                      ),

              ),
            ],
          ),
        ),

      )
    );
  }

  void _showDeleteConfirmationDialog(int auctionId) {
    showAnimatedDialogWidget(
      context,
      ConfirmationDialogWidget(
        icon: Images.delete,
        title: getTranslated('confirm_delete', context) ?? '',
        description: getTranslated('are_you_sure_you_want_to_delete', context) ?? '',
        onYesPressed: () {
          Navigator.pop(context);
          _deleteAuction(auctionId);

        },
      ),
    );
  }

  Future<void> _deleteAuction(int id) async {
    final controller = Provider.of<AuctionProductController>(context, listen: false);
    final bool success = await controller.deleteAuctionProduct(id);
    if (!mounted) return;
    if (success) {
      controller.getAuctionList(auctionStatus: 'all', search: '', offset: 1, reload: true, tabIndex: 0);
      showCustomSnackBarWidget(
        getTranslated('auction_deleted_successfully', context) ?? '',
        context,
        isError: false,
        sanckBarType: SnackBarType.success,
      );
      Navigator.of(context).pop(true);
    } else {
      showCustomSnackBarWidget(
        getTranslated('failed_t_delete_auction', context) ?? '',
        context,
        isError: true,
        sanckBarType: SnackBarType.error,
      );
    }
  }

  void _navigateToEdit(AuctionDetailsProduct detailsProduct) {
    final auctionProduct = widget.auctionProduct;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AddAuctionProductTabView(
        fromPage: AddAuctionFromPage.auctionList,
        auctionProduct: auctionProduct,
      ),
    ));
  }

  void _navigateToRelaunch(AuctionDetailsProduct detailsProduct) {
    final auctionProduct = widget.auctionProduct;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AddAuctionProductTabView(
        fromPage: AddAuctionFromPage.auctionList,
        auctionProduct: auctionProduct,
        isRelaunch: true,
      ),
    ));
  }

  Widget _buildToggleStatusWidget(
    BuildContext context,
    AuctionProductController controller,
    AuctionDetailsProduct? product,
  ) {
    final isActive = product?.status == '1';
    return GestureDetector(
      onTap: product?.id == null ? null : () async {
        final auctionController = Provider.of<AuctionProductController>(context, listen: false);
        final confirmed = await showAuctionDialog(
          context, isActive ? AuctionDialogType.turnOff : AuctionDialogType.turnOn,
        );
        if (confirmed != true || !mounted) return;
        final ok = await auctionController.toggleAuctionStatus(product!.id!);
        if (ok && mounted) {
          auctionController.getAuctionProductDetails(
            widget.auctionId,
            reload: true,
            auctionStatus: widget.auctionProduct?.auctionStatus ?? '',
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeExtraSmall),
        child: AbsorbPointer(
          child: FlutterSwitch(
            activeColor: Theme.of(context).primaryColor,
            width: 40, height: 22, toggleSize: 18, padding: 2,
            value: isActive,
            onToggle: (_) {},
          ),
        ),
      ),
    );
  }
}


class ProductDetailsTab extends StatelessWidget {
  final AuctionDetailsProduct? detailsProduct;

  const ProductDetailsTab({super.key, this.detailsProduct});

  DateTime _safeDate(String? raw, DateTime fallback) {
    final parsed = DateTime.tryParse(raw ?? '');
    return parsed?.toLocal() ?? fallback;
  }

  String _money(double? amount, String fallback) {
    if (amount == null) return fallback;
    return '\$${amount.toStringAsFixed(2)}';
  }

  String _getLocalizedItemCondition(BuildContext context, String? condition) {
    const conditionMap = {
      'NEW': 'item_condition_new',
      'LIKE_NEW': 'item_condition_like_new',
      'LIKE NEW': 'item_condition_like_new',
      'EXCELLENT': 'item_condition_excellent',
      'GOOD': 'item_condition_good',
      'FAIR': 'item_condition_fair',
      'New': 'item_condition_new',
      'Like_New': 'item_condition_like_new',
      'Excellent': 'item_condition_excellent',
      'Good': 'item_condition_good',
      'Fair': 'item_condition_fair',
    };
    final key = conditionMap[condition];
    return (key != null ? getTranslated(key, context) : null) ?? condition ?? '';
  }

  List<String> _imageUrls() {
    final List<String> urls = [];

    final thumb = detailsProduct?.thumbnailFullUrl?.path;
    if (thumb != null && thumb.isNotEmpty) urls.add(thumb);

    final detailsImages = detailsProduct?.imagesFullUrl ?? [];
    for (final image in detailsImages) {
      final path = image.path;
      if (path != null && path.isNotEmpty) {
        urls.add(path);
      }
    }

    if (urls.isEmpty) {
      return const [Images.aboutUs];
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {

    final String statusText = (detailsProduct?.auctionStatus ?? detailsProduct?.approvalStatus ??  detailsProduct?.status ?? 'pending').toString();
    final AuctionStatus statusEnum = AuctionStatus.fromString(statusText);

    final List<String> taxList = (detailsProduct?.taxVats ?? [])
        .where((tv) => tv.tax != null)
        .map((tv) => '${tv.tax!.name ?? ''} (${tv.tax!.taxRate?.toStringAsFixed(0) ?? '0'}%)')
        .toList();

    final List<String> imageUrls = _imageUrls();
    final String description = detailsProduct?.details ?? 'No description';

    final splashController = Provider.of<SplashController>(context, listen: false);
    final double entryFeePercentage = splashController.configModel?.auctionEntryFeeAmount ?? 0.0;
    final double entryFee = (entryFeePercentage / 100) * (detailsProduct?.startingPrice ?? 0);

    return SingleChildScrollView(
      child: Column(
        children: [

          AuctionStatusWidget(
            auctionId: '${detailsProduct?.id ?? ''}',
            status: statusEnum,
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          AuctionProductCardWidget(
            title: detailsProduct?.name ?? '',
            startingPrice: detailsProduct?.startingPrice ?? 0,
            entryFee: entryFee,
            imageUrls: imageUrls,
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          if(detailsProduct?.rejectedNote != null  && detailsProduct!.rejectedNote!.isNotEmpty)...[
            NoteWidget(note: detailsProduct?.rejectedNote ?? ''),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ],

          if(detailsProduct?.auctionDetails?.endTime != null && (DateTime.tryParse(detailsProduct!.auctionDetails!.endTime!)?.toLocal().isAfter(DateTime.now()) ?? false))...[
            AuctionDurationCardWidget(
              startDate: _safeDate(detailsProduct?.auctionDetails?.startTime, DateTime.now()),
              endDate: _safeDate(detailsProduct?.auctionDetails?.endTime, DateTime.now()),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ],


          AuctionProductDetailsWidget(
            title: detailsProduct?.name ?? '',
            description: description,
            videoProvider: detailsProduct?.videoProvider,
            videoUrl: detailsProduct?.youtubeVideoUrl,
            customVideoUrl: detailsProduct?.customVideoUrlFullUrl?.path,
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          InfoSectionWidget(
            title: getTranslated('product_info', context) ?? "",
            items: [
              {
                "label": getTranslated('brand', context) ?? "",
                "value": detailsProduct?.brand?.name ?? "Francisco",
              },
              {
                "label": getTranslated('category', context) ?? "",
                "value": detailsProduct?.category?.name ?? "Women's Fashion",
              },

              if(detailsProduct?.itemCondition != null && detailsProduct!.itemCondition!.isNotEmpty)
              {
                "label": getTranslated('item_condition', context) ?? "",
                "value": _getLocalizedItemCondition(context, detailsProduct?.itemCondition),
              },
              {
                "label": getTranslated('starting_price', context) ?? "",
                "value": _money(detailsProduct?.startingPrice, "\$22.00"),
              },
              {
                "label": getTranslated('minimum_increment', context) ?? "",
                "value": _money(detailsProduct?.minimumIncrementAmount, "\$5.00"),
              },
              {
                "label": getTranslated('maximum_decrement', context) ?? "",
                "value": _money(detailsProduct?.maximumDecrementAmount, "\$10.00"),
              },
            ],
            listValueItems: taxList.isNotEmpty
              ? [(label: getTranslated('tax', context) ?? '', values: taxList)]
              : const [],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          InfoSectionWidget(
            title: getTranslated('shipping_charge_return_policy', context) ?? "",
            items: [
              {
                "label": getTranslated('shipping_charge', context) ?? "",
                "value": _money(detailsProduct?.shippingFee, "Francisco"),
              },
              {
                "label": getTranslated('return_policy', context) ?? "",
                "value": detailsProduct?.returnPolicy ?? "Return accepted for 7 Days",
              },
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          if((detailsProduct?.metaImageFullUrl?.path != null && detailsProduct!.metaImageFullUrl!.path!.isNotEmpty))...[
            ProductSeoMetaDataWidget(
              seoTitle: detailsProduct?.seoInfo?.title ?? '',
              metaDescription: detailsProduct?.seoInfo?.description ?? '',
              imageUrl: detailsProduct?.metaImageFullUrl?.path ?? '',
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ],


          if(detailsProduct?.videoUrl != null && detailsProduct!.videoUrl!.isNotEmpty)...[
            ProductVideoCardWidget(
              linkLabel: 'youtube_video_link',
              videoUrl: detailsProduct?.videoUrl ?? '',
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
          ],

          AuctionTimelineWidget(
            entries: [
              if(detailsProduct?.createdAt != null)
              AuctionTimelineEntry(
                label: 'auction_created_at',
                dateTime: DateConverter.formatDateWithCommaAnd24Hour(_safeDate(detailsProduct?.createdAt, DateTime.now())),
              ),

              if(detailsProduct?.approvedAt != null)
              AuctionTimelineEntry(
                label: 'auction_approved_at',
                dateTime: DateConverter.formatDateWithCommaAnd24Hour(_safeDate(detailsProduct?.approvedAt, DateTime.now())),
              ),

              if(detailsProduct?.auctionDetails != null && detailsProduct?.updatedAt != null)
                AuctionTimelineEntry(
                  label: 'auction_modified_at',
                  dateTime: DateConverter.formatDateWithCommaAnd24Hour(_safeDate(detailsProduct?.updatedAt, DateTime.now())),
                ),


            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),


        ],
      ),
    );
  }
}
