import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/ai/controllers/ai_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_ai_controller.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import '../../../main.dart' show Get;

class GeneratesLeftCount extends StatelessWidget {
  final bool isAuction;
  const GeneratesLeftCount({super.key, this.isAuction = false});

  @override
  Widget build(BuildContext context) {
    return Provider.of<SplashController>(Get.context!,listen: false).configModel?.isAiFeatureActive == 1 ?  Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
            color: Theme.of(context).primaryColor.withValues(alpha: 0.15)
          ),
          padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),

          child: isAuction
            ? Consumer<AuctionAiController>(
                builder: (context, aiController, child) => _buildRow(context, aiController.genLimit),
              )
            : Consumer<AiController>(
                builder: (context, aiController, child) => _buildRow(context, aiController.genLimit),
              ),
        )
      ],
    ) : SizedBox();
  }

  Widget _buildRow(BuildContext context, int genLimit) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Text('$genLimit',
            style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeOrder),
          child: Text(getTranslated('generates_left', context) ?? '',
            style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ),

        Icon(Icons.auto_awesome, color: Colors.blue, size: 16),

      ],
    );
  }
}
