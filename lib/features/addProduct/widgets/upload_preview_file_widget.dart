import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/digital_product_controller.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';


class UploadPreviewFileWidget extends StatefulWidget {
  final Product? product;
  const UploadPreviewFileWidget({super.key, this.product});

  @override
  State<UploadPreviewFileWidget> createState() => _UploadPreviewFileWidgetState();
}

class _UploadPreviewFileWidgetState extends State<UploadPreviewFileWidget> {
  final tooltipController = JustTheController();

  @override
  void initState() {
    if(widget.product!= null && widget.product?.previewFileFullUrl != null && widget.product?.previewFileFullUrl?.path != null && widget.product?.previewFileFullUrl?.path != '') {
      Provider.of<DigitalProductController>(context,listen: false).setPreviewData(false);
    } else {
      Provider.of<DigitalProductController>(context,listen: false).setPreviewData(true);
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<DigitalProductController>(
        builder: (context, digitalProductController, child) {
        return Padding(
          padding: const EdgeInsets.only(
            left : Dimensions.paddingSizeDefault,
            right : Dimensions.paddingSizeDefault,
            top : Dimensions.paddingSizeDefault,
            bottom : Dimensions.paddingSizeDefault,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              color: Theme.of(context).cardColor,
            ),
            padding: EdgeInsets.all(Dimensions.paddingSizeMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
                getTranslated('upload_preview_file', context)!,
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
                    TextSpan(text: getTranslated('file_type_jpg_jpeg', context) ?? ''),
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

                              if(!digitalProductController.isPreviewNull || digitalProductController.digitalProductPreview != null )
                                Positioned(
                                    top: 10,
                                    right: 10,
                                    child: InkWell(
                                        onTap: () {
                                          if(!digitalProductController.isPreviewNull) {
                                            digitalProductController.deleteDigitalPreviewFile(widget.product?.id);
                                          } else {
                                            digitalProductController.deleteDigitalPreviewFile(null);
                                          }
                                        } ,
                                        child: digitalProductController.isPreviewLoading ? const Center(child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator())) : Image.asset(width:25, Images.digitalPreviewDeleteIcon))
                                ),

                              Positioned.fill(
                                child: Center(
                                  child:Column(
                                    mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [

                                      if(digitalProductController.digitalProductPreview == null && digitalProductController.isPreviewNull)
                                        ...[
                                          InkWell(
                                            onTap: () => digitalProductController.pickFileDigitalProductPreview(),
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


                                      if(digitalProductController.digitalProductPreview != null)
                                      ...[
                                        Column(
                                          children: [
                                            SizedBox(width: 30, child: Image.asset(Images.digitalPreviewFileIcon) ),
                                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                            Text(digitalProductController.digitalProductPreview?.name ?? '',
                                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color), overflow: TextOverflow.ellipsis,)
                                          ],
                                        )
                                      ],


                                      if(digitalProductController.digitalProductPreview == null && !digitalProductController.isPreviewNull)
                                      ...[
                                        Column(
                                          children: [
                                            SizedBox(width: 30, child: Image.asset(Images.digitalPreviewFileIcon)),
                                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                            Text(widget.product?.previewFileFullUrl?.key ?? '',
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
          ),
        );
      }
    );
  }
}
