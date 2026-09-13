import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/digital_product_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/category_model.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/category_controller.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/product/domain/enums/product_type_enum.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/filter_model.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/config_model.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class ProductFilterBottomSheet extends StatefulWidget {
  const ProductFilterBottomSheet({super.key});
  
  @override
  State<ProductFilterBottomSheet> createState() => _ProductFilterBottomSheetState();
}

class _ProductFilterBottomSheetState extends State<ProductFilterBottomSheet> {
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();

  final List<String> _sortingOptions = [
    'default_recent_created',
    'show_older_first',
    'top_selling_products',
    'most_popular_products'
  ];

  @override
  void initState() {
    final ProductController productController = Provider.of<ProductController>(context, listen: false);
    productController.initFilterData(context);
    minPriceController.text = (productController.minPrice ?? 0).toStringAsFixed(0);
    maxPriceController.text = (productController.maxPrice ?? 0).toStringAsFixed(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    if(!isKeyboardOpen){
      _onCheckPriceRangeValidity(minPriceController, maxPriceController);
    }

    return GestureDetector(
      onTap: ()=> _onCloseKeyboard(minPriceController, maxPriceController),
      child: Consumer<ProductController>(builder: (context, productProvider, _) {

        return Container(
          constraints: BoxConstraints(maxHeight: size.height * 0.95),
          color: Theme.of(context).cardColor,
          child: Column(children: [
            FilterTitleWidget(),
            Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: .15), thickness: 1),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Dimensions.paddingSizeSmall),

                      Container(
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeMedium),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TitleWidget(title: getTranslated('sorting', context)!),

                            Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              ),
                              child: RadioGroup<int>(
                                groupValue: productProvider.filterSortIndex,
                                onChanged: (int? value) {
                                  productProvider.setFilterSortIndex(value!);
                                },
                                child: Column(
                                  children: [
                                    ...List.generate(_sortingOptions.length, (index) {
                                      return RadioListTile<int>(
                                        contentPadding: EdgeInsets.zero,
                                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                        activeColor: Theme.of(context).primaryColor,
                                        title: Text(
                                          getTranslated(_sortingOptions[index], context) ?? _sortingOptions[index],
                                          style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                                        ),
                                        value: index,
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Dimensions.paddingSizeSmall),


                      Container(
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeMedium),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TitleWidget(title: getTranslated('product_type', context)!),

                            Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _CheckboxItem(
                                          isStart: true,
                                          title: getTranslated('physical', context),
                                          checked: productProvider.filterModel.productType!.contains('physical'),
                                          onTap: () {
                                            if(productProvider.filterModel.productType!.contains('physical')) {
                                              productProvider.filterModel.productType!.remove('physical');
                                            } else{
                                              productProvider.filterModel.productType!.add('physical');
                                            }
                                            _onCloseKeyboard(minPriceController, maxPriceController);
                                            productProvider.setSelectedProductType(type: ProductTypeEnum.physical);
                                            productProvider.onClearAuthorIds();
                                            productProvider.onClearPublisherIds();
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: _CheckboxItem(
                                          isStart: true,
                                          title: getTranslated('digital', context),
                                          checked: productProvider.filterModel.productType!.contains('digital'),
                                          onTap: () {
                                            if(productProvider.filterModel.productType!.contains('digital')) {
                                              productProvider.filterModel.productType!.remove('digital');
                                            } else{
                                              productProvider.filterModel.productType!.add('digital');
                                            }
                                            _onCloseKeyboard(minPriceController, maxPriceController);
                                            productProvider.setSelectedProductType(type: ProductTypeEnum.digital);
                                            productProvider.onClearBrandIds();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: Dimensions.paddingSizeSmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Dimensions.paddingSizeSmall),


                      Container(
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeMedium),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TitleWidget(title: getTranslated('product_status', context)!),

                            Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _CheckboxItem(
                                          isStart: true,
                                          title: getTranslated('active', context),
                                          checked: productProvider.filterModel.status!.contains('active'),
                                          onTap: () {
                                            if(productProvider.filterModel.status!.contains('active')) {
                                              productProvider.filterModel.status!.remove('active');
                                            } else{
                                              productProvider.filterModel.status!.add('active');
                                            }
                                            setState(() {});
                                          },
                                        ),
                                      ),

                                      Expanded(
                                        child: _CheckboxItem(
                                          isStart: true,
                                          title: getTranslated('inactive', context),
                                          checked: productProvider.filterModel.status!.contains('inactive'),
                                          onTap: () {
                                            if(productProvider.filterModel.status!.contains('inactive')) {
                                              productProvider.filterModel.status!.remove('inactive');
                                            } else{
                                              productProvider.filterModel.status!.add('inactive');
                                            }
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: Dimensions.paddingSizeSmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeMedium),


                      /// price range
                      // TitleWidget(title: getTranslated('price_range', context)!),
                      // ProductPriceRangeWidget(
                      //   minPriceController: minPriceController,
                      //   maxPriceController: maxPriceController,
                      // ),
                      // const SizedBox(height: Dimensions.paddingSizeMedium),
                      // Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: .15), thickness: 1),


                      /// time range
                      // TitleWidget(title: getTranslated('created_at', context)!),
                      // InkWell(
                      //   onTap: () {
                      //     _onCloseKeyboard(minPriceController, maxPriceController);
                      //     showDialog(context: context, builder: (BuildContext context){
                      //       return Dialog(child: SizedBox(height: 400, child: CustomCalendarWidget(
                      //         initDateRange: PickerDateRange(productProvider.startDate, productProvider.endDate),
                      //         onSubmit: (PickerDateRange? range) => productProvider.selectDate(range?.startDate, range?.endDate),
                      //       )));
                      //     });
                      //   },
                      //   child: Container(
                      //     padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeMedium),
                      //     decoration: BoxDecoration(
                      //       border: Border.all(width: 1, color: Theme.of(context).hintColor.withValues(alpha: .15)),
                      //       borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                      //     ),
                      //     child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      //       Row(children: [
                      //         CustomDateRangePickerWidget(
                      //           text: productProvider.startDate == null ? 'dd-mm-yyyy' : DateConverter.dateStringMonthYear(productProvider.startDate),
                      //         ),
                      //         const SizedBox(width: Dimensions.paddingSizeSmall),
                      //         const Icon(Icons.horizontal_rule, size: Dimensions.iconSizeSmall),
                      //         const SizedBox(width: Dimensions.paddingSizeSmall),
                      //         CustomDateRangePickerWidget(
                      //           text: productProvider.endDate == null ? 'dd-mm-yyyy' : DateConverter.dateStringMonthYear(productProvider.endDate),
                      //         ),
                      //       ]),
                      //       SizedBox(width: Dimensions.iconSizeMedium, height: Dimensions.iconSizeMedium, child: Image.asset(Images.calendarIconFilter)),
                      //     ]),
                      //   ),
                      // ),
                      // const SizedBox(height: Dimensions.paddingSizeMedium),
                      // Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: .15), thickness: 1),


                      // 6. Brand (Checkbox List + See More)



                      if(!productProvider.filterModel.productType!.contains('digital'))...[
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeMedium),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: Consumer<ProductController>(builder: (context, productController, _) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TitleWidget(title: getTranslated('brand', context)!),

                                  Container(
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                    ),
                                    child: Column(
                                          children: [
                                            _CheckboxItem(
                                              title: getTranslated('all', context),
                                              checked: productProvider.selectedBrandIds.isEmpty,
                                              onTap: () => productProvider.onClearBrandIds(),
                                            ),

                                            Consumer<ProductController>(builder: (context, productController, _) {
                                              return Column(
                                                children: [
                                                  ListView.builder(
                                                    itemCount: productController.brandList?.length ?? 0,
                                                    shrinkWrap: true,
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    itemBuilder: (context, index){
                                                      if (!productController.brandSeeMore && index > 3) return const SizedBox.shrink();
                                                      if(productController.brandList?[index].id == null) return const SizedBox.shrink();

                                                      return _CheckboxItem(
                                                        title: productController.brandList?[index].name,
                                                        checked: productProvider.selectedBrandIds.contains(productController.brandList?[index].id),
                                                        onTap: () {
                                                          // _onCloseKeyboard(minPriceController, maxPriceController);
                                                          productProvider.onChangeBrandIds(productController.brandList![index].id!);
                                                        },
                                                      );
                                                    },
                                                  ),


                                                ],
                                              );
                                            }),

                                            SizedBox(height: Dimensions.paddingSizeSmall),
                                          ],

                                    ),
                                  ),



                                  if((productController.brandList?.length ?? 0) > 4)
                                    _ViewMoreWidget(
                                      count: ((productController.brandList!.length) - 4).toString(),
                                      onTap: () {
                                        productProvider.toggleBrandSeeMore();
                                      },
                                      isMore: productProvider.brandSeeMore,
                                      isActive: true,
                                    ),

                                ],
                              );
                            }
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeMedium),
                      ],


                      Consumer<DigitalProductController>(builder: (context, digitalProductController, _) {
                        return (!productProvider.filterModel.productType!.contains('physical')) ? Column(
                          children: [
                            if((digitalProductController.publishingHouseList?.length ?? 0) > 0)...[
                              _PublisherFilterItemWidget(minPriceController, maxPriceController),
                              const SizedBox(height: Dimensions.paddingSizeMedium),
                            ],

                            if((digitalProductController.authorsList?.length ?? 0) > 0)...[
                              _AuthorFilterItemWidget(minPriceController, maxPriceController),
                              const SizedBox(height: Dimensions.paddingSizeMedium),
                            ]
                          ],
                        ) : SizedBox();
                      }),



                      // 8. Category
                      Consumer<CategoryController>(builder: (context, addProductProvider, _) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeMedium),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          child: Consumer<ProductController>(builder: (context, productController, _) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TitleWidget(title: getTranslated('category', context)!),
                                Container(
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  ),
                                  child: Column(
                                    children: [
                                      ListView.builder(
                                        itemCount: addProductProvider.categoryList?.length,
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index){
                                          if (!productProvider.categorySeeMore && index > 3) return const SizedBox.shrink();
                                          return Column(
                                            children: [
                                              _CheckboxItem(
                                              title: addProductProvider.categoryList?[index].name,
                                                checked: addProductProvider.categoryList?[index].checked ?? false,
                                                showDropdown: addProductProvider.categoryList?[index].subCategories?.isNotEmpty,
                                                onTap: () {
                                                  _onCloseKeyboard(minPriceController, maxPriceController);
                                                  addProductProvider.toggleCategoryChecked(index);
                                                },
                                              ),

                                              // Sub Categories
                                              if((addProductProvider.categoryList?[index].checked ?? false) && addProductProvider.categoryList?[index].subCategories != null && addProductProvider.categoryList![index].subCategories!.isNotEmpty)
                                              ListView.builder(
                                                itemCount: addProductProvider.categoryList?[index].subCategories?.length,
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, subIndex){
                                                  return Column(
                                                    children: [
                                                      _CheckboxItem(
                                                        isSubCategory: true,
                                                        title: addProductProvider.categoryList?[index].subCategories?[subIndex].name,
                                                        checked: addProductProvider.categoryList?[index].subCategories?[subIndex].checked ?? false,
                                                        showDropdown: addProductProvider.categoryList?[subIndex].subCategories?.isNotEmpty,
                                                        onTap: () {
                                                          //_onCloseKeyboard(minPriceController, maxPriceController);
                                                          addProductProvider.toggleSubCategoryChecked(index, subIndex);
                                                        },
                                                      ),


                                                      // Sub Sub Categories
                                                      if((addProductProvider.categoryList?[index].subCategories![subIndex].checked ?? false) && addProductProvider.categoryList?[index].subCategories![subIndex].subSubCategories != null && addProductProvider.categoryList![index].subCategories![subIndex].subSubCategories!.isNotEmpty)
                                                        ListView.builder(
                                                          itemCount: addProductProvider.categoryList?[index].subCategories![subIndex].subSubCategories?.length,
                                                          shrinkWrap: true,
                                                          physics: const NeverScrollableScrollPhysics(),
                                                          itemBuilder: (context, subSubindex){
                                                            return _CheckboxItem(
                                                              isSubSubCategory: true,
                                                              title: addProductProvider.categoryList?[index].subCategories![subIndex].subSubCategories![subSubindex].name,
                                                              checked: addProductProvider.categoryList?[index].subCategories![subIndex].subSubCategories![subSubindex].checked ?? false,
                                                              showDropdown: false,
                                                              onTap: () {
                                                                //_onCloseKeyboard(minPriceController, maxPriceController);
                                                                addProductProvider.toggleSubSubCategoryChecked(index, subIndex, subSubindex);
                                                              },
                                                            );
                                                          },
                                                        ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      SizedBox(height: Dimensions.paddingSizeSmall),
                                    ],
                                  ),
                                ),


                                if((addProductProvider.categoryList?.length ?? 0) > 4)
                                  _ViewMoreWidget(
                                    count: ((addProductProvider.categoryList?.length ?? 0) - 4).toString() ,
                                    onTap: () {
                                      _onCloseKeyboard(minPriceController, maxPriceController);
                                      productProvider.toggleCategorySeeMore();
                                    },
                                    isMore: productProvider.categorySeeMore,
                                    isActive: true,
                                  ),

                              ],
                            );
                          }
                          ),
                        );
                      }),


                    ],
                  ),
                ),
              ),
            ),

            _ButtonWidget(minPriceController, maxPriceController)
          ]),
        );
      }),
    );
  }
}


