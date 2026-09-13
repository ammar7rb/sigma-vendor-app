import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_tab_view_screen.dart';
import 'package:sixvalley_vendor_app/features/barcode/controllers/barcode_controller.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/filter_model.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/features/product_details/enums/preview_type.dart';
import 'package:sixvalley_vendor_app/features/product_details/widgets/audio_preview.dart';
import 'package:sixvalley_vendor_app/features/product_details/widgets/download_preview_file.dart';
import 'package:sixvalley_vendor_app/features/product_details/widgets/image_preview.dart';
import 'package:sixvalley_vendor_app/features/product_details/widgets/pdf_preview_flutter.dart';
import 'package:sixvalley_vendor_app/features/product_details/widgets/video_preview.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/helper/product_helper.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/confirmation_dialog_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/features/product_details/screens/product_details_screen.dart';
import 'package:sixvalley_vendor_app/features/barcode/screens/bar_code_generator_screen.dart';

import '../../../main.dart';


class ShopProductWidget extends StatefulWidget {
  final Product? productModel;
  final bool isDetails;
  const ShopProductWidget({super.key, required this.productModel, this.isDetails = false});

  @override
  State<ShopProductWidget> createState() => _ShopProductWidgetState();
}

class _ShopProductWidgetState extends State<ShopProductWidget> {
  var renderOverlay = true;
  var visible = true;
  var switchLabelPosition = false;
  var extend = false;
  var mini = false;
  var customDialRoot = false;
  var closeManually = false;
  var useRAnimation = true;
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  var speedDialDirection = Provider.of<LocalizationController>(Get.context!, listen: false).isLtr ? SpeedDialDirection.left : SpeedDialDirection.right;
  var buttonSize = const Size(35.0, 35.0);
  var childrenButtonSize = const Size(45.0, 45.0);

