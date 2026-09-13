import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class ActionButtonWidget extends StatelessWidget {
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onRelaunch;
  final bool isDeleting;
  final String? editLabel;
  final String? deleteLabel;
  final bool showDelete;

  const ActionButtonWidget({
    super.key,
    this.onDelete,
    this.onEdit,
    this.onRelaunch,
    this.isDeleting = false,
    this.editLabel,
    this.deleteLabel,
    this.showDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSize, horizontal: 0),
      child: Row(
        children: [
          if (showDelete)
            Expanded(
              child: ActionButton(
                label: deleteLabel ?? getTranslated('delete', context) ?? "",
                color: Theme.of(context).colorScheme.error,
                onTap: isDeleting ? null : onDelete,
                isLoading: isDeleting,
              ),
            ),

          if (onRelaunch != null || onEdit != null) ...[
            if (showDelete) const SizedBox(width: Dimensions.paddingSize),
            if (onRelaunch != null)
              Expanded(
                child: ActionButton(
                  label: getTranslated('relaunch', context) ?? "Relaunch",
                  color: Theme.of(context).colorScheme.tertiary,
                  onTap: isDeleting ? null : onRelaunch,
                ),
              )
            else
              Expanded(
                child: ActionButton(
                  label: editLabel ?? getTranslated('recreate', context) ?? "",
                  color: Theme.of(context).primaryColor,
                  onTap: isDeleting ? null : onEdit,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isLoading;

  const ActionButton({
    super.key,
    required this.label,
    required this.color,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.paddingSize),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingEye),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(label,
                  style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, fontWeight: FontWeight.w600, color: Colors.white),
                ),
        ),
      ),
    );
  }
}