class _StatusFilterWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int index) onFilterChanged;

  const _StatusFilterWidget({required this.selectedIndex, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    // Labels matching your controller logic (All, Active, Inactive)
    final List<String> filterList = ['all', 'active', 'inactive'];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filterList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          bool isSelected = selectedIndex == index;

          return Padding(
            padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
            child: InkWell(
              onTap: () => onFilterChanged(index),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : const Color(0xFFF4F5F7), // Light grey for unselected
                  borderRadius: BorderRadius.circular(50),
                ),
                alignment: Alignment.center,
                child: Text(
                  getTranslated(filterList[index], context) ?? filterList[index],
                  style: isSelected
                      ? robotoBold.copyWith(
                      color: Colors.white,
                      fontSize: Dimensions.fontSizeDefault
                  )
                      : robotoRegular.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                      fontSize: Dimensions.fontSizeDefault
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CheckboxItem extends StatelessWidget {
  final String? title;
  final bool checked;
  final bool? isStart;
  final bool? isSubCategory;
  final bool? isSubSubCategory;
  final bool? showDropdown;
  final Function()? onTap;
  const _CheckboxItem({required this.title, required this.checked, this.onTap, this.isStart = false, this.showDropdown = false, this.isSubCategory = false, this.isSubSubCategory = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: isStart!
              ? MainAxisAlignment.start
              : MainAxisAlignment.spaceBetween,
          children: [
            if (isStart!) ...[
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: checked
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).hintColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  color: checked
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                ),
                child: checked
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              SizedBox(width: Dimensions.paddingSizeSmall),
            ],

            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: isSubCategory! ? Dimensions.paddingSizeDefault : isSubSubCategory! ? Dimensions.paddingSizeButton : 0,
                  ),

                  Flexible(
                    child: Text(
                      title ?? '',
                      style: robotoRegular.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  if (showDropdown ?? false)
                    Icon(
                      checked ? Icons.keyboard_arrow_down_outlined : Icons.keyboard_arrow_right,
                      size: Dimensions.iconSizeMedium,
                      color: Theme.of(context).textTheme.headlineMedium?.color,
                    ),
                ],
              ),
            ),


            if (!isStart!)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: checked ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  color: checked ? Theme.of(context).primaryColor : Colors.transparent,
                ),
                child: checked ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
              ),
          ],
        ),
      ),
    );
  }
}

