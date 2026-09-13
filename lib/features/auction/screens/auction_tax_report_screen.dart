import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/no_data_screen.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/paginated_list_view_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_product_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_tax_filter_bottom_sheet_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_tax_info_card_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_tax_order_list_card_widget.dart';
import 'package:sixvalley_vendor_app/features/vat_management/widgets/order_info_card_widget.dart';
import 'package:sixvalley_vendor_app/features/vat_management/widgets/order_list_card_shimmer_widget.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AuctionTaxReportScreen extends StatefulWidget {
  const AuctionTaxReportScreen({super.key});

  @override
  State<AuctionTaxReportScreen> createState() => _AuctionTaxReportScreenState();
}

class _AuctionTaxReportScreenState extends State<AuctionTaxReportScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final controller = Provider.of<AuctionProductController>(context, listen: false);
    controller.resetVatData(isUpdate: false);
    controller.setVatInitialDateRange();
    controller.getAuctionVatReport(
      1,
      startDate: controller.vatStartDate.toString(),
      endDate: controller.vatEndDate.toString(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: getTranslated('auction_tax_report', context),
        isAction: true,
        isFilter: true,
        widget: Consumer<AuctionProductController>(
          builder: (context, controller, _) {
            return InkWell(
                onTap: () => showModalBottomSheet(
                  backgroundColor: Theme.of(context).cardColor,
                  useSafeArea: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  isScrollControlled: true,
                  context: context,
                  builder: (_) => const AuctionTaxFilterBottomSheet(),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.onTertiaryContainer),
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                  ),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  child: CustomAssetImageWidget(
                    Images.dropdown,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                    height: Dimensions.paddingSizeDefault,
                    width: Dimensions.paddingSizeDefault,
                  ),
                ),
              );
          },
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium, vertical: Dimensions.paddingSizeLarge),
          child: Consumer<AuctionProductController>(
            builder: (context, controller, _) {
              final report = controller.auctionVatReportModel;

              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Summary section
                report != null ? (report.typeWiseTaxesList?.isNotEmpty ?? false) ?
                Column(children: [
                  Row(children: [
                    Expanded(
                      child: OrderInfoCardWidget(
                        image: Images.totalOrderIcon,
                        amount: report.totalOrders.toString(),
                        infoName: getTranslated('total_auctions', context)!,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: OrderInfoCardWidget(
                        image: Images.totalAmountIcon,
                        amount: PriceConverter.convertPrice(
                          context,
                          double.tryParse(report.totalOrderAmount.toString()) ?? 0,
                        ),
                        infoName: getTranslated('total_auction_amount', context)!,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ]),
                  SizedBox(height: Dimensions.paddingSizeSmall),

                  // Total VAT + type-wise breakdown
                  Container(
                    padding: EdgeInsets.all(Dimensions.paddingSizeSmall).copyWith(right: 0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

                      Row(children: [
                        CustomAssetImageWidget(
                          Images.vatReportIcon,
                          color: Theme.of(context).colorScheme.onTertiaryContainer,
                          height: Dimensions.topSpace,
                          width: Dimensions.topSpace,
                        ),
                        SizedBox(width: Dimensions.paddingSizeSmall),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            PriceConverter.convertPrice(context, report.totalTax ?? 0),
                            style: robotoBold.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: Dimensions.fontSizeLarge,
                              color: Theme.of(context).colorScheme.onTertiaryContainer,
                            ),
                          ),
                          Text(getTranslated('total_vat_amount', context)!, style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
                          )),
                        ]),
                      ]),
                      SizedBox(height: Dimensions.paddingSizeLarge),

                      Container(
                        height: 66,
                        padding: EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: report.typeWiseTaxesList?.length ?? 0,
                          itemBuilder: (_, index) => AuctionTaxInfoCard(
                            taxGroup: report.typeWiseTaxesList![index],
                          ),
                          separatorBuilder: (_, __) => SizedBox(width: Dimensions.paddingEye),
                        ),
                      ),
                    ]),
                  ),
                ])
              : (report.orderTransactions?.isEmpty ?? false)
                ? SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  width: MediaQuery.of(context).size.width,
                  child: Center(child: NoDataScreen(title: 'no_tax_report_found')),
                ) : const SizedBox()
          : const AuctionVatReportShimmerWidget(isEnabled: true),

                // Auction list header
            if (report?.orderTransactions?.isNotEmpty ?? false) ...[
              SizedBox(height: Dimensions.paddingSizeLarge),
              Text(getTranslated('auction_list', context)!, style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              )),
              SizedBox(height: Dimensions.paddingSizeSmall),
            ],

                // Paginated auction list
              report != null ? (report.orderTransactions?.isNotEmpty ?? false)
                ? PaginatedListViewWidget(
                  scrollController: _scrollController,
                  totalSize: report.totalOrders,
                  offset: report.offset,
                  onPaginate: (int? offset) async {
                    await controller.getAuctionVatReport(
                      offset ?? 1,
                      startDate: controller.isVatFilterActive ? controller.vatStartDate.toString() : null,
                      endDate: controller.isVatFilterActive ? controller.vatEndDate.toString() : null,
                    );
                  },
                  itemView: ListView.separated(
                    itemCount: report.orderTransactions?.length ?? 0,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (_, index) => AuctionTaxOrderListCardWidget(
                      orderModel: report.orderTransactions?[index],
                    ),
                    separatorBuilder: (_, __) => SizedBox(height: Dimensions.paddingSizeSmall),
                  ),
                ) : const SizedBox()
              : const OrderListCardShimmer(),


              ]);
            },
          ),
        ),
      ),
    );
  }
}

class AuctionVatReportShimmerWidget extends StatelessWidget {
  final bool isEnabled;
  const AuctionVatReportShimmerWidget({super.key, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeExtraSmall,
        horizontal: Dimensions.paddingSizeSmall,
      ),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).highlightColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.grey[200]!, blurRadius: 10, spreadRadius: 1)],
      ),
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).hintColor.withValues(alpha: 0.18),
        highlightColor: Theme.of(context).hintColor.withValues(alpha: 0.06),
        enabled: isEnabled,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: _cardSkeleton(context)),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(child: _cardSkeleton(context)),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            padding: EdgeInsets.all(Dimensions.paddingSizeSmall).copyWith(right: 0),
            decoration: BoxDecoration(
              color: Theme.of(context).highlightColor,
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  height: Dimensions.topSpace, width: Dimensions.topSpace,
                  decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(6)),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 80, height: 14, color: Colors.grey[400]),
                  const SizedBox(height: 6),
                  Container(width: 100, height: 12, color: Colors.grey[400]),
                ]),
              ]),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              SizedBox(
                height: Dimensions.topSpace,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: Dimensions.paddingEye),
                  itemBuilder: (_, __) => Container(
                    width: Dimensions.topSpace * 2,
                    height: Dimensions.topSpace,
                    decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
        ]),
      ),
    );
  }

  Widget _cardSkeleton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(color: Theme.of(context).highlightColor, borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 40, width: 40, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Container(height: 14, width: 60, color: Colors.grey[400]),
        const SizedBox(height: 6),
        Container(height: 12, width: 100, color: Colors.grey[400]),
      ]),
    );
  }
}
