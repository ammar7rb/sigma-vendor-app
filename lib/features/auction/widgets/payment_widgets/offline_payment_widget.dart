import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_action_sheet_widget.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';


class OfflinePaymentDialogWidget extends StatelessWidget {
  final double rotateAngle;
  final Function()? onTap;
  final TextEditingController? paymentBy;
  final TextEditingController? transactionId;
  final TextEditingController? paymentNote;
  const OfflinePaymentDialogWidget({super.key,  this.rotateAngle = 0,  required this.onTap, this.paymentBy, this.transactionId, this.paymentNote});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(getTranslated('offline_payment', context)!, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),),
                  InkWell(onTap: ()=> Navigator.of(context).pop(),
                      child: const SizedBox(child: Icon(Icons.clear)))]),


              const SizedBox(height: Dimensions.paddingSizeExtraLarge,),
              Text(getTranslated('payment_by', context)!, style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),),
              const SizedBox(height: Dimensions.paddingSizeSmall,),
              CustomTextFieldWidget(controller: paymentBy,
                textInputAction: TextInputAction.next, border: true,),

              const SizedBox(height: Dimensions.paddingSizeDefault,),
              Text(getTranslated('transaction_id', context)!, style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),),
              const SizedBox(height: Dimensions.paddingSizeSmall,),

              CustomTextFieldWidget(controller: transactionId,
                textInputAction: TextInputAction.next, border: true,),
              const SizedBox(height: Dimensions.paddingSizeDefault,),

              Text(getTranslated('payment_note', context)!, style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),),
              const SizedBox(height: Dimensions.paddingSizeSmall,),
              CustomTextFieldWidget(controller: paymentNote, textInputAction: TextInputAction.done, border: true),

              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              Row(children: [
                Expanded(child: CustomButton(label: getTranslated('cancel', context) ?? '',
                backgroundColor: Theme.of(context).hintColor,
                onPressed: ()=> Navigator.of(context).pop(),)),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(child: CustomButton(label: getTranslated('submit', context) ?? '', onPressed: () => onTap))]
              )
            ]
        ),
      ),
    );
  }
}
