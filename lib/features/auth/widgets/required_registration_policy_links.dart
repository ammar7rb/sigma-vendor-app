import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/auth/screens/registration_policy_screen.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';

class RequiredRegistrationPolicyLinks extends StatelessWidget {
  final List<Map<String, dynamic>> policies;

  const RequiredRegistrationPolicyLinks({
    super.key,
    required this.policies,
  });

  @override
  Widget build(BuildContext context) {
    if (policies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getTranslated('review_required_policies', context) ??
              'Review the required policies before accepting',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        ...policies.map((policy) {
          final title = '${policy['title'] ?? ''}'.trim();
          final version = '${policy['version'] ?? ''}'.trim();
          final content = '${policy['content'] ?? ''}';

          return Padding(
            padding:
                const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
            child: Semantics(
              button: true,
              link: true,
              label: title,
              child: InkWell(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => RegistrationPolicyScreen(
                    title: title,
                    content: content,
                    version: version,
                  ),
                )),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: Dimensions.paddingSeven,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: Dimensions.iconSizeDefault,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Text(
                          version.isEmpty ? title : '$title (v$version)',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.open_in_new_rounded,
                        size: Dimensions.iconSizeDefault,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
