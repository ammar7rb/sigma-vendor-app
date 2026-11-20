import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';

/// Shared support-chat bubble: own messages on one side (filled), the other party
/// on the other side (outlined), with sender, time and automatic text direction.
class SigmaChatBubble extends StatelessWidget {
  final String body;
  final bool mine;
  final String sender;
  final DateTime? time;
  final bool pending;
  final bool failed;
  final Color primary;

  const SigmaChatBubble({
    super.key,
    required this.body,
    required this.mine,
    required this.sender,
    required this.primary,
    this.time,
    this.pending = false,
    this.failed = false,
  });

  static DateTime? parse(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString().replaceFirst(' ', 'T'))?.toLocal();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rtlText = intl.Bidi.detectRtlDirectionality(body);
    final radius = BorderRadiusDirectional.only(
      topStart: Radius.circular(mine ? 16 : 5),
      topEnd: Radius.circular(mine ? 5 : 16),
      bottomStart: const Radius.circular(16),
      bottomEnd: const Radius.circular(16),
    );
    final label = failed
        ? (getTranslated('support_chat_not_sent', context) ?? 'Not sent')
        : pending
            ? (getTranslated('sending', context) ?? 'Sending…')
            : (time == null ? '' : intl.DateFormat('HH:mm').format(time!));
    return Align(
      alignment: mine ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            crossAxisAlignment: mine ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(sender, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.hintColor)),
              ),
              Opacity(
                opacity: pending ? .65 : 1,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 9, 14, 8),
                  decoration: BoxDecoration(
                    color: mine ? primary : theme.cardColor,
                    borderRadius: radius,
                    border: failed
                        ? Border.all(color: Colors.red, width: 1.5)
                        : (mine ? null : Border.all(color: theme.dividerColor)),
                    boxShadow: const [BoxShadow(color: Color(0x0F172942), blurRadius: 2, offset: Offset(0, 1))],
                  ),
                  child: SelectableText(
                    body,
                    textDirection: rtlText ? TextDirection.rtl : TextDirection.ltr,
                    style: TextStyle(fontSize: 14, height: 1.6, color: mine ? Colors.white : null),
                  ),
                ),
              ),
              if (label.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(label, style: TextStyle(fontSize: 11, color: failed ? Colors.red : theme.hintColor)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small centered day label between messages ("اليوم", "أمس" or the date).
class SigmaChatDay extends StatelessWidget {
  final DateTime day;
  const SigmaChatDay({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(day.year, day.month, day.day);
    final text = d == today
        ? (getTranslated('today', context) ?? 'Today')
        : d == today.subtract(const Duration(days: 1))
            ? (getTranslated('yesterday', context) ?? 'Yesterday')
            : intl.DateFormat('d/M/yyyy').format(d);
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        decoration: BoxDecoration(color: Theme.of(context).dividerColor.withValues(alpha: .35), borderRadius: BorderRadius.circular(999)),
        child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
