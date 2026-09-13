import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sixvalley_vendor_app/features/addProduct/controllers/add_product_tax_controller.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/tax_vat_model.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/dropdown_decorator_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_tag_widget.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:textfield_tags/textfield_tags.dart';

class AddAuctionInfoWidget extends StatefulWidget {
  final TextEditingController startPriceController;
  final TextEditingController minimumIncrementController;
  final TextEditingController maximumDecrementController;
  final DateTime? startTime;
  final DateTime? endTime;
  final ValueChanged<DateTime?> onStartTimeChanged;
  final ValueChanged<DateTime?> onEndTimeChanged;
  final ValueChanged<List<TaxVatModel>> onVatTaxChanged;
  final TextfieldTagsController tagsController;

  final bool isAiGenerating;
  final VoidCallback? onAiTap;
  final List<String> initialTags;

  const AddAuctionInfoWidget({
    super.key,
    required this.startPriceController,
    required this.minimumIncrementController,
    required this.maximumDecrementController,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    required this.onVatTaxChanged,
    required this.tagsController,
    this.startTime,
    this.endTime,
    this.isAiGenerating = false,
    this.onAiTap,
    this.initialTags = const [],
  });

  @override
  State<AddAuctionInfoWidget> createState() => _AddAuctionInfoWidgetState();
}

class _AddAuctionInfoWidgetState extends State<AddAuctionInfoWidget> {

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickDateTime({
    required DateTime? initial,
    required ValueChanged<DateTime?> onPicked,
    DateTime? firstDateTime,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDate = firstDateTime != null
        ? DateTime(firstDateTime.year, firstDateTime.month, firstDateTime.day)
        : today;

    final initialDate = initial != null && !initial.isBefore(firstDate) ? initial : firstDate;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial ?? now),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
    if (time == null) return;

    onPicked(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1B7FED),
            offset: Offset(0, 6),
            blurRadius: 12,
            spreadRadius: -3,
          ),
          BoxShadow(
            color: Color(0x0D1B7FED),
            offset: Offset(0, -6),
            blurRadius: 12,
            spreadRadius: -3,
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.fontSizeExtraLarge),
            child: Row(
              children: [
                Expanded(
                  child: Text(getTranslated('auction_info', context) ?? '',
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                if (Provider.of<SplashController>(context, listen: false).configModel?.isAiFeatureActive == 1 && widget.onAiTap != null)
                  widget.isAiGenerating
                      ? Shimmer.fromColors(
                          baseColor: Theme.of(context).primaryColor,
                          highlightColor: Colors.grey[100]!,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome, color: Colors.blue),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                              Text(
                                getTranslated('generating', context) ?? 'Generating...',
                                style: robotoBold.copyWith(color: Colors.blue),
                              ),
                            ],
                          ),
                        )
                      : InkWell(
                          onTap: widget.onAiTap,
                          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                          child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            child: Icon(Icons.auto_awesome, size: Dimensions.iconSizeMedium, color: Theme.of(context).primaryColor),
                          ),
                        ),
              ],
            ),
          ),

          Padding(padding: const EdgeInsets.symmetric(vertical: 0, horizontal: Dimensions.fontSizeExtraLarge),
            child: Text(getTranslated('auction_info_description', context) ?? '',
              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.headlineLarge?.color),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          _ShimmerOverlayWrapper(
            isActive: widget.isAiGenerating,
            baseColor: Theme.of(context).primaryColor.withValues(alpha: 0.7),
            highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Dimensions.paddingSizeSmall),

                AuctionTextField(
                  controller: widget.startPriceController,
                  hintText: getTranslated('start_price', context) ?? "",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                AuctionTextField(
                  controller: widget.minimumIncrementController,
                  hintText: getTranslated('minimum_increment', context) ?? "",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                AuctionTextField(
                  controller: widget.maximumDecrementController,
                  hintText: getTranslated('maximum_decrement', context) ?? "",
                  keyboardType: TextInputType.number,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
                  child: Consumer<AddProductTaxController>(
                    builder: (context, addProductTaxController, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownDecoratorWidget(
                            isRequired: true,
                            child: DropdownButton<TaxVatModel>(
                              icon: const Icon(Icons.keyboard_arrow_down_outlined),
                              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingEye)),
                              hint: Text(getTranslated('select_tax_rate', context) ?? '',
                                  style: titilliumRegular.copyWith(color: Theme.of(context).hintColor)),
                              items: addProductTaxController.taxVatList.map((TaxVatModel? value) {
                                bool isSelected = addProductTaxController.isSelected(value!);
                                return DropdownMenuItem<TaxVatModel>(
                                  enabled: !isSelected,
                                  value: value,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('${value.name} ${value.id != 0 ? '(${value.taxRate}%)' : ''}'),
                                      if (isSelected)
                                        Icon(Icons.check, color: Theme.of(context).primaryColor, size: 18),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (TaxVatModel? value) {
                                if (value == null) return;
                                if (value.id == 0) {
                                  for (TaxVatModel taxVatModel in addProductTaxController.taxVatList) {
                                    if (taxVatModel.id != 0 && !addProductTaxController.isSelected(taxVatModel)) {
                                      addProductTaxController.addToSelectedTaxList(taxVatModel);
                                    }
                                  }
                                  widget.onVatTaxChanged(addProductTaxController.selectedTaxList);
                                  return;
                                } else {
                                  addProductTaxController.addToSelectedTaxList(value);
                                }
                                widget.onVatTaxChanged(addProductTaxController.selectedTaxList);
                              },
                              isExpanded: true,
                              underline: const SizedBox(),
                            ),
                          ),

                          !addProductTaxController.selectedTaxList.isNotEmpty ?
                          const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox.shrink(),

                          addProductTaxController.selectedTaxList.isNotEmpty ?
                          SizedBox(
                            height: addProductTaxController.selectedTaxList.isNotEmpty ? 40 : 0,
                            child: ListView.builder(
                              itemCount: addProductTaxController.selectedTaxList.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeVeryTiny),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeMedium),
                                    margin: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                                    decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha:.20),
                                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                                    ),
                                    child: Row(children: [
                                      Consumer<SplashController>(builder: (ctx, colorP,child){
                                        return Text(
                                          '${addProductTaxController.selectedTaxList[index].name} (${addProductTaxController.selectedTaxList[index].taxRate}%)',
                                          style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                                        );
                                      }),
                                      const SizedBox(width: Dimensions.paddingSizeSmall),

                                      InkWell(
                                        splashColor: Colors.transparent,
                                        onTap: (){
                                          addProductTaxController.removeToSelectedTaxList (addProductTaxController.selectedTaxList[index], index);
                                          widget.onVatTaxChanged(addProductTaxController.selectedTaxList);
                                        },
                                        child: Icon(Icons.close, size: 15, color: Theme.of(context).textTheme.bodyLarge?.color),
                                      ),
                                    ]),
                                  ),
                                );
                              },
                            ),
                          ) : const SizedBox(),

                          addProductTaxController.selectedTaxList.isNotEmpty ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),
                        ],
                      );
                    }
                  ),
                ),

                Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
                  child: AuctionDateTimeField(
                    hintText: getTranslated('start_time', context) ?? "",
                    value: DateConverter.formatAuctionDateTime(widget.startTime),
                    onTap: () => _pickDateTime(
                      initial: widget.startTime,
                      onPicked: widget.onStartTimeChanged,
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
                  child: AuctionDateTimeField(
                    hintText: getTranslated('end_time', context) ?? "",
                    value: DateConverter.formatAuctionDateTime(widget.endTime),
                    onTap: () => _pickDateTime(
                      initial: widget.endTime,
                      onPicked: widget.onEndTimeChanged,
                      firstDateTime: widget.startTime,
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AuctionTagWidget(
                        controller: widget.tagsController,
                        initialTags: widget.initialTags,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TaxDropdownField extends StatelessWidget {
  final String hintText;
  final List<TaxVatModel> items;
  final TaxVatModel? selectedItem;
  final ValueChanged<TaxVatModel?> onChanged;

  const TaxDropdownField({
    super.key,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.selectedItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeMedium,
        vertical: Dimensions.paddingSizeVeryTiny,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: .25),
          width: .75,
        ),
      ),
      child: DropdownButton<TaxVatModel>(
        value: selectedItem,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down_outlined, size: Dimensions.iconSizeMedium),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        hint: Text(
          '$hintText *',
          style: titilliumRegular.copyWith(color: Theme.of(context).hintColor),
        ),
        items: items.map((TaxVatModel tax) {
          return DropdownMenuItem<TaxVatModel>(
            value: tax,
            child: Text(tax.name ?? '', style: titilliumRegular),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class AuctionTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;

  const AuctionTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeMedium,
            vertical: Dimensions.paddingSizeMedium,
          ),
          hintText: '$hintText *',
          hintStyle: titilliumRegular.copyWith(color: Theme.of(context).hintColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            borderSide: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: .25)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            borderSide: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: .25), width: .75),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
        ),
      ),
    );
  }
}

