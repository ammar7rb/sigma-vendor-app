import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/seller_promotion/controllers/seller_promotion_controller.dart';
import 'package:sixvalley_vendor_app/features/seller_promotion/domain/models/seller_promotion_overview_model.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class SellerPromotionScreen extends StatefulWidget {
  const SellerPromotionScreen({super.key});

  @override
  State<SellerPromotionScreen> createState() => _SellerPromotionScreenState();
}

class _SellerPromotionScreenState extends State<SellerPromotionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final controller = Provider.of<SellerPromotionController>(context, listen: false);
      // Package quotas are the only promotion eligibility source.
      controller.getOverview(SellerPromotionType.search);
      controller.getOverview(SellerPromotionType.homepage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: CustomAppBarWidget(title: getTranslated('promotions', context) ?? 'Promotions'),
        body: Column(children: [
          Container(
            color: Theme.of(context).cardColor,
            child: TabBar(tabs: [
              Tab(text: getTranslated('search_results', context) ?? 'Search results'),
              Tab(text: getTranslated('homepage', context) ?? 'Homepage'),
            ]),
          ),
          const Expanded(child: TabBarView(children: [
            _PromotionTypeView(type: SellerPromotionType.search),
            _PromotionTypeView(type: SellerPromotionType.homepage),
          ])),
        ]),
      ),
    );
  }
}

class _PromotionTypeView extends StatelessWidget {
  final SellerPromotionType type;

  const _PromotionTypeView({required this.type});

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerPromotionController>(builder: (context, controller, _) {
      final overview = controller.overview(type);
      if (overview == null) {
        return controller.isLoading(type)
            ? const Center(child: CircularProgressIndicator())
            : Center(child: IconButton(
              tooltip: getTranslated('retry', context) ?? 'Retry', icon: const Icon(Icons.refresh),
              onPressed: () => controller.getOverview(type),
            ));
      }

      return RefreshIndicator(
        onRefresh: () => controller.getOverview(type),
        child: ListView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          children: [
            _PromotionQuotaCard(summary: overview.summary, type: type),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Text(getTranslated('eligible_products', context) ?? 'Eligible products', style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            if (overview.products.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                child: Center(child: Text(getTranslated('no_approved_products_available', context) ?? 'No approved products are available.')),
              ),
            ...overview.products.map((product) => _PromotionProductTile(
              product: product, summary: overview.summary, type: type,
            )),
          ],
        ),
      );
    });
  }
}

class _PromotionQuotaCard extends StatelessWidget {
  final SellerPromotionSummary summary;
  final SellerPromotionType type;

  const _PromotionQuotaCard({required this.summary, required this.type});

  @override
  Widget build(BuildContext context) {
    final title = type == SellerPromotionType.search
        ? (getTranslated('search_promotion', context) ?? 'Search promotion')
        : (getTranslated('homepage_promotion', context) ?? 'Homepage promotion');
    final available = summary.canPromote;
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: .25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(type == SellerPromotionType.search ? Icons.search : Icons.home_outlined),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(child: Text(title, style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge))),
          Icon(available ? Icons.verified_outlined : Icons.lock_outline,
            color: available ? Colors.green : Theme.of(context).colorScheme.error),
        ]),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text('${getTranslated('remaining', context) ?? 'Remaining'}: ${summary.remaining} / ${summary.limit}', style: titilliumSemiBold),
        Text('${getTranslated('duration', context) ?? 'Duration'}: ${summary.durationDays} ${getTranslated('days', context) ?? 'days'}', style: titilliumRegular),
        if (summary.activePackage != null) Text('${getTranslated('package', context) ?? 'Package'}: ${summary.activePackage}', style: titilliumRegular),
      ]),
    );
  }
}

class _PromotionProductTile extends StatelessWidget {
  final SellerPromotionProduct product;
  final SellerPromotionSummary summary;
  final SellerPromotionType type;

  const _PromotionProductTile({required this.product, required this.summary, required this.type});

  @override
  Widget build(BuildContext context) {
    final canActivate = summary.canPromote && !product.isPromoted && !product.hasPendingRequest;
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: .25)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: titilliumSemiBold),
        subtitle: product.hasPendingRequest
            ? Text(getTranslated('advertising_request_pending_admin_review', context) ?? 'Advertising request is pending admin review.', style: titilliumRegular)
            : product.approvalStatus == 'rejected'
                ? Text('${getTranslated('advertising_request_rejected', context) ?? 'Advertising request rejected'}: ${product.reviewNote ?? '-'}', style: titilliumRegular.copyWith(color: Theme.of(context).colorScheme.error))
            : product.isPromoted
            ? Text('${getTranslated('active_until', context) ?? 'Active until'}: ${product.expiresAt ?? '-'}', style: titilliumRegular)
            : null,
        trailing: product.hasPendingRequest
            ? const Icon(Icons.hourglass_top, color: Colors.orange)
            : product.isPromoted
            ? const Icon(Icons.verified, color: Colors.green)
            : IconButton(
              tooltip: getTranslated('request_advertising', context) ?? 'Request advertising',
              onPressed: canActivate ? () => _activate(context) : null,
              icon: const Icon(Icons.campaign_outlined),
            ),
      ),
    );
  }

  Future<void> _activate(BuildContext context) async {
    final activated = await Provider.of<SellerPromotionController>(context, listen: false)
        .activatePromotion(type: type, productId: product.id);
    if (activated && context.mounted) {
      showCustomSnackBarWidget(getTranslated('advertising_request_sent_for_admin_review', context) ?? 'Advertising request sent for admin review.', context, isError: false);
    }
  }
}
