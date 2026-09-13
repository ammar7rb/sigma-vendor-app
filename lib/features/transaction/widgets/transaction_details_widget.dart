import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/bottom_sheet_topbar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_edit_dialog_widget.dart';
import 'package:sixvalley_vendor_app/features/transaction/domain/models/transaction_model.dart';
import 'package:sixvalley_vendor_app/features/transaction/widgets/transaction_widget.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class TransactionDetailsWidget extends StatelessWidget {
  final TransactionModel transactionModel;
  const TransactionDetailsWidget({super.key, required this.transactionModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(
        children: [

          BottomSheetTopBarWidget(),

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(

              children: [
                Text(
                  getTranslated("withdraw_request", context)??"",
                  style: robotoBold.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeExtraLarge,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Text.rich(TextSpan(
                            text: "${getTranslated("withdraw_amount", context)} : ",
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).textTheme.headlineLarge?.color,
                            ),
                            children: [
                              TextSpan(
                                text: "\$${transactionModel.amount}",
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              )
                            ]
                        )),


                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeVeryTiny),
                            color: transactionModel.approved == 1
                                ? Colors.green.withAlpha(50) : transactionModel.approved == 2
                                ? Colors.red.withAlpha(50) : Theme.of(context).primaryColor.withAlpha(50),
                          ),
                          child: Text(getTranslated(transactionModel.approved == 2 ? 'denied' : transactionModel.approved == 1 ? 'approved' : 'pending', context)!,
                            style: robotoMedium.copyWith(
                                color: transactionModel.approved == 1 ? Colors.green : transactionModel.approved == 2 ?
                            Colors.red : Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeDefault),
                          ),
                        ),

                      ],
                    ),

                    Text.rich(TextSpan(
                        text: "${getTranslated("request_time", context) ??""} : ",
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.headlineLarge?.color,
                        ),
                        children: [
                          TextSpan(
                            text: transactionModel.createdAt != null? DateConverter.toLocalFormattedDateTime(transactionModel.createdAt??"") : "null",
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          )
                        ]
                    )),
                  ],
                ),

                // need payment method and other fields
                // const SizedBox(height: Dimensions.paddingSizeExtraLarge,),
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                //   decoration: BoxDecoration(
                //     color: Theme.of(context).highlightColor,
                //     borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                //   ),
                //   child: Row(
                //     children: [
                //       IntrinsicWidth(
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.stretch,
                //           children: [
                //             _FieldTile(field: getTranslated("withdrawn_method", context)??'',),
                //             _FieldTile(field: getTranslated("bank_name", context)??'',),
                //             _FieldTile(field: getTranslated("holder_name", context)??'',),
                //             _FieldTile(field: getTranslated("account_no", context)??'',),
                //           ],
                //         ),
                //       ),
                //
                //       Expanded(
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.stretch,
                //           children: [
                //             _ValueTile( value: "bank",),
                //             _ValueTile( value: 'City Bank',),
                //             _ValueTile( value: 'Willam Smith dfgsdf gdf',),
                //             _ValueTile( value: '456969849864',),
                //           ],
                //         ),
                //       ),
                //
                //
                //     ],
                //   ),
                // ),
                //

                if((transactionModel.approved == 1 || transactionModel.approved == 2) && (transactionModel.transactionNote ?? '').isNotEmpty)...[
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                  _noteWidget(context, transactionModel.approved == 1, transactionModel.transactionNote??"Empty!"),
                ],

                if(transactionModel.approved == 0)...[
                  const SizedBox( height: Dimensions.paddingSizeExtraLarge,),
                  Consumer<WalletController>(
                      builder: (context, withdraw,_) {
                        return Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  cancelTransaction(context, transactionModel);
                                },
                                child: Card(
                                  color: Theme.of(context).colorScheme.error.withAlpha(30),
                                  shadowColor: Colors.transparent,
                                  margin: EdgeInsets.zero,
                                  child: SizedBox(
                                    height: 40,
                                    child: Center(
                                      child: Text(getTranslated('delete_request', context)!,
                                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w600,color: Theme.of(context).colorScheme.error)),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: Dimensions.paddingSizeDefault,),

                            Expanded(
                              child: InkWell(
                                splashColor: Colors.transparent,
                                onTap: () {
                                  Navigator.pop(context);
                                    showModalBottomSheet(
                                      backgroundColor: Colors.transparent,
                                      isScrollControlled: true,
                                      context: context, builder: (_) => CustomEditDialogWidget(totalEarning: transactionModel.amount ?? 0.0, existingTransaction: transactionModel)
                                    );
                                },
                                child: Card(
                                  color: Theme.of(context).primaryColor,
                                  margin: EdgeInsets.zero,
                                  child: SizedBox(
                                    height: 40,
                                    child: Center(
                                      child: Text(getTranslated('edit_info_bt', context)!,
                                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w600,color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );

                      }
                  ),
                ]

              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _FieldTile extends StatelessWidget {
  final String field;
  const _FieldTile({super.key, required this.field,});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(TextSpan(
            text: "$field",
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.headlineLarge?.color,
            ),
          children: []
        )),

        Text.rich(TextSpan(
            text: "  :  ",
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.headlineLarge?.color,
            ),
        )),
      ],
    );
  }
}

class _ValueTile extends StatelessWidget {
  final String value;
  const _ValueTile({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(TextSpan(
            text: "$value ",
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.headlineLarge?.color,
            ),
        )),
      ],
    );
  }
}


Widget _noteWidget(BuildContext context,bool isApprove, String note){
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
    decoration: BoxDecoration(
      color:
      isApprove
          ? Theme.of(context).colorScheme.onTertiaryContainer.withAlpha(20)
          : Theme.of(context).colorScheme.error.withAlpha(20),
      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
    ),
    child:  Text.rich(TextSpan(
      text: isApprove ? (getTranslated("approve_note", context)??"") :  (getTranslated("denied_note", context)),
      style: robotoRegular.copyWith(
        fontSize: Dimensions.fontSizeDefault,
        color: isApprove ? Theme.of(context).colorScheme.onTertiaryContainer : Theme.of(context).colorScheme.error,
      ),
      children: [
        TextSpan(
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          text: " : $note",
        )
      ]
    )),
  );
}