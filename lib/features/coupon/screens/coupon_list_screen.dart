import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_dialog_widget.dart';
import 'package:sixvalley_vendor_app/features/coupon/widgets/coupon_details_dialog_widget.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/coupon/controllers/coupon_controller.dart';
import 'package:sixvalley_vendor_app/features/coupon/domain/models/coupon_model.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/no_data_screen.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/paginated_list_view_widget.dart';
import 'package:sixvalley_vendor_app/features/coupon/screens/add_new_coupon_screen.dart';
import 'package:sixvalley_vendor_app/features/coupon/widgets/coupon_card_widget.dart';
import 'package:sixvalley_vendor_app/features/order/screens/order_screen.dart';
import 'package:sixvalley_vendor_app/features/seller_package/screens/seller_package_screen.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';



class CouponListScreen extends StatefulWidget {
  const CouponListScreen({super.key});
  @override
  State<CouponListScreen> createState() => _CouponListScreenState();
}

class _CouponListScreenState extends State<CouponListScreen> {

  ScrollController scrollController = ScrollController();

  bool isScrolledToEnd = false;


  void _onScroll() {
    if (scrollController.position.atEdge) {
      isScrolledToEnd = scrollController.position.pixels == scrollController.position.maxScrollExtent;
      setState(() {});
    }
  }


  @override
  void initState() {
    Provider.of<CouponController>(context, listen: false).getCouponList(context,1);
    scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: getTranslated('coupon_list', context)),
      body: Consumer<CouponController>(
        builder: (context, couponProvider,_) {
          if (couponProvider.couponModel == null) {
            return const OrderShimmer();
          }

          final coupons = couponProvider.couponModel!.coupons;
          return Column(children: [
            if (couponProvider.couponModel!.couponEntitlement != null)
              _CouponEntitlementBanner(entitlement: couponProvider.couponModel!.couponEntitlement!),
            Expanded(
              child: coupons != null && coupons.isNotEmpty
                  ? SingleChildScrollView(
                      controller: scrollController,
                      child: PaginatedListViewWidget(
                        reverse: false,
                        scrollController: scrollController,
                        totalSize: couponProvider.couponModel!.totalSize,
                        offset: int.tryParse(couponProvider.couponModel!.offset ?? '1'),
                        onPaginate: (int? offset) async {
                          await couponProvider.getCouponList(context, offset!, reload: false);
                        },
                        itemView: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: coupons.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) => InkWell(
                            onTap: () {
                              showAnimatedDialogWidget(context, CouponDetailsDialogWidget(coupons: coupons[index]));
                            },
                            child: Padding(
                              padding: EdgeInsets.only(bottom: coupons.length == index + 1 ? Dimensions.paddingSizeSmall : 0),
                              child: CouponCardWidget(coupons: coupons[index], index: index),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const NoDataScreen(),
            ),
          ]);

        }
      ),

      // Do not offer coupon creation in the app when the active package has no remaining quota.
      floatingActionButton: isScrolledToEnd || couponCreationLocked(context) ? null : FloatingActionButton(
        backgroundColor: Theme.of(context).cardColor,
        child: Icon(Icons.add,color: Theme.of(context).primaryColor,),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (_)=> const AddNewCouponScreen()));
        },
      ),
    );
  }

  bool couponCreationLocked(BuildContext context) {
    final entitlement = Provider.of<CouponController>(context, listen: false).couponModel?.couponEntitlement;
    return entitlement != null && !entitlement.allowed;
  }
}

class _CouponEntitlementBanner extends StatelessWidget {
  final CouponEntitlement entitlement;

  const _CouponEntitlementBanner({required this.entitlement});

  @override
  Widget build(BuildContext context) {
    final isAllowed = entitlement.allowed;
    final remaining = entitlement.remaining;
    final total = entitlement.limit;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, 0),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: isAllowed ? Theme.of(context).primaryColor.withValues(alpha: .08) : Theme.of(context).colorScheme.error.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Package coupon quota: $remaining / $total remaining', style: Theme.of(context).textTheme.titleSmall),
        if (!isAllowed) ...[
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          const Text('Your current package has no coupon quota available.'),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          OutlinedButton.icon(
            // Package upgrades are controlled by the existing seller package screen.
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerPackageScreen())),
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('View packages'),
          ),
        ],
      ]),
    );
  }
}
