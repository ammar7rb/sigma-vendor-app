import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class UploadTrackingUrlWidget extends StatefulWidget {
  final String? initialUrl;
  final String? tooltipMessage;
  final Future<bool> Function(String url)? onSave;

  const UploadTrackingUrlWidget({super.key, this.initialUrl, this.tooltipMessage, this.onSave});

  @override
  State<UploadTrackingUrlWidget> createState() => _UploadTrackingUrlWidgetState();
}

class _UploadTrackingUrlWidgetState extends State<UploadTrackingUrlWidget> {
  late final TextEditingController _controller;
  String? _error;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }

  Future<void> _onSave() async {
    final url = _controller.text.trim();

    if (!_isValidUrl(url)) {
      setState(() => _error = getTranslated('enter_valid_url', context) ?? 'Enter a valid URL starting with http:// or https://');
      return;
    }

    setState(() {
      _error = null;
      _isSaving = true;
    });

    final success = await widget.onSave?.call(url) ?? false;

    if (mounted) {
      setState(() => _isSaving = false);
      if (!success) {
        setState(() => _error = getTranslated('failed_to_save_tracking_url', context) ?? 'Failed to save. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                getTranslated('upload_tracking_url', context) ?? "",
                style: titilliumSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: theme.textTheme.bodyLarge!.color,
                ),
              ),
              Tooltip(
                message: widget.tooltipMessage ?? getTranslated('paste_shipment_tracking_url', context) ?? "",
                triggerMode: TooltipTriggerMode.tap,
                child: Icon(Icons.info_outline_rounded, size: Dimensions.iconSizeDefault, color: Colors.grey.shade500),
              ),
            ],
          ),

          SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
          SizedBox(height: Dimensions.paddingSizeSmall),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.url,
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  style: titilliumRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: theme.textTheme.bodyLarge!.color,
                  ),
                  decoration: InputDecoration(
                    hintText: 'https://',
                    hintStyle: titilliumRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Colors.grey.shade400,
                    ),
                    errorText: _error,
                    errorStyle: titilliumRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Colors.red,
                    ),
                    errorMaxLines: 2,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeSmall,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      borderSide: BorderSide(color: _error != null ? Colors.red : theme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      borderSide: BorderSide(color: _error != null ? Colors.red : theme.colorScheme.primary, width: 1.5),
                    ),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                ),
              ),
              SizedBox(width: Dimensions.paddingSizeSmall),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.cardColor,
                    disabledBackgroundColor: theme.colorScheme.primary.withValues(alpha: 0.6),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                  ),
                  child: _isSaving
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: theme.cardColor),
                      )
                    : Text(
                        widget.initialUrl != null ? getTranslated('update', context) ?? "" : getTranslated('save', context) ?? "",
                        style: titilliumSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: theme.cardColor,
                        ),
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
