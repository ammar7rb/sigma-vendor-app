import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/features/order/controllers/order_controller.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/features/order_details/controllers/order_details_controller.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';
import 'package:sixvalley_vendor_app/features/order_details/screens/seller_shipping_support_screen.dart';

class SellerShippingAssignmentWidget extends StatefulWidget {
  final Order order;
  const SellerShippingAssignmentWidget({super.key, required this.order});
  @override
  State<SellerShippingAssignmentWidget> createState() =>
      _SellerShippingAssignmentWidgetState();
}

class _SellerShippingAssignmentWidgetState
    extends State<SellerShippingAssignmentWidget> {
  PlatformFile? proof;
  final note = TextEditingController();
  bool opening = false;
  String tr(String key) => getTranslated(key, context) ?? key;
  String date(dynamic value) {
    final parsed = DateTime.tryParse('$value');
    return parsed == null
        ? tr('finance_not_set')
        : DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
            .format(parsed.toLocal());
  }

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.order.shippingAssignment;
    if (data == null || data['status'] != 'assigned') {
      return const SizedBox.shrink();
    }
    final controller = context.watch<OrderDetailsController>();
    final response = data['seller_shipping_response'] as Map? ?? {};
    final needsResponse = response['required'] == true;
    final company = data['responsible_party'] == 'company';
    final completed = widget.order.orderStatus == 'delivered';
    final terminal = [
      'delivered',
      'canceled',
      'cancelled',
      'returned',
      'failed'
    ].contains(widget.order.orderStatus);
    return Card(
        elevation: 0,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
            side: BorderSide(color: Theme.of(context).dividerColor)),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(14)),
                    child: Icon(
                        completed
                            ? Icons.task_alt
                            : Icons.local_shipping_outlined,
                        color: Theme.of(context).colorScheme.primary)),
                const SizedBox(width: 11),
                Expanded(
                    child: Text(tr('shipping_assignment'),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800)))
              ]),
              const SizedBox(height: 12),
              line('shipping_party',
                  tr(company ? 'company_shipping' : 'seller_shipping')),
              line(
                  'finance_shipping_due',
                  PriceConverter.convertPrice(
                      context,
                      double.tryParse(
                              '${data['seller_entitlement'] ?? data['seller_cost']}') ??
                          0)),
              line('expected_delivery_date',
                  date(data['expected_delivery_date'])),
              line('sales_due_date', date(data['sales_due_at'])),
              line('shipping_due_date', date(data['shipping_due_at'])),
              if (data['tracking_number'] != null)
                line('tracking_id', '${data['tracking_number']}'),
              if ('${data['instructions'] ?? ''}'.isNotEmpty)
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('${data['instructions']}')),
              if (needsResponse && !terminal) ...[
                const Divider(),
                Text(tr('seller_journey_accept_terms')),
                line('seller_journey_response_due', date(response['due_at'])),
                Wrap(spacing: 8, children: [
                  FilledButton.icon(
                      onPressed: controller.actionInProgress
                          ? null
                          : () => respond(controller, 'accept'),
                      icon: const Icon(Icons.check),
                      label: Text(tr('seller_journey_accept'))),
                  OutlinedButton(
                      onPressed: controller.actionInProgress
                          ? null
                          : () => reject(controller),
                      child: Text(tr('seller_journey_reject'))),
                ]),
              ],
              if (completed)
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(tr('seller_journey_completed'),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold))),
              if (!company && !terminal && !needsResponse) ...[
                const Divider(),
                Text(tr('seller_journey_delivery_proof'),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(tr('seller_journey_proof_notice')),
                const SizedBox(height: 12),
                TextField(
                    controller: note,
                    maxLines: 2,
                    maxLength: 1000,
                    enabled: !controller.actionInProgress,
                    decoration: InputDecoration(
                        labelText: tr('note'),
                        border: const OutlineInputBorder())),
                OutlinedButton.icon(
                    onPressed: controller.actionInProgress ? null : pick,
                    icon: const Icon(Icons.attach_file),
                    label: Text(
                        proof?.name ?? tr('seller_journey_select_document'))),
                const SizedBox(height: 8),
                SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                        onPressed:
                            proof?.path == null || controller.actionInProgress
                                ? null
                                : () => submit(controller),
                        icon: controller.actionInProgress
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.task_alt),
                        label: Text(tr('seller_journey_complete_order')))),
              ],
              if (company)
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                        tr('company_manages_shipping_status_after_packaging'))),
              const Divider(),
              Text(tr('seller_journey_proof_history'),
                  style: Theme.of(context).textTheme.titleSmall),
              if (controller.proofError != null)
                TextButton.icon(
                    onPressed: () =>
                        controller.getOrderDetails('${widget.order.id}'),
                    icon: const Icon(Icons.refresh),
                    label: Text(tr(controller.proofError!))),
              if (controller.shippingProofs.isEmpty &&
                  controller.proofError == null)
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(tr('finance_empty'))),
              for (final item in controller.shippingProofs)
                ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.description_outlined),
                    title: Text(
                        '${item['original_name'] ?? tr('seller_journey_delivery_proof')}'),
                    subtitle: Text(
                        '${tr('${item['shipping_status']}')} • ${date(item['created_at'])}\n${item['note'] ?? ''}${item['review_note'] == null ? '' : '\n${item['review_note']}'}'),
                    trailing: IconButton(
                        tooltip: tr('seller_journey_open_proof'),
                        onPressed:
                            opening ? null : () => open(controller, item),
                        icon: const Icon(Icons.open_in_new))),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppDesign.warning,
                    side: const BorderSide(color: AppDesign.warning),
                    backgroundColor: AppDesign.warning.withValues(alpha: .07),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDesign.radiusMedium),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SellerShippingSupportScreen(
                        orderId: widget.order.id!,
                        shippingEntitlement: double.tryParse(
                                '${data['seller_entitlement'] ?? data['seller_cost']}') ??
                            0,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.report_problem_outlined),
                  label: Text(tr('shipping_due_support_action')),
                ),
              ),
            ])));
  }

  Widget line(String key, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Text(tr(key))),
        const SizedBox(width: 8),
        Flexible(child: Text(value, textAlign: TextAlign.end))
      ]));
  Future<void> pick() async {
    try {
      final selection = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: [
            'jpg',
            'jpeg',
            'png',
            'webp',
            'pdf',
            'mp4',
            'mov',
            'avi',
            'mkv',
            'webm'
          ]);
      final file = selection?.files.firstOrNull;
      if (file == null || !mounted) return;
      if (file.size > 100 * 1024 * 1024 || file.path == null) {
        showCustomSnackBarWidget(tr('seller_journey_proof_limit'), context);
        return;
      }
      setState(() => proof = file);
    } catch (_) {
      if (mounted) {
        showCustomSnackBarWidget(tr('finance_proof_failed'), context);
      }
    }
  }

  Future<void> refreshLists() async {
    if (!mounted) return;
    final orders = context.read<OrderController>();
    final wallet = context.read<WalletController>();
    await orders.getOrderList(context, 1, orders.orderType, orders.filterModel);
    await wallet.getSellerDashboardOverview();
    await wallet.getSellerBalance();
  }

  Future<void> submit(OrderDetailsController controller) async {
    try {
      final ok = await controller.submitShippingProof(
          '${widget.order.id}', 'delivered', proof!.path!, note.text.trim());
      if (ok && mounted) {
        setState(() {
          proof = null;
          note.clear();
        });
        showCustomSnackBarWidget(tr('seller_journey_completed'), context,
            isError: false);
        await refreshLists();
      }
    } catch (_) {
      if (mounted) {
        showCustomSnackBarWidget(tr('seller_journey_action_failed'), context);
      }
    }
  }

  Future<void> respond(OrderDetailsController controller, String decision,
      [String reason = '']) async {
    try {
      final ok = await controller.respondToShipping(
          '${widget.order.id}', decision, reason);
      if (ok && mounted) {
        await refreshLists();
        if (decision == 'reject' && mounted) Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        showCustomSnackBarWidget(tr('seller_journey_action_failed'), context);
      }
    }
  }

  Future<void> reject(OrderDetailsController controller) async {
    final reason = TextEditingController();
    final form = GlobalKey<FormState>();
    final result = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
                title: Text(tr('seller_journey_reject')),
                content: Form(
                    key: form,
                    child: TextFormField(
                        controller: reason,
                        maxLines: 3,
                        maxLength: 5000,
                        decoration: InputDecoration(
                            labelText: tr('seller_journey_rejection_reason')),
                        validator: (v) => (v ?? '').trim().isEmpty
                            ? tr('seller_journey_rejection_reason')
                            : null)),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(tr('cancel'))),
                  FilledButton(
                      onPressed: () {
                        if (form.currentState!.validate()) {
                          Navigator.pop(context, reason.text.trim());
                        }
                      },
                      child: Text(tr('submit')))
                ]));
    reason.dispose();
    if (result != null && mounted) await respond(controller, 'reject', result);
  }

  Future<void> open(
      OrderDetailsController controller, Map<String, dynamic> item) async {
    setState(() => opening = true);
    try {
      await controller.openShippingProof('${widget.order.id}',
          int.parse('${item['id']}'), '${item['original_name']}');
    } catch (_) {
      if (mounted) {
        showCustomSnackBarWidget(
            tr('seller_journey_proof_load_failed'), context);
      }
    } finally {
      if (mounted) setState(() => opening = false);
    }
  }
}
