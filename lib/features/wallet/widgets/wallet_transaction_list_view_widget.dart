import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/transaction/controllers/transaction_controller.dart';
import 'package:sixvalley_vendor_app/features/transaction/widgets/transaction_widget.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';

class WalletTransactionListViewWidget extends StatelessWidget {
  final TransactionController? transactionProvider;
  final int? limit;
  const WalletTransactionListViewWidget({super.key, this.transactionProvider, this.limit});

  @override
  Widget build(BuildContext context) {
    final items = transactionProvider!.transactionList!;
    final count = limit != null ? items.length.clamp(0, limit!) : items.length;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (context, index) => TransactionWidget(transactionModel: transactionProvider!.transactionList![index]),
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: Dimensions.paddingSizeExtraSmall),
    );
  }
}
