import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_tab_view_screen.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/features/product/widgets/limited_stock_product_update_dialog.dart';
import 'package:sixvalley_vendor_app/features/product_details/controllers/product_details_controller.dart';
import 'package:sixvalley_vendor_app/features/restock/controllers/restock_controller.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product? productModel;

  const ProductDetailsScreen({super.key, this.productModel});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final TextEditingController _stockQuantityController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.productModel?.id != null) {
      await Provider.of<ProductDetailsController>(context, listen: false)
          .getProductDetails(widget.productModel!.id);
    }
  }

  @override
  void dispose() {
    _stockQuantityController.dispose();
    super.dispose();
  }

  Future<void> _openRestockDialog(Product product) async {
    final restockController =
        Provider.of<RestockController>(context, listen: false);
    await showDialog<void>(
      context: context,
      builder: (_) => LimitedStockQuantityUpdateDialogWidget(
        stockQuantityController: _stockQuantityController,
        product: product,
        title: getTranslated('restock', context),
        onYesPressed: () async {
          final quantity = int.tryParse(_stockQuantityController.text.trim());
          if (quantity == null || quantity < 0) return;
          await restockController.updateProductQuantity(
            context,
            product.id,
            quantity,
            product.variation ?? [],
          );
          if (mounted) await _load();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductDetailsController>(
      builder: (context, controller, _) {
        final product = controller.productDetails ?? widget.productModel;
        return Scaffold(
          appBar: CustomAppBarWidget(
            title: getTranslated('product_details', context),
            isBackButtonExist: true,
          ),
          body: product == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    children: [
                      _ProductImage(image: product.thumbnailFullUrl?.path),
                      const SizedBox(height: 12),
                      _ProductHeader(
                        product: product,
                        onStatusChanged: (active) async {
                          await controller.productStatusOnOff(
                            context,
                            product.id,
                            active ? 1 : 0,
                          );
                        },
                      ),
                      if (product.imagesFullUrl?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 12),
                        _ProductGallery(product: product),
                      ],
                      const SizedBox(height: 12),
                      _DetailsCard(product: product),
                      if (product.details?.trim().isNotEmpty ?? false) ...[
                        const SizedBox(height: 12),
                        _SectionCard(
                          title: getTranslated('description', context) ?? '',
                          child: Html(data: product.details ?? ''),
                        ),
                      ],
                    ],
                  ),
                ),
          bottomNavigationBar: product == null
              ? null
              : SafeArea(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context)
                              .dividerColor
                              .withValues(alpha: .35),
                        ),
                      ),
                    ),
                    child: Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddProductTabView(
                                product: product,
                                addProduct: null,
                                fromHome: false,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(getTranslated('edit', context) ?? ''),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: () => _openRestockDialog(product),
                          icon: const Icon(Icons.add_box_outlined),
                          label: Text(getTranslated('restock', context) ?? ''),
                        ),
                      ),
                    ]),
                  ),
                ),
        );
      },
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String? image;

  const _ProductImage({this.image});

  @override
  Widget build(BuildContext context) => Container(
        height: 220,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
        ),
        clipBehavior: Clip.antiAlias,
        child: CustomImageWidget(image: image ?? '', fit: BoxFit.contain),
      );
}

class _ProductHeader extends StatelessWidget {
  final Product product;
  final ValueChanged<bool> onStatusChanged;

  const _ProductHeader({required this.product, required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    final isActive = product.status == 1 || product.requestStatus != 1;
    return _SectionCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name ?? '',
                    style: robotoBold.copyWith(fontSize: 18)),
                Text(
                  PriceConverter.convertPrice(context, product.unitPrice),
                  style: robotoBold.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppDesign.brandLight
                        : Theme.of(context).primaryColor,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Column(children: [
            Switch(value: isActive, onChanged: onStatusChanged),
            Text(
              getTranslated(isActive ? 'active' : 'inactive', context) ?? '',
              style: robotoMedium.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Color.lerp(
                        isActive ? AppDesign.success : AppDesign.warning,
                        Colors.white,
                        .7)
                    : (isActive ? AppDesign.success : AppDesign.warning),
              ),
            ),
          ]),
        ]),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _Pill(
            text:
                '${getTranslated('current_stock', context)}: ${product.currentStock ?? 0}',
          ),
          if (product.saleUnitType == 'package')
            _Pill(
              text:
                  '${product.piecesPerUnit ?? 0} ${getTranslated('seller_product_sale_unit_piece', context)}',
              success: true,
            ),
        ]),
      ]),
    );
  }
}

class _ProductGallery extends StatelessWidget {
  final Product product;

  const _ProductGallery({required this.product});

  @override
  Widget build(BuildContext context) => _SectionCard(
        title: getTranslated('additional_product_images', context) ?? '',
        child: SizedBox(
          height: 86,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: product.imagesFullUrl?.length ?? 0,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) => ClipRRect(
              borderRadius: BorderRadius.circular(AppDesign.radiusMedium),
              child: SizedBox(
                width: 86,
                child: CustomImageWidget(
                  image: product.imagesFullUrl?[index].path ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      );
}

class _DetailsCard extends StatelessWidget {
  final Product product;

  const _DetailsCard({required this.product});

  @override
  Widget build(BuildContext context) => _SectionCard(
        title: getTranslated('general_information', context) ?? '',
        child: Column(children: [
          _InfoRow(
            label: getTranslated('product_sku', context) ?? '',
            value: product.code ?? '-',
          ),
          _InfoRow(
            label: getTranslated('category', context) ?? '',
            value: product.category?.name ?? '-',
          ),
          _InfoRow(
            label: getTranslated('brand', context) ?? '',
            value: product.brand?.name ??
                getTranslated('no_brand', context) ??
                '-',
          ),
          _InfoRow(
            label:
                getTranslated('seller_product_sale_unit_type', context) ?? '',
            value: getTranslated(
                  product.saleUnitType == 'package'
                      ? 'seller_product_sale_unit_package'
                      : 'seller_product_sale_unit_piece',
                  context,
                ) ??
                '',
          ),
          _InfoRow(
            label: getTranslated('minimum_order_quantity', context) ?? '',
            value: '${product.minimumOrderQty ?? 1}',
            divider: false,
          ),
        ]),
      );
}

class _SectionCard extends StatelessWidget {
  final String? title;
  final Widget child;

  const _SectionCard({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: .45),
        ),
        boxShadow: AppDesign.softShadow(Theme.of(context).brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title?.isNotEmpty ?? false) ...[
            Text(title!, style: robotoBold.copyWith(fontSize: 16)),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool divider;

  const _InfoRow(
      {required this.label, required this.value, this.divider = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: divider
            ? Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: .35),
                ),
              )
            : null,
      ),
      child: Row(children: [
        Expanded(
          child: Text(label,
              style:
                  robotoRegular.copyWith(color: Theme.of(context).hintColor)),
        ),
        Flexible(
            child: Text(value, style: robotoBold, textAlign: TextAlign.end)),
      ]),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final bool success;

  const _Pill({required this.text, this.success = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: .12)
            : (success ? AppDesign.success : Theme.of(context).primaryColor)
                .withValues(alpha: .09),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: robotoMedium.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: isDark
              ? Colors.white
              : (success ? AppDesign.success : Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}
