import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/confirmation_dialog_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_dialog_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_product_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/extensions/payment_method_extension.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_bid_list_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_product_details_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_product_model.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/addAuctionProduct/add_auction_product_tab_view.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/auction_digital_payment_screen.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/auction_list_screen.dart';
import 'package:sixvalley_vendor_app/features/auction/screens/edit_auction_address_screen.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/address_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_details_shimmer_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_ended_banner.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_winner_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_withdrawal_bottom_sheet.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/bid_list_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/billing_info_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/info_section_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/order_status_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/payment_widgets/offline_payment_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/payment_widgets/payment_method_bottom_sheet_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/upload_tracking_url_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/withdrawal_card_widget.dart';
import 'package:sixvalley_vendor_app/features/chat/domain/models/chat_model.dart';
import 'package:sixvalley_vendor_app/features/chat/screens/chat_screen.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/config_model.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

import '../../../main.dart';

class BiddingDetailsScreen extends StatefulWidget {
  final bool fromNotification;
  final AuctionDetailsProduct? detailsProduct;
  final AuctionProduct? auctionProduct;
  const BiddingDetailsScreen({super.key, this.fromNotification = false, this.detailsProduct, this.auctionProduct});

  @override
  State<BiddingDetailsScreen> createState() => _BiddingDetailsScreenState();
}

