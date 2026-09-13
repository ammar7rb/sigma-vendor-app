import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/confirmation_dialog_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_dialog_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_search_field_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/filter_icon_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/paginated_list_view_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_product_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_product_model.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/addAuctionProduct/add_auction_product_tab_view.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/auction_details_screen.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_card_shimmer_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_card_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_filter_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_action_sheet_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_tab_bar_widget.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_vendor_app/features/shop/widgets/animated_floating_button_widget.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AuctionListScreen extends StatefulWidget {
  final bool fromNotification;
  const AuctionListScreen({super.key, this.fromNotification = false});

  @override
  State<AuctionListScreen> createState() => _AuctionListScreenState();
}

class _AuctionListScreenState extends State<AuctionListScreen> {
  int _selectedTab = 0;
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const List<String> _auctionStatusKeys = [
    '',               // 0 - All
    'upcoming',       // 1 - Upcoming
    'live',           // 2 - Live
    'ready_to_claim', // 3 - Ready to Claim
    'purchase_complete', // 6 - Purchase Complete
    'ready_to_delivery', // 4 - Ready to Delivery
    'on_the_way',     // 5 - On the Way
    'delivered',     // 5 - On the Way
    'unsold',        // 7 - Unsold
    'canceled'       // 8 - Canceled
  ];

