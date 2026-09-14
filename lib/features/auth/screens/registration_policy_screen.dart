import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';

class RegistrationPolicyScreen extends StatelessWidget {
  final String title;
  final String content;
  final String? version;

  const RegistrationPolicyScreen({
    super.key,
    required this.title,
    required this.content,
    this.version,
  });

  String get _safeContent => content
      .replaceAll(
        RegExp(
          r'<\s*(script|style|iframe|object|embed|form)\b[^>]*>[\s\S]*?<\s*/\s*\1\s*>',
          caseSensitive: false,
        ),
        '',
      )
      .replaceAll(
        RegExp(
          r'<\s*(script|iframe|object|embed|form)\b[^>]*/?\s*>',
          caseSensitive: false,
        ),
        '',
      );

  @override
  Widget build(BuildContext context) {
    final trimmedVersion = version?.trim() ?? '';
    final unavailable = getTranslated('policy_content_unavailable', context) ??
        'Policy content is currently unavailable';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          CustomAppBarWidget(title: title),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(Dimensions.paddingSizeMedium),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusExtraLarge),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (trimmedVersion.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeSmall,
                          vertical: Dimensions.paddingSizeExtraSmall,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: .08),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Text(
                          '${getTranslated('policy_version', context) ?? 'Version'} $trimmedVersion',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                    ],
                    if (_safeContent.trim().isEmpty)
                      Text(unavailable)
                    else
                      Html(
                        data: _safeContent,
                        style: {
                          'body': Style(
                            margin: Margins.zero,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            lineHeight: const LineHeight(1.6),
                          ),
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
