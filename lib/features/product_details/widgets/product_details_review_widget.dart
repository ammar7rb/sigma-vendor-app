import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/no_data_screen.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/paginated_list_view_widget.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/features/review/controllers/product_review_controller.dart';
import 'package:sixvalley_vendor_app/features/review/domain/models/product_review_model.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/rating_bar_widget.dart';
import 'package:sixvalley_vendor_app/features/product/widgets/product_review_item_widget.dart';

class ProductReviewWidget extends StatefulWidget {
  final Product? productModel;
  const ProductReviewWidget({super.key, this.productModel});
  @override
  State<ProductReviewWidget> createState() => _ProductReviewWidgetState();
}

class _ProductReviewWidgetState extends State<ProductReviewWidget> {
  ScrollController scrollController = ScrollController();
  late ScrollController _controller;
  String message = "";
  bool activated = false;
  bool endScroll = false;

  void _onStartScroll(ScrollMetrics metrics) {
    setState(() {
      message = "start";
    });
  }

  void _onUpdateScroll(ScrollMetrics metrics) {
    setState(() {
      message = "scrolling";
    });
  }

  void _onEndScroll(ScrollMetrics metrics) {
    setState(() {
      message = "end";
    });
  }

  void _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent && !_controller.position.outOfRange) {
      setState(() {
        endScroll = true;
        message = "bottom";
      });
    }
  }

  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(message == 'end' && !endScroll){
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            activated = true;
          });
        }
      });
    }else{
      activated = false;
    }

    return RefreshIndicator(
      onRefresh: () async{
        Provider.of<ProductReviewController>(context, listen: false).getProductWiseReviewList(context, 1, widget.productModel!.id);
      },
      child: Consumer<ProductReviewController>(
          builder: (context, review,_) {
            double fiveStar = 0.0, fourStar = 0.0, threeStar = 0.0, twoStar = 0.0, oneStar = 0.0;

            if(review.productReviewModel != null && review.productReviewModel!.groupWiseRating!.isNotEmpty){
              List<GroupWiseRating> rating = review.productReviewModel!.groupWiseRating!;
              for(int i =0 ; i< rating.length; i++){
                if(rating[i].rating == 1){
                  oneStar = (rating[i].rating! * rating[i].total!) / (rating.length * 5);
                }
                if(rating[i].rating == 2){
                  twoStar = (rating[i].rating! * rating[i].total!) / (rating.length * 5);
                }
                if(rating[i].rating == 3){
                  threeStar = (rating[i].rating! * rating[i].total!) / (rating.length * 5);
                }
                if(rating[i].rating == 4){
                  fourStar = (rating[i].rating! * rating[i].total!) / (rating.length * 5);
                }
                if(rating[i].rating == 5){
                  fiveStar = (rating[i].rating! * rating[i].total!) / (rating.length * 5);
                }
              }
            }

            return review.productReviewModel == null  ? const Center(child: CircularProgressIndicator()) : NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollStartNotification) {
                  _onStartScroll(scrollNotification.metrics);
                } else if (scrollNotification is ScrollUpdateNotification) {
                  _onUpdateScroll(scrollNotification.metrics);
                } else if (scrollNotification is ScrollEndNotification) {
                  _onEndScroll(scrollNotification.metrics);
                }
                return false;
              },
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.02),
                              spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2)
                            )
                          ]
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault)
                              ),
                              padding: const EdgeInsets.symmetric(vertical:  Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeSmall),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    (review.productReviewModel?.averageRating ?? review.productReviewModel?.averageRating.toString()) ?? '',
                                    style: robotoBold.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 25
                                    )
                                  ),

                                  RatingBarIndicatorWidget(
                                    rating: review.productReviewModel?.averageRating != null? double.parse(review.productReviewModel!.averageRating.toString()) : 0,
                                    itemBuilder: (context, index) => Icon(
                                      Icons.star_rate_rounded,
                                      color: Theme.of(context).colorScheme.secondary
                                    ),
                                    itemCount: 5,
                                    itemSize: 16,
                                    unratedColor: Theme.of(context).hintColor.withValues(alpha: 0.3),
                                    direction: Axis.horizontal,
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                  Text(
                                    "${review.productReviewModel?.totalSize} ${getTranslated('reviews', context)}",
                                    style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color),
                                  ),
                                ],
                              ),
                            ),



                            Expanded(
                              flex: 7,
                              child: Padding(
                                padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                                child: Column(
                                  children: [
                                    _progressBar(title: 'excellent', percent: fiveStar),
                                    _progressBar(title: 'good', percent: fourStar),
                                    _progressBar(title: 'average', percent: threeStar),
                                    _progressBar(title: 'below_average', percent: twoStar),
                                    _progressBar(title: 'poor', percent: oneStar),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      if(review.productReviewModel != null && (review.productReviewModel?.totalSize ?? 0) > 0)...[
                        Text(
                          getTranslated('review_list', context)!,
                          style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Theme.of(context).textTheme.bodyLarge?.color
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        PaginatedListViewWidget(
                          reverse: false,
                          scrollController: scrollController,
                          totalSize: review.productReviewModel!.totalSize,
                          offset: review.productReviewModel != null ? int.parse(review.productReviewModel!.offset!) : null,
                          onPaginate: (int? offset) async {
                            await review.getProductWiseReviewList(context, offset!, widget.productModel!.id);
                          },
                          itemView: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: review.productReviewList.length,
                            itemBuilder: (context, index){
                              return ProductReviewItemWidget(
                                reviewModel: review.productReviewList[index],
                                index: index,
                                productId: widget.productModel!.id!
                              );
                            },
                          ),
                        ),
                      ],

                      if(review.productReviewModel == null || (review.productReviewModel?.totalSize ?? 0) == 0)
                      NoDataScreen(
                        title:  getTranslated('no_reviews_found', context),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
      ),
    );
  }

  Widget _progressBar({required String title, required double percent, Color? colr}) {
    int percentageValue = (percent * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              getTranslated(title, context)!,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.headlineLarge?.color),
            ),
          ),

          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: percent,
                valueColor: AlwaysStoppedAnimation<Color>(colr ?? Theme.of(context).primaryColor),
                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ),
            ),
          ),

          const SizedBox(width: Dimensions.paddingSizeSmall),

          SizedBox(
            width: 30,
            child: Text(
              '$percentageValue%',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.headlineLarge?.color
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
