import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_loader_widget.dart';
import 'package:sixvalley_vendor_app/features/restock/controllers/restock_controller.dart';
import 'package:sixvalley_vendor_app/features/restock/widgets/restock_calender_widget.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

import '../../product/widgets/product_filter_bottomsheet_widget.dart';

class ProductFilterDialog extends StatefulWidget {
  final int? sellerId;
  final bool fromShop;
  const ProductFilterDialog({super.key, this.sellerId,  this.fromShop = true});

  @override
  ProductFilterDialogState createState() => ProductFilterDialogState();
}

class ProductFilterDialogState extends State<ProductFilterDialog> {
  List<int> authors = [];
  List<int> publishingHouses = [];


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Dismissible(
      key: const Key('key'),
      direction: DismissDirection.down,
      onDismissed: (_) => Navigator.pop(context),
      child: Consumer<RestockController>(builder: (context, restockProvider, child) {
        return  Container(
          constraints: BoxConstraints(maxHeight: size.height * 0.8, minHeight: 150),
          decoration: BoxDecoration(color: Theme.of(context).highlightColor,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: Column(
            children: [

              Column( mainAxisSize: MainAxisSize.min, children: [
                // const SizedBox(height: Dimensions.paddingSizeSmall),
                // Center(child: Container(width: 35,height: 4,decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                //   color: Theme.of(context).hintColor.withValues(alpha:.5)))),
                // const SizedBox(height: Dimensions.paddingSizeDefault),

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

              ]),


            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeMedium),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleWidget(title: getTranslated('restoke_request_date', context)!),

                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  border: Border.all(color: Theme.of(context).hintColor),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(child: Row(children: [
                                      Text(restockProvider.startDate != null ? DateConverter.localDateToIsoStringDate(DateTime.parse(restockProvider.startDate!)) : getTranslated('start_date', context)!,
                                          style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),

                                      const Text(' - '),

                                      Text(restockProvider.endDate != null ?  DateConverter.localDateToIsoStringDate(DateTime.parse(restockProvider.endDate!)) : getTranslated('end_date', context)!,
                                          style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault,  color: Theme.of(context).textTheme.bodyLarge?.color)
                                      ),
                                    ],
                                    )),

                                    InkWell(
                                      onTap: ()=> showDialog(context: context, builder: (_)=> const RestockCalenderWidget()),
                                      child: SizedBox(
                                          height: 25, width: 25,
                                          child: Image.asset(Images.calender)
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: Dimensions.paddingSizeSmall),

            if(restockProvider.brands != null && (restockProvider.brands?.isNotEmpty ?? false))
            Expanded(child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeMedium),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitleWidget(title: getTranslated('brand', context)!),

                      if(restockProvider.brands != null && (restockProvider.brands?.isNotEmpty ?? false))
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeMedium),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: 40.0,
                              maxHeight: 350.0,
                            ),
                            child: SizedBox(
                              child: ListView.builder(
                                itemCount: restockProvider.brands?.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index){
                                  return CategoryFilterItem(
                                    title: restockProvider.brands![index].name,
                                    count: restockProvider.brands![index].productCount.toString(),
                                    checked: restockProvider.brands![index].checked!,
                                    onTap: () => restockProvider.checkedToggleBrand(index)
                                  );
                                }),
                            ),
                          ),
                        ),

                    ],
                  ),
                ),
              ),
            )),




              Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child:  Row(
                  children: [
                    Expanded(
                      child: CustomButtonWidget(
                        btnTxt: getTranslated('clear_filter', context),
                        backgroundColor: Theme.of(context).hintColor.withValues(alpha: 0.1),
                        fontColor: Theme.of(context).textTheme.bodyLarge?.color,
                        onTap: () async {
                          showDialog(context: context, builder: (ctx)  => const CustomLoaderWidget());
                          await restockProvider.resetChecked();
                          if(context.mounted) {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    
                    Expanded(
                      child: CustomButtonWidget(
                        btnTxt : getTranslated('apply', context),
                        backgroundColor: (restockProvider.startDate == null && restockProvider.selectedBrandIds.isEmpty) ? Theme.of(context).hintColor : null,
                        onTap: () async {
                          if(restockProvider.startDate == null && restockProvider.selectedBrandIds.isEmpty) {
                            // showCustomSnackBarWidget('${getTranslated('select_date_or_brand', context)}', context, isToaster: true);
                          } else{
                            restockProvider.getRestockProductList(1);
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ],
                )



              ),
            ],
          ),
        );
      }),
    );
  }
}

// class FilterItemWidget extends StatelessWidget {
//   final String? title;
//   final int index;
//   const FilterItemWidget({super.key, required this.title, required this.index});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
//       child: Container(decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
//         child: Row(children: [
//           Padding(padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
//             child: InkWell(
//                 onTap: ()=> Provider.of<SearchProductController>(context, listen: false).setFilterIndex(index),
//                 child: Icon(Provider.of<SearchProductController>(context).filterIndex == index? Icons.check_box_rounded: Icons.check_box_outline_blank_rounded,
//                     color: (Provider.of<SearchProductController>(context).filterIndex == index )? Theme.of(context).primaryColor: Theme.of(context).hintColor.withValues(alpha:.5))),
//           ),
//           Expanded(child: Text(title??'', style: textRegular.copyWith())),
//
//         ],),),
//     );
//   }
// }
//
class CategoryFilterItem extends StatelessWidget {
  final String? title;
  final String? count;
  final bool checked;
  final Function()? onTap;
  const CategoryFilterItem({super.key, required this.title, required this.checked, this.onTap, this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: onTap,
        child: Container(decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Padding(padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
              child: Icon(checked? Icons.check_box_rounded: Icons.check_box_outline_blank_rounded,
                  color: (checked && !Provider.of<ThemeController>(context, listen: false).darkTheme)?
                  Theme.of(context).primaryColor:(checked && Provider.of<ThemeController>(context, listen: false).darkTheme)?
                  Colors.white : Theme.of(context).hintColor.withValues(alpha:.5)),
            ),
            Expanded(child: Text(title??'', style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 1,  overflow: TextOverflow.ellipsis)),

            Text(count??'', style: robotoMedium.copyWith(color: Theme.of(context).hintColor))

          ],),
        ),
      ),
    );
  }
}