  @override
  void initState() {
    super.initState();
    _loadData(isReload: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData({bool isReload = false}) {
    final controller = Provider.of<AuctionProductController>(context, listen: false);
    controller.getAuctionList(
      tabIndex: _selectedTab,
      auctionStatus: _auctionStatusKeys[_selectedTab],
      search: _searchController.text.trim(),
      offset: 1,
      reload: isReload,
      isUpdate: false,
    );
  }

  void _triggerSearch() {
    _loadData(isReload: true);
    setState(() => _isSearchActive = true);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _isSearchActive = false);
    _loadData(isReload: true);
  }

  String _getTabLabel(int index) {
    switch (index) {
      case 0: return getTranslated('all', context) ?? 'All';
      case 1: return getTranslated('upcoming', context) ?? 'Upcoming';
      case 2: return getTranslated('live', context) ?? 'Live';
      case 3: return getTranslated('ready_to_claim', context) ?? 'Ready to Claim';
      case 4: return getTranslated('purchase_complete', context) ?? 'Purchase Complete';
      case 5: return getTranslated('ready_to_delivery', context) ?? 'Ready to Delivery';
      case 6: return getTranslated('on_the_way', context) ?? 'On the Way';
      case 7: return getTranslated('delivered', context) ?? 'Delivered';
      case 8: return getTranslated('unsold', context) ?? 'Unsold';
      case 9: return getTranslated('canceled', context) ?? 'Canceled';
      default: return '';
    }
  }

  int get _filterTabIndex => _selectedTab;

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AuctionFilterWidget(
        tabIndex: _filterTabIndex,
        onApply: () => _loadData(isReload: true),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int auctionId) {
    showAnimatedDialogWidget(
      context,
      ConfirmationDialogWidget(
        icon: Images.delete,
        title: getTranslated('confirm_delete', context) ?? '',
        description: getTranslated('are_you_sure_you_want_to_delete', context) ?? '',
        onYesPressed: () {
          Navigator.pop(context);
          _deleteAuctionProduct(auctionId);
        },
      ),
    );
  }

  Future<void> _deleteAuctionProduct(int id) async {
    final controller = Provider.of<AuctionProductController>(context, listen: false);
    final bool isDeleted = await controller.deleteAuctionProduct(id);

    if (isDeleted) {
      if (mounted) {
        showCustomSnackBarWidget(getTranslated('auction_deleted_successfully', context) ?? '', context, isError: false, sanckBarType: SnackBarType.success);
        _loadData(isReload: true);
      }
    } else {
      if (mounted) {
        showCustomSnackBarWidget(getTranslated('failed_t_delete_auction', context) ?? '', context, isError: true, sanckBarType: SnackBarType.error);
      }
    }
  }

  void _showCancelConfirmationDialog(int auctionId) async {
    final confirmed = await showAuctionDialog(context, AuctionDialogType.cancel);
    if (!mounted) return;
    if (confirmed == true) _cancelAuctionProduct(auctionId);
  }

  Future<void> _cancelAuctionProduct(int id) async {
    final controller = Provider.of<AuctionProductController>(context, listen: false);
    final bool ok = await controller.cancelAuctionProduct(id);
    if (!mounted) return;
    if (ok) {
      showCustomSnackBarWidget(getTranslated('auction_canceled_successfully', context) ?? 'Auction canceled successfully', context, isError: false, sanckBarType: SnackBarType.success);
      _loadData(isReload: true);
    } else {
      showCustomSnackBarWidget(getTranslated('failed_to_cancel_auction', context) ?? 'Failed to cancel auction', context, isError: true, sanckBarType: SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final configModel = Provider.of<SplashController>(context, listen: false).configModel;
    final bool canCreateAuction = configModel?.isAuctionFeatureEnabled == true && configModel?.activeAuctionForVendor == true;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (widget.fromNotification) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const DashboardScreen()), (route) => false);
        } else {
          if (!didPop) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: CustomAppBarWidget(
          title: getTranslated('auction_list', context) ?? 'Auction List',
          onBackPressed: () {
            if (widget.fromNotification) {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const DashboardScreen()), (route) => false);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        floatingActionButton: canCreateAuction? FloatingActionButton(
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
                  final counts = controller.auctionCounts;
                  return AuctionTabBarWidget(
                    selectedIndex: _selectedTab,
                    tabs: List.generate(_auctionStatusKeys.length, _getTabLabel),
                    counts: counts == null
                        ? null
                        : [
                      counts.total,
                      counts.upcoming,
                      counts.live,
                      counts.readyToClaim,
                      counts.purchaseComplete,
                      counts.readyToDelivery,
                      counts.onTheWay,
                      counts.delivered,
                      counts.unsold,
                      counts.canceled,
                    ],
                    onTabChanged: (index) {
                      setState(() {
                        _selectedTab = index;
                        if (_isSearchActive) {
                          _isSearchActive = false;
                          _searchController.clear();
                        }
                      });
                      _loadData(isReload: true);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: Dimensions.paddingSize),

            SizedBox(
              height: 60,
              child: Container(
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeMedium,
                    vertical: Dimensions.paddingSizeExtraSmall,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomSearchFieldWidget(
                          controller: _searchController,
                          hint: getTranslated('search_by_product_name', context) ?? '',
                          prefix: Images.iconsSearch,
                          showCloseIcon: _isSearchActive,
                          iconPressed: () => _isSearchActive ? _clearSearch() : _triggerSearch(),
                          onSubmit: (text) => _triggerSearch(),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSize),

                      Consumer<AuctionProductController>(
                        builder: (context, controller, _) {
                          return FilterIconWidget(
                            filterCount: controller.activeFilterCountForTab(_filterTabIndex),
                            onTap: _openFilterSheet,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Expanded(
              child: Consumer<AuctionProductController>(
                builder: (context, controller, _) {
                  if (controller.isAuctionListLoading ||
                      controller.auctionListModel == null) {
                    return ListView.builder(
                      itemCount: 10,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (_, __) => const AuctionCardShimmerWidget(fromRequest: false),
                    );
                  }

                  final List<AuctionProduct> products = controller.auctionListModel?.products ?? [];

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
                    onRefresh: () async => _loadData(isReload: true),
                    child: SingleChildScrollView(
                      child: PaginatedListViewWidget(
                        scrollController: _scrollController,
                        totalSize: controller.auctionListModel?.totalSize,
                        offset: controller.auctionListModel?.offset,
                        onPaginate: (offset) async {
                          await controller.getAuctionList(
                            tabIndex: _selectedTab,
                            auctionStatus: _auctionStatusKeys[_selectedTab],
                            search: _searchController.text.trim(),
                            offset: offset ?? 1,
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
                            final auctionStatus = AuctionStatus.fromString(product.auctionStatus ?? '');
                            final participantCount = product.participantsCount ?? product.totalParticipants ?? 0;
                            final showDelete = auctionStatus.isLive ? participantCount == 0 : true;
                            final showCancel = auctionStatus.isLive && participantCount == 0;
                            return AuctionCardWidget(
                              auctionProduct: product,
                              showDelete: showDelete,
                              showCancel: showCancel,
                              imageUrl: product.thumbnailFullUrl?.path ?? '',
                              title: product.name ?? '',
                              auctionId: '${product.id ?? ''}',
                              duration: DateConverter.utcStringToAuctionDuration(product.startTime, product.endTime),
                              startDate: product.startTime,
                              endDate: product.endTime,
                              status: AuctionStatus.fromString(product.auctionStatus ?? ''),
                              showAuctionStatus: (product.isRelaunched == true &&
                                      AuctionStatus.fromString(product.auctionStatus ?? '').isUnsold)
                                  ? AuctionStatus.recreated
                                  : product.auctionDetails?.auctionEnum,
                              isActive: product.status == '1',
                              startingPrice: product.startingPrice ?? 0,
                              minIncrement: product.minimumIncrementAmount,
                              maxDecrement: product.maximumDecrementAmount,
                              highestBid: product.highestBidAmount ?? product.currentHighestBidAmount,
                              views: product.totalViews,
                              bidCount: product.bidsCount ?? product.totalBids,
                              totalParticipate: product.participantsCount ?? product.totalParticipants,
                              claimedByName: '${product.winner?.fName ?? ''} ${product.winner?.lName ?? ''}'.trim(),
                              claimedByAvatarUrl: product.winner?.imageFullUrl?.path,
                              reason: product.rejectedNote,
                              claimRemainingDuration: product.claimRemainingDuration,
                              formAuctionList: true,
                              onMenuSelected: (action) async {
                                if (action == AuctionMenuAction.toggleStatus) {
                                  final isActive = product.status == '1';
                                  final confirmed = await showAuctionDialog(context, isActive ? AuctionDialogType.turnOff : AuctionDialogType.turnOn);
                                  if (confirmed != true) return;
                                  final ok = await Provider.of<AuctionProductController>(context, listen: false).toggleAuctionStatus(product.id!);
                                  if (ok) _loadData(isReload: true);
                                } else if (action == AuctionMenuAction.delete) {
                                  _showDeleteConfirmationDialog(context, product.id ?? 0);
                                } else if (action == AuctionMenuAction.cancel) {
                                  _showCancelConfirmationDialog(product.id ?? 0);
                                } else if (action == AuctionMenuAction.edit) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => AddAuctionProductTabView(
                                      fromPage: AddAuctionFromPage.auctionList,
                                      auctionProduct: product,
                                    ),
                                  ));
                                } else if (action == AuctionMenuAction.view) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => AuctionDetailsScreen(
                                      fromNotification: false,
                                      auctionId: product.id ?? 0,
                                      auctionProduct: product,
                                    ),
                                  )).then((deleted) {
                                    if (deleted == true) _loadData(isReload: true);
                                  });
                                } else if (action == AuctionMenuAction.recreate) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => AddAuctionProductTabView(
                                      fromPage: AddAuctionFromPage.biddingDetails,
                                      isRelaunch: true,
                                      auctionProduct: product,
                                    ),
                                  ));
                                }
                              },
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
}