  @override
  Widget build(BuildContext context) {
    final productController = Provider.of<ProductController>(context, listen: false);
    String? filterStatus = productController.filterModel.isApproved;
    final String reviewStatus = widget.productModel?.sellerReviewStatus ?? _legacyReviewStatus(widget.productModel?.requestStatus);
    final String? reviewReason = widget.productModel?.sellerReviewReason ?? widget.productModel?.deniedNote;

    //bool showStatusTag = filterStatus == null || filterStatus == '' || filterStatus == 'all';

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          child: GestureDetector(
            onTap: widget.isDetails ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(productModel: widget.productModel))),
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                    spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2)
                  )
                ]
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 50, width: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: CustomImageWidget(image: '${widget.productModel?.thumbnailFullUrl?.path}', fit: BoxFit.cover),
                        ),
                      ),

                      if ((widget.productModel?.clearanceSale?.discountAmount ?? 0) > 0)
                        const DiscountTagWidget()
                    ],
                  ),

                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: !widget.isDetails ? 40.0 : 0),
                          child: Text(
                            widget.productModel?.name ?? '',
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).textTheme.bodyLarge?.color
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                        Row(
                          children: [
                            Text(
                              PriceConverter.convertPrice(context, widget.productModel!.unitPrice,
                                discountType: (widget.productModel?.clearanceSale?.discountAmount ?? 0) > 0
                                  ? widget.productModel?.clearanceSale?.discountType
                                  : widget.productModel?.discountType,
                                discount: (widget.productModel?.clearanceSale?.discountAmount ?? 0) > 0
                                  ? widget.productModel?.clearanceSale?.discountAmount
                                  : widget.productModel?.discount
                              ),
                              style: robotoMedium.copyWith(fontSize: 18, color: Theme.of(context).primaryColor),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                            if(widget.productModel!.discount! > 0 || (widget.productModel?.clearanceSale?.discountAmount ?? 0) > 0)
                            Text(
                              PriceConverter.convertPrice(context, widget.productModel!.unitPrice),
                              style: robotoRegular.copyWith(
                                color: Theme.of(context).disabledColor,
                                decoration: TextDecoration.lineThrough,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${getTranslated('product_type', context)} : ',
                                    style: robotoRegular.copyWith(color: Theme.of(context).textTheme.headlineLarge?.color, fontSize: Dimensions.fontSizeSmall),
                                  ),
                                  TextSpan(
                                    text: getTranslated(widget.productModel?.productType, context),
                                    style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeSmall),
                                  ),
                                ],
                              ),
                            ),


                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _reviewStatusColor(context, reviewStatus),
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                ),
                                child: Text(
                                  getTranslated(reviewStatus, context) ?? reviewStatus,
                                  style: robotoRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall),
                                ),
                              ),
                          ],
                        ),


                        if(widget.isDetails && widget.productModel?.productType == 'digital' && widget.productModel?.previewFileFullUrl != null && widget.productModel?.previewFileFullUrl?.path != '')
                        Padding(
                          padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                          child: InkWell(
                            onTap: () => _showPreview(widget.productModel?.previewFileFullUrl?.path ?? '', widget.productModel?.name ?? '', widget.productModel?.previewFileFullUrl?.key ?? ''),
                            child: Text(
                              getTranslated('see_preview', context)!,
                              style: robotoRegular.copyWith(color: Theme.of(context).primaryColor, decoration: TextDecoration.underline,
                                decorationColor: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),


                        if(reviewReason != null && reviewReason.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start,children: [
                              Text('${getTranslated('review_reason', context) ?? getTranslated('note', context)}: ',
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)),
                              Expanded(child: Text(reviewReason,overflow: TextOverflow.ellipsis,
                                maxLines: 50,
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault))),
                            ],),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        extend ?
        Align(
            alignment: Provider.of<LocalizationController>(context, listen: false).isLtr ? Alignment.topRight : Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                width: 205, height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [BoxShadow(color: Theme.of(context).hintColor, spreadRadius: .1, blurRadius: .2, offset: Offset.fromDirection(2,1))],
                  borderRadius: BorderRadius.circular(Dimensions.iconSizeExtraLarge)
                ),
              ),
            )
        ) : const SizedBox(),


        !widget.isDetails ?
        // Align(
        //   alignment: Provider.of<LocalizationController>(context, listen: false).isLtr ? Alignment.topRight : Alignment.topLeft,
        //   child: Padding(
        //     padding: const EdgeInsets.all(15),
        //     child: SpeedDial(
        //       animationDuration: const Duration(milliseconds: 150),
        //       overlayOpacity: 0,
        //       icon: Icons.more_vert,
        //       activeIcon: Icons.close,
        //       spacing: 3,
        //       mini: mini,
        //       openCloseDial: isDialOpen,
        //       childPadding: const EdgeInsets.all(5),
        //       spaceBetweenChildren: 4,
        //       buttonSize: buttonSize,
        //       childrenButtonSize: childrenButtonSize,
        //       visible: visible,
        //       direction: speedDialDirection,
        //       switchLabelPosition: switchLabelPosition,
        //       closeManually: true,
        //       renderOverlay: renderOverlay,
        //       useRotationAnimation: useRAnimation,
        //       backgroundColor: Theme.of(context).cardColor,
        //       foregroundColor: Theme.of(context).disabledColor,
        //       elevation: extend ? 0 : 8.0,
        //       animationCurve: Curves.elasticInOut,
        //       isOpenOnStart: false,
        //       shape: customDialRoot ? const RoundedRectangleBorder() : const StadiumBorder(),
        //       onOpen: () {
        //         setState(() { extend = true; });
        //       },
        //       onClose: () {
        //         setState(() { extend = false; });
        //       },
        //       children: [
        //         SpeedDialChild(
        //           elevation: 0,
        //           child: Padding(padding: const EdgeInsets.all(8.0), child: Image.asset(Images.editIcon)),
        //           onTap: () async {
        //             setState(() { isDialOpen.value = false; extend = false; });
        //             await Future.delayed(const Duration(milliseconds : 350));
        //             Navigator.of(Get.context!).push(MaterialPageRoute(builder: (_) => AddProductTabView(product: widget.productModel, fromHome: false,)));
        //           },
        //         ),
        //         SpeedDialChild(
        //           elevation: 0,
        //           child: Padding(padding: const EdgeInsets.all(8.0), child: Image.asset(Images.barCode)),
        //           onTap: () async {
        //             setState(() { isDialOpen.value = false; extend = false; });
        //             await Future.delayed(const Duration(milliseconds : 350));
        //             Navigator.of(Get.context!).push(MaterialPageRoute(builder: (_) => BarCodeGenerateScreen(product: widget.productModel)));
        //             Provider.of<BarcodeController>(Get.context!, listen: false).setBarCodeQuantity(4);
        //           },
        //         ),
        //         SpeedDialChild(
        //           elevation: 0,
        //           child: Padding(padding: const EdgeInsets.all(8.0), child: Image.asset(Images.delete)),
        //           onTap: () async {
        //             setState(() { isDialOpen.value = false; extend = false; });
        //             await Future.delayed(const Duration(milliseconds : 350));
        //             showDialog(context: Get.context!, builder: (BuildContext context){
        //               return ConfirmationDialogWidget(
        //                   icon: Images.deleteProduct,
        //                   refund: false,
        //                   description: getTranslated('are_you_sure_want_to_delete_this_product', context),
        //                   onYesPressed: () {
        //                     Provider.of<ProductController>(context, listen:false).deleteProduct(context ,widget.productModel!.id).then((value) {
        //                       Provider.of<ProductController>(Get.context!,listen: false).getStockOutProductList(1, 'en');
        //                       Provider.of<ProductController>(Get.context!, listen: false).getSellerProductList(
        //                         Provider.of<ProfileController>(Get.context!, listen: false).userInfoModel!.id.toString(),
        //                         1, 'en','',
        //                         filterModel: FilterModel(reload: true)
        //                       );
        //                     });
        //                   }
        //               );
        //             });
        //           },
        //         ),
        //       ],
        //     ),
        //   ),
        // )

        Positioned(
          top: 10,
          right: 10,
          child: SpeedDial(
            animationDuration: const Duration(milliseconds: 150),
            overlayOpacity: 0,
            icon: Icons.more_vert,
            activeIcon: Icons.close,
            spacing: 3,
            mini: mini,
            openCloseDial: isDialOpen,
            childPadding: const EdgeInsets.only(top: Dimensions.paddingSizeMedium),
            spaceBetweenChildren: 4,
            buttonSize: buttonSize,
            childrenButtonSize: childrenButtonSize,
            visible: visible,
            direction: speedDialDirection,
            switchLabelPosition: switchLabelPosition,
            closeManually: true,
            renderOverlay: renderOverlay,
            useRotationAnimation: useRAnimation,
            backgroundColor: Theme.of(context).cardColor,
            foregroundColor: Theme.of(context).disabledColor,
            elevation: 0,
            animationCurve: Curves.elasticInOut,
            isOpenOnStart: false,
            shape: customDialRoot ? const RoundedRectangleBorder() : const StadiumBorder(),
            onOpen: () {
              setState(() { extend = true; });
            },
            onClose: () {
              setState(() { extend = false; });
            },
            children: [
              SpeedDialChild(
                elevation: 0,
                child: Padding(padding: const EdgeInsets.all(8.0), child: Image.asset(Images.editIcon)),
                onTap: () async {
                  setState(() { isDialOpen.value = false; extend = false; });
                  await Future.delayed(const Duration(milliseconds : 350));
                  Navigator.of(Get.context!).push(MaterialPageRoute(builder: (_) => AddProductTabView(product: widget.productModel, fromHome: false,)));
                },
              ),
              SpeedDialChild(
                elevation: 0,
                child: Padding(padding: const EdgeInsets.all(8.0), child: Image.asset(Images.barCode)),
                onTap: () async {
                  setState(() { isDialOpen.value = false; extend = false; });
                  await Future.delayed(const Duration(milliseconds : 350));
                  Navigator.of(Get.context!).push(MaterialPageRoute(builder: (_) => BarCodeGenerateScreen(product: widget.productModel)));
                  Provider.of<BarcodeController>(Get.context!, listen: false).setBarCodeQuantity(4);
                },
              ),
              SpeedDialChild(
                elevation: 0,
                child: Padding(padding: const EdgeInsets.all(8.0), child: Image.asset(Images.delete)),
                onTap: () async {
                  setState(() { isDialOpen.value = false; extend = false; });
                  await Future.delayed(const Duration(milliseconds : 350));
                  showDialog(context: Get.context!, builder: (BuildContext context){
                    return ConfirmationDialogWidget(
                        icon: Images.deleteProduct,
                        refund: false,
                        description: getTranslated('are_you_sure_want_to_delete_this_product', context),
                        onYesPressed: () {
                          Provider.of<ProductController>(context, listen:false).deleteProduct(context ,widget.productModel!.id).then((value) {
                            Provider.of<ProductController>(Get.context!,listen: false).getStockOutProductList(1, 'en');
                            Provider.of<ProductController>(Get.context!, listen: false).getSellerProductList(
                                Provider.of<ProfileController>(Get.context!, listen: false).userInfoModel!.id.toString(),
                                1, 'en','',
                                filterSearchModel: FilterModel(reload: true)
                            );
                          });
                        }
                    );
                  });
                },
              ),
            ],
          ),
        ) : const SizedBox()


      ],
    );
  }

  String _legacyReviewStatus(int? requestStatus) {
    if (requestStatus == 1) return 'approved_published';
    if (requestStatus == 2) return 'rejected';
    return 'submitted';
  }

  Color _reviewStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'approved_published': return Theme.of(context).colorScheme.onTertiaryContainer;
      case 'suspended': return Colors.orange;
      case 'rejected': return Theme.of(context).colorScheme.error;
      case 'under_review': return Theme.of(context).primaryColor;
      default: return Theme.of(context).primaryColor;
    }
  }

  void _showPreview(String url, String productName, String fileName) {
    PreviewType type = ProductHelper.getFileType(url);
    showDialog(context: context, builder: (BuildContext context){
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
        insetPadding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: (type == PreviewType.pdf) ?
        PdfPreview(url: url, fileName: productName) : (type == PreviewType.image) ?
        ImagePreview(url: url, fileName: productName) : (type == PreviewType.video) ?
        VideoPreview(url: url, fileName: productName) : (type == PreviewType.audio)  ?
        AudioPreview(url: url, fileName: productName) : (type == PreviewType.others) ?
        DownloadPreview(url: url, fileName: fileName) :
        const SizedBox(),
      );
    });
  }
}