class AuctionDateTimeField extends StatelessWidget {
  final String hintText;
  final String value;
  final VoidCallback onTap;

  const AuctionDateTimeField({
    super.key,
    required this.hintText,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeMedium,
          vertical: Dimensions.paddingSizeMedium,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: .25), width: .75),
        ),
        child: Row(children: [
          Expanded(
            child: Text(
              value.isEmpty ? '$hintText *' : value,
              style: value.isEmpty
                  ? titilliumRegular.copyWith(color: Theme.of(context).hintColor)
                  : titilliumSemiBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
          Icon(Icons.calendar_month_outlined, size: Dimensions.iconSizeMedium, color: Theme.of(context).hintColor),
        ]),
      ),
    );
  }
}

class _ShimmerOverlayWrapper extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final double opacity;
  final Color? baseColor;
  final Color? highlightColor;

  const _ShimmerOverlayWrapper({
    required this.child,
    this.isActive = false,
    this.opacity = 0.3,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      child,
      if (isActive)
        Positioned.fill(
          child: Opacity(
            opacity: opacity,
            child: Shimmer.fromColors(
              baseColor: Theme.of(context).hintColor.withValues(alpha: 0.18),
              highlightColor: Theme.of(context).hintColor.withValues(alpha: 0.06),
              child: Container(color: Colors.white),
            ),
          ),
        ),
    ]);
  }
}