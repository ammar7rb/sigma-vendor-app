import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_tab_view_screen.dart';
import 'package:sixvalley_vendor_app/features/product_details/screens/product_details_screen.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/filter_model.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/no_data_screen.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/paginated_list_view_widget.dart';
import 'package:sixvalley_vendor_app/features/order/screens/order_screen.dart';

class ProductViewWidget extends StatefulWidget {
  final int? sellerId;
  final bool fromNotification;
  final double keyboardHeight;
  const ProductViewWidget(
      {super.key,
      required this.sellerId,
      this.fromNotification = false,
      required this.keyboardHeight});

  @override
  State<ProductViewWidget> createState() => _ProductViewWidgetState();
}

class _ProductViewWidgetState extends State<ProductViewWidget> {
  ScrollController scrollController = ScrollController();
  String message = "";
  bool activated = false;
  bool endScroll = false;
  void _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        endScroll = true;
        message = "bottom";
        if (kDebugMode) {
          print('=========$message=========');
        }
      });
    } else {
      if (endScroll) {
        setState(() {
          endScroll = false;
        });
      }
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  int? userId;

  @override
  void initState() {
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
    userId = Provider.of<ProfileController>(context, listen: false).userId;
    if (widget.fromNotification) {
      Provider.of<ProductController>(context, listen: false)
          .emptySellerProduct();
      Provider.of<ProfileController>(context, listen: false)
          .getSellerInfo()
          .then((responce) {
        if (responce.isSuccess) {
          userId = Provider.of<ProfileController>(Get.context!, listen: false)
              .userId;
          Provider.of<ProductController>(Get.context!, listen: false)
              .getSellerProductList(
                  Provider.of<ProfileController>(Get.context!, listen: false)
                      .userId
                      .toString(),
                  1,
                  Provider.of<LocalizationController>(Get.context!,
                                  listen: false)
                              .locale
                              .languageCode ==
                          'US'
                      ? 'en'
                      : Provider.of<LocalizationController>(Get.context!,
                              listen: false)
                          .locale
                          .countryCode!
                          .toLowerCase(),
                  '');
        } else {
          Provider.of<ProductController>(Get.context!, listen: false)
              .getSellerProductList(
                  Provider.of<ProfileController>(Get.context!, listen: false)
                      .userId
                      .toString(),
                  1,
                  Provider.of<LocalizationController>(Get.context!,
                                  listen: false)
                              .locale
                              .languageCode ==
                          'US'
                      ? 'en'
                      : Provider.of<LocalizationController>(Get.context!,
                              listen: false)
                          .locale
                          .countryCode!
                          .toLowerCase(),
                  '');
        }
      });
    } else {
      Provider.of<ProductController>(context, listen: false)
          .getSellerProductList(
              Provider.of<ProfileController>(context, listen: false)
                  .userId
                  .toString(),
              1,
              Provider.of<LocalizationController>(context, listen: false)
                          .locale
                          .languageCode ==
                      'US'
                  ? 'en'
                  : Provider.of<LocalizationController>(context, listen: false)
                      .locale
                      .countryCode!
                      .toLowerCase(),
              '');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String userId = Provider.of<ProfileController>(context, listen: false)
        .userId
        .toString();

    return RefreshIndicator(
      onRefresh: () async {
        Provider.of<ProductController>(context, listen: false)
            .getSellerProductList(
                Provider.of<ProfileController>(context, listen: false)
                    .userId
                    .toString(),
                1,
                Provider.of<LocalizationController>(context, listen: false)
                            .locale
                            .languageCode ==
                        'US'
                    ? 'en'
                    : Provider.of<LocalizationController>(
                            context,
                            listen: false)
                        .locale
                        .countryCode!
                        .toLowerCase(),
                '',
                filterSearchModel:
                    Provider.of<ProductController>(context, listen: false)
                        .filterModel);
      },
      child: Consumer<ProductController>(
        builder: (context, prodProvider, child) {
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                (prodProvider.sellerProductModel != null)
                    ? (prodProvider.sellerProductModel!.products != null &&
                            prodProvider
                                .sellerProductModel!.products!.isNotEmpty)
                        ? NotificationListener<ScrollNotification>(
                            onNotification: (scrollNotification) {
                              return false;
                            },
                            child: SingleChildScrollView(
                              controller: scrollController,
                              child: PaginatedListViewWidget(
                                reverse: false,
                                scrollController: scrollController,
                                totalSize:
                                    prodProvider.sellerProductModel?.totalSize,
                                offset: prodProvider.sellerProductModel != null
                                    ? int.parse(prodProvider
                                        .sellerProductModel!.offset
                                        .toString())
                                    : null,
                                onPaginate: (int? offset) async {
                                  await prodProvider.getSellerProductList(
                                    userId,
                                    offset!,
                                    'en',
                                    '',
                                    filterSearchModel: FilterModel(
                                      reload: false,
                                      minPrice: prodProvider
                                          .sellerProductModel?.minPrice,
                                      maxPrice: prodProvider
                                          .sellerProductModel?.maxPrice,
                                      productType: [
                                        prodProvider.sellerProductModel
                                                ?.productType?.name ??
                                            ''
                                      ],
                                      categoryIds: prodProvider
                                          .sellerProductModel?.categoryIds,
                                      brandIds: prodProvider
                                          .sellerProductModel?.brandIds
                                          ?.toList(),
                                      authorIds: prodProvider
                                          .sellerProductModel?.authorIds
                                          ?.toList(),
                                      publishingHouseIds: prodProvider
                                          .sellerProductModel?.publishHouseIds
                                          ?.toList(),
                                      startDate: prodProvider
                                          .sellerProductModel?.startDate,
                                      endDate: prodProvider
                                          .sellerProductModel?.endDate,
                                    ),
                                  );
                                },
                                itemView: ListView.builder(
                                  itemCount: prodProvider
                                      .sellerProductModel!.products!.length,
                                  padding: const EdgeInsets.all(0),
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal:
                                                Dimensions.paddingSizeSmall),
                                        child: _SellerProductCard(
                                            product: prodProvider
                                                .sellerProductModel!
                                                .products![index]));
                                  },
                                ),
                              ),
                            ),
                          )
                        : const NoDataScreen()
                    : const OrderShimmer(),
                if (widget.keyboardHeight == 0) ...[
                  if (!endScroll)
                    Positioned(
                      bottom: 20,
                      right: Provider.of<LocalizationController>(context,
                                  listen: false)
                              .isLtr
                          ? 20
                          : null,
                      left: Provider.of<LocalizationController>(context,
                                  listen: false)
                              .isLtr
                          ? null
                          : 20,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton.extended(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          icon: const Icon(Icons.add_rounded),
                          label: Text(getTranslated('add_product', context)!,
                              style: robotoBold.copyWith(color: Colors.white)),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => AddProductTabView(
                                      product: null,
                                      addProduct: null,
                                      fromHome: false,
                                    )));
                          },
                        ),
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SellerProductCard extends StatelessWidget {
  final Product product;

  const _SellerProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    // Approval remains an internal administration workflow. The seller only
    // manages whether the product itself is active or paused.
    final isActive = product.status == 1 || product.requestStatus != 1;
    final imageUrl = product.thumbnailFullUrl?.path ?? '';
    final expiry = DateTime.tryParse(product.expiryDate ?? '');
    final daysToExpiry = expiry?.difference(DateTime.now()).inDays;
    final isNearExpiry =
        daysToExpiry != null && daysToExpiry >= 0 && daysToExpiry <= 90;

    return InkWell(
      borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(productModel: product))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
          border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: .45)),
          boxShadow: AppDesign.softShadow(Theme.of(context).brightness),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
            child: imageUrl.isEmpty
                ? Image.asset(Images.placeholderImage,
                    width: 92, height: 92, fit: BoxFit.cover)
                : FadeInImage.assetNetwork(
                    placeholder: Images.placeholderImage,
                    image: imageUrl,
                    width: 92,
                    height: 92,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (_, __, ___) => Image.asset(
                        Images.placeholderImage,
                        width: 92,
                        height: 92,
                        fit: BoxFit.cover),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    child: Text(product.name ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: robotoBold.copyWith(fontSize: 16))),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_horiz_rounded),
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => AddProductTabView(
                                  product: product,
                                  addProduct: null,
                                  fromHome: false)));
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailsScreen(productModel: product)));
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                        value: 'details',
                        child: Text(
                            getTranslated('product_details', context) ?? '')),
                    PopupMenuItem(
                        value: 'edit',
                        child: Text(getTranslated('edit', context) ?? '')),
                  ],
                ),
              ]),
              Text(PriceConverter.convertPrice(context, product.unitPrice),
                  style: robotoBold.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppDesign.brandLight
                          : Theme.of(context).primaryColor,
                      fontSize: 17)),
              const SizedBox(height: 7),
              Wrap(spacing: 8, runSpacing: 6, children: [
                _StatusChip(
                  label: getTranslated(
                          isActive ? 'active' : 'inactive', context) ??
                      '',
                  color: isActive ? AppDesign.success : AppDesign.warning,
                ),
                _StatusChip(
                  label:
                      '${getTranslated('current_stock', context)}: ${product.currentStock ?? 0}',
                  color: (product.currentStock ?? 0) > 0
                      ? AppDesign.primary
                      : AppDesign.danger,
                  muted: true,
                ),
                _StatusChip(
                  label:
                      '${getTranslated('orders', context)}: ${product.sellerOrdersCount ?? 0}',
                  color: AppDesign.primary,
                  muted: true,
                ),
                if (isNearExpiry)
                  _StatusChip(
                    label:
                        getTranslated('near_expiry', context) ?? 'Near expiry',
                    color: AppDesign.warning,
                  ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool muted;

  const _StatusChip(
      {required this.label, required this.color, this.muted = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
          color: isDark && muted
              ? Colors.white.withValues(alpha: .12)
              : color.withValues(alpha: muted ? .07 : .11),
          borderRadius: BorderRadius.circular(30)),
      child: Text(label,
          style: robotoMedium.copyWith(
              color: isDark
                  ? (muted ? Colors.white : Color.lerp(color, Colors.white, .7))
                  : color,
              fontSize: 12)),
    );
  }
}
