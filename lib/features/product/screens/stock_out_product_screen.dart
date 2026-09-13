import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/features/product/widgets/stock_out_product_widget.dart';
import 'package:sixvalley_vendor_app/features/product/screens/stock_violation_screen.dart';

class StockOutProductScreen extends StatelessWidget {
  const StockOutProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: CustomAppBarWidget(
        title: getTranslated('stock_out_product',context),
        isAction: true,
        isTooltip: true,
        widget: IconButton(
          tooltip: getTranslated('stock_violation_history', context),
          icon: const Icon(Icons.history_outlined),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StockViolationScreen())),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async{
          Provider.of<ProductController>(context,listen: false).getStockOutProductList(1, 'en');
        },
        child: Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
          child: StockOutProductView(isHome: false),
        ),
      ),
    );
  }
}
