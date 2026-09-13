import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_ai_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/config_model.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AuctionGenerateTitleBottomSheet extends StatefulWidget {
  final List<Language>? languageList;
  final TabController? tabController;
  final List<TextEditingController>? nameControllerList;
  final List<TextEditingController>? descriptionControllerList;

  const AuctionGenerateTitleBottomSheet({
    super.key,
    this.languageList,
    this.tabController,
    this.nameControllerList,
    this.descriptionControllerList,
  });

  @override
  State<AuctionGenerateTitleBottomSheet> createState() => _AuctionGenerateTitleBottomSheetState();
}

class _AuctionGenerateTitleBottomSheetState extends State<AuctionGenerateTitleBottomSheet> {
  final TextEditingController _keywordController = TextEditingController();
  final List<String> _keywords = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuctionAiController>(context, listen: false).clearTitleSuggestions();
    });
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  void _addKeyword(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      setState(() => _keywords.add(trimmed));
      _keywordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusExtraLarge),
            topRight: Radius.circular(Dimensions.radiusExtraLarge),
          ),
        ),
        child: Consumer<AuctionAiController>(
          builder: (context, aiController, child) {
            return Column(mainAxisSize: MainAxisSize.min, children: [

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const SizedBox(width: 20),
                Container(
                  height: 5, width: 35,
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    right: Dimensions.paddingSizeSmall,
                    top: Dimensions.paddingSizeSmall,
                  ),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.close,
                      color: Theme.of(context).hintColor.withValues(alpha: 0.6),
                      size: 22,
                    ),
                  ),
                ),
              ]),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Text(
                      getTranslated('great', context) ?? '',
                      style: robotoBold.copyWith(color: Theme.of(context).textTheme.titleMedium?.color),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    Text(
                      getTranslated('now_tell_me_which_product_you_want_to_create_just_type_it_simply_like', context) ?? '',
                      style: robotoBold.copyWith(color: Theme.of(context).textTheme.titleMedium?.color),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Row(children: [
                      CircleAvatar(backgroundColor: Theme.of(context).hintColor, radius: 3),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Text(
                          getTranslated('enter_some_keywords_you_want_in_the_name', context) ?? '',
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).textTheme.headlineLarge?.color,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Row(children: [
                      CircleAvatar(backgroundColor: Theme.of(context).hintColor, radius: 3),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Text(
                          getTranslated('or_you_can_give_related_title_we_will_generate_some_new_title_for_you', context) ?? '',
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).textTheme.headlineLarge?.color,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Text(
                      getTranslated('feel_free_to_describe_it_your_own_way', context) ?? '',
                      style: robotoRegular.copyWith(
                        color: Theme.of(context).textTheme.headlineLarge?.color,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                        vertical: Dimensions.paddingSizeLarge,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).hintColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Row(children: [
                          Expanded(
                            flex: 8,
                            child: CustomTextFieldWidget(
                              hintText: getTranslated('enter_sample_keyword', context),
                              labelText: getTranslated('keyword', context),
                              controller: _keywordController,
                              textInputAction: TextInputAction.done,
                              onFieldSubmit: (value) => _addKeyword(value),
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          Expanded(
                            flex: 2,
                            child: CustomButtonWidget(
                              btnTxt: getTranslated('add', context),
                              backgroundColor: Theme.of(context).primaryColor,
                              onTap: () => _addKeyword(_keywordController.text),
                            ),
                          ),
                        ]),

                        if (_keywords.isNotEmpty) ...[
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          SizedBox(
                            height: 40,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: _keywords.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).hintColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  ),
                                  child: Center(
                                    child: Row(children: [
                                      Text(
                                        _keywords[index],
                                        style: robotoMedium.copyWith(color: Theme.of(context).hintColor),
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                      InkWell(
                                        onTap: () => setState(() => _keywords.removeAt(index)),
                                        child: Icon(Icons.clear, size: 18, color: Theme.of(context).hintColor),
                                      ),
                                    ]),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ]),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                    if (!aiController.titleSuggestionsLoading)
                      CustomButtonWidget(
                        backgroundColor: Theme.of(context).primaryColor,
                        onTap: () {
                          if (_keywords.isEmpty) {
                            showCustomSnackBarWidget(
                              getTranslated('please_add_a_keyword_to_generate_food_name', context),
                              context,
                            );
                          } else {
                            aiController.generateTitleSuggestions(keywords: _keywords);
                          }
                        },
                        btnTxt: getTranslated('generate_product_name', context) ?? '',
                      ),

                    if (aiController.titleSuggestionsLoading) ...[
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      Shimmer.fromColors(
                        baseColor: Theme.of(context).hintColor.withValues(alpha: 0.18),
                        highlightColor: Theme.of(context).hintColor.withValues(alpha: 0.06),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.auto_awesome, color: Colors.blue),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Text(
                            '${getTranslated('generating', context)}...',
                            style: robotoBold.copyWith(color: Colors.blue),
                          ),
                        ]),
                      ),
                    ],

                    if (aiController.titleSuggestions.isNotEmpty) ...[
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      Text(
                        getTranslated('suggested_titles', context) ?? '',
                        style: robotoBold.copyWith(color: Theme.of(context).textTheme.titleMedium?.color),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: aiController.titleSuggestions.length,
                        itemBuilder: (context, index) {
                          final String title = aiController.titleSuggestions[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                              vertical: Dimensions.paddingSizeExtraSmall,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).hintColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                            ),
                            child: Row(children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: robotoRegular.copyWith(
                                    color: Theme.of(context).textTheme.headlineLarge?.color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeSmall),
                              SizedBox(
                                width: 70,
                                child: CustomButtonWidget(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  btnTxt: getTranslated('use', context) ?? '',
                                  onTap: () {
                                    final nav = Navigator.of(context);
                                    final int tabIndex = widget.tabController?.index ?? 0;
                                    widget.nameControllerList?[tabIndex].text = title;
                                    nav.pop();
                                    nav.pop();
                                  },
                                ),
                              ),
                            ]),
                          );
                        },
                      ),
                    ],
                  ]),
                ),
              ),
            ]);
          },
        ),
      ),
    );
  }
}
