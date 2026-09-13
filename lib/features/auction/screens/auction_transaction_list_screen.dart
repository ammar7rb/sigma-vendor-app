import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_icon_search_field_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/paginated_list_view_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_transaction_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_transaction_filter_bottom_sheet_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_transaction_shimmer_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_transaction_tile_widget.dart';
import 'package:sixvalley_vendor_app/helper/debounce_helper.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AuctionTransactionListScreen extends StatefulWidget {
  const AuctionTransactionListScreen({super.key});

  @override
  State<AuctionTransactionListScreen> createState() => _AuctionTransactionListScreenState();
}

class _AuctionTransactionListScreenState extends State<AuctionTransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DebounceHelper _debounce = DebounceHelper(milliseconds: 500);
  final ScrollController _scrollController = ScrollController();
  int? _searchAuctionId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<AuctionTransactionController>(context, listen: false);
      controller.resetFilters(notify: false);
      controller.getAuctionTransactionList(context, isRefresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce.run(() {
      _searchAuctionId = int.tryParse(query.trim());
      _fetchWithCurrentFilters(isRefresh: true);
    });
  }

  Future<void> _fetchWithCurrentFilters({bool isRefresh = false, int offset = 1}) async {
    final controller = Provider.of<AuctionTransactionController>(context, listen: false);
    final String? start = (controller.filterDurationType == 'custom_date' && controller.filterStartDate != null)
        ? '${controller.filterStartDate!.year}-${controller.filterStartDate!.month.toString().padLeft(2, '0')}-${controller.filterStartDate!.day.toString().padLeft(2, '0')}'
        : null;
    final String? end = (controller.filterDurationType == 'custom_date' && controller.filterEndDate != null)
        ? '${controller.filterEndDate!.year}-${controller.filterEndDate!.month.toString().padLeft(2, '0')}-${controller.filterEndDate!.day.toString().padLeft(2, '0')}'
        : null;

    controller.getAuctionTransactionList(
      context,
      isRefresh: isRefresh,
      offset: offset,
      searchAuctionId: _searchAuctionId,
      transactionTypes: controller.selectedTransactionTypes.isEmpty ? null : controller.selectedTransactionTypes,
      filterDurationType: controller.filterDurationType == 'all' ? null : controller.filterDurationType,
      startDate: start,
      endDate: end,
    );
  }

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).cardColor,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      context: context,
      builder: (_) => AuctionTransactionFilterBottomSheet(
        searchAuctionId: _searchAuctionId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: getTranslated('auction_transactions', context) ?? 'Auction Transactions',
        isAction: true,
        isFilter: true,
        widget: Consumer<AuctionTransactionController>(
          builder: (context, controller, _) {
            return InkWell(
              onTap: () => _openFilterSheet(context),
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
      body: Column(
        children: [
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: CustomIconSearchFieldWidget(
              controller: _searchController,
              hint: getTranslated('search_by_auction_number', context) ?? 'Search by auction number',
              prefix: Images.iconsSearch,
              keyboardType: TextInputType.number,
              iconPressed: () => _onSearchChanged(_searchController.text),
              onSubmit: (text) => _onSearchChanged(text),
              onChanged: (value) => _onSearchChanged(value as String),
              onClear: () {
                _searchAuctionId = null;
                _fetchWithCurrentFilters(isRefresh: true);
              },
            ),
          ),

          // Active filter summary chips
          Consumer<AuctionTransactionController>(
            builder: (context, controller, _) {
              final chips = <Widget>[];

              if (controller.selectedTransactionTypes.isNotEmpty) {
                for (final t in controller.selectedTransactionTypes) {
                  chips.add(_ActiveFilterChip(
                    label: getTranslated(t, context) ?? t,
                    onRemove: () {
                      controller.toggleTransactionType(t);
                      _fetchWithCurrentFilters(isRefresh: true);
                    },
                  ));
                }
              }

              if (controller.filterDurationType != 'all') {
                final durationLabel = _durationLabel(context, controller.filterDurationType);
                chips.add(_ActiveFilterChip(
                  label: durationLabel,
                  onRemove: () {
                    controller.setFilterDurationType('all');
                    _fetchWithCurrentFilters(isRefresh: true);
                  },
                ));
              }

              if (chips.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(
                  left: Dimensions.paddingSizeDefault,
                  right: Dimensions.paddingSizeDefault,
                  top: Dimensions.paddingSizeSmall,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: chips),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        controller.resetFilters();
                        _searchAuctionId = null;
                        _searchController.clear();
                        controller.getAuctionTransactionList(context, isRefresh: true);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        getTranslated('clear_all', context) ?? 'Clear All',
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          Expanded(
            child: Consumer<AuctionTransactionController>(
              builder: (context, controller, _) {
                if (controller.isLoading && controller.transactions.isEmpty) {
                  return const AuctionTransactionShimmerWidget();
                }

                if (controller.transactions.isEmpty) {
                  return Center(
                    child: Text(
                      getTranslated('no_transaction_found', context) ?? 'No transactions found',
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => _fetchWithCurrentFilters(isRefresh: true),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: PaginatedListViewWidget(
                      scrollController: _scrollController,
                      totalSize: controller.totalSize,
                      offset: controller.offset,
                      onPaginate: (offset) => _fetchWithCurrentFilters(offset: offset ?? 1),
                      itemView: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(
                          top: Dimensions.paddingSizeExtraSmall,
                          bottom: Dimensions.paddingSizeDefault,
                        ),
                        itemCount: controller.transactions.length,
                        itemBuilder: (context, index) {
                          final t = controller.transactions[index];
                          return AuctionTransactionTileWidget(
                            amount: t.amount ?? 0.0,
                            auctionNumber: '${t.auctionProductId ?? ''}',
                            dateTime: DateTime.tryParse(t.date ?? '')?.toLocal() ?? DateTime.now(),
                            type: t.type == 'credit' ? TransactionType.credit : TransactionType.debit,
                            transactionType: t.transactionType,
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
    );
  }

  String _durationLabel(BuildContext context, String type) {
    switch (type) {
      case 'this_month': return getTranslated('this_month', context) ?? 'This Month';
      case 'this_year': return getTranslated('this_year', context) ?? 'This Year';
      case 'custom_date': return getTranslated('custom', context) ?? 'Custom';
      default: return type;
    }
  }
}

class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveFilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: robotoRegular.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: Theme.of(context).colorScheme.primary,
        )),
        const SizedBox(width: 4),
        InkWell(
          onTap: onRemove,
          child: Icon(Icons.close, size: 14, color: Theme.of(context).colorScheme.primary),
        ),
      ]),
    );
  }
}