class _PublisherFilterItemWidget extends StatelessWidget {
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  const _PublisherFilterItemWidget(this.minPriceController, this.maxPriceController);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(builder: (context, productController, _) {
      return Consumer<DigitalProductController>(builder: (context, digitalProductController, _) {
        return Container(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeMedium),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Consumer<ProductController>(builder: (context, productController, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleWidget(title: getTranslated('publisher', context)!),

                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    child: Column(
                      children: [
                        Consumer<ProductController>(builder: (context, productController, _) {
                          return Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: digitalProductController.publishingHouseList?.length ?? 0,
                                itemBuilder: (context, index){
                                  if (!productController.publishingHouseSeeMore && index > 3) return const SizedBox.shrink();
                                  if(digitalProductController.publishingHouseList?[index].id == null) return const SizedBox.shrink();

                                  return _CheckboxItem(
                                    title: digitalProductController.publishingHouseList?[index].name,
                                    checked: productController.selectedPublishingHouseIds.contains(digitalProductController.publishingHouseList?[index].id),
                                    onTap: () => productController.onChangePublisherIds(digitalProductController.publishingHouseList![index].id!),
                                  );
                                },
                              ),
                            ],
                          );
                        }),

                        SizedBox(height: Dimensions.paddingSizeSmall),
                      ],

                    ),
                  ),

                  if((digitalProductController.publishingHouseList?.length ?? 0) > 4)
                    _ViewMoreWidget(
                      count: ((digitalProductController.publishingHouseList!.length) - 4).toString(),
                      onTap: () {
                        _onCloseKeyboard(minPriceController, maxPriceController);
                        productController.onTogglePublishingHouseSeeMore();
                      },
                      isMore: productController.publishingHouseSeeMore,
                      isActive: true,
                    ),

                ],
              );
            }
            ),
          );

      });
    }
    );
  }
}

