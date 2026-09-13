
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/confirmation_dialog_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/features/transaction/controllers/transaction_controller.dart';
import 'package:sixvalley_vendor_app/features/transaction/domain/models/transaction_model.dart';
import 'package:sixvalley_vendor_app/features/transaction/widgets/transaction_details_widget.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/helper/color_helper.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import '../../../main.dart' show Get;

class TransactionWidget extends StatelessWidget {
  final TransactionModel transactionModel;
  const TransactionWidget({super.key, required this.transactionModel});

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap:()=> _onTap(context),
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        margin: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall,0, Dimensions.paddingSizeSmall, Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(
              offset: const Offset(0, 3),
              blurRadius: 8,
              spreadRadius: 0,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
            )]
        ),
        child: Column(crossAxisAlignment : CrossAxisAlignment.start, children: [

          Container(
            padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              color: Provider.of<ThemeController>(context).darkTheme ?
              ColorHelper.blendColors(Colors.white, Theme.of(context).highlightColor, 0.9) :
              Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Row(
              children: [

                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(crossAxisAlignment: CrossAxisAlignment.start,children: [
                      Text(getTranslated('transaction_id', context)!, style: robotoMedium.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: Dimensions.fontSizeSmall,
                      )),

                      Text.rich(
                        style: robotoMedium.copyWith(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                        TextSpan(children: [
                          const TextSpan(text: ' # ',),
                          TextSpan(text: '${transactionModel.id}'),
                        ]),
                      ),
                    ]),

                    Text(
                      DateConverter.isoStringToLocalDateAndTime(transactionModel.createdAt!),
                      style: titilliumRegular.copyWith(
                        color: Theme.of(context).hintColor.withValues(),
                        fontSize: Dimensions.fontSizeExtraSmall,
                      ),
                    ),

                  ],
                ),),

                Center(
                  child: Row(children: [

                    SizedBox(width: Dimensions.iconSizeSmall, child: Image.asset(
                      transactionModel.approved == 1 ? Images.approveIcon:transactionModel.approved == 2? Images.declineIcon : Images.pendingIcon,
                    )),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      child: Text(getTranslated(transactionModel.approved == 2 ? 'denied' : transactionModel.approved == 1 ? 'approved' : 'pending', context)!,
                        style: robotoMedium.copyWith(color: transactionModel.approved == 1 ? Colors.green : transactionModel.approved == 2 ?
                        Colors.red : Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault),
                      ),
                    ),
                  ]))
              ],
            ),
          ),

          const SizedBox(
            height: Dimensions.paddingSizeSmall,
          ),

          Row(
            children: [
              Text(PriceConverter.convertPrice(context, transactionModel.amount), style: robotoBold.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: Dimensions.fontSizeDefault,
              )),

              Spacer(),

              if(transactionModel.approved != 1 && transactionModel.approved != 2)
                Consumer<WalletController>(
                  builder: (context, walletController, child) {
                    return InkWell(
                      onTap:()=> cancelTransaction(context, transactionModel),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium ,vertical: Dimensions.paddingSizeOrder),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                        ),
                        alignment: Alignment.center,
                        child: Text(getTranslated('cancel', context)!, style: robotoRegular.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: Dimensions.fontSizeSmall,
                        )),
                      ),
                    );
                  },
                ),

            ],
          ),

        ]),
      ),
    );
  }

  void _onTap(BuildContext context){
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context, builder: (_) =>  Wrap(
        children: [
          TransactionDetailsWidget(transactionModel: transactionModel,),
        ],
      ),
    );
  }
}

void cancelTransaction (BuildContext context, TransactionModel transactionModel) {
  showDialog(context: context,barrierDismissible: false, builder: (BuildContext context){
    return Consumer<WalletController>(
      builder: (context, walletController, child) {
        return ConfirmationDialogWidget(
          icon: Images.deleteIcon,
          description: getTranslated('are_you_sure_you_want', context),
          refund: false,
          isLoading: walletController.isLoading,
          onYesPressed: () {
            walletController.isLoading ?
            const Center(child: CircularProgressIndicator()) : walletController.closeWithdrawRequest(transactionModel.id ?? 0, transactionModel.amount.toString()).then((value) {
              if(value.response!.statusCode == 200) {
                Navigator.pop(Get.context!);
                Provider.of<TransactionController>(Get.context!, listen: false).getTransactionList(Get.context!, 'all','','');
                showCustomSnackBarWidget(getTranslated('withdraw_request_deleted', Get.context!), Get.context!, isError: false);
              }
            });
          },
        );
      },
    );
  });
}
