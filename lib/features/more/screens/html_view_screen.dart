import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/features/splash/domain/models/business_pages_model.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';

class HtmlViewScreen extends StatelessWidget {
  final BusinessPageModel? page;
  const HtmlViewScreen({super.key, required this.page});
  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocalizationController>().locale.languageCode;
    return Scaffold(
      body: Column(
        children: [
          CustomAppBarWidget(title: page?.localizedTitle(language) ?? ''),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: Column(
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: SizedBox(
                        height: 70,
                        width: double.infinity,
                        child: CustomImageWidget(
                          fit: BoxFit.cover,
                          image: page?.bannerFullUrl?.path ?? "",
                        ),
                      ),
                    ),
                    // const SizedBox(height: Dimensions.paddingSizeSmall),

                    Html(
                      style: {
                        "body": Style(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: FontSize.medium,
                        ),
                      },
                      data: page?.localizedDescription(language) ?? '',
                    ),

                  ],
                )
              ),
            ),
          ),
        ],
      ),
    );
  }
}