class _AuthorFilterItemWidget extends StatelessWidget {
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  const _AuthorFilterItemWidget(this.minPriceController, this.maxPriceController);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductController>(builder: (context, productController, _) {
      return Consumer<DigitalProductController>(builder: (context, digitalProductController, _) {
        return
          Container(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeMedium),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Consumer<ProductController>(builder: (context, productController, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleWidget(title: getTranslated('author', context)!),

                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: digitalProductController.authorsList?.length ?? 0,
                          itemBuilder: (context, index){
                            if (!productController.authorSeeMore && index > 3) return const SizedBox.shrink();
                            if(digitalProductController.authorsList?[index].id == null) return const SizedBox.shrink();

                            return _CheckboxItem(
                              title: digitalProductController.authorsList?[index].name,
                              checked: productController.selectedAuthorIds.contains(digitalProductController.authorsList?[index].id),
                              onTap: () => productController.onChangeAuthorIds(digitalProductController.authorsList![index].id!),
                            );
                          },
                        ),

                        SizedBox(height: Dimensions.paddingSizeSmall),
                      ],

                    ),
                  ),

                  if((digitalProductController.authorsList?.length ?? 0) > 4)
                    _ViewMoreWidget(
                      count: ((digitalProductController.authorsList?.length ?? 0) - 4).toString(),
                      onTap: (){
                        _onCloseKeyboard(minPriceController, maxPriceController);
                        productController.onToggleAuthorSeeMore();
                      },
                      isMore: productController.authorSeeMore,
                      isActive: true,
                    ),

                ],
              );
            }
            ),
          );

      });
    });
  }
}

