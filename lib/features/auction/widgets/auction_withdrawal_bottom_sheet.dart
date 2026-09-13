import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/bottom_sheet_topbar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/textfeild/custom_text_feild_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_product_controller.dart';
import 'package:sixvalley_vendor_app/features/profile/domain/models/withdraw_model.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

import '../../../main.dart';

class AuctionWithdrawalBottomSheet extends StatefulWidget {
  final int auctionProductId;
  final double amount;
  final String? initialNote;
  final int? initialMethodId;
  final Map<String, dynamic>? initialMethodFields;
  final int? initialWithdrawId;

  const AuctionWithdrawalBottomSheet({
    super.key,
    required this.auctionProductId,
    required this.amount,
    this.initialNote,
    this.initialMethodId,
    this.initialMethodFields,
    this.initialWithdrawId,
  });

  @override
  State<AuctionWithdrawalBottomSheet> createState() => _AuctionWithdrawalBottomSheetState();
}

class _AuctionWithdrawalBottomSheetState extends State<AuctionWithdrawalBottomSheet> {
  final List<String> groupItems = ['my_methods', 'other'];
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final walletController = Provider.of<WalletController>(context, listen: false);
    final auctionController = Provider.of<AuctionProductController>(context, listen: false);

    if (widget.initialNote != null) {
      _noteController.text = widget.initialNote!;
    }

    Future.wait([
      walletController.getWithdrawMethods(context, includeGlobalMethods: true),
      walletController.getPaymentInfoList(),
    ]).then((_) {
      auctionController.selectWithdrawMethodById(walletController, widget.initialMethodId, initialFieldValues: widget.initialMethodFields);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Provider.of<ThemeController>(context).darkTheme ? Theme.of(context).cardColor : Theme.of(context).highlightColor,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Consumer<WalletController>(
              builder: (context, wallet, _) {
                List<DropdownMenuItem<MethodModel>> dropdownItems = [];

                for (var values in groupItems) {
                  if ((values == 'my_methods' && wallet.myMethodsIds.isNotEmpty) || values == 'other') {
                    dropdownItems.add(
                      DropdownMenuItem<MethodModel>(
                        enabled: false,
                        value: MethodModel(id: values == 'my_methods' ? -1 : -2, inputName: values),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            getTranslated(values, context) ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  }

                  if (values == 'my_methods') {
                    dropdownItems.addAll(wallet.myMethodsIds.map((item) {
                      return DropdownMenuItem<MethodModel>(
                        value: item,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(item?.inputName ?? ''),
                        ),
                      );
                    }));
                  }

                  if (values == 'other') {
                    dropdownItems.addAll(wallet.methodsIds.map((item) {
                      return DropdownMenuItem<MethodModel>(
                        value: item,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(item?.inputName ?? ''),
                        ),
                      );
                    }));
                  }
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const BottomSheetTopBarWidget(),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    
                    Text(
                      getTranslated('withdraw_request', context) ?? '',
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    
                    Text(
                      '${getTranslated('amount', context)}: ${PriceConverter.convertPrice(context, widget.amount)}',
                      style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border: Border.all(width: .5, color: Theme.of(context).hintColor.withValues(alpha: .7)),
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                      ),
                      child: DropdownButton<MethodModel>(
                        hint: Text(getTranslated('select_withdraw_method', context) ?? ''),
                        value: dropdownItems.any((item) => item.value == wallet.methodSelected) ? wallet.methodSelected : null,
                        items: dropdownItems,
                        onChanged: (MethodModel? value) {
                          wallet.setMethodTypeIndex(value);
                        },
                        isExpanded: true,
                        underline: const SizedBox(),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    if (wallet.methodSelected?.type == 'my_methods' && wallet.methodSelected?.methodInfo != null)
                      Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          color: Theme.of(context).hintColor.withValues(alpha: 0.07),
                          borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const CustomAssetImageWidget(Images.bankInfoIcon, width: 15, height: 15),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                Text(wallet.methodSelected?.inputName ?? '', style: robotoBold),
                              ],
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Table(
                              columnWidths: const {0: FixedColumnWidth(100)},
                              children: [
                                for (var entry in wallet.methodSelected!.methodInfo!.entries)
                                  TableRow(children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Text(_formatField(entry.key), style: robotoMedium.copyWith(color: Theme.of(context).hintColor)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Text(': ${entry.value}', style: robotoMedium),
                                    ),
                                  ]),
                              ],
                            ),
                          ],
                        ),
                      ),

                    if (wallet.methodSelected?.type == 'other' && wallet.methodSelected?.methodFields != null)
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: wallet.methodSelected?.methodFields?.length ?? 0,
                        itemBuilder: (context, index) {
                          final field = wallet.methodSelected!.methodFields![index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                            child: CustomTextFieldWidget(
                              textInputType: (field.inputType == 'number' || field.inputType == 'phone') ? TextInputType.number : TextInputType.text,
                              border: true,
                              controller: wallet.inputFieldControllerList[index],
                              hintText: field.placeholder,
                            ),
                          );
                        },
                      ),
                    
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    CustomTextFieldWidget(
                      controller: _noteController,
                      border: true,
                      hintText: getTranslated('transaction_note', context),
                      maxLine: 3,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                    Consumer<AuctionProductController>(
                      builder: (context, auction, _) {
                        return !auction.isWithdrawRequestLoading
                            ? InkWell(
                                onTap: () => _submitRequest(context, wallet, auction),
                                child: Container(
                                  width: double.infinity,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  ),
                                  child: Center(
                                    child: Text(
                                      getTranslated('withdraw', context) ?? '',
                                      style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge),
                                    ),
                                  ),
                                ),
                              )
                            : const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _submitRequest(BuildContext context, WalletController wallet, AuctionProductController auction) async {
    if (wallet.methodSelected == null) {
      showCustomSnackBarWidget(getTranslated('select_withdraw_method', context), context, isToaster: true, sanckBarType: SnackBarType.warning);
      return;
    }

    Map<String, dynamic> data = {
      'auction_product_id': widget.auctionProductId,
      'withdraw_method_id': wallet.methodSelected!.id,
      'transaction_note': _noteController.text.trim(),
      if (widget.initialWithdrawId != null) 'existing_withdraw_id': widget.initialWithdrawId,
    };

    if (wallet.methodSelected?.type == 'other') {
      for (int i = 0; i < wallet.inputFieldControllerList.length; i++) {
        if (wallet.inputFieldControllerList[i].text.isEmpty) {
          showCustomSnackBarWidget(getTranslated('please_fill_all_the_field', context), context, isToaster: true, sanckBarType: SnackBarType.warning);
          return;
        }
        data[wallet.keyList[i]!] = wallet.inputFieldControllerList[i].text.trim();
      }
    } else if (wallet.methodSelected?.type == 'my_methods') {
      data.addAll(wallet.methodSelected!.methodInfo!);
    }

    bool success = await auction.submitWithdrawRequest(data);
    if (success) {
      showCustomSnackBarWidget(getTranslated('withdraw_request_submitted_successfully', Get.context!), Get.context!, isToaster: true, isError: false);
      Navigator.pop(Get.context!);
    }
  }

  String _formatField(String input) {
    return input.split('_').where((word) => word.isNotEmpty).map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}
