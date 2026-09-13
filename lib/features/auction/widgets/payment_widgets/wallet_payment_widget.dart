import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_action_sheet_widget.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';

class WalletPaymentWidget extends StatelessWidget {
  final double rotateAngle;
  final Function()? onTap;
  final double orderAmount;
  final double currentBalance;

  const WalletPaymentWidget({super.key,  this.rotateAngle = 0,  required this.onTap, required this.orderAmount, required this.currentBalance});

  @override
  Widget build(BuildContext context) {
    return Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

            Text(getTranslated('wallet_payment', context)!, style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            )),

            InkWell(onTap: (){Navigator.of(context).pop();}, child: const SizedBox(child: Icon(Icons.clear))),
          ]),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

          Text(getTranslated('your_current_balance', context)!, style: titilliumRegular.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          )),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).hintColor.withValues(alpha:.1),
              border: Border.all(width: .5, color: Theme.of(context).hintColor),
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
            ),
            child: Text(PriceConverter.convertPrice(context, currentBalance), style: titilliumRegular.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            )),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Text(getTranslated('order_amount', context)!, style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).hintColor.withValues(alpha:.1),
              border: Border.all(width: .5, color: Theme.of(context).hintColor),
              borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
            ),
            child: Text(PriceConverter.convertPrice(context, orderAmount), style: titilliumRegular.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            )),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Text(getTranslated('remaining_balance', context)!, style: titilliumRegular.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          )),
          const SizedBox(height: Dimensions.paddingSizeSmall,),

          Container(width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(color: Theme.of(context).hintColor.withValues(alpha:.1),
                border: Border.all(width: .5, color: Theme.of(context).hintColor),
                borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)),
            child: Text(PriceConverter.convertPrice(context, (currentBalance - orderAmount)), style: titilliumRegular.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
            )),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

          Row(children: [
            Expanded(child: CustomButton(label: getTranslated('cancel', context) ?? '',
              backgroundColor: Theme.of(context).hintColor,
              onPressed: ()=> Navigator.of(context).pop())),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(child: CustomButton(label: getTranslated('submit', context) ?? '', onPressed: ()=> onTap)),
          ]),
        ]),
      ),
    );
  }
}
