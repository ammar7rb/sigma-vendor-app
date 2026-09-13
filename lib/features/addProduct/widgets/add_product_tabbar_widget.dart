import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';

class AddProductTitleBar extends StatefulWidget {
  final TabController tabController;
  const AddProductTitleBar({super.key, required this.tabController});

  @override
  State<AddProductTitleBar> createState() => _AddProductTitleBarState();
}

class _AddProductTitleBarState extends State<AddProductTitleBar>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).hintColor.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        ),
        child: TabBar(
          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
          controller: widget.tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Theme.of(context).hintColor,
          labelStyle: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: Theme.of(context).textTheme.labelMedium,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(4),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
            color: Theme.of(context).primaryColor,
          ),
          tabs: widget.tabController.length == 3
              ? [
                  Tab(text: getTranslated('general_info', context)),
                  Tab(
                      text:
                          getTranslated('seller_product_price_stock', context)),
                  Tab(
                      text: getTranslated(
                          'seller_product_review_submit', context)),
                ]
              : List.generate(widget.tabController.length,
                  (index) => Tab(text: '${index + 1}')),
        ),
      ),
    );
  }
}
