import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_button_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/no_data_screen.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_product_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_action_sheet_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/payment_widgets/custom_check_box_widget.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/config_model.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';

class PaymentMethodBottomSheetWidget extends StatefulWidget {
  final bool onlyDigital;
  const PaymentMethodBottomSheetWidget({super.key, required this.onlyDigital,});
  @override
  PaymentMethodBottomSheetWidgetState createState() => PaymentMethodBottomSheetWidgetState();
}
class PaymentMethodBottomSheetWidgetState extends State<PaymentMethodBottomSheetWidget> {
  final TextEditingController changeAmountTextController = TextEditingController();

  @override
  void initState() {
    final ConfigModel? configModel = Provider.of<SplashController>(context, listen: false).configModel;
    final AuctionProductController auctionProductController = Provider.of<AuctionProductController>(context, listen: false);
    changeAmountTextController.text = '${auctionProductController.cashChangesAmount ?? ''}';
    if((configModel?.cashOnDelivery ?? false) && !widget.onlyDigital && !auctionProductController.isCODChecked) {
      auctionProductController.setOfflineChecked('cod', notify: false);
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    final ConfigModel? configModel = Provider.of<SplashController>(context, listen: false).configModel;

    return Consumer<AuctionProductController>(
      builder: (context, auctionProductController, _) {
        return PopScope(
          onPopInvokedWithResult: (_, __){
            if(auctionProductController.isCODChecked) {
              auctionProductController.onChangeCashChangesAmount(double.tryParse(changeAmountTextController.text));
            }else {
              auctionProductController.onChangeCashChangesAmount(null);

            }
          },
          child: Container(constraints : BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7,
              minHeight: MediaQuery.of(context).size.height * 0.5 ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(color: Theme.of(context).highlightColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
            child: Column(mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                        child: Center(child: Container(width: 35,height: 4,decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                          color: Theme.of(context).hintColor.withValues(alpha:.5))))),

                      Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          Text(
                            getTranslated('choose_payment_method', context)??'',
                            style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                          ),

                          Expanded(child: Padding(padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
                            child: Text(
                              '${getTranslated('click_one_of_the_option_below', context)}',
                              style: titilliumRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
                            ),
                          )),
                        ]),
                      ),


                        _isPaymentMethodsAvailable(context) ?
                        Column(crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min, children: [

                            Row(children: [
                              if((configModel?.cashOnDelivery ?? false) && !widget.onlyDigital) Expanded(child: CustomButtonWidget(
                              //  leftIcon: Images.cod,
                                backgroundColor: auctionProductController.isCODChecked? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                fontColor:  auctionProductController.isCODChecked? Colors.white : Theme.of(context).primaryColor,
                                borderColor: auctionProductController.isCODChecked? Theme.of(context).primaryColor : Theme.of(context).primaryColor,
                                isColor: true,
                                textSize : Dimensions.fontSizeSmall,
                                onTap: () => auctionProductController.setOfflineChecked('cod'),
                                btnTxt : '${getTranslated('cash_on_delivery', context)}',
                              )),
                              const SizedBox(width: Dimensions.paddingSizeDefault),

                              if(configModel?.walletStatus == true && Provider.of<AuthController>(context, listen: false).isLoggedIn())
                                Expanded(child: CustomButtonWidget(
                                  onTap: () => auctionProductController.setOfflineChecked('wallet'),
                                  // bordar : true,
                                  // leftIcon: Images.payWallet,
                                  backgroundColor: auctionProductController.isWalletChecked ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                  fontColor:  auctionProductController.isWalletChecked? Colors.white : Theme.of(context).primaryColor,
                                  borderColor: auctionProductController.isWalletChecked ? Theme.of(context).primaryColor : Theme.of(context).primaryColor,
                                  isColor: true,
                                  textSize: Dimensions.fontSizeSmall,
                                  btnTxt: '${getTranslated('pay_via_wallet', context)}',
                                )),
                            ]),




                            if((configModel?.digitalPayment ?? false) && (configModel?.paymentMethods?.isNotEmpty ?? false) && !auctionProductController.isCODChecked)
                              const SizedBox(height: Dimensions.paddingSizeSmall),


                            if((configModel?.digitalPayment ?? false) && (configModel?.paymentMethods?.isNotEmpty ?? false))
                            Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                border: Border.all(width: 1, color: Theme.of(context).hintColor.withValues(alpha: .125),
                                ),
                                borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                              ),

                              child: Column(
                                children: [
                                  if((configModel?.digitalPayment ?? false) && (configModel?.paymentMethods?.isNotEmpty ?? false))
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeDefault),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${getTranslated('pay_via_online', context)}', style: titilliumBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                                        ],
                                      ),
                                    ),

                                  if((configModel?.digitalPayment ?? false) && (configModel?.paymentMethods?.isNotEmpty ?? false))
                                    Consumer<SplashController>(builder: (context, configProvider,_) {
                                      return ListView.separated(
                                        padding: EdgeInsets.zero,
                                        itemCount: configProvider.configModel?.paymentMethods?.length??0,
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index){
                                          return  CustomCheckBoxWidget(index: index,
                                            padding: 0,
                                            icon: configProvider.configModel?.paymentMethods?[index].additionalDatas?.gatewayImage??'',
                                            name: configProvider.configModel!.paymentMethods![index].keyName!,
                                            title: configProvider.configModel!.paymentMethods![index].additionalDatas?.gatewayTitle??'',
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          return const SizedBox(height: Dimensions.paddingSizeSmall);
                                        },
                                      );
                                    }),
                                ],
                              ),
                            ),

