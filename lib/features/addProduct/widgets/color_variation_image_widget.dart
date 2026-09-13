import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_image_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/variation_controller.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/helper/color_helper.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class ColorVariationImageWidget extends StatefulWidget {
  final Product? product;
  const ColorVariationImageWidget({super.key, this.product});

  @override
  State<ColorVariationImageWidget> createState() => _ColorVariationImageWidgetState();
}

class _ColorVariationImageWidgetState extends State<ColorVariationImageWidget> {
  @override
  Widget build(BuildContext context) {
    bool _update = widget.product != null;
    return Consumer<VariationController>(
      builder: (context, variationController, child){



        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              color: Theme.of(context).cardColor,
            ),
            padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getTranslated('colour_wise_images', context)!,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Dimensions.paddingSizeExtraSmall),

                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                    children: <InlineSpan>[
                      TextSpan(text: getTranslated('jpg_png_less_then_1_mb', context) ?? ''),
                      TextSpan(
                        text: getTranslated('ratio_1_1', context) ?? '',
                        style: TextStyle(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                if(variationController.attributeList![0].active && variationController.attributeList![0].variants.isNotEmpty)
                  Consumer<AddProductImageController>(
                    builder: (context, addProductImageController, child) {
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 1,
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: addProductImageController.imagesWithColor.length,
                        itemBuilder: (context, index){
                          String colorString = '0xff000000';
                          if(addProductImageController.imagesWithColor[index].color != null){
                            if(addProductImageController.imagesWithColor[index].color != null){
                              colorString = '0xff${addProductImageController.imagesWithColor[index].color!.substring(1, 7)}';
                            }
                          }

                          Brightness brightness = ThemeData.estimateBrightnessForColor(Color(int.parse(colorString)));


                          Color iconColor = (brightness == Brightness.dark) ? Colors.white : Colors.black;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                            child: (addProductImageController.imagesWithColor[index].color != null && addProductImageController.imagesWithColor[index].image == null) ?
                            GestureDetector(
                              onTap: () async {
                                addProductImageController.pickImage(false, false, false, index, update: _update);
                              },
                              child: Stack(children: [
                                DottedBorder(
                                  options: RoundedRectDottedBorderOptions (
                                    dashPattern: const [4,5],
                                    color: Theme.of(context).hintColor,
                                    radius: const Radius.circular(15),
                                  ),
                                  child:  ClipRRect(
                                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                    child: (_update) ? (addProductImageController.imagesWithColor[index].colorImage?.imageName?.path != null && addProductImageController.imagesWithColor[index].colorImage?.imageName?.path != '') ?
                                    CustomImageWidget(
                                      placeholder: Images.placeholderImage,
                                      image: addProductImageController.imagesWithColor[index].colorImage?.imageName?.path ?? "",
                                      width: MediaQuery.of(context).size.width/2.3,
                                      height: MediaQuery.of(context).size.width/2.3,
                                      fit: BoxFit.cover
                                    ): SizedBox(
                                      width: MediaQuery.of(context).size.width/2.3,
                                      height: MediaQuery.of(context).size.width/2.3,
                                    ) : SizedBox(
                                      width: MediaQuery.of(context).size.width/2.3,
                                      height: MediaQuery.of(context).size.width/2.3,
                                    ),
                                  )
                                ),

                                if(addProductImageController.imagesWithColor[index].colorImage?.imageName?.path == null || addProductImageController.imagesWithColor[index].colorImage?.imageName?.path == '')
                                Positioned(bottom: 0, right: 0, top: 0, left: 0,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      CustomAssetImageWidget(Images.addImageIcon, height: 30, width: 30, color: Theme.of(context).hintColor.withValues(alpha: .7)),

                                      const SizedBox(height: Dimensions.paddingSizeSmall),
                                      Text(getTranslated('click_to_add', context)!, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineMedium?.color))
                                    ]),

                                  ),
                                ),

                                Positioned(left: 10, top: 10,
                                  child: Container(width: 25, height: 25,
                                    decoration: BoxDecoration(
                                      color: Color(int.parse(colorString)),
                                      border: Border.all(color: ColorHelper.darken(Color(int.parse(colorString)), 0.10), width: 1 ),
                                      borderRadius: BorderRadius.circular(20)),
                                    child: Padding(padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(Images.edit, color: iconColor,))
                                  )
                                ),


                                if(addProductImageController.imagesWithColor[index].colorImage?.imageName?.path != null && addProductImageController.imagesWithColor[index].colorImage?.imageName?.path != '')
                                Positioned(right: 10, top: 10,
                                  child: SizedBox(width: 25, height: 25,
                                    child: InkWell(
                                      onTap: () {
                                        addProductImageController.pickImage(false, false, false, index);
                                      },
                                      child: const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CustomAssetImageWidget(Images.editImageIcon, height: 25, width: 25),
                                        ],
                                      ),
                                    ),
                                  )
                                ),


                              ]),
                            ) : Stack(children: [
                              DottedBorder(
                                options: RoundedRectDottedBorderOptions (
                                  dashPattern: const [4,5],
                                  color: Theme.of(context).hintColor,
                                  radius: const Radius.circular(15),
                                ),
                                child: Container(decoration: const BoxDecoration(color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(20)),),
                                    child: ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeSmall)),
                                      child: Image.file(File(addProductImageController.imagesWithColor[index].image!.path),
                                        width: MediaQuery.of(context).size.width/2.3,
                                        height: MediaQuery.of(context).size.width/2.3,
                                        fit: BoxFit.cover)
                                    )
                                )
                              ),

                              // Positioned(bottom: 0, right: 0, top: 0, left: 0,
                              //   child: Align(alignment: Alignment.center,
                              //     child: Icon(Icons.camera_alt, color: Colors.black.withValues(alpha:.5), size: 40))
                              // ),

                              Positioned(top: 10, left: 10,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    addProductImageController.pickImage(false, false, false, index);
                                  },
                                  child: Container(width: 25,height: 25,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: ColorHelper.darken(Color(int.parse(colorString)), 0.10), width: 1),
                                      color: Color(int.parse(colorString)),
                                      borderRadius: BorderRadius.circular(20)

                                    ),
                                    child: Padding(padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(Images.edit, color: iconColor))
                                  )
                                )
                              ),


                              Positioned(right: 10, top: 10,
                                child: SizedBox(width: 25, height: 25,
                                  child: InkWell(
                                    onTap: () {
                                      addProductImageController.pickImage(false, false, false, index);
                                    },
                                    child: const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CustomAssetImageWidget(Images.editImageIcon, height: 25, width: 25),
                                      ],
                                    ),
                                  ),
                                )
                              ),
                            ]),
                          );
                      });

                    }
                  ),
              ],
            ),
          ),
        );
      }
    );
  }
}
