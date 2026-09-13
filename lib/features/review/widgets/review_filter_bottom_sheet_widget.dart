import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_container_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_date_picker_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_drop_down_item_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/coupon/controllers/coupon_controller.dart';
import 'package:sixvalley_vendor_app/features/pos/controllers/customer_controller.dart';
import 'package:sixvalley_vendor_app/features/pos/screens/customer_search_screen.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/review/controllers/product_review_controller.dart';
import 'package:sixvalley_vendor_app/features/review/widgets/review_product_filter_widget.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class ReviewFilterBottomSheetWidget extends StatefulWidget {
  const ReviewFilterBottomSheetWidget({super.key});

  @override
  State<ReviewFilterBottomSheetWidget> createState() => _ReviewFilterBottomSheetWidgetState();
}

class _ReviewFilterBottomSheetWidgetState extends State<ReviewFilterBottomSheetWidget> {

  @override
  void initState() {
    Provider.of<ProductReviewController>(Get.context!,listen: false).setAllFieldSelected(true, isUpdate: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Consumer<ProductReviewController>(
          builder: (context, reviewProvider,_) {
            return Consumer<ProductController>(
                builder: (context, productProvider,_) {
                  return Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(Dimensions.paddingSizeDefault),
                            topRight: Radius.circular(Dimensions.paddingSizeDefault)
                        )
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeDefault),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(width: 30),

                              Text(getTranslated('filter_data', context)!,
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                              ),

                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  width: 30, height: 30,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).hintColor.withValues(alpha: 0.1)
                                  ),
                                  child: Icon(Icons.close, size: 20, color: Theme.of(context).textTheme.bodyLarge?.color),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Divider(color: Theme.of(context).hintColor.withValues(alpha: 0.1), height: 1),
                        const SizedBox(height: Dimensions.paddingSizeDefault),


                        if(productProvider.sellerProductModel != null && productProvider.sellerProductModel!.products != null && productProvider.sellerProductModel!.products!.isNotEmpty)
                          Consumer<ProductReviewController>(
                            builder: (context,productReviewController,_){
                              return CustomContainerWidget(title: productReviewController.selectedProductName, onTap: (){
                                showDialog(context: context, barrierDismissible: true,
                                  builder: (_) => const ReviewProductFilterWidget());
                              });
                            },
                          ),


                        Consumer<CouponController>(
                          builder: (context,cartController,_) {
                            return InkWell(
                              onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> const CustomerSearchScreen(isCoupon: true))),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                child: ClipRRect(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                  child: Container(width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      border: Border.all(width: .25, color: Theme.of(context).hintColor.withValues(alpha:.75)),
                                      color: Theme.of(context).cardColor,
                                      boxShadow: ThemeShadow.getShadow(context),
                                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)
                                    ),
                                    child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSize),
                                      child: Row(children: [
                                        Expanded(child: Text(cartController.searchCustomerController.text.trim().isNotEmpty?
                                        cartController.searchCustomerController.text: '${getTranslated('select_customer', context)}',
                                            style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color))),
                                        const Icon(Icons.arrow_drop_down_sharp)
                                      ],
                                      ),
                                    )),
                                ),
                              ));
                          }
                        ),


                        CustomDropDownItemWidget(
                          widget: DropdownButtonFormField<String>(
                            initialValue: reviewProvider.reviewStatusName,
                            isExpanded: true,
                            decoration: const InputDecoration(border: InputBorder.none),
                            iconSize: 24, elevation: 16, style: robotoRegular,
                            onChanged: (value){
                              reviewProvider.setReviewStatusIndex(value == 'select_status'? 0 : value == 'active'? 1 :2);
                            },
                            items: reviewProvider.reviewStatusList.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(getTranslated(value, context)!,
                                  style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
                              );
                            }).toList(),
                          ),
                        ),


                        Row(children: [
                          Expanded(child: CustomDatePickerWidget(
                            prefixIcon: false,
                            title: getTranslated('from', context),
                            image: Images.reviewCalenderIcon,
                            text: reviewProvider.startDate != null ?
                            reviewProvider.dateFormat.format(reviewProvider.startDate!).toString() : getTranslated('select_date', context),
                            selectDate: () => reviewProvider.selectDate("start", context),
                          )),
                          Expanded(child: CustomDatePickerWidget(
                            prefixIcon: false,
                            title: getTranslated('to', context),
                            image: Images.reviewCalenderIcon,
                            text: reviewProvider.endDate != null ?
                            reviewProvider.dateFormat.format(reviewProvider.endDate!).toString() : getTranslated('select_date', context),
                            selectDate: () => reviewProvider.selectDate("end", context),
                          )),
                        ]),
                        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                        Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomButtonWidget(
                                  btnTxt: getTranslated('clear_filter', context),
                                  backgroundColor: Theme.of(context).hintColor.withValues(alpha: 0.1),
                                  fontColor: Theme.of(context).textTheme.bodyLarge?.color,
                                  onTap: () {
                                    reviewProvider.resetReviewData();
                                    reviewProvider.getReviewList(context);
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeDefault),


                              Expanded(
                                child: CustomButtonWidget(
                                  isLoading: reviewProvider.isLoading,
                                  btnTxt: getTranslated('filter', context),
                                  onTap: () {
                                    if(reviewProvider.startDate == null && reviewProvider.endDate == null && reviewProvider.reviewStatusIndex == 0 && Provider.of<CustomerController>(context, listen: false).customerId == 0 && Provider.of<ProductReviewController>(context, listen: false).selectedProductId == 0) {
                                      showCustomToast(message: getTranslated('select_all_fields', context)!, context:  context, isSuccess: false);
                                    } else if ((reviewProvider.startDate != null &&  reviewProvider.endDate == null) || (reviewProvider.startDate == null &&  reviewProvider.endDate != null)) {
                                      showCustomToast(message: getTranslated('select_start_and_end_time', context)!, context:  context, isSuccess: false);
                                    } else if(reviewProvider.startDate != null && reviewProvider.endDate != null && !isEndDateValid(reviewProvider.startDate!, reviewProvider.endDate!)) {
                                      showCustomToast(message: getTranslated('end_date_should_not_before_start_date', context)!, context:  context, isSuccess: false);
                                    } else{
                                      reviewProvider.setAllFieldSelected(true);
                                      int?  productId = Provider.of<ProductReviewController>(context, listen: false).selectedProductId;
                                      int?  customerId = Provider.of<CouponController>(context, listen: false).customerId;

                                      String selectedCustomerId = customerId == 0 ? 'all' : customerId.toString();
                                      reviewProvider.filterReviewList(context, productId, selectedCustomerId);
                                      // Navigator.pop(context); // Close sheet after filter
                                    }
                                  }
                                ),
                              ),

                            ],
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                      ],
                    ),
                  );
                }
            );
          }
      ),
    );
  }

  bool isEndDateValid(DateTime startDate, DateTime endDate) {
    return endDate.isAfter(startDate) || endDate.isAtSameMomentAs(startDate);
  }
}