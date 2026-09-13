import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart' show FlutterSwitch;
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/dropdown_decorator_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class MetaSeoWidget extends StatelessWidget {
  const MetaSeoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AddProductController>(
        builder: (context, resProvider, child){
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                color: Theme.of(context).primaryColor.withValues(alpha: 0.05)
              ),
              padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.25)),
                    ),
                    child: RadioGroup<String>(
                      groupValue: resProvider.metaSeoInfo?.metaIndex == '1' ? 'index' : resProvider.metaSeoInfo?.metaIndex,
                      onChanged: (String? value) {
                        if (value == 'index') {
                          resProvider.metaSeoInfo!.metaIndex = 'index';
                          resProvider.metaSeoInfo!.metaNoFollow = 'follow';
                          resProvider.metaSeoInfo!.metaNoImageIndex = '0';
                          resProvider.metaSeoInfo!.metaNoArchive = '0';
                          resProvider.metaSeoInfo!.metaNoSnippet = '0';
                        } else if (value == 'noindex') {
                          resProvider.metaSeoInfo!.metaIndex = 'noindex';
                          resProvider.metaSeoInfo!.metaNoFollow = 'nofollow';
                          resProvider.metaSeoInfo!.metaNoImageIndex = '1';
                          resProvider.metaSeoInfo!.metaNoArchive = '1';
                          resProvider.metaSeoInfo!.metaNoSnippet = '1';
                        }
                        resProvider.updateState();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                resProvider.metaSeoInfo!.metaIndex = 'index';
                                resProvider.metaSeoInfo!.metaNoFollow = 'follow';
                                resProvider.metaSeoInfo!.metaNoImageIndex = '0';
                                resProvider.metaSeoInfo!.metaNoArchive = '0';
                                resProvider.metaSeoInfo!.metaNoSnippet = '0';
                                resProvider.updateState();
                              },
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'index',
                                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Text(getTranslated('index', context)!,
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w600)
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Expanded(
                            child: InkWell(
                              onTap: () {
                                resProvider.metaSeoInfo!.metaIndex = 'noindex';
                                resProvider.metaSeoInfo!.metaNoFollow = 'nofollow';
                                resProvider.metaSeoInfo!.metaNoImageIndex = '1';
                                resProvider.metaSeoInfo!.metaNoArchive = '1';
                                resProvider.metaSeoInfo!.metaNoSnippet = '1';
                                resProvider.updateState();
                              },
                              child: Row(
                                children: [
                                  Radio<String>(
                                    value: 'noindex',
                                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Text(getTranslated('no_index', context)!,
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: MetaSeoItem(
                                title: 'no_follow',
                                value: resProvider.metaSeoInfo?.metaNoFollow == 'nofollow',
                                callback: (bool? value) {
                                  resProvider.metaSeoInfo!.metaNoFollow = value == true ? 'nofollow' : '0';
                                  resProvider.updateState();
                                },
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Expanded(
                              child: MetaSeoItem(
                                title: 'no_archive',
                                value: resProvider.metaSeoInfo?.metaNoArchive == '1',
                                callback: (bool? value) {
                                  resProvider.metaSeoInfo!.metaNoArchive = value == true ? '1' : '0';
                                  resProvider.updateState();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),

                        Row(
                          children: [
                            Expanded(
                              child: MetaSeoItem(
                                title: 'no_image_index',
                                value: resProvider.metaSeoInfo?.metaNoImageIndex == '1',
                                callback: (bool? value) {
                                  resProvider.metaSeoInfo!.metaNoImageIndex = value == true ? '1' : '0';
                                  resProvider.updateState();
                                },
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Expanded(
                              child: MetaSeoItem(
                                title: 'no_snippet',
                                value: resProvider.metaSeoInfo?.metaNoSnippet == '1',
                                callback: (bool? value) {
                                  resProvider.metaSeoInfo!.metaNoSnippet = value == true ? '1' : '0';
                                  resProvider.updateState();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getTranslated('max_snippet', context) ?? '',
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                Text(
                                  getTranslated('maximum_characters_for', context) ?? '',
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          FlutterSwitch(
                            width: 35.0, height: 20.0, toggleSize: 20.0,
                            value: resProvider.metaSeoInfo?.metaMaxSnippet == '1',
                            borderRadius: 20.0,
                            activeColor: Theme.of(context).primaryColor,
                            padding: 1.0,
                            onToggle: (bool isActive) {
                              resProvider.metaSeoInfo!.metaMaxSnippet = isActive ? '1' : '0';
                              resProvider.updateState();
                            },
                          ),
                        ],
                      ),


                      if (resProvider.metaSeoInfo?.metaMaxSnippet == '1') ...[
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        CustomTextFieldWidget(
                          textInputType: TextInputType.number,
                          controller: resProvider.maxSnippetController,
                          border: true,
                          hintText: getTranslated('input_snippet_value', context),
                          onChanged: (value) {
                            resProvider.metaSeoInfo?.metaMaxSnippetValue = value;
                            resProvider.updateState();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getTranslated('max_video_preview', context) ?? '',
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                Text(
                                  getTranslated('maximum_seconds_for_the_video', context) ?? '',
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          FlutterSwitch(
                            width: 35.0, height: 20.0, toggleSize: 20.0,
                            value: resProvider.metaSeoInfo?.metaMaxVideoPreview == '1',
                            borderRadius: 20.0,
                            activeColor: Theme.of(context).primaryColor,
                            padding: 1.0,
                            onToggle: (bool isActive) {
                              resProvider.metaSeoInfo!.metaMaxVideoPreview = isActive ? '1' : '0';
                              resProvider.updateState();
                            },
                          ),
                        ],
                      ),


                      if (resProvider.metaSeoInfo?.metaMaxVideoPreview == '1') ...[
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        CustomTextFieldWidget(
                          textInputType: TextInputType.number,
                          controller: resProvider.maxImagePreviewController,
                          border: true,
                          hintText: getTranslated('input_max_video_preview_value', context),
                          onChanged: (value) {
                            resProvider.metaSeoInfo?.metaMaxVideoPreviewValue = value;
                            resProvider.updateState();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getTranslated('max_image_preview', context) ?? ' ',
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                            Text(
                              getTranslated('determine_the_maximum_size_or', context) ?? '',
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      FlutterSwitch(width: 35.0, height: 20.0, toggleSize: 20.0,
                        value: resProvider.metaSeoInfo?.metaMaxImagePreview == '1',
                        borderRadius: 20.0,
                        activeColor: Theme.of(context).primaryColor,
                        padding: 1.0,
                        onToggle:(bool isActive) {
                          resProvider.metaSeoInfo!.metaMaxImagePreview = isActive ? '1' : '0';
                          resProvider.updateState();
                        },
                      ),
                    ],
                  ),



                  if (resProvider.metaSeoInfo?.metaMaxImagePreview == '1') ...[
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    DropdownDecoratorWidget(
                      child: DropdownButton<String>(
                        value: resProvider.imagePreviewSelectedType,
                        icon: const Icon(Icons.keyboard_arrow_down_outlined),
                        isExpanded: true,
                        underline: const SizedBox(),
                        // Matching the style from your brand dropdown
                        borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),

                        items: resProvider.imagePreviewType.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              getTranslated(value, context) ?? value,
                              style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                            ),
                          );
                        }).toList(),

                        onChanged: (value) {
                          resProvider.setImagePreviewType(value!, true);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            )




          ]
        );
      }
    );
  }
}




class MetaSeoItem extends StatelessWidget {
  final String title;
  final bool value;
  final Function(bool?) callback;

  const MetaSeoItem({super.key, required this.title, required this.value, required this.callback});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(
          height: Dimensions.paddingSizeDefault, width: Dimensions.paddingSizeDefault,
          child: Checkbox(
            checkColor: Theme.of(context).cardColor,
            value: value,
            onChanged: callback,
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Flexible(child: Text(getTranslated(title, context)!, maxLines: 2, overflow: TextOverflow.ellipsis, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color))),
      ]),
    );
  }
}



// Container(
//   decoration: BoxDecoration(
//     borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
//     border: Border.all(color: Theme.of(context).hintColor.withValues(alpha:0.50))
//   ),
//   child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Expanded(child: Column( crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: Dimensions.paddingSizeSmall),
//
//         RadioGroup<String>(
//           groupValue: resProvider.metaSeoInfo?.metaIndex,
//           onChanged: (value) {
//             if (value != null) {
//               resProvider.metaSeoInfo!.metaIndex = value;
//               resProvider.updateState();
//             }
//           },
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               const SizedBox(width: Dimensions.paddingSizeSmall),
//
//
//               InkWell(
//                 borderRadius: BorderRadius.circular(8),
//                 onTap: () {
//                   resProvider.metaSeoInfo!.metaIndex = '1';
//                   resProvider.updateState();
//                 },
//                 child: Row(children: [
//
//                   SizedBox(height: 20, width: 20, child: Radio<String>(value: '1')),
//                   const SizedBox(width: Dimensions.paddingSizeSmall),
//
//                   Text(getTranslated('index', context)!, style: robotoTitleRegular.copyWith(
//                     fontSize: Dimensions.fontSizeDefault,
//                     color: Theme.of(context).textTheme.bodyLarge?.color,
//                   )),
//                 ]),
//               ),
//
//               const SizedBox(width: Dimensions.paddingSizeDefault),
//             ],
//           ),
//         ),
//
//
//         MetaSeoItem(
//           title: 'no_follow',
//           value: resProvider.metaSeoInfo?.metaNoFollow == 'nofollow' ? true : false,
//           callback: (bool? value){
//             resProvider.metaSeoInfo!.metaNoFollow = value == true ? 'nofollow' : '0';
//             resProvider.updateState();
//           },
//         ),
//
//         MetaSeoItem(
//           title: 'no_image_index',
//           value: resProvider.metaSeoInfo?.metaNoImageIndex == '1' ? true : false,
//           callback: (bool? value){
//             resProvider.metaSeoInfo!.metaNoImageIndex = value == true ? '1' : '0';
//             resProvider.updateState();
//           },
//         ),
//
//
//         ],
//       )),
//
//       Expanded(child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: Dimensions.paddingSizeSmall),
//
//         RadioGroup<String>(
//           groupValue: resProvider.metaSeoInfo?.metaIndex,
//           onChanged: (value) {
//             if (value != null) {
//               resProvider.metaSeoInfo!.metaIndex = value;
//               resProvider.metaSeoInfo!.metaNoFollow = 'nofollow';
//               resProvider.metaSeoInfo!.metaNoImageIndex = '1';
//               resProvider.metaSeoInfo!.metaNoArchive = '1';
//               resProvider.metaSeoInfo!.metaNoSnippet = '1';
//               resProvider.updateState();
//             }
//           },
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               const SizedBox(width: Dimensions.paddingSizeSmall),
//
//               InkWell(
//                 borderRadius: BorderRadius.circular(8),
//                 onTap: () {
//                   resProvider.metaSeoInfo!.metaIndex = 'noindex';
//                   resProvider.metaSeoInfo!.metaNoFollow = 'nofollow';
//                   resProvider.metaSeoInfo!.metaNoImageIndex = '1';
//                   resProvider.metaSeoInfo!.metaNoArchive = '1';
//                   resProvider.metaSeoInfo!.metaNoSnippet = '1';
//                   resProvider.updateState();
//                 },
//                 child: Row(children: [
//
//                   SizedBox(height: Dimensions.paddingSizeLarge, width: Dimensions.paddingSizeLarge, child: Radio<String>(value: 'noindex')),
//                   const SizedBox(width: Dimensions.paddingSizeSmall),
//
//                   Text(getTranslated('no_index', context)!, style: robotoTitleRegular.copyWith(
//                     fontSize: Dimensions.fontSizeDefault,
//                     color: Theme.of(context).textTheme.bodyLarge?.color,
//                   )),
//                 ]),
//               ),
//             ],
//           ),
//         ),
//
//         MetaSeoItem(
//             title: 'no_archive',
//             value: resProvider.metaSeoInfo?.metaNoArchive == '1' ? true : false,
//             callback: (bool? value){
//               resProvider.metaSeoInfo!.metaNoArchive = value == true ? '1' : '0';
//               resProvider.updateState();
//             },
//           ),
//
//           MetaSeoItem(
//             title: 'no_snippet',
//             value: resProvider.metaSeoInfo?.metaNoSnippet == '1' ? true : false,
//             callback: (bool? value){
//               resProvider.metaSeoInfo!.metaNoSnippet = value == true ? '1' : '0';
//               resProvider.updateState();
//             },
//           ),
//
//         ],
//       )),
//
//     ],
//   ),
// ),
//
// const SizedBox(height: Dimensions.paddingSizeExtraLarge),
