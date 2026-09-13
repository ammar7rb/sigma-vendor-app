import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/variation_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/widgets/add_product_section_widget.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AttributeViewWidget extends StatefulWidget {
  final Product? product;
  final bool colorOn;
  final bool onlyQuantity;
  const AttributeViewWidget({super.key, required this.product, required this.colorOn, this.onlyQuantity = false});
  @override
  State<AttributeViewWidget> createState() => _AttributeViewWidgetState();
}

class _AttributeViewWidgetState extends State<AttributeViewWidget> {
  bool? colorONOFF;
  int addVar = 0;

  void _load(){
    Provider.of<VariationController>(context,listen: false).selectedColor;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }


  @override
  Widget build(BuildContext context) {
    colorONOFF = widget.colorOn;
    return Consumer<VariationController>(
      builder: (context, variationController, child){
        return Consumer<AddProductController>(
          builder: (context, resProvider, child){

            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: Dimensions.paddingSizeSmall,),

              widget.onlyQuantity ? const SizedBox():

              DropdownButtonHideUnderline(
                child: PopupMenuButton<int>(
                  offset: const Offset(0, 55),
                  elevation: 3,
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - (Dimensions.paddingSizeExtraLarge * 2),
                    maxWidth: MediaQuery.of(context).size.width - (Dimensions.paddingSizeExtraLarge * 2),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                  ),

                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                      border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTranslated('select_attribute', context) ?? '',
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Theme.of(context).hintColor),
                      ],
                    ),
                  ),

                  onSelected: (int index) {
                    variationController.toggleAttribute(context, index, widget.product);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    });
                  },

                  itemBuilder: (context) {
                    return variationController.attributeList!.asMap().entries.map((entry) {
                      int index = entry.key;
                      var attributeModel = entry.value;

                      if (index == 0) {
                        return null;
                      }

                      return PopupMenuItem<int>(
                        value: index,
                        child: Row(
                          children: [
                            Text(
                              attributeModel.attribute.name!.substring(0, 1).toUpperCase() + attributeModel.attribute.name!.substring(1),
                              style: robotoRegular.copyWith(
                                color: attributeModel.active ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).whereType<PopupMenuItem<int>>().toList(); // Filter out nulls
                  },
                ),
              ),

              if (variationController.attributeList != null && variationController.attributeList!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                child: Wrap(
                  spacing: 0,
                  runSpacing: Dimensions.paddingSizeSmall,
                  children: variationController.attributeList!.asMap().entries.map((entry) {
                    int index = entry.key;
                    var attributeModel = entry.value;

                    if ((index == 0 && widget.colorOn) || !attributeModel.active) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      margin: EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                        vertical: Dimensions.paddingSizeExtraSmall
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).hintColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            attributeModel.attribute.name!.substring(0, 1).toUpperCase() + attributeModel.attribute.name!.substring(1),
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).textTheme.bodyLarge!.color,
                            ),
                          ),

                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                          InkWell(
                            onTap: () {
                              variationController.toggleAttribute(context, index, widget.product);
                            },
                            child: Icon(Icons.close, size: 16, color: Theme.of(context).hintColor),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: variationController.attributeList!.where((element) => element.active).isNotEmpty ?
              Dimensions.paddingSizeLarge : 0),

              widget.onlyQuantity ? const SizedBox() :
              variationController.attributeList!.isNotEmpty?
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: variationController.attributeList!.length,
                itemBuilder: (context, index) {

                  return (variationController.attributeList![index].active && index != 0) ?
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        '${variationController.attributeList![index].attribute.name!.substring(0, 1).toUpperCase()}${variationController.attributeList![index].attribute.name!.substring(1)} ${getTranslated('attribute', context)}', maxLines: 2, textAlign: TextAlign.center,
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      Row(children: [
                        Expanded(child: CustomTextFieldWidget(
                          border: true,
                          controller: variationController.attributeList![index].controller,
                          textInputAction: TextInputAction.done,
                          capitalization: TextCapitalization.words,
                        )),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        InkWell(
                          onTap: () {
                            String variant = variationController.attributeList![index].controller.text.trim();
                            if(variant.isEmpty) {
                              showCustomSnackBarWidget(getTranslated('enter_a_variant_name', context), context, sanckBarType: SnackBarType.warning);
                            } else if(variationController.attributeList![index].variants.contains(variant)) {
                              showCustomSnackBarWidget(getTranslated('variant_already_exist', context) ?? 'Variant already exists', context, sanckBarType: SnackBarType.warning);
                            } else {
                              variationController.attributeList![index].controller.text = '';
                              variationController.addVariant(context,index, variant, widget.product, true);
                            }
                          },
                          child: Container(height: 50, width : 50,
                            padding: EdgeInsets.all(Dimensions.paddingSizeMedium),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                            ),
                            child: SizedBox(height: 20, width : 20, child: CustomAssetImageWidget(Images.addAttribuiteIcon)),
                          ),
                        ),

                      ]),
                    ]),

                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    SizedBox(
                      height: 30,
                      child: variationController.attributeList![index].variants.isNotEmpty? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                        itemCount: variationController.attributeList![index].variants.length,
                        itemBuilder: (context, i) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                            margin: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              color: Theme.of(context).hintColor.withValues(alpha:0.2),
                              borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,children: [
                              Text(variationController.attributeList![index].variants[i]!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              InkWell(
                                splashColor: Colors.transparent,
                                onTap: () => variationController.removeVariant(context,index, i, widget.product),
                                child: const Icon(Icons.close, size: 15),
                              ),
                            ]),
                          );
                        },
                      ) : Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          getTranslated('no_variant_added_yet', context)!,
                          style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error.withValues(alpha:.8)),
                        ),
                      ),
                    ),

                    const SizedBox(height: Dimensions.paddingSizeSmall),

                  ]) : const SizedBox();
                },
              ) : const SizedBox(),
            ]);
          },
        );
      }
    );
  }
}