                            if((configModel?.digitalPayment ?? false) && (configModel?.paymentMethods?.isNotEmpty ?? false))
                            const SizedBox(height: Dimensions.paddingSizeSmall),



                            if(configModel?.offlinePayment != null)
                              Container(
                                  decoration: BoxDecoration(
                                    color: auctionProductController.isOfflineChecked?Theme.of(context).primaryColor.withValues(alpha:.15): null,
                                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                  ),
                                  child: Column(children: [

                                    InkWell(
                                      onTap: () {
                                        auctionProductController.setOfflineChecked('offline');
                                      },
                                      child: Padding(padding: const EdgeInsets.all(8.0), child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)),
                                        child: Row(children: [
                                          Theme(
                                            data: Theme.of(context).copyWith(unselectedWidgetColor: Theme.of(context).primaryColor.withValues(alpha:.25)),
                                            child: Checkbox(
                                              visualDensity: VisualDensity.compact,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraLarge)),
                                              checkColor: Colors.white,
                                              value: auctionProductController.isOfflineChecked, activeColor: Colors.green,
                                              onChanged: (bool? isChecked){
                                                auctionProductController.setOfflineChecked('offline');
                                              },
                                            ),
                                          ),

                                          Text('${getTranslated('pay_offline', context)}', style: titilliumBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                                        ]),
                                      )),
                                    ),
                                  ])),


                          ],
                        ) : const NoDataScreen( title: 'no_payment_method_available_right_now'),

                    ]),
                  ),
                ),

                CustomButton(
                  label: '${getTranslated('save', context)}',
                  isLoading: auctionProductController.isPayCommissionLoading,
                  onPressed: () {
                    Navigator.of(context).pop();
                    if((configModel?.cashOnDelivery ?? false) && !widget.onlyDigital) {
                      auctionProductController.updatePaymentSelection();
                    }
                  },
                ),

              ],
            ),
          ),
        );
      }
    );
  }
}



bool _isPaymentMethodsAvailable(BuildContext context){
  final ConfigModel? configModel = Provider.of<SplashController>(context, listen: false).configModel;

  bool isCashOnDeliveryOn = configModel?.cashOnDelivery ?? false;
  bool isWalletOn = configModel?.walletStatus == true && Provider.of<AuthController>(context, listen: false).isLoggedIn();
  bool isOnlinePaymentMethodsOn = configModel?.paymentMethods?.isNotEmpty ?? false;
  bool isOfflinePaymentMethodsOn = configModel?.offlinePayment != null;

  return isCashOnDeliveryOn || isWalletOn || isOnlinePaymentMethodsOn || isOfflinePaymentMethodsOn;
}