class _BiddingDetailsScreenState extends State<BiddingDetailsScreen> {
  AuctionDetailsProduct? _detailsProduct;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _detailsProduct = widget.detailsProduct;
    final productId = _detailsProduct?.id;
    if (productId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<AuctionProductController>(context, listen: false).getBidList(productId, 1);
      });
    }
  }

  Future<void> _refreshProductDetails() async {
    final productId = _detailsProduct?.id;
    if (productId == null) return;
    final controller = Provider.of<AuctionProductController>(context, listen: false);
    await controller.getAuctionProductDetails(productId, reload: false);
    if (mounted) {
      setState(() {
        _detailsProduct = controller.auctionProductDetailsModel?.product;
      });
    }
  }

  void _showDeleteConfirmation() {
    showAnimatedDialogWidget(
      context,
      ConfirmationDialogWidget(
        icon: Images.delete,
        title: getTranslated('confirm_delete', context) ?? '',
        description: getTranslated('are_you_sure_you_want_to_delete', context) ?? '',
        onYesPressed: () {
          Navigator.pop(context);
          _deleteAuction();
        },
      ),
    );
  }

  Future<void> _deleteAuction() async {
    final id = _detailsProduct?.id;
    if (id == null) return;
    setState(() => _isDeleting = true);
    final controller = Provider.of<AuctionProductController>(context, listen: false);
    final success = await controller.deleteAuctionProduct(id);
    if (!mounted) return;
    setState(() => _isDeleting = false);
    if (success) {
      showCustomSnackBarWidget(
        getTranslated('auction_deleted_successfully', context) ?? '',
        context,
        isError: false,
        sanckBarType: SnackBarType.success,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuctionListScreen(fromNotification: true)),
        (route) => false,
      );
    } else {
      showCustomSnackBarWidget(
        getTranslated('failed_t_delete_auction', context) ?? '',
        context,
        isError: true,
        sanckBarType: SnackBarType.error,
      );
    }
  }

  void _navigateToReCreate() {
    final product = widget.auctionProduct ?? AuctionProduct(id: _detailsProduct?.id);
    if (product.id == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddAuctionProductTabView(
          fromPage: AddAuctionFromPage.biddingDetails,
          isRelaunch: true,
          auctionProduct: product,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ConfigModel? configModel = Provider.of<SplashController>(Get.context!, listen: false).configModel;

    final isLive = AuctionStatus.fromLabel(_detailsProduct?.auctionStatus ?? '').isLive;
    final isReadyToClaim = AuctionStatus.fromLabel(_detailsProduct?.auctionStatus ?? '').isReadyToClaim;
    final isReadyToDelivery = AuctionStatus.fromLabel(_detailsProduct?.deliveryStatus ?? '').isReadyToDelivery;
    final isUnsold = AuctionStatus.fromLabel(_detailsProduct?.auctionStatus ?? '').isUnsold;
    final isPurchaseComplete = AuctionStatus.fromLabel(_detailsProduct?.auctionStatus ?? '').isPurchaseComplete;
    final isDelivered = AuctionStatus.fromLabel(_detailsProduct?.deliveryStatus ?? '').isDelivered;
    final isOnTheWay = AuctionStatus.fromLabel(_detailsProduct?.deliveryStatus ?? '').isOnTheWay;


    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (widget.fromNotification) {
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
              builder: (BuildContext context) => const DashboardScreen(),
            ), (route) => false);
          } else {
            if (!didPop) {
              Navigator.of(context).pop();
            }
          }
        },
        child: Scaffold(
          bottomNavigationBar: isUnsold ? SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isDeleting ? null : _showDeleteConfirmation,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).colorScheme.error),
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                      ),
                      child: _isDeleting
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            )
                          : Text(
                              getTranslated('delete', context) ?? 'Delete',
                              style: titilliumSemiBold.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: Dimensions.fontSizeDefault,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isDeleting ? null : _navigateToReCreate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                      ),
                      child: Text(
                        getTranslated('re_create', context) ?? 'Re-create',
                        style: titilliumSemiBold.copyWith(
                          color: Colors.white,
                          fontSize: Dimensions.fontSizeDefault,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ) : null,
          body: SingleChildScrollView(
            child: Column(
              children: [

                if (isUnsold) ...[
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  const AuctionEndedBanner(),
                ],



                if (isDelivered) const SizedBox(height: Dimensions.paddingSizeSmall),
                if (isDelivered) Consumer<AuctionProductController>(
                  builder: (context, controller, child) {
                    final bool isCOD = controller.auctionProductDetailsModel?.deliveredPayout?.claimPaymentMethod == 'cash_on_delivery';
                    final payout = controller.auctionProductDetailsModel?.deliveredPayout;
                    final withdrawInfo = controller.auctionProductDetailsModel?.auctionWithdrawInfo;
                    final withdraw = withdrawInfo?.withdraw;
                    final breakdown = withdrawInfo?.breakdown ?? payout?.breakdown;
                    
                    return WithdrawalCardWidget(
                      state: _getWithdrawState(withdraw),
                      amount: isCOD ? payout?.breakdown?.commissionAmount ?? 0 : breakdown?.vendorReceivable ?? 0,
                      withdrawInfo: withdraw?.withdrawalMethodFields,
                      adminNote: withdraw?.transactionNote,
                      claimPaymentMethod: payout?.claimPaymentMethod,
                      adminCommissionGiven: _detailsProduct?.adminCommissionGiven ?? false,
                      onPayNowPressed: () async {
                        final controller = Provider.of<AuctionProductController>(context, listen: false);
                        controller.setOfflineChecked('', notify: false);
                        
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (c) => const PaymentMethodBottomSheetWidget(onlyDigital: true),
                        );
                        
                        String paymentMethod = '';
                        Map<String, dynamic> methodInformations = {};
                        String paymentNote = '';
                        
                        if (controller.isWalletChecked) {
                          paymentMethod = 'wallet';
                        } else if (controller.isOfflineChecked) {
                          paymentMethod = 'offline_payment';
                          
                          final paymentByController = TextEditingController();
                          final transactionIdController = TextEditingController();
                          final paymentNoteController = TextEditingController();
                          
                          bool submitOffline = await showDialog(
                            context: context,
                            builder: (ctx) => OfflinePaymentDialogWidget(
                              paymentBy: paymentByController,
                              transactionId: transactionIdController,
                              paymentNote: paymentNoteController,
                              onTap: () {
                                Navigator.of(ctx).pop(true);
                              },
                            ),
                          ) ?? false;

                          if (!submitOffline) return;
                          
                          methodInformations = {
                            'payment_by': paymentByController.text,
                            'transaction_id': transactionIdController.text,
                          };
                          paymentNote = paymentNoteController.text;
                          
                        } else if (controller.paymentMethodIndex != null && controller.paymentMethodIndex != -1 && controller.selectedPaymentMethod != null && controller.selectedPaymentMethod!.isNotEmpty) {
                          paymentMethod = controller.selectedPaymentMethod!;
                        }
                        
                        if (paymentMethod.isEmpty) return; 
                        
                        Map<String, dynamic> requestData = {
                          'payment_method': paymentMethod,
                        };
                        
                        if (paymentMethod == 'offline_payment') {
                          requestData['payment_note'] = paymentNote;
                          requestData['method_informations'] = methodInformations;
                        }
                        
                        String? redirectLink = await controller.payCommission(_detailsProduct!.id!, requestData);
                        if (redirectLink != null) {
                          if (redirectLink.isNotEmpty) {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => AuctionDigitalPaymentScreen(url: redirectLink)
                            )).then((_) {
                              _refreshProductDetails();
                            });
                          } else {
                            showCustomSnackBarWidget(getTranslated('commission_paid_successfully', Get.context!), Get.context!, isError: false);
                            _refreshProductDetails();
                          }
                        }
                      },
                      onWithdrawPressed: () {
                        if (breakdown?.vendorReceivable != null && breakdown!.vendorReceivable! > 0) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (c) => AuctionWithdrawalBottomSheet(
                              auctionProductId: _detailsProduct!.id!,
                              amount: breakdown.vendorReceivable!,
                            ),
                          );
                        }
                      },
                      onEditPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (c) => AuctionWithdrawalBottomSheet(
                            auctionProductId: _detailsProduct!.id!,
                            amount: withdraw?.amount ?? breakdown?.vendorReceivable ?? 0,
                            initialNote: withdraw?.transactionNote,
                            initialMethodId: withdraw?.withdrawalMethodId,
                            initialMethodFields: withdraw?.withdrawalMethodFields,
                            initialWithdrawId: withdraw?.id,
                          ),
                        );
                      },
                    );
                  },
                ),


                if (isReadyToDelivery || isPurchaseComplete || isDelivered || isOnTheWay) const SizedBox(height: Dimensions.paddingSizeSmall),
                if (isReadyToDelivery && _detailsProduct?.id != null || isPurchaseComplete || isOnTheWay || isDelivered)
                  Consumer<AuctionProductController>(
                    builder: (context, controller, _) {
                      final deliveryStatus = AuctionDeliveryStatus.fromLabel(_detailsProduct?.deliveryStatus ?? '');
                      final isPaid = controller.auctionProductDetailsModel?.auctionPayment?.paymentStatus == 'paid';
                      final paymentTxn = _detailsProduct?.transactions?.cast<AuctionTransaction?>()
                          .firstWhere((t) => t?.type == 'auction_payment', orElse: () => null);
                      final isPaymentEditable = paymentTxn?.paymentMethod == 'cash_on_delivery';
                      return OrderStatusWidget(
                        selectedDeliveryStatus: deliveryStatus,
                        isPaid: isPaid,
                        isPaymentEditable: isPaymentEditable,
                        isPaymentStatusUpdating: controller.isPaymentStatusUpdating,
                        isDeliveryStatusUpdating: controller.isDeliveryStatusUpdating,
                        onPaymentStatusChanged: (paid) async {
                          final success = await controller.updatePaymentStatus(
                            _detailsProduct!.id!,
                            paymentStatus: paid ? 'paid' : 'unpaid',
                          );
                          if (success) _refreshProductDetails();
                        },
                        onDeliveryStatusChanged: (status) async {
                          if (status == null) return;
                          final success = await controller.updateDeliveryStatus(
                            _detailsProduct!.id!,
                            deliveryStatus: status.label,
                          );
                          if (success) _refreshProductDetails();
                        },
                      );

                    },
                  ),


                if ((isReadyToDelivery || isOnTheWay || isDelivered) && _detailsProduct != null) const SizedBox(height: Dimensions.paddingSizeSmall),
                if ((isReadyToDelivery || isOnTheWay || isDelivered)  && _detailsProduct != null)
                   BillingInfoWidget(product: _detailsProduct!),


                if (isLive || isReadyToClaim || isReadyToDelivery || isUnsold || isPurchaseComplete || isOnTheWay) const SizedBox(height: Dimensions.paddingSizeSmall),
                if (isLive || isReadyToClaim || isReadyToDelivery || isUnsold || isPurchaseComplete || isOnTheWay) InfoSectionWidget(
                  title: getTranslated('bidding_info', context) ?? "",
                  items: [
                    {
                      "label": getTranslated('highest_bid', context) ?? "",
                      "value": PriceConverter.convertPrice(
                          context, _detailsProduct?.highestBidAmount),
                    },
                    {
                      "label": getTranslated('total_bid', context) ?? "",
                      "value": _detailsProduct?.totalBids?.toString() ?? "0",
                    },
                    {
                      "label": getTranslated('total_view', context) ?? "",
                      "value": _detailsProduct?.totalViews?.toString() ?? "0",
                    },
                    {
                      "label": getTranslated('total_participate', context) ?? "",
                      "value": _detailsProduct?.totalParticipants?.toString() ?? "0",
                    },
                  ],
                ),



                if (isLive || isReadyToClaim || isReadyToDelivery || isUnsold || isPurchaseComplete || isOnTheWay || isDelivered) const SizedBox(height: Dimensions.paddingSizeSmall),
                if (isLive || isReadyToClaim || isReadyToDelivery || isUnsold ||isPurchaseComplete || isOnTheWay || isDelivered) InfoSectionWidget(
                  title: getTranslated('auction_insights', context) ?? "",
                  items: [
                    {
                      "label": getTranslated('avg_bid_increase', context) ?? "",
                      "value": _detailsProduct?.auctionInsights?.avgBidIncrease?.toString() ?? "0",
                    },
                    {
                      "label": getTranslated('highest_jump', context) ?? "",
                      "value": _detailsProduct?.auctionInsights?.highestJump?.toString() ?? "0",
                    },
                  ],
                ),


                Builder(builder: (context) {
                  final paymentTxn = _detailsProduct?.transactions
                      ?.cast<AuctionTransaction?>().firstWhere((t) => t?.type == 'auction_payment', orElse: () => null);
                  if (paymentTxn == null) return const SizedBox.shrink();
                  return Column(
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      InfoSectionWidget(
                        title: getTranslated('payment_info', context) ?? "",
                        statusBadge: paymentTxn.paymentStatus,
                        items: [
                          {
                            "label": getTranslated('payment_method', context) ?? "",
                            "value": paymentTxn.paymentMethod.toPaymentMethodLabel(context),
                          },
                          {
                            "label": getTranslated('paid_amount', context) ?? "",
                            "value": PriceConverter.convertPrice(context, paymentTxn.amount),
                          },
                        ],
                      ),
                    ],
                  );
                }),

                if (isReadyToDelivery || isOnTheWay || isDelivered) const SizedBox(height: Dimensions.paddingSizeSmall),
                if (isReadyToDelivery || isOnTheWay || isDelivered) AddressWidget(
                  shippingAddress: _detailsProduct?.shippingAddressInfo,
                  billingAddress: _detailsProduct?.billingAddressInfo,
                  onShowOnMap: () {},
                  isSameBilling: _detailsProduct?.billingSameAsShipping,
                  onEditShipping: _detailsProduct?.id != null ? () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) =>
                      EditAuctionAddressScreen(
                        auctionProductId: _detailsProduct!.id!,
                        addressType: 'shipping',
                        currentAddress: _detailsProduct?.shippingAddressInfo,
                      ),
                    )).then((result) {
                      if (result == true) _refreshProductDetails();
                    });
                  } : null,
                  onEditBilling: _detailsProduct?.id != null && _detailsProduct?.billingAddressInfo != null ? () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) =>
                      EditAuctionAddressScreen(
                        auctionProductId: _detailsProduct!.id!,
                        addressType: 'billing',
                        currentAddress: _detailsProduct?.billingAddressInfo,
                      ),
                    )).then((result) {
                      if (result == true) _refreshProductDetails();
                    });
                  } : null,
                ),

                if (isReadyToDelivery || isOnTheWay || isDelivered) const SizedBox(height: Dimensions.paddingSizeSmall),
                if (isReadyToDelivery || isOnTheWay || isDelivered) UploadTrackingUrlWidget(
                  initialUrl: _detailsProduct?.trackingUrl ?? '',
                  onSave: (url) async {
                    final productId = _detailsProduct?.id;
                    if (productId == null) return false;
                    return await Provider.of<AuctionProductController>(context, listen: false).uploadTrackingUrl(productId, url);
                  },
                ),

                if (isLive || isReadyToClaim || isReadyToDelivery || isPurchaseComplete ) const SizedBox(height: Dimensions.paddingSizeSmall),
                if (_detailsProduct?.winner != null) AuctionWinnerWidget(
                  name: '${_detailsProduct?.winner?.fName ?? ''} ${_detailsProduct?.winner?.lName ?? ''}'.trim(),
                  avatarUrl: _detailsProduct?.winner?.imageFullUrl?.path ?? '',
                  onMessageTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return ChatScreen(
                        userId: _detailsProduct?.winner?.id ?? 0,
                        name: '${_detailsProduct?.winner?.fName ?? ''} ${_detailsProduct?.winner?.lName ?? ''}'.trim(),
                        chat: Chat(
                          userId: _detailsProduct?.winner?.id ?? 0,
                          customer: _detailsProduct?.winner != null ? Customer(id: _detailsProduct!.winner!.id, fName: _detailsProduct!.winner!.fName, lName: _detailsProduct!.winner!.lName, imageFullUrl: _detailsProduct?.winner?.imageFullUrl) : null,
                        ),
                      );
                    }));
                  },
                ),
                if (isReadyToClaim || isReadyToDelivery || isPurchaseComplete) const SizedBox(height: Dimensions.paddingSizeSmall),

                if (isLive || isReadyToClaim || isReadyToDelivery || isUnsold || isPurchaseComplete || isOnTheWay)
                  Consumer<AuctionProductController>(
                    builder: (context, controller, _) {
                      if (controller.isBidListLoading) {
                        return const AuctionDetailsBiddingShimmer();
                      }
                      final bids = _buildBidItems(context, controller.bidListModel?.bids ?? []);
                      return bids.isNotEmpty ?  BidListWidget(
                        bids: bids,
                        totalSize: controller.bidListModel?.totalSize,
                        offset: controller.bidListModel?.offset,
                        onPaginate: (offset) {
                          final productId = _detailsProduct?.id;
                          if (productId != null && offset != null) {
                            controller.getBidList(productId, offset);
                          }
                        },
                        auctionStatus: _detailsProduct?.deliveryStatus != null
                          ? AuctionStatus.fromLabel(_detailsProduct?.deliveryStatus ?? '')
                          : AuctionStatus.fromLabel(_detailsProduct?.auctionStatus ?? ''),
                      ) : SizedBox();
                    },
                  ),
              ],
            ),
          ),
        ));
  }

  List<BidListItem> _buildBidItems(
      BuildContext context, List<AuctionBid>? rawBids) {
    final bids = rawBids ?? [];
    return List.generate(bids.length, (i) {
      final bid = bids[i];
      final prevBidAmount = i + 1 < bids.length ? (bids[i + 1].bidAmount ?? 0) : 0;
      final isBidUp = (bid.bidAmount ?? 0) >= prevBidAmount;
      final name = '${bid.customer?.fName ?? ''} ${bid.customer?.lName ?? ''}'.trim();
      return BidListItem(
        rank: i + 1,
        name: name.isEmpty ? 'Unknown' : name,
        timeAgo: _formatBidTime(bid.bidTime),
        bidAmount: PriceConverter.convertPrice(context, bid.bidAmount),
        avatarUrl: bid.customer?.imageFullUrl?.path,
        isLeading: bid.isLeadBid ?? false,
        isCurrentUser: bid.isMyBid ?? false,
        isBidUp: isBidUp,
        isWithdrawBid: bid.isWithdrawBid ?? false,
        isClaimExpired: bid.userContext?.isClaimExpired ?? false,
      );
    });
  }

  String _formatBidTime(String? bidTime) {
    if (bidTime == null) return '';
    final time = DateTime.tryParse(bidTime);
    if (time == null) return '';
    final diff = DateTime.now().difference(time.toLocal());
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  WithdrawState _getWithdrawState(Withdraw? withdraw) {
    if (withdraw == null) return WithdrawState.pending;
    if (withdraw.status == 'pending') return WithdrawState.requested;
    if (withdraw.status == 'approved') return WithdrawState.approved;
    if (withdraw.status == 'denied') return WithdrawState.denied;
    return WithdrawState.pending;
  }
}