class AttributePricingWidget extends StatefulWidget {
  final Product? product;
  final bool colorOn;
  final bool onlyQuantity;
  const AttributePricingWidget({super.key, this.product, required this.colorOn, this.onlyQuantity = false});

  @override
  State<AttributePricingWidget> createState() => _AttributePricingWidgetState();
}

class _AttributePricingWidgetState extends State<AttributePricingWidget> {
  @override
  Widget build(BuildContext context) {
    return  Builder(
      builder: (context) {
        return Consumer<VariationController>(
            builder: (context, variationController, child){
            return Consumer<AddProductController>(
              builder: (context, resProvider, child){
                return AddProductSectionWidget(
                  title: getTranslated('variation_wise_price', context)!,
                  childrens: [
                    variationController.variantTypeList.isNotEmpty ?
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: variationController.variantTypeList.length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                          decoration: BoxDecoration(
                            color: index.isEven ? Theme.of(context).cardColor
                              : Theme.of(context).primaryColor.withValues(alpha: 0.03),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                variationController.variantTypeList[index].variantType,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).textTheme.bodyLarge!.color,
                                ),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              Row(
                                children: [
                                  if (!widget.onlyQuantity)
                                    Expanded(
                                      child: CustomTextFieldWidget(
                                        variant: true,
                                        border: true,
                                        hintText: getTranslated('price', context),
                                        controller: variationController.variantTypeList[index].controller,
                                        focusNode: variationController.variantTypeList[index].node,
                                        nextNode: index != variationController.variantTypeList.length - 1
                                          ? variationController.variantTypeList[index + 1].node
                                          : null,
                                        textInputAction: TextInputAction.next,
                                        isAmount: true,
                                        textInputType: TextInputType.number,
                                        amountIcon: true,
                                      ),
                                    ),

                                  if (!widget.onlyQuantity)
                                    const SizedBox(width: Dimensions.paddingSizeSmall),


                                  Expanded(
                                    child: CustomTextFieldWidget(
                                      variant: true,
                                      border: true,
                                      hintText: getTranslated('quantity', context),
                                      controller: variationController.variantTypeList[index].qtyController,
                                      focusNode: variationController.variantTypeList[index].qtyNode,
                                      nextNode: null,
                                      textInputAction: index != variationController.variantTypeList.length - 1
                                          ? TextInputAction.next
                                          : TextInputAction.done,
                                      isAmount: true,
                                      amountIcon: false,
                                      textInputType: TextInputType.number,
                                      onChanged: (String cng) {
                                        variationController.calculateVariationQuantity();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ) : const SizedBox(),

                    SizedBox(height: variationController.hasAttribute() ? Dimensions.paddingSizeExtraSmall : 0),
                  ],
                );
              }
            );
          }
        );
      }
    );
  }
}

