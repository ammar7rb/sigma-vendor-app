import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_date_picker_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_product_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class AuctionTaxFilterBottomSheet extends StatelessWidget {
  const AuctionTaxFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Consumer<AuctionProductController>(
        builder: (context, controller, child) {
          return Column(mainAxisSize: MainAxisSize.min, children: [

            Align(
              alignment: Alignment.center,
              child: Container(
                height: 4, width: 40,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: Theme.of(context).hintColor.withValues(alpha: 0.5),
                ),
              ),
            ),

            Transform.translate(
              offset: const Offset(0, -7),
              child: Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.cancel_outlined, size: Dimensions.iconSizeMedium, color: Theme.of(context).hintColor),
                ),
              ),
            ),

            Row(children: [
              const Expanded(flex: 1, child: SizedBox()),

              Expanded(
                flex: 1,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: Dimensions.paddingSizeDefault,
                      top: Dimensions.paddingSizeExtraLarge,
                    ),
                    child: Text(getTranslated('filter_date', context)!, style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    )),
                  ),
                ]),
              ),

              Expanded(
                flex: 1,
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  if (controller.vatStartDate != null || controller.vatEndDate != null)
                    InkWell(
                      onTap: () async {
                        controller.resetVatData();
                        await controller.getAuctionVatReport(1);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      child: Row(children: [
                        SizedBox(width: 20, child: Image.asset(Images.reset)),
                        Text(getTranslated('reset', context) ?? 'Reset', style: robotoRegular.copyWith(color: Theme.of(context).primaryColor)),
                        const SizedBox(width: Dimensions.paddingSizeDefault),
                      ]),
                    ),
                ]),
              ),
            ]),

            SizedBox(height: Dimensions.paddingSizeSmall),

            Container(
              margin: const EdgeInsets.symmetric(
                vertical: Dimensions.paddingSizeSmall,
                horizontal: Dimensions.paddingSizeDefault,
              ),
              child: Row(children: [
                Expanded(child: CustomDatePickerWidget(
                  fromClearance: true,
                  title: getTranslated('start_date', context),
                  image: Images.calenderIcon,
                  text: controller.vatStartDate != null
                      ? controller.vatDateFormat.format(controller.vatStartDate!).toString()
                      : getTranslated('select_date', context),
                  selectDate: () => controller.selectVatDate('start', context),
                )),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(child: CustomDatePickerWidget(
                  fromClearance: true,
                  title: getTranslated('end_date', context),
                  image: Images.calenderIcon,
                  text: controller.vatEndDate != null
                      ? controller.vatDateFormat.format(controller.vatEndDate!).toString()
                      : getTranslated('select_date', context),
                  selectDate: () => controller.selectVatDate('end', context),
                )),
              ]),
            ),

            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: CustomButtonWidget(
                isLoading: controller.isAuctionVatReportLoading,
                buttonHeight: 50,
                btnTxt: getTranslated('filter', context),
                onTap: () async {
                  if ((controller.vatStartDate != null && controller.vatEndDate == null) ||
                      (controller.vatStartDate == null && controller.vatEndDate != null)) {
                    showCustomToast(
                      message: getTranslated('select_start_and_end_time', context)!,
                      context: context,
                      isSuccess: false,
                    );
                  } else if (controller.vatStartDate != null &&
                      controller.vatEndDate != null &&
                      !_isEndDateValid(controller.vatStartDate!, controller.vatEndDate!)) {
                    showCustomToast(
                      message: getTranslated('end_date_should_not_before_start_date', context)!,
                      context: context,
                      isSuccess: false,
                    );
                  } else {
                    await controller.getAuctionVatReport(
                      1,
                      startDate: controller.vatStartDate.toString(),
                      endDate: controller.vatEndDate.toString(),
                    );
                    controller.setVatFilterActive(true);
                    if (context.mounted) Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ]);
        },
      ),
    );
  }

  bool _isEndDateValid(DateTime start, DateTime end) =>
      end.isAfter(start) || end.isAtSameMomentAs(start);
}
