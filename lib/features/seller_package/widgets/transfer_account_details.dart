import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sixvalley_vendor_app/features/seller_package/domain/models/seller_package_overview_model.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';

SellerOfflinePaymentMethod? transferMethodForChannel(
    List<SellerOfflinePaymentMethod> methods, String channel) {
  for (final method in methods) {
    final name = method.methodName.toLowerCase();
    if (channel == 'instapay'
        ? name.contains('insta') || name.contains('انستا')
        : name.contains('wallet') || name.contains('محفظ')) {
      return method;
    }
  }
  return null;
}

class TransferAccountDetails extends StatelessWidget {
  final List<SellerOfflineMethodField> fields;
  const TransferAccountDetails({super.key, required this.fields});

  @override
  Widget build(BuildContext context) => Column(
        children: fields
            .where((field) => field.inputData.trim().isNotEmpty)
            .map((field) {
          final key = field.inputName.toLowerCase();
          final label = key == 'wallet_number'
              ? (getTranslated('transfer_wallet_number', context) ??
                  'رقم المحفظة')
              : key == 'account_holder_name'
                  ? (getTranslated('transfer_account_holder', context) ??
                      'اسم صاحب الحساب')
                  : key.contains('instapay') || key.contains('account_number')
                      ? (getTranslated('transfer_instapay_account', context) ??
                          'حساب إنستا باي')
                      : field.inputName.replaceAll('_', ' ');
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 6),
                    Row(children: [
                      Expanded(
                          child: SelectableText(field.inputData,
                              textDirection: RegExp(r'^[+\d\s-]+$')
                                      .hasMatch(field.inputData)
                                  ? TextDirection.ltr
                                  : null,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold))),
                      IconButton(
                        tooltip: getTranslated('copy', context) ?? 'نسخ',
                        icon: const Icon(Icons.copy_outlined),
                        onPressed: () => Clipboard.setData(
                            ClipboardData(text: field.inputData)),
                      ),
                    ]),
                  ]),
            ),
          );
        }).toList(),
      );
}