class _ViewMoreWidget extends StatelessWidget {
  final Function() onTap;
  final bool isMore;
  final bool isActive;
  final String count;
  const _ViewMoreWidget({required this.onTap, required this.isMore, required this.isActive, required this.count});

  @override
  Widget build(BuildContext context) {
    return isActive ? Center(child: TextButton(
      onPressed: ()=> onTap(),
      child: Text('${getTranslated(isMore ? 'see_less' : 'see_more', context)!}${!isMore ? '($count)' : ''}', style: robotoMedium.copyWith(
        color: Theme.of(context).primaryColor,
      )),
    )) : const SizedBox();
  }
}

class TitleWidget extends StatelessWidget {
  final String title;
  const TitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeExtraSmall),
      child: Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),
    );
  }
}

class FilterTitleWidget extends StatelessWidget {
  const FilterTitleWidget({super.key});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 30),
          Text(getTranslated('filter_data', context)!, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color)),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).hintColor.withValues(alpha: .1)),
              child: const Icon(Icons.close, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _ButtonWidget extends StatelessWidget {
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;

  const _ButtonWidget(this.minPriceController, this.maxPriceController);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.grey[Provider.of<ThemeController>(context).darkTheme ? 800 : 200]!, spreadRadius: 0.5, blurRadius: 0.3)],
      ),
      child: Consumer<ProductController>(builder: (ctx, productController, _) {
        return Row(children: [
          Expanded(child: CustomButtonWidget(
            isColor: true,
            btnTxt: '${getTranslated('clear_filter', context)}',
            backgroundColor: Theme.of(context).hintColor.withValues(alpha: .1),
            fontColor: Theme.of(context).textTheme.bodyLarge?.color,
            onTap: () async {
              if(true) {
                await productController.getSellerProductList(
                  '${Provider.of<ProfileController>(context, listen: false).userId}',
                  productController.sellerProductModel?.offset ?? 1, 'en',
                  productController.sellerProductModel?.search ?? '',
                  filterSearchModel: FilterModel(isUpdate: true),
                );
                productController.clearFilterData();
                productController.setPriceRange(0, Provider.of<SplashController>(context, listen: false).configModel?.productMaxPriceRange ?? 0);
                productController.setFilterSortIndex(0);
                productController.setFilterIsActive(false);
                if(context.mounted) Navigator.pop(context);
              }
            },
          )),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(child: CustomButtonWidget(
            isLoading: productController.sellerProductModel == null,
            btnTxt: '${getTranslated('filter', context)}',
            backgroundColor: _canFilter(productController.sellerProductModel, context) ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.6),
            onTap: !_canFilter(productController.sellerProductModel, context) ? null : () async {
              final priceRange = _getPriceRange(min: productController.minPrice, max: productController.maxPrice, context: ctx);

              await productController.getSellerProductList(
                '${Provider.of<ProfileController>(context, listen: false).userId}',
                productController.sellerProductModel?.offset ?? 1,
                'en',
                productController.sellerProductModel?.search ?? '',
                  filterSearchModel: productController.filterModel.copyWith(
                  brandIds: productController.selectedBrandIds.toList(),
                  categoryIds: _getSelectedCategoryIds(context),
                  filterSubCategoryIds: _getSelectedSubCategoryIds(context),
                  filterSubSubCategoryIds: _getSelectedSubSubCategoryIds(context),
                  isUpdate: true,
                  productType: productController.filterModel.productType,
                  minPrice: priceRange.minPrice,
                  maxPrice: priceRange.maxPrice,
                  startDate: productController.startDate,
                  endDate: productController.endDate,
                  publishingHouseIds: productController.selectedPublishingHouseIds.toList(),
                  authorIds: productController.selectedAuthorIds.toList(),
                  isApproved: productController.filterModel.isApproved,
                  status: productController.filterModel.status,
                  sorting: _getSortingValue(productController.filterSortIndex),
                )
              );
              if(context.mounted) Navigator.pop(context);
            },
          )),
        ]);
      }),
    );
  }


  String? _getSortingValue(int index) {
    switch(index) {
      case 0: return 'latest';
      case 1: return 'oldest';
      case 2: return 'top-selling';
      case 3: return 'most-favorite';
      default: return null;
    }
  }

  ({double? minPrice, double? maxPrice}) _getPriceRange({required double? min, required double? max, required BuildContext context}) {
    if((min == null || min == 0) && max == Provider.of<SplashController>(context, listen: false).configModel?.productMaxPriceRange) return (minPrice: null, maxPrice: null);
    return (minPrice: min, maxPrice: max);
  }

  bool _canResetFilters(BuildContext context) {
    final productController = Provider.of<ProductController>(context, listen: false);
    return (productController.sellerProductModel?.brandIds?.isNotEmpty ?? false) ||
        (productController.sellerProductModel?.categoryIds?.isNotEmpty ?? false) ||
        (productController.sellerProductModel?.authorIds?.isNotEmpty ?? false) ||
        (productController.sellerProductModel?.publishHouseIds?.isNotEmpty ?? false) ||
        productController.sellerProductModel?.productType != null ||
        productController.sellerProductModel?.startDate != null ||
        productController.sellerProductModel?.endDate != null ||
        productController.sellerProductModel?.maxPrice != null ||
        productController.sellerProductModel?.minPrice != null ||
        productController.filterIsActive != null ||
        productController.filterSortIndex != 0;
  }

  List<int> _getSelectedCategoryIds(BuildContext context) {
    return (Provider.of<CategoryController>(context, listen: false).categoryList ?? [])
      .where((category) => category.checked ?? false)
      .map((category) => category.id!)
      .toList();
  }

  List<int> _getSelectedSubCategoryIds(BuildContext context) {
    List<int> selectedIds = [];

    for (var category in (Provider.of<CategoryController>(context, listen: false).categoryList ?? [])) {
      if (category.subCategories != null) {
        for (var sub in category.subCategories!) {
          if (sub.checked == true) {
            selectedIds.add(sub.id!);
          }
        }
      }
    }

    return selectedIds;
  }


  List<int> _getSelectedSubSubCategoryIds(BuildContext context) {
    List<int> selectedIds = [];

    for (var category in (Provider.of<CategoryController>(context, listen: false).categoryList ?? [])) {
      if (category.subCategories != null) {
        for (var sub in category.subCategories!) {
          if (sub.subSubCategories != null) {
            for (var subSub in sub.subSubCategories!) {
              if (subSub.checked == true) {
                selectedIds.add(subSub.id!);
              }
            }
          }
        }
      }
    }
    return selectedIds;
  }



  bool _canFilter(ProductModel? productModel, BuildContext context) {
    if (productModel == null) return false;

    final ProductController productController = Provider.of<ProductController>(context, listen: false);
    final CategoryController categoryController = Provider.of<CategoryController>(context, listen: false);

    if (!productController.isPriceRangeValid) return false;


    bool _areListsEqual(List<int>? list1, List<int>? list2) {
      if (list1 == null && list2 == null) return true;
      if (list1 == null || list2 == null) return false;
      if (list1.length != list2.length) return false;
      return Set.from(list1).containsAll(list2) && Set.from(list2).containsAll(list1);
    }
    return

      // productController.endDate != productModel.endDate ||
      //   productController.startDate != productModel.startDate ||
       productController.sellerProductModel?.productType?.name !=  productController.filterModel.productType ||
      //   productController.minPrice != productModel.minPrice ||
      //   (productController.maxPrice != productModel.maxPrice && productModel.maxPrice != null) ||

        // --- NEW: Check Offer Type ---
        //productController.filterModel.sorting != productModel.offerType ||
        !_areCategoriesEqual(categoryController.categoryList, productModel.categoryIds) ||

        !areSubCategoriesEqual(categoryController.categoryList, productModel.filterSubCategoryIds) ||

        !areSubSubCategoriesEqual(categoryController.categoryList, productModel.filterSubSubCategoryIds) ||


        !_areBrandsEqual(productController.selectedBrandIds, productModel.brandIds ?? {}, productModel.productType) ||
        !_areAuthorsEqual(productController.selectedAuthorIds, productModel.authorIds ?? {}, productModel.productType) ||
        !_arePublishersEqual(productController.selectedPublishingHouseIds, productModel.publishHouseIds ?? {}, productModel.productType) ||
        !_areSortFilterEqual(productController.sellerProductModel?.filterSortBy ?? '',  _getSortingValue(productController.filterSortIndex) ?? '')

        || productController.filterSortIndex != 0 || productController.filterIsActive != null;
  }

  bool _areCategoriesEqual(List<CategoryModel>? categoryList, List<int>? currentCategoryIds) {
    final Set<int> selectedCategoryIds = (categoryList?.isEmpty ?? true) ? {} : categoryList!
        .where((category) => category.checked == true)
        .map((category) => category.id!)
        .toSet();
    final Set<int> currentCategorySet = currentCategoryIds?.toSet() ?? {};
    return selectedCategoryIds.length == currentCategorySet.length && selectedCategoryIds.containsAll(currentCategorySet);
  }

  bool areSubCategoriesEqual(
      List<CategoryModel>? categoryList,
      List<int>? currentSubIds,
      ) {
    final Set<dynamic> selectedSet = (categoryList ?? [])
      .expand((cat) => cat.subCategories ?? [])
      .where((sub) => sub.checked == true)
      .map((sub) => sub.id!)
      .toSet();

    final Set<int> currentSet = currentSubIds?.toSet() ?? {};

    return selectedSet.length == currentSet.length &&
        selectedSet.containsAll(currentSet);
  }



  bool areSubSubCategoriesEqual(
      List<CategoryModel>? categoryList,
      List<int>? currentSubSubIds,
      ) {
    final Set<dynamic> selectedSet = (categoryList ?? [])
      .expand((cat) => cat.subCategories ?? [])
      .expand((sub) => sub.subSubCategories ?? [])
      .where((subSub) => subSub.checked == true)
      .map((subSub) => subSub.id!)
      .toSet();

    final Set<int> currentSet = currentSubSubIds?.toSet() ?? {};

    return selectedSet.length == currentSet.length &&
        selectedSet.containsAll(currentSet);
  }




  bool _areAuthorsEqual(Set<int> authorIds, Set<int> currentAuthorIds, ProductTypeEnum? type) {
    if(type == ProductTypeEnum.physical) return true;
    return authorIds.length == currentAuthorIds.length && authorIds.containsAll(currentAuthorIds);
  }

  bool _arePublishersEqual(Set<int> publisherIds, Set<int> currentPublisherIds, ProductTypeEnum? type) {
    if(type == ProductTypeEnum.physical) return true;
    return publisherIds.length == currentPublisherIds.length && publisherIds.containsAll(currentPublisherIds);
  }

  bool _areBrandsEqual(Set<int> brandIds, Set<int> currentBrandIds, ProductTypeEnum? type) {
    if(type == ProductTypeEnum.digital) return true;
    return brandIds.length == currentBrandIds.length && brandIds.containsAll(currentBrandIds);
  }
}

