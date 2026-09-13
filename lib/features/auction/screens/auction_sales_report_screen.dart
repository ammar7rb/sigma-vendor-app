import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/no_data_screen.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/paginated_list_view_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_product_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_sales_report_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/enum/auction_status.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_sales_filter_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_sales_report_shimmer_widget.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AuctionSalesReportScreen extends StatefulWidget {
  const AuctionSalesReportScreen({super.key});

  @override
  State<AuctionSalesReportScreen> createState() => _AuctionSalesReportScreenState();
}

class _AuctionSalesReportScreenState extends State<AuctionSalesReportScreen> {
  final ScrollController _scrollController = ScrollController();

  String _selectedFilter = 'all_time';
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData(reload: true));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String get _dateType {
    switch (_selectedFilter) {
      case 'today':
        return 'today';
      case 'this_week':
        return 'this_week';
      case 'this_month':
        return 'this_month';
      case 'custom_date':
        return 'custom_date';
      default:
        return '';
    }
  }

  Future<void> _loadData({bool reload = false, int offset = 1}) {
    return Provider.of<AuctionProductController>(context, listen: false).getSalesReport(
      offset: offset,
      dateType: _dateType,
      from: _selectedFilter == 'custom_date' && _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : null,
      to: _selectedFilter == 'custom_date' && _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : null,
      reload: reload,
    );
  }

  void _onFilterSelected(String filter) {
    if (filter == 'custom_date') {
      AuctionSalesCustomDateSheet.show(
        context,
        initialFrom: _fromDate,
        initialTo: _toDate,
        onApply: (from, to) {
          setState(() {
            _selectedFilter = 'custom_date';
            _fromDate = from;
            _toDate = to;
          });
          _loadData(reload: true);
        },
      );
    } else {
      setState(() {
        _selectedFilter = filter;
        _fromDate = null;
        _toDate = null;
      });
      _loadData(reload: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: getTranslated('auction_sales_report', context) ?? '',
        isAction: true,
        isFilter: true,
        widget: _FilterPopupMenu(
          selectedFilter: _selectedFilter,
          onSelected: _onFilterSelected,
        ),
      ),
      body: Consumer<AuctionProductController>(
        builder: (context, controller, _) {
          final report = controller.salesReportModel;
          final loading = controller.isSalesReportLoading;

          if (loading && report == null) {
            return const AuctionSalesReportShimmer();
          }

          final auctions = report?.auctions ?? [];

          return RefreshIndicator(
            onRefresh: () async => _loadData(reload: true),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  SizedBox(
                    height: 125,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      children: [
                        AuctionStatCard(
                          imagePath: Images.gavelIcon,
                          count: '${report?.totalAuctionsCreated ?? 0}',
                          label: 'auctions_created',
                        ),
                        const SizedBox(width: Dimensions.paddingEye),
                        AuctionStatCard(
                          imagePath: Images.packageIcon,
                          count: '${report?.totalAuctionsSold ?? 0}',
                          label: 'total_sold',
                          color: Theme.of(context).colorScheme.onTertiaryContainer.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: Dimensions.paddingEye),
                        AuctionStatCard(
                          imagePath: Images.package01Icon,
                          isAmount: true,
                          amount: report?.totalProductSalesValue ?? 0,
                          label: 'total_sales_value',
                          color: Theme.of(context).colorScheme.onTertiaryContainer,
                        ),
                        const SizedBox(width: Dimensions.paddingEye),
                        AuctionStatCard(
                          imagePath: Images.vatIcon,
                          isAmount: true,
                          amount: report?.totalVatTax ?? 0,
                          label: 'vat_tax_collected',
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: Dimensions.paddingEye),
                        AuctionStatCard(
                          imagePath: Images.shippingDeliveredIcon,
                          isAmount: true,
                          amount: report?.totalShippingFee ?? 0,
                          label: 'shipping_fee_collected',
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        const SizedBox(width: Dimensions.paddingEye),
                        AuctionStatCard(
                          imagePath: Images.coinIcon,
                          isAmount: true,
                          amount: report?.grossSalesAmount ?? 0,
                          label: 'total_gross_amount',
                          tooltipKey: 'total_gross_amount_tooltip',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  if (auctions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraLarge),
                      child: NoDataScreen(
                        title: getTranslated('no_auction_found', context) ?? '',
                      ),
                    )
                  else
                    PaginatedListViewWidget(
                      scrollController: _scrollController,
                      onPaginate: (offset) => _loadData(offset: offset ?? 1),
                      totalSize: report?.totalSize,
                      offset: report?.offset,
                      itemView: Column(
                        children: auctions.map((a) => AuctionDetailCard(auction: AuctionDetailModel.fromSale(a))).toList(),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilterPopupMenu extends StatelessWidget {
  final String selectedFilter;
  final void Function(String) onSelected;

  const _FilterPopupMenu({
    required this.selectedFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      onSelected: onSelected,
      itemBuilder: (_) => _buildItems(context),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.onTertiaryContainer),
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
        ),
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        child: CustomAssetImageWidget(
          Images.dropdown,
          color: theme.colorScheme.onTertiaryContainer,
          height: Dimensions.paddingSizeDefault,
          width: Dimensions.paddingSizeDefault,
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildItems(BuildContext context) {
    final entries = <String>[
      'all_time',
      'today',
      'this_week',
      'this_month',
      'custom_date',
    ];

    return entries.map((key) {
      final isSelected = selectedFilter == key;
      return PopupMenuItem<String>(
        value: key,
        height: 30,
        child: Row(
          children: [
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Text(
              getTranslated(key, context) ?? key,
              style: robotoRegular.copyWith(color: isSelected ? Theme.of(context).textTheme.bodyLarge?.color
                : Theme.of(context).textTheme.headlineLarge?.color,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraLarge),
          ],
        ),
      );
    }).toList();
  }
}

class AuctionStatCard extends StatefulWidget {
  final String imagePath;
  final String count;
  final double? amount;
  final bool isAmount;
  final Color? color;
  final String? label;
  final String? tooltipKey;
  final double imageSize;

  const AuctionStatCard({
    super.key,
    required this.imagePath,
    this.count = '',
    this.amount,
    this.isAmount = false,
    this.color,
    this.label,
    this.tooltipKey,
    this.imageSize = Dimensions.iconSizeExtraLarge,
  });

  @override
  State<AuctionStatCard> createState() => _AuctionStatCardState();
}

class _AuctionStatCardState extends State<AuctionStatCard> {
  final JustTheController _tooltipController = JustTheController();

  @override
  void dispose() {
    _tooltipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countColor = widget.color ?? theme.colorScheme.primary;
    final displayText = widget.isAmount
        ? PriceConverter.showCurrencyCode(context, PriceConverter.longToShortPrice(widget.amount ?? 0, withDecimalPoint: true))
        : widget.count;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      width: 140,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAssetImageWidget(widget.imagePath, height: widget.imageSize, width: widget.imageSize, fit: BoxFit.contain),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Text(
            displayText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeWallet, color: countColor),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Row(
            children: [
              Expanded(
                child: Text(
                  widget.label != null ? getTranslated(widget.label!, context) ?? '' : '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: titilliumRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: theme.textTheme.bodySmall!.color,
                  ),
                ),
              ),
              if (widget.tooltipKey != null) ...[
                const SizedBox(width: Dimensions.paddingSizeVeryTiny),
                JustTheTooltip(
                  controller: _tooltipController,
                  backgroundColor: Colors.black,
                  content: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingEye),
                    child: Text(
                      getTranslated(widget.tooltipKey!, context) ?? '',
                      style: titilliumRegular.copyWith(color: Colors.white),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () => _tooltipController.showTooltip(),
                    child: Icon(Icons.info_outline, size: 14, color: theme.textTheme.bodySmall!.color),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

extension AuctionStatusStyle on AuctionStatus {
  String statusLabel(BuildContext context) {
    switch (this) {
      case AuctionStatus.complete:
        return getTranslated('completed', context) ?? 'Completed';
      case AuctionStatus.live:
        return getTranslated('live', context) ?? 'Live';
      case AuctionStatus.pending:
        return getTranslated('pending', context) ?? 'Pending';
      case AuctionStatus.rejected:
        return getTranslated('cancelled', context) ?? 'Cancelled';
      case AuctionStatus.scheduled:
        return getTranslated('scheduled', context) ?? 'Scheduled';
      case AuctionStatus.upcoming:
        return getTranslated('upcoming', context) ?? 'Upcoming';
      case AuctionStatus.approved:
        return getTranslated('approved', context) ?? 'Approved';
      case AuctionStatus.unsold:
        return getTranslated('unsold', context) ?? 'Unsold';
      case AuctionStatus.readyToClaim:
        return getTranslated('ready_to_claim', context) ?? 'Ready to Claim';
      case AuctionStatus.readyToDelivery:
        return getTranslated('ready_to_delivery', context) ?? 'Ready to Deliver';
      case AuctionStatus.onTheWay:
        return getTranslated('on_the_way', context) ?? 'On the Way';
      case AuctionStatus.purchaseComplete:
        return getTranslated('purchase_complete', context) ?? 'Purchase Complete';
      case AuctionStatus.delivered:
        return getTranslated('delivered', context) ?? 'Delivered';
      case AuctionStatus.all:
        // TODO: Handle this case.
        throw UnimplementedError();
      case AuctionStatus.canceled:
        return getTranslated('cancelled', context) ?? 'Cancelled';
      case AuctionStatus.recreated:
        return getTranslated('recreated', context) ?? 'Recreated';
    }
  }

  Color bgColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (this) {
      case AuctionStatus.complete:
      case AuctionStatus.purchaseComplete:
      case AuctionStatus.delivered:
        return cs.onTertiaryContainer.withValues(alpha: 0.2);
      case AuctionStatus.live:
      case AuctionStatus.readyToClaim:
        return cs.secondary.withValues(alpha: 0.15);
      case AuctionStatus.pending:
        return cs.tertiaryContainer.withValues(alpha: 0.3);
      case AuctionStatus.rejected:
      case AuctionStatus.unsold:
        return cs.error.withValues(alpha: 0.15);
      case AuctionStatus.scheduled:
      case AuctionStatus.upcoming:
      case AuctionStatus.approved:
        return cs.primaryContainer.withValues(alpha: 0.2);
      case AuctionStatus.readyToDelivery:
      case AuctionStatus.onTheWay:
        return cs.outline.withValues(alpha: 0.15);
      case AuctionStatus.all:
        return cs.primary.withValues(alpha: 0.15);
      case AuctionStatus.canceled:
        return cs.error.withValues(alpha: 0.15);
      case AuctionStatus.recreated:
        return cs.primary.withValues(alpha: 0.15);
    }
  }

  Color textColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (this) {
      case AuctionStatus.complete:
      case AuctionStatus.purchaseComplete:
      case AuctionStatus.delivered:
        return cs.onTertiaryContainer;
      case AuctionStatus.live:
      case AuctionStatus.readyToClaim:
        return cs.secondary;
      case AuctionStatus.pending:
        return cs.tertiary;
      case AuctionStatus.rejected:
      case AuctionStatus.unsold:
        return cs.error;
      case AuctionStatus.scheduled:
      case AuctionStatus.upcoming:
      case AuctionStatus.approved:
        return cs.primary;
      case AuctionStatus.readyToDelivery:
      case AuctionStatus.onTheWay:
        return cs.outline;
      case AuctionStatus.all:
        return cs.primary;
      case AuctionStatus.canceled:
        return cs.error.withValues(alpha: 0.15);
      case AuctionStatus.recreated:
        return cs.primary;
    }
  }
}

class AuctionDetailModel {
  final String auctionNumber;
  final String productName;
  final String completionDate;
  final String imageUrl;
  final AuctionStatus status;
  final double startingPrice;
  final double soldAmount;
  final double vatTax;
  final double shippingFee;
  final double commissionPaid;
  final bool adminCommissionGiven;

  const AuctionDetailModel({
    required this.auctionNumber,
    required this.productName,
    required this.completionDate,
    required this.imageUrl,
    required this.status,
    required this.startingPrice,
    required this.soldAmount,
    required this.vatTax,
    required this.shippingFee,
    required this.commissionPaid,
    required this.adminCommissionGiven,
  });

  factory AuctionDetailModel.fromSale(AuctionSaleModel s) {
    final displayDate = s.endTime.isNotEmpty ? DateConverter.isoStringToLocalDateOnly(s.endTime) : '';
    return AuctionDetailModel(
      auctionNumber: '${s.id}',
      productName: s.name,
      completionDate: displayDate,
      imageUrl: s.thumbnailUrl,
      status: AuctionStatus.fromString(s.status),
      startingPrice: s.startingPrice,
      soldAmount: s.soldAmount,
      vatTax: s.vatTax,
      shippingFee: s.shippingFee,
      commissionPaid: s.adminCommission,
      adminCommissionGiven: s.adminCommissionGiven ?? false,
    );
  }

  double get grossSalesBeforeCommission => soldAmount + vatTax + shippingFee;
  double get grossSalesAfterCommission => grossSalesBeforeCommission - commissionPaid;
}

class AuctionDetailCard extends StatelessWidget {
  final AuctionDetailModel auction;

  const AuctionDetailCard({super.key, required this.auction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: Dimensions.paddingSizeExtraSmall),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Column(
          children: [
            _ProductHeader(auction: auction),
            Divider(height: 1, color: theme.hintColor.withValues(alpha: 0.3)),
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(
                children: [
                  PriceRow(
                    label: getTranslated('starting_price', context) ?? '',
                    value: auction.startingPrice,
                  ),
                  PriceRow(
                    label: getTranslated('sold_amount', context) ?? '',
                    value: auction.soldAmount,
                  ),
                  PriceRow(
                    label: getTranslated('vat_tax', context) ?? '',
                    value: auction.vatTax,
                  ),
                  PriceRow(
                    label: getTranslated('shipping_fee', context) ?? '',
                    value: auction.shippingFee,
                  ),
                  PriceRow(
                    label: getTranslated('gross_sales_before_commission', context) ?? '',
                    value: auction.grossSalesBeforeCommission,
                  ),

                  PriceRow(
                    label: getTranslated('commission_paid', context) ?? '',
                    value: auction.commissionPaid,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Divider(
                      height: 1,
                      color: theme.hintColor.withValues(alpha: 0.3)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  PriceRow(
                    label: getTranslated('gross_sales_after_commission', context) ?? '',
                    value: auction.grossSalesAfterCommission,
                    isTotal: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductHeader extends StatelessWidget {
  final AuctionDetailModel auction;

  const _ProductHeader({required this.auction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: CustomImageWidget(
              image: auction.imageUrl,
              height: Dimensions.imageSize,
              width: Dimensions.imageSize,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${getTranslated('auction_number', context) ?? ''} #${auction.auctionNumber}',
                        style: titilliumRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: theme.textTheme.bodySmall!.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    _StatusBadge(status: auction.status),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeVeryTiny),
                Text(
                  auction.productName,
                  style: titilliumSemiBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: theme.textTheme.bodyLarge!.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Dimensions.paddingSizeVeryTiny),
                Text(
                  '${getTranslated('completion_date', context) ?? ''} : ${auction.completionDate}',
                  style: titilliumRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: theme.textTheme.bodySmall!.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AuctionStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeVeryTiny,
      ),
      decoration: BoxDecoration(
        color: status.bgColor(context),
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
      ),
      child: Text(
        status.statusLabel(context),
        style: titilliumRegular.copyWith(
          fontSize: Dimensions.fontSizeExtraSmall,
          color: status.textColor(context),
        ),
      ),
    );
  }
}

class PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isTotal;

  const PriceRow({
    super.key,
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: Dimensions.paddingSizeVeryTiny),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: isTotal
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslated('gross_sales', context) ?? 'Gross Sales',
                    style: titilliumSemiBold.copyWith(
                      color: primary,
                      fontSize: Dimensions.fontSizeDefault,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    getTranslated('after_commission', context) ?? '(After Commission)',
                    style: titilliumRegular.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                ],
              ) : Text(label, style: titilliumRegular.copyWith(color: Theme.of(context).hintColor)
            ),
          ),
          Text(':', style: titilliumRegular.copyWith(color: Theme.of(context).hintColor)),
          Expanded(
            flex: 4,
            child: Text(
              PriceConverter.convertPrice(context, value),
              textAlign: TextAlign.end,
              style: isTotal ? titilliumSemiBold.copyWith(
                color: primary, fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.bold)
                : titilliumSemiBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
        ],
      ),
    );
  }
}
