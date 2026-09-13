import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/paginated_list_view_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_product_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_product_model.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/auction_details_screen.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_action_sheet_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_card_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_card_shimmer_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_tab_bar_widget.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/addAuctionProduct/add_auction_product_tab_view.dart';
import 'package:sixvalley_vendor_app/features/shop/widgets/animated_floating_button_widget.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';

class AuctionRequestListScreen extends StatefulWidget {
  final bool? fromNotification;
  const AuctionRequestListScreen({super.key, this.fromNotification = false});

  @override
  State<AuctionRequestListScreen> createState() => _AuctionRequestListScreenState();
}

class _AuctionRequestListScreenState extends State<AuctionRequestListScreen> {
  int selectedTab = 0;
  final ScrollController _scrollController = ScrollController();

  final List<String> _statusKeys = ['pending', 'rejected'];

  @override
  void initState() {
    super.initState();
    _loadData(isReload: true, isUpdate: false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


  void _loadData({bool isReload = false, bool isUpdate = true }) {
    final controller = Provider.of<AuctionProductController>(context, listen: false);
    controller.getAuctionProductList(_statusKeys[selectedTab], 1, reload: isReload, isUpdate: isUpdate);
  }

  String _getTabLabel(int index) {
    switch (index) {
      case 0:
        return getTranslated('pending', context) ?? 'Pending';
      case 1:
        return getTranslated('rejected', context) ?? 'Rejected';
      default:
        return '';
    }
  }

  Future<void> _deleteAuctionProduct(int id) async {
    final controller = Provider.of<AuctionProductController>(context, listen: false);

    final bool isDeleted = await controller.deleteAuctionProduct(id);

    if (isDeleted) {
      if (mounted) {
        showCustomSnackBarWidget(
          getTranslated('auction_deleted_successfully', context) ?? 'Auction deleted successfully',
          context,
          isError: false,
          sanckBarType: SnackBarType.success,
        );
        _loadData(isReload: true);
      }
    } else {
      if (mounted) {
        showCustomSnackBarWidget(
          getTranslated('failed_to_delete_auction', context) ?? 'Failed to delete auction',
          context,
          isError: true,
          sanckBarType: SnackBarType.error,
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final configModel = Provider.of<SplashController>(context, listen: false).configModel;
    final bool canCreateAuction = configModel?.isAuctionFeatureEnabled == true && configModel?.activeAuctionForVendor == true;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if(widget.fromNotification!) {
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
          title: getTranslated('auction_request', context) ?? 'Auction Request',
          onBackPressed: () {
            if(widget.fromNotification!) {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => const DashboardScreen()), (route) => false);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),

        floatingActionButton: canCreateAuction ? FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: Theme.of(context).cardColor,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddAuctionProductTabView(fromPage: AddAuctionFromPage.auctionRequest)));
            },
            child: Image.asset(Images.addIcon, width: Dimensions.iconSizeExtraLarge)) : null,

        body: Column(
          children: [
            const SizedBox(height: Dimensions.paddingSize),

            Align(
              alignment: Alignment.centerLeft,
              child: Consumer<AuctionProductController>(
                builder: (context, controller, _) {
                  final counts = controller.auctionRequestCounts;
                  return AuctionTabBarWidget(
                    selectedIndex: selectedTab,
                    tabs: List.generate(_statusKeys.length, (i) => _getTabLabel(i)),
                    counts: counts == null ? null : [counts.pending, counts.rejected],
                    onTabChanged: (index) {
                      setState(() {
                        selectedTab = index;
                      });
                      _loadData(isReload: true);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: Dimensions.paddingSize),

            Expanded(
              child: Consumer<AuctionProductController>(
                builder: (context, controller, _) {
                  final bool isLoading = selectedTab == 0
                      ? controller.isPendingLoading
                      : controller.isRejectedLoading;

                  final AuctionProductListModel? model = selectedTab == 0
                      ? controller.pendingModel
                      : controller.rejectedModel;

                  if (isLoading || model == null || controller.isDeleting) {
                    return ListView.builder(
                      itemCount: 10,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return AuctionCardShimmerWidget(fromRequest: true);
                      },
                    );
                  }

                  final List<AuctionProduct> products = model.products ?? [];

                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.gavel_outlined,
                            size: 64,
                            color: Theme.of(context).hintColor.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),
                          Text(
                            getTranslated('no_auction_product_found', context) ?? 'No auction products found',
                            style: titilliumRegular.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),
                        ],
                      ),
                    );
                  }


                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadData(isReload: true);
                    },
                    child: SingleChildScrollView(
                      child: PaginatedListViewWidget(
                        scrollController: _scrollController,
                        totalSize: model.totalSize,
                        offset: model.offset,
                        onPaginate: (offset) async {
                          await controller.getAuctionProductList(
                            _statusKeys[selectedTab],
                            offset ?? 1,
                          );
                        },
                        itemView: ListView.builder(
                          controller: _scrollController,
                          itemCount: products.length,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final product = products[index];

                            return AuctionCardWidget(
                                imageUrl: product.thumbnailFullUrl?.path ?? '',
                                title: product.name ?? '',
                                auctionId: '${product.id ?? ''}',
                                duration: DateConverter.utcStringToAuctionDuration(product.startTime, product.endTime),
                                reason: selectedTab == 1 ? product.rejectedNote : null,
                                status: selectedTab == 1 ? AuctionStatus.rejected : AuctionStatus.scheduled,
                                startingPrice: product.startingPrice ?? 0,
                                minIncrement: product.minimumIncrementAmount,
                                maxDecrement: product.maximumDecrementAmount,
                                showDelete: product.approvalStatus == 'pending',
                                onMenuSelected: (action) {
                                  if (action == AuctionMenuAction.delete) {
                                    _showConfirmationDialog(product.id ?? 0, AuctionDialogType.delete);
                                  } else if (action == AuctionMenuAction.edit) {
                                    _showConfirmationDialog(product.id ?? 0, AuctionDialogType.edit, product: product);
                                  } else if (action == AuctionMenuAction.recreate) {
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => AddAuctionProductTabView(
                                        fromPage: AddAuctionFromPage.auctionRequest,
                                        isRelaunch: true,
                                        auctionProduct: product,
                                      ),
                                    ));
                                  } else if (action == AuctionMenuAction.view) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => AuctionDetailsScreen(fromNotification: false, auctionId: product.id ?? 0, auctionProduct: product),
                                        )
                                    );
                                  }
                                }
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(
      int auctionId, AuctionDialogType dialogType, {AuctionProduct? product}) async {
    final confirmed = await showAuctionDialog(context, dialogType);
    if (!mounted) return;
    if (confirmed == true) {
      if (dialogType == AuctionDialogType.delete) {
        _deleteAuctionProduct(auctionId);
      } else if (dialogType == AuctionDialogType.edit) {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AddAuctionProductTabView(fromPage: AddAuctionFromPage.auctionRequest, auctionProduct: product)));
      }
    }
  }

}