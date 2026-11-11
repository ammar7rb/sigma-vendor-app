import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/features/seller_package/screens/seller_package_screen.dart';
import 'package:sixvalley_vendor_app/features/order_details/widgets/vendor_eligibility_view.dart';

class _ProofInputException implements Exception {
  final String message;
  const _ProofInputException(this.message);
}

class VendorFulfillmentView extends StatefulWidget {
  final Map<String, dynamic> order;
  final Future<void> Function() onRefresh;
  const VendorFulfillmentView({
    super.key,
    required this.order,
    required this.onRefresh,
  });
  @override
  State<VendorFulfillmentView> createState() => _VendorFulfillmentViewState();
}

class _VendorFulfillmentViewState extends State<VendorFulfillmentView> {
  bool busy = false;
  static const labels = {
    'accept': 'قبول صريح للجزء',
    'reject': 'رفض قبل القبول — دون غرامة',
    'preparing': 'بدء التجهيز',
    'ready': 'جاهز للشحن',
    'shipping': 'بدء الشحن',
    'cancel': 'إلغاء بعد القبول',
  };
  String money(dynamic amount) =>
      '${(double.tryParse('$amount') ?? 0).toStringAsFixed(2)} ج.م';

  void message(Object error) {
    if (!mounted) return;
    final data = error is DioException ? error.response?.data : null;
    final text = error is _ProofInputException
        ? error.message
        : data is Map
            ? '${data['message'] ?? 'تعذر تنفيذ الإجراء؛ حدّث التفاصيل وحاول مجددًا.'}'
            : 'تعذر تنفيذ الإجراء؛ حدّث التفاصيل وحاول مجددًا.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text, textDirection: TextDirection.rtl)),
    );
  }

  Future<void> run(Future<void> Function() task) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await task();
    } catch (error) {
      message(error);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> unlock(Map portion) => run(() async {
        final response = await VendorWorkspace.instance.client.get(
          '/api/v3/seller/fulfillment-requests/${portion['id']}/unlock-quote',
        );
        final quote = Map<String, dynamic>.from(response.data['quote']);
        if (quote['already_unlocked'] == true) {
          await widget.onRefresh();
          return;
        }
        if (!mounted) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text('فتح الإعلان وعرض التفاصيل'),
              content: SingleChildScrollView(
                child: Text(
                  '${quote['message']}\n\nالإعلانات الإضافية: ${quote['extra_count']}\n'
                  'سعر الإعلان: ${money(quote['unit_price'])}\nإجمالي الرسوم: ${money(quote['total'])}\n'
                  'خصم من رصيد المدفوعات: ${money(quote['wallet_debit'])}\nيسجل دينًا: ${money(quote['debt'])}\n'
                  'النهاية مع الاشتراك: ${quote['expires_at']}\n\nيسدد الدين من الإيداع المؤكد التالي. '
                  'فتح الإعلان يتيح التفاصيل للمراجعة ولا يعد قبولًا. يمكنك الرفض قبل القبول دون غرامة.',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('رجوع دون تنفيذ'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('تأكيد التخصيص وعرض التفاصيل'),
                ),
              ],
            ),
          ),
        );
        if (confirmed != true) return;
        await VendorWorkspace.instance.client.post(
          '/api/v3/seller/fulfillment-requests/${portion['id']}/unlock',
          data: {'token': quote['token']},
        );
        await widget.onRefresh();
      });

  Future<void> decide(Map portion, String action) => run(() async {
        var reason = '';
        final penalty = portion['cancellation_preview'] as Map? ?? {};
        final needsReason = action == 'reject' || action == 'cancel';
        bool confirmed = false;
        confirmed = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => Directionality(
                textDirection: TextDirection.rtl,
                child: StatefulBuilder(
                  builder: (context, refreshDialog) => AlertDialog(
                    title: Text(labels[action] ?? action),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (action == 'accept')
                            const Text(
                              'راجعت تفاصيل هذا الجزء ومستحقاته، وأوافق على تنفيذه. يسجل القبول وتوقيته، ويخضع الإلغاء اللاحق لقاعدة الغرامة.',
                            ),
                          if (action == 'reject')
                            const Text(
                              'رفض هذا الجزء قبل القبول دون غرامة إلغاء، حتى بعد شراء الباقة أو فتح الإعلان.',
                            ),
                          if (action == 'cancel')
                            Text(
                              'الغرامة الحالية: ${money(penalty['assessed_amount'])}.\n'
                              '${penalty['mode'] == 'percentage' ? 'النسبة ${penalty['percentage']}٪ من مستحق بضائع هذا الجزء دون الشحن والضرائب وهامش الشركة.' : 'مبلغ ثابت بالجنيه لهذا الجزء.'} '
                              'تخصم من رصيد المدفوعات ويسجل العجز دينًا يسدد من الإيداع المؤكد التالي.',
                            ),
                          if (!needsReason && action != 'accept')
                            const Text(
                              'تأكيد تقدم هذا الجزء فقط؛ الأجزاء الأخرى تحتفظ بحالتها.',
                            ),
                          if (needsReason)
                            TextField(
                              maxLength: 1000,
                              onChanged: (value) =>
                                  refreshDialog(() => reason = value),
                              decoration: const InputDecoration(
                                labelText: 'سبب القرار',
                                border: OutlineInputBorder(),
                              ),
                            ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('رجوع'),
                      ),
                      FilledButton(
                        onPressed: needsReason && reason.trim().isEmpty
                            ? null
                            : () => Navigator.pop(dialogContext, true),
                        child: const Text('تأكيد القرار'),
                      ),
                    ],
                  ),
                ),
              ),
            ) ??
            false;
        if (!confirmed) return;
        await VendorWorkspace.instance.client.post(
          '/api/v3/seller/fulfillment-requests/${portion['id']}/decision',
          data: {
            'action': action,
            if (needsReason) 'reason': reason.trim(),
            if (action == 'cancel') 'penalty_revision': penalty['revision'],
          },
        );
        await widget.onRefresh();
      });

  Future<void> proof(Map portion) => run(() async {
        final result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf', 'mp4'],
          allowMultiple: false,
          withReadStream: true,
        );
        if (result == null || result.files.isEmpty) return;
        final file = result.files.single;
        if (file.size > 10 * 1024 * 1024) {
          throw const _ProofInputException(
              'حجم إثبات التسليم يجب ألا يتجاوز 10 ميجابايت.');
        }
        final upload = file.readStream != null
            ? MultipartFile.fromStream(() => file.readStream!, file.size,
                filename: file.name)
            : file.bytes != null
                ? MultipartFile.fromBytes(file.bytes!, filename: file.name)
                : file.path != null
                    ? await MultipartFile.fromFile(file.path!,
                        filename: file.name)
                    : throw const _ProofInputException(
                        'تعذر قراءة الملف؛ اختره مرة أخرى.');
        await VendorWorkspace.instance.client.post(
          '/api/v3/seller/fulfillment-requests/${portion['id']}/delivery-proof',
          data: FormData.fromMap({
            'proof': upload,
          }),
        );
        await widget.onRefresh();
      });

  @override
  Widget build(BuildContext context) {
    final summary = Map<String, dynamic>.from(
      widget.order['fulfillment_eligibility'],
    );
    final portions = summary['portions'] as List? ?? [];
    final lines = widget.order['order_details'] as List? ?? [];
    final address = widget.order['shipping_address_data'] as Map? ?? {};
    return Directionality(
      textDirection: TextDirection.rtl,
      child: RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'طلب #${widget.order['id']}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (busy) const LinearProgressIndicator(),
            if (summary['has_restrictions'] == true)
              VendorEligibilityLockCard(
                summary: summary,
                onRefresh: widget.onRefresh,
              ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'راجع كل جزء قبل القبول. شراء الباقة وإتاحة التفاصيل لا يعدان قبولًا للطلب.',
              ),
            ),
            if (summary['details_locked'] != true)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('بيانات التسليم'),
                      Text('${address['contact_person_name'] ?? ''}'),
                      Text('${address['phone'] ?? ''}'),
                      Text('${address['address'] ?? ''}'),
                    ],
                  ),
                ),
              ),
            for (final portion in portions)
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'جزء التنفيذ #${portion['id']} — ${portion['status_label'] ?? portion['status']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'قيمة الجزء عند التحويل: ${money(portion['amount'])}',
                      ),
                      if (portion['can_request_unlock'] == true) ...[
                        FilledButton.icon(
                          onPressed: busy ? null : () => unlock(portion),
                          icon: const Icon(Icons.lock_open),
                          label: const Text('فتح الإعلان وعرض التفاصيل'),
                        ),
                        OutlinedButton(
                          onPressed: busy
                              ? null
                              : () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SellerPackageScreen(),
                                    ),
                                  );
                                  await widget.onRefresh();
                                },
                          child: const Text('اختيار باقة'),
                        ),
                      ] else ...[
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final step in const {
                              'available': 'مراجعة',
                              'accepted': 'قبول',
                              'preparing': 'تجهيز',
                              'ready': 'جاهز',
                              'shipping': 'شحن',
                              'delivered': 'تسليم',
                            }.entries)
                              Chip(
                                avatar: Icon(
                                  portion['status'] == step.key
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  size: 16,
                                ),
                                label: Text(step.value),
                              ),
                          ],
                        ),
                        for (final line in lines.where(
                          (line) => (portion['line_ids'] as List? ?? [])
                              .contains(line['id']),
                        ))
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.inventory_2_outlined),
                            title: Text(
                              '${line['product_details']?['name'] ?? 'منتجك'}',
                            ),
                            subtitle: Text(
                              'الكمية: ${line['qty']} — سعر التوريد: ${money(line['price'])}',
                            ),
                          ),
                        for (final action in portion['actions'] as List? ?? [])
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: OutlinedButton(
                              onPressed: busy
                                  ? null
                                  : () => decide(portion, '$action'),
                              child: Text(labels[action] ?? '$action'),
                            ),
                          ),
                        if (portion['delivery_proof_required'] == true)
                          FilledButton.icon(
                            onPressed: busy ? null : () => proof(portion),
                            icon: const Icon(Icons.add_a_photo_outlined),
                            label: const Text('إرفاق إثبات التسليم لهذا الجزء'),
                          ),
                        if (portion['accepted_at'] != null)
                          Text('القبول الصريح: ${portion['accepted_at']}'),
                        if (portion['decision_reason'] != null)
                          Text('السبب: ${portion['decision_reason']}'),
                        if (portion['penalty'] is Map)
                          Text(
                            'الغرامة المسجلة: ${money(portion['penalty']['assessed_amount'])} — الدين عند التقييم: ${money(portion['penalty']['debt_assessed'])}',
                          ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
