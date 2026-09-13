import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/coupon/controllers/coupon_controller.dart';
import 'package:sixvalley_vendor_app/features/pos/controllers/customer_controller.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/filter_model.dart';
import 'package:sixvalley_vendor_app/features/review/domain/models/review_model.dart';
import 'package:sixvalley_vendor_app/features/review/screens/review_reply_widget.dart';
import 'package:sixvalley_vendor_app/helper/debounce_helper.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/review/controllers/product_review_controller.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_search_field_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/no_data_screen.dart';
import 'package:sixvalley_vendor_app/features/order/screens/order_screen.dart';
import 'package:sixvalley_vendor_app/features/review/widgets/review_filter_bottom_sheet_widget.dart';
import 'package:sixvalley_vendor_app/features/review/widgets/review_widget.dart';


class ProductReviewScreen extends StatefulWidget {
  const ProductReviewScreen({super.key});

  @override
  State<ProductReviewScreen> createState() => _ProductReviewScreenState();
}

class _ProductReviewScreenState extends State<ProductReviewScreen> {

  final DebounceHelper _debounce = DebounceHelper(milliseconds: 500);

  @override
  void initState() {
    Provider.of<ProductReviewController>(context, listen: false).resetReviewData(isUpdate: false);
    Provider.of<CustomerController>(context, listen: false).getCustomerList('');
    Provider.of<CouponController>(context, listen: false).getCouponCustomerList(context,'');
    Provider.of<ProductController>(context, listen: false).getSellerProductList(Provider.of<ProfileController>(context, listen: false).
    userInfoModel!.id.toString(), 1, 'en','', filterSearchModel: FilterModel(reload: false)
    );
    super.initState();
  }


  @override
  void dispose() {
    _debounce.dispose();
    super.dispose();
  }

  TextEditingController searchController = TextEditingController();
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    Provider.of<ProductReviewController>(context, listen: false).getReviewList(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBarWidget(title: getTranslated('reviews', context),),
      body: Consumer<ProductReviewController>(
        builder: (context, reviewProvider, child) {
          List<ReviewModel> reviewList;
          reviewList = reviewProvider.reviewList;
          return
          Column(children: [
            //const SizedBox(height: Dimensions.paddingSizeSmall),
            Container(height: 70,
              color: Theme.of(context).canvasColor,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.paddingSizeSmall, 0,
                  Dimensions.paddingSizeSmall, 0
                ),
                child: CustomSearchFieldWidget(
                  controller: searchController,
                  hint: getTranslated('search_by_product_name', context),
                  prefix: Images.iconsSearch,
                  iconPressed: () => () {},
                  onSubmit: (text) => () {},
                  onChanged: (value) {
                    _debounce.run(() async {
                      await reviewProvider.searchReviewList(context, value);
                    });
                  },
                  isFilter: true,
                  filterAction: () {
                    showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      context: context, builder: (_) => const ReviewFilterBottomSheetWidget()
                    );
                  },
                ),
              ),
            ),

            (!reviewProvider.isLoading || !reviewProvider.isSearching) ? reviewList.isNotEmpty?
            Expanded(
              child: ListView.builder(
                itemCount: reviewList.length,
                padding: const EdgeInsets.all(0),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> ReviewReplyScreen(reviewModel: reviewList[index], index: index, productId: reviewList[index].productId,  formProduct: false))),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: reviewList.length == index+1 ? Dimensions.paddingSizeSmall : 0),
                      child: ReviewWidget(reviewModel: reviewList[index], index: index))
                  );
                },
              ),
            ) : const Expanded(child: NoDataScreen()): const Expanded(child: OrderShimmer()),


            ],
          );
        },
      ),
    );
  }
}