void _onCloseKeyboard(TextEditingController minController, TextEditingController maxController){
  _onCheckPriceRangeValidity(minController, maxController);
  FocusManager.instance.primaryFocus?.unfocus();
}

bool _areSortFilterEqual(String productSort, String filterSort) {
  return  productSort == filterSort;
}

void _onCheckPriceRangeValidity(TextEditingController minController, TextEditingController maxController){
  final ProductController productController = Provider.of<ProductController>(Get.context!, listen: false);
  if(!productController.isPriceRangeValid){
    final ConfigModel? configModel = Provider.of<SplashController>(Get.context!, listen: false).configModel;
    final double systemMaxPrice = PriceConverter.convertAmount(configModel?.productMaxPriceRange ?? 1, Get.context!);
    final double tempMin = productController.invalidMinPrice ?? 0;
    final double tempMax = productController.invalidMaxPrice ?? 0;

    if(tempMin > systemMaxPrice || tempMax > systemMaxPrice){
      productController.setPriceRange(systemMaxPrice, systemMaxPrice);
      minController.text = systemMaxPrice.toString();
      maxController.text = systemMaxPrice.toString();
    }
    else if(tempMin > tempMax){
      productController.setPriceRange(tempMin, tempMin);
      minController.text = tempMin.toString();
      maxController.text = tempMin.toString();
    }
  }
}