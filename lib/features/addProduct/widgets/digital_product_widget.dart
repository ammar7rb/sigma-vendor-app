import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/dropdown_decorator_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/digital_product_controller.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/config_model.dart';
import 'package:sixvalley_vendor_app/helper/image_size_checker.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_controller.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

import '../../../main.dart';

class DigitalProductWidget extends StatefulWidget {
  final AddProductController? resProvider;
  final Product? product;
  final bool fromAddProductNextScreen;
  const DigitalProductWidget({super.key, this.resProvider, this.product, this.fromAddProductNextScreen = false});

  @override
  State<DigitalProductWidget> createState() => _DigitalProductWidgetState();
}

class _DigitalProductWidgetState extends State<DigitalProductWidget> {
  PlatformFile? fileNamed;
  File? file;
  int?  fileSize;
  final List<String> itemList = ['physical', 'digital'];




  @override
  Widget build(BuildContext context) {

    return Column(children: [
      !widget.fromAddProductNextScreen ?
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
        child: DropdownDecoratorWidget(
            title: 'product_type',
            child: DropdownButton<String>(
              icon: const Icon(Icons.keyboard_arrow_down_outlined),
              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingEye)),
              value: widget.resProvider!.productTypeIndex == 0 ? 'physical' : 'digital',
              items: itemList.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(getTranslated(value, context)!, style: robotoMedium),
                );
              }).toList(),
              onChanged: (value) {
                widget.resProvider!.setProductTypeIndex(value == 'physical' ? 0 : 1, true);
              },
              isExpanded: true,
              underline: const SizedBox(),
            )),
      ) : const SizedBox(),

      !widget.fromAddProductNextScreen ?
      SizedBox(height: widget.resProvider!.productTypeIndex == 1? Dimensions.paddingSizeSmall : 0) : const SizedBox(),


      widget.fromAddProductNextScreen && widget.resProvider!.productTypeIndex == 1 && Provider.of<DigitalProductController>(context,listen: false).digitalProductTypeIndex == 1?
      Consumer<DigitalProductController>(
        builder: (context, digitalProductController, child){
          return Padding(
            padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault, 0),
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)
              ),
              child: InkWell(
                splashColor: Colors.transparent,
                onTap: () async {
                  List<String> disallowedExtensions = [];

                  disallowedExtensions.addAll(AppConstants.disallowedExtensions);

                  if(!AppConstants.demo) {
                    disallowedExtensions.addAll(['zip']);
                  }

                  FilePickerResult? result = await FilePicker.pickFiles(
                    type: FileType.custom,
                  );

                  bool hasInvalidFile = false;

                  if(result != null) {
                    if (disallowedExtensions.contains(result.files.first.extension?.toLowerCase())) {
                      hasInvalidFile = true;
                      result = null;
                    }
                  }

                  if(hasInvalidFile) {
                    showCustomSnackBarWidget('${getTranslated('invalid_file_type', Get.context!)} ', Get.context!, sanckBarType: SnackBarType.error);
                  }


                  if (result != null) {
                    double value =   ImageValidationHelper.getFileSizeFromFile(File(result.files.single.path!));

                    ConfigModel? configModel = Provider.of<SplashController>(Get.context!, listen: false).configModel;

                    if(value >  (configModel?.systemGeneralFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)) {
                      showCustomSnackBarWidget('${getTranslated('maximum_image_size', Get.context!)} ${(configModel?.systemGeneralFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)}MB', Get.context!, sanckBarType: SnackBarType.warning);
                    } else {
                      file = File(result.files.single.path!);
                      fileSize = await file!.length();
                      fileNamed = result.files.first;
                      digitalProductController.setSelectedFileName(file);
                    }
                  }
                },
                child: Builder(
                  builder: (context) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        color: Theme.of(context).cardColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getTranslated('upload_file', context)!,
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
                                TextSpan(text: ''),
                              ],
                            ),
                            textAlign: TextAlign.justify,
                          ),
                          SizedBox(height: Dimensions.paddingSizeSmall),


                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [


                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingEye)),
                                  color: Theme.of(context).highlightColor,
                                ),
                                child: DottedBorder(
                                    options: RoundedRectDottedBorderOptions (
                                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                      dashPattern: const [4,5],
                                      color: (!digitalProductController.isPreviewNull || digitalProductController.digitalProductPreview != null ) ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
                                      radius: const Radius.circular(Dimensions.paddingEye),
                                    ),
                                    child: Container(
                                        height: 110,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                        ),
                                        child: Stack(
                                          children: [

                                            Positioned.fill(
                                              child: Center(
                                                child:Column(
                                                  mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [

                                                    if(fileNamed == null && widget.product?.digitalFileReady == null)
                                                      ...[
                                                        InkWell(
                                                          onTap: () async {
                                                            List<String> disallowedExtensions = [];
                                                            disallowedExtensions.addAll(AppConstants.disallowedExtensions);

                                                            if(AppConstants.demo) {
                                                              disallowedExtensions.addAll(['zip']);
                                                            }

                                                            FilePickerResult? result = await FilePicker.pickFiles(
                                                              type: FileType.custom,
                                                            );

                                                            bool hasInvalidFile = false;

                                                            if(result != null) {
                                                              if (disallowedExtensions.contains(result.files.first.extension?.toLowerCase())) {
                                                                hasInvalidFile = true;
                                                                result = null;
                                                              }
                                                            }

                                                            if(hasInvalidFile) {
                                                              showCustomSnackBarWidget('${getTranslated('invalid_file_type', Get.context!)} ', Get.context!, sanckBarType: SnackBarType.error);
                                                            }

                                                            if (result != null) {
                                                              double value =   ImageValidationHelper.getFileSizeFromFile(File(result.files.single.path!));

                                                              ConfigModel? configModel = Provider.of<SplashController>(Get.context!, listen: false).configModel;

                                                              if(value >  (configModel?.systemGeneralFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)) {
                                                                showCustomSnackBarWidget('${getTranslated('maximum_image_size', Get.context!)} ${(configModel?.systemGeneralFileUploadMaxSize ?? AppConstants.fileImageMaxLimit)}MB', Get.context!, sanckBarType: SnackBarType.warning);
                                                              } else {
                                                                file = File(result.files.single.path!);
                                                                fileSize = await file!.length();
                                                                fileNamed = result.files.first;
                                                                digitalProductController.setSelectedFileName(file);
                                                              }
                                                            }
                                                          },
                                                          child: Column(
                                                            children: [
                                                              SizedBox(width: 30, child: CustomAssetImageWidget(Images.addImageIcon, height: 30, width: 30, color: Theme.of(context).hintColor.withValues(alpha: .7))),
                                                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                                              Text(getTranslated('click_to_add', context)!,
                                                                  style: robotoRegular.copyWith( fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodySmall?.color))
                                                            ],
                                                          ),
                                                        )
                                                      ],




                                                    if(fileNamed != null || widget.product?.digitalFileReady != null)
                                                      ...[
                                                        Column(
                                                          children: [
                                                            SizedBox(width: 30, child: Image.asset(Images.digitalPreviewFileIcon)),
                                                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                                            Text(fileNamed != null? fileNamed?.name??'':'${widget.product?.digitalFileReady}',
                                                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)
                                                            )
                                                          ],
                                                        )
                                                      ],

                                                  ],
                                                ),
                                              ),
                                            ),



                                          ],
                                        )
                                    )
                                ),
                              ),


                            ],
                          ),
                        ],
                      ),
                    );
                  }
                ),

              ),
            ),
          );
        }
      ):const SizedBox(),

      widget.fromAddProductNextScreen ?
      const SizedBox(height: Dimensions.paddingSizeDefault) : const SizedBox(),

    ]);
  }
}
