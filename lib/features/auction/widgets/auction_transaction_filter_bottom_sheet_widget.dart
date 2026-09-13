import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_date_picker_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_transaction_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AuctionTransactionFilterBottomSheet extends StatelessWidget {
  final int? searchAuctionId;

  const AuctionTransactionFilterBottomSheet({super.key, this.searchAuctionId});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuctionTransactionController>(
      builder: (context, controller, _) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: Dimensions.paddingSizeSmall,
            right: Dimensions.paddingSizeSmall,
            bottom: MediaQuery.of(context).viewInsets.bottom + Dimensions.paddingSizeDefault,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            // Handle bar
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 4, width: 40,
                margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                ),
              ),
            ),

            // Header row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Row(children: [
                Expanded(
                  child: Text(
                    getTranslated('filter', context) ?? 'Filter',
                    textAlign: TextAlign.center,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                if (controller.isFilterActive)
                  InkWell(
                    onTap: () async {
                      controller.resetFilters();
                      await controller.getAuctionTransactionList(
                        context,
                        isRefresh: true,
                        searchAuctionId: searchAuctionId,
                      );
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: Row(children: [
                      SizedBox(width: 18, height: 18, child: Image.asset(Images.reset)),
                      const SizedBox(width: 4),
                      Text(
                        getTranslated('reset', context) ?? 'Reset',
                        style: robotoRegular.copyWith(color: Theme.of(context).primaryColor),
                      ),
                    ]),
                  ),
              ]),
            ),

            Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: 0.5)),
            const SizedBox(height: Dimensions.paddingSizeMedium),

            // Transaction type chips
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: Text(
                  getTranslated('transaction_status', context) ?? 'Transaction Status',
                  style: robotoMedium.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(children: [
                _TypeChip(
                  label: getTranslated('credit', context) ?? 'Credit',
                  value: 'credit',
                  isSelected: controller.selectedTransactionTypes.contains('credit'),
                  onTap: () => controller.toggleTransactionType('credit'),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                _TypeChip(
                  label: getTranslated('debit', context) ?? 'Debit',
                  value: 'debit',
                  isSelected: controller.selectedTransactionTypes.contains('debit'),
                  onTap: () => controller.toggleTransactionType('debit'),
                ),
              ]),
            ),

            const SizedBox(height: Dimensions.paddingSizeMedium),

            // Duration type selector
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: Text(
                  getTranslated('duration', context) ?? 'Duration',
                  style: robotoMedium.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.4)),
                ),
                child: DropdownButton<String>(
                  value: controller.filterDurationType,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  dropdownColor: Theme.of(context).cardColor,
                  style: robotoRegular.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text(getTranslated('all_time', context) ?? 'All Time')),
                    DropdownMenuItem(value: 'this_month', child: Text(getTranslated('this_month', context) ?? 'This Month')),
                    DropdownMenuItem(value: 'this_year', child: Text(getTranslated('this_year', context) ?? 'This Year')),
                    DropdownMenuItem(value: 'custom_date', child: Text(getTranslated('custom', context) ?? 'Custom')),
                  ],
                  onChanged: (value) {
                    if (value != null) controller.setFilterDurationType(value);
                  },
                ),
              ),
            ),

            // Custom date pickers (shown only when custom is selected)
            if (controller.filterDurationType == 'custom_date') ...[
              const SizedBox(height: Dimensions.paddingSizeMedium),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: Row(children: [
                  Expanded(child: CustomDatePickerWidget(
                    fromClearance: true,
                    title: getTranslated('start_date', context),
                    image: Images.calenderIcon,
                    text: controller.filterStartDate != null
                        ? controller.dateFormat.format(controller.filterStartDate!)
                        : getTranslated('select_date', context),
                    selectDate: () => controller.selectFilterDate('start', context),
                  )),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(child: CustomDatePickerWidget(
                    fromClearance: true,
                    title: getTranslated('end_date', context),
                    image: Images.calenderIcon,
                    text: controller.filterEndDate != null
                        ? controller.dateFormat.format(controller.filterEndDate!)
                        : getTranslated('select_date', context),
                    selectDate: () => controller.selectFilterDate('end', context),
                  )),
                ]),
              ),
            ],

            const SizedBox(height: Dimensions.paddingSizeLarge),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: CustomButtonWidget(
                isLoading: controller.isLoading,
                buttonHeight: 50,
                btnTxt: getTranslated('filter', context),
                onTap: () async {
                  if (controller.filterDurationType == 'custom_date') {
                    if (controller.filterStartDate != null && controller.filterEndDate == null ||
                        controller.filterStartDate == null && controller.filterEndDate != null) {
                      showCustomToast(
                        message: getTranslated('select_start_and_end_time', context)!,
                        context: context,
                        isSuccess: false,
                      );
                      return;
                    }
                    if (controller.filterStartDate != null &&
                        controller.filterEndDate != null &&
                        controller.filterEndDate!.isBefore(controller.filterStartDate!)) {
                      showCustomToast(
                        message: getTranslated('end_date_should_not_before_start_date', context)!,
                        context: context,
                        isSuccess: false,
                      );
                      return;
                    }
                  }

                  await controller.applyFilters(context, searchAuctionId: searchAuctionId);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ),
          ]),
        );
      },
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).hintColor.withValues(alpha: 0.2);
    final textColor = isSelected
        ? Colors.white
        : Theme.of(context).textTheme.bodyLarge?.color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeMedium,
          vertical: Dimensions.paddingSizeSmall,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).hintColor.withValues(alpha: 0.4),
          ),
        ),
        child: Text(label, style: robotoMedium.copyWith(
          color: textColor,
          fontSize: Dimensions.fontSizeDefault,
        )),
      ),
    );
  }
}