class DiscountTagWidget extends StatelessWidget {
  const DiscountTagWidget({
    super.key,
    this.positionedTop = 0,
    this.positionedLeft = 0,
    this.positionedRight = 0,
  });

  final double positionedTop;
  final double positionedLeft;
  final double positionedRight;

  @override
  Widget build(BuildContext context) {
    final bool isLtr  = Provider.of<LocalizationController>(context, listen: false).isLtr;
    return Positioned(
      top: positionedTop,
      left: isLtr ? positionedLeft : null,
      right: !isLtr ? positionedRight : null,
      child: Image.asset(Images.clearanceDiscountIcon, height: 25, width: 25),
    );
  }
}


// class ShopProductWidget extends StatefulWidget {
//   final Product? productModel;
//   final bool isDetails;
//   const ShopProductWidget({super.key, required this.productModel, this.isDetails = false});
//
//   @override
//   State<ShopProductWidget> createState() => _ProductWidgetState();
// }
//
// class _ProductWidgetState extends State<ShopProductWidget> {
//   var renderOverlay = true;
//   var visible = true;
//   var switchLabelPosition = false;
//   var extend = false;
//   var mini = false;
//   var customDialRoot = false;
//   var closeManually = false;
//   var useRAnimation = true;
//   ValueNotifier<bool> isDialOpen = ValueNotifier(false);
//   var speedDialDirection = Provider.of<LocalizationController>(Get.context!, listen: false).isLtr ? SpeedDialDirection.left : SpeedDialDirection.right;
//   var buttonSize = const Size(35.0, 35.0);
//   var childrenButtonSize = const Size(45.0, 45.0);
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     String? baseUrl = Provider.of<SplashController>(context, listen: false).baseUrls!.productImageUrl;
//     return Stack(children: [
//         Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
//           child: GestureDetector(
//             onTap:  widget.isDetails? null: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> ProductDetailsScreen(productModel: widget.productModel))),
//             child: Container(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium, vertical: Dimensions.paddingSizeSmall),
//               decoration: BoxDecoration(color: Theme.of(context).cardColor,
//                 boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha:.05),
//                   spreadRadius: 1, blurRadius: 1, offset: const Offset(1,2))]),
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Row(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start, children: [
//                       Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
//                         child: Column(children: [
//                           Stack(
//                             children: [
//                               Container(decoration: BoxDecoration(
//                                 color: Theme.of(context).primaryColor.withValues(alpha:.10),
//                                 borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),),
//                                   width: 110, height: 110,
//                                   child: ClipRRect(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
//                                       child: CustomImageWidget(image: '${widget.productModel?.thumbnailFullUrl?.path}'))
//                               ),
//                                (widget.productModel?.clearanceSale?.discountAmount ?? 0) > 0 ?
//                                 const DiscountTagWidget() : const SizedBox(),
//                             ],
//                           ),
//
//
//
//
//
//                             const SizedBox(height: Dimensions.paddingSizeExtraSmall),
//                             widget.isDetails?const SizedBox():
//                             Text(getTranslated(widget.productModel?.productType, context)!, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor)),
//
//
//                           (widget.isDetails && widget.productModel?.productType == 'digital' && widget.productModel?.previewFileFullUrl != null && widget.productModel?.previewFileFullUrl?.path != '') ? InkWell(
//                             onTap: () => _showPreview(widget.productModel?.previewFileFullUrl?.path ?? '', widget.productModel?.name ?? '', widget.productModel?.previewFileFullUrl?.key ?? ''),
//                             child: Text(
//                               getTranslated('see_preview', context)!,
//                               style: robotoRegular.copyWith(color: Theme.of(context).primaryColor, decoration: TextDecoration.underline,
//                                 decorationColor: Theme.of(context).primaryColor),
//                             ),
//                           ) : const SizedBox(),
//
//
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: Dimensions.paddingSizeSmall),
//
//
//                       Expanded(flex: 6,
//                         child: Padding(padding: const EdgeInsets.all(8.0),
//                           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                             Padding(padding: EdgeInsets.only(right: Provider.of<LocalizationController>(context, listen: false).isLtr? 30:0,
//                                 left: Provider.of<LocalizationController>(context, listen: false).isLtr? 0:30,
//                               ),
//                               child: Text(widget.productModel!.name ?? '', style: robotoRegular.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7)),
//                                 maxLines: 2, overflow: TextOverflow.ellipsis),),
//                             const SizedBox(height: Dimensions.paddingSizeSmall),
//
//                             Container(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall,vertical: Dimensions.paddingSizeExtraSmall),
//                                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
//                                     color: widget.productModel!.requestStatus == 0?
//                                     ColorHelper.blendColors(Colors.white, Theme.of(context).colorScheme.outline, 0.2)  :
//                                     widget.productModel!.requestStatus == 1 ? ColorHelper.blendColors(Colors.white,  Theme.of(context).colorScheme.onTertiaryContainer, 0.2)  :   ColorHelper.blendColors(Colors.white,   Theme.of(context).colorScheme.error, 0.2)),
//
//                                 child: Text(widget.productModel!.requestStatus == 0? '${getTranslated('new_request', context)}':
//                                 widget.productModel!.requestStatus == 1? '${getTranslated('approved', context)}' : '${getTranslated('denied', context)}',
//                                     style: robotoRegular.copyWith(color: widget.productModel!.requestStatus == 0?
//                                       Theme.of(context).colorScheme.outline : widget.productModel!.requestStatus == 1
//                                       ? Theme.of(context).colorScheme.onTertiaryContainer : Theme.of(context).colorScheme.error)
//                                     ,
//                                     maxLines: 1, overflow: TextOverflow.ellipsis)),
//                             const SizedBox(height: Dimensions.paddingSizeSmall),
//
//                             widget.isDetails && widget.productModel!.images != null?
//                             SizedBox(height: Dimensions.productImageSize,
//                               child: ListView.builder(
//                                 itemCount: widget.productModel!.images?.length,
//                                 shrinkWrap: true,
//                                   scrollDirection: Axis.horizontal,
//                                   itemBuilder: (context, index){
//                                 return GestureDetector(
//                                   onTap: (){
//                                     showDialog(context: context, builder: (_){
//                                       return ImageDialogWidget(imageUrl: '$baseUrl/${widget.productModel!.images![index]}');
//                                     });
//                                   },
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
//                                     child: Container(decoration: BoxDecoration(
//                                       color: Theme.of(context).cardColor,
//                                     ),
//                                     width: Dimensions.productImageSize,height: Dimensions.imageSize,
//                                         child: ClipRRect(
//                                           borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
//                                           child: CustomImageWidget(image: '${widget.productModel!.imagesFullUrl![index].path}',
//                                             width: Dimensions.productImageSize,height: Dimensions.productImageSize,),
//                                         )),
//                                   ),
//                                 );
//                             }),):
//                             Column(children: [
//
//                               Row(children: [
//                                 // Text('${getTranslated('selling_price', context)} : ',
//                                 //   style: robotoRegular.copyWith(color: Theme.of(context).hintColor)),
//
//                                 Text(PriceConverter.convertPrice(context, widget.productModel!.unitPrice,
//                                   discountType: (widget.productModel?.clearanceSale?.discountAmount ?? 0) > 0
//                                     ? widget.productModel?.clearanceSale?.discountType
//                                     : widget.productModel?.discountType,
//                                   discount: (widget.productModel?.clearanceSale?.discountAmount ?? 0) > 0
//                                     ? widget.productModel?.clearanceSale?.discountAmount
//                                     : widget.productModel?.discount
//                                 ),
//                                    style: robotoMedium.copyWith(color: ColorHelper.blendColors(Colors.white, Theme.of(context).textTheme.bodyLarge!.color!, 0.7))
//                                 ),
//                                 const SizedBox(width: Dimensions.paddingSizeExtraSmall),
//
//                                 (widget.productModel!.discount! > 0 || (widget.productModel?.clearanceSale?.discountAmount ?? 0) > 0) ?
//                                 Text(PriceConverter.convertPrice(context, widget.productModel!.unitPrice),
//                                   maxLines: 1,overflow: TextOverflow.ellipsis,
//                                   style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error,
//                                     decoration: TextDecoration.lineThrough,
//                                     fontSize: Dimensions.fontSizeSmall,
//                                   ),): const SizedBox.shrink(),
//
//                               ]),
//
//
//                             ],)
//                         ],),
//                       ),
//                       ),
//                     ],),
//
//
//                   widget.isDetails && widget.productModel!.deniedNote != null?
//                   Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
//                     child: Row(crossAxisAlignment: CrossAxisAlignment.start,children: [
//                       Text('${getTranslated('note', context)}: ',
//                           style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)),
//
//                       Expanded(child: Text( widget.productModel!.deniedNote!,overflow: TextOverflow.ellipsis,
//                           maxLines: 50,
//                           style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault))),
//                     ],),
//                   ):const SizedBox.shrink(),
//                 ],
//               ),
//             ),
//           ),
//         ),
//
//         ///for the background of the speed dial
//         extend?
//         Align(alignment: Provider.of<LocalizationController>(context, listen: false).isLtr? Alignment.topRight:Alignment.topLeft,
//             child: Padding(padding: const EdgeInsets.all(10),
//               child: Container(width: 205, height: 50,
//                 decoration: BoxDecoration(color: Theme.of(context).cardColor,
//                     boxShadow: [BoxShadow(color: Theme.of(context).hintColor,
//                         spreadRadius: .1, blurRadius: .2, offset: Offset.fromDirection(2,1))],
//                     borderRadius: BorderRadius.circular(Dimensions.iconSizeExtraLarge)),
//               ),
//             )) : const SizedBox(),
//
//         !widget.isDetails?
//         Align(
//           alignment: Provider.of<LocalizationController>(context, listen: false).isLtr? Alignment.topRight:Alignment.topLeft,
//           child: Padding(
//             padding: const EdgeInsets.all(15),
//             child: SpeedDial(
//               animationDuration: const Duration(milliseconds: 150),
//               overlayOpacity: 0,
//               icon: Icons.more_horiz,
//               activeIcon: Icons.close,
//               spacing: 3,
//               mini: mini,
//               openCloseDial: isDialOpen,
//               childPadding: const EdgeInsets.all(5),
//               spaceBetweenChildren: 4,
//               buttonSize: buttonSize,
//               childrenButtonSize: childrenButtonSize,
//               visible: visible,
//               direction: speedDialDirection,
//               switchLabelPosition: switchLabelPosition,
//               closeManually: true,
//               renderOverlay: renderOverlay,
//               useRotationAnimation: useRAnimation,
//               backgroundColor: Theme.of(context).cardColor,
//               foregroundColor: Theme.of(context).disabledColor,
//               elevation: extend? 0:  8.0,
//               animationCurve: Curves.elasticInOut,
//               isOpenOnStart: false,
//               shape: customDialRoot ? const RoundedRectangleBorder() : const StadiumBorder(),
//               onOpen: () {
//                 setState(() {
//                   extend = true;
//                 });
//               },
//               onClose: () {
//                 setState(() {
//                   extend = false;
//                 });
//               },
//
//               children: [
//                 SpeedDialChild(
//                   elevation: 0,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Image.asset(Images.editIcon),
//                   ),
//
//                   onTap: () async {
//                     setState(() {
//                       isDialOpen.value = false;
//                       extend = false;
//                     });
//
//                     await Future.delayed(const Duration(milliseconds : 350));
//                     Navigator.of(Get.context!).push(MaterialPageRoute(builder: (_) => AddProductTabView(product: widget.productModel, fromHome: false,)));
//                   },
//                 ),
//
//                 SpeedDialChild(
//                   elevation: 0,
//                   child: Padding( padding: const EdgeInsets.all(8.0),
//                     child: Image.asset(Images.barCode),),
//
//                   onTap: () async {
//                     setState(() {
//                       isDialOpen.value = false;
//                       extend = false;
//                     });
//
//                     await Future.delayed(const Duration(milliseconds : 350));
//                     Navigator.of(Get.context!).push(MaterialPageRoute(builder: (_) => BarCodeGenerateScreen(product: widget.productModel)));
//                     Provider.of<BarcodeController>(Get.context!, listen: false).setBarCodeQuantity(4);
//                   },
//                 ),
//
//                 SpeedDialChild(
//                   elevation: 0,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Image.asset(Images.delete),
//                   ),
//
//                   onTap: () async {
//                     setState(() {
//                       isDialOpen.value = false;
//                       extend = false;
//                     });
//
//                     await Future.delayed(const Duration(milliseconds : 350));
//                     showDialog(context: Get.context!, builder: (BuildContext context){
//                       return ConfirmationDialogWidget(icon: Images.deleteProduct,
//                           refund: false,
//                           description: getTranslated('are_you_sure_want_to_delete_this_product', context),
//                           onYesPressed: () {
//                             Provider.of<ProductController>(context, listen:false).deleteProduct(context ,widget.productModel!.id).then((value) {
//                               Provider.of<ProductController>(Get.context!,listen: false).getStockOutProductList(1, 'en');
//                               Provider.of<ProductController>(Get.context!, listen: false).getSellerProductList(Provider.of<ProfileController>(Get.context!, listen: false).
//                               userInfoModel!.id.toString(), 1, 'en','',
//                                 filterModel: FilterModel(
//                                   reload: true
//                                 )
//                               );
//                             });
//                           }
//
//                       );});
//                   },
//                 ),
//
//               ],
//             ),
//           ),
//         ):const SizedBox()
//       ],
//     );
//   }
//
//   void _showPreview(String url, String productName, String fileName) {
//     PreviewType type = ProductHelper.getFileType(url);
//
//       showDialog(context: context, builder: (BuildContext context){
//         return Dialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
//           insetPadding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
//           child: (type == PreviewType.pdf) ?
//           PdfPreview(url: url, fileName: productName) : (type == PreviewType.image) ?
//           ImagePreview(url: url, fileName: productName) : (type == PreviewType.video) ?
//           VideoPreview(url: url, fileName: productName) : (type == PreviewType.audio)  ?
//           AudioPreview(url: url, fileName: productName) : (type == PreviewType.others) ?
//           DownloadPreview(url: url, fileName: fileName) :
//           const SizedBox(),
//         );
//       });
//   }
// }
//
//
// class DiscountTagWidget extends StatelessWidget {
//   const DiscountTagWidget({
//     super.key,
//     this.positionedTop = 10,
//     this.positionedLeft = 10,
//     this.positionedRight = 10,
//   });
//
//   final double positionedTop;
//   final double positionedLeft;
//   final double positionedRight;
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isLtr  = Provider.of<LocalizationController>(context, listen: false).isLtr;
//
//     return Positioned(
//       top: positionedTop,
//       left: isLtr ? positionedLeft : null,
//       right: !isLtr ? positionedRight : null,
//       child: Image.asset(Images.clearanceDiscountIcon, height: 30, width: 30),
//     );
//   }
// }
