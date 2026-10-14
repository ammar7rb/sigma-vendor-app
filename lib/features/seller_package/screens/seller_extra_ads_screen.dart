import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/features/seller_package/domain/models/seller_package_overview_model.dart';
import 'package:sixvalley_vendor_app/features/seller_package/widgets/transfer_account_details.dart';
import 'package:sixvalley_vendor_app/features/wallet/widgets/vendor_finance_ui.dart';

class SellerExtraAdsScreen extends StatefulWidget {
  final Map<String, dynamic>? subscription;
  final SellerPackageOverviewModel overview;
  const SellerExtraAdsScreen(
      {super.key, required this.subscription, required this.overview});
  @override
  State<SellerExtraAdsScreen> createState() => _ExtraAdsState();
}

class _ExtraAdsState extends State<SellerExtraAdsScreen> {
  final form = GlobalKey<FormState>();
  final quantity = TextEditingController(text: '1');
  final note = TextEditingController();
  final transferReference = TextEditingController();
  final Map<String, TextEditingController> fields = {};
  String requestKey = withdrawalRequestKey();
  Map<String, dynamic>? settings;
  List<Map<String, dynamic>> purchases = [];
  SellerOfflinePaymentMethod? method;
  XFile? proof;
  String? error;
  bool busy = false;
  bool loading = true;
  String? nextPage;
  bool get ar => Localizations.localeOf(context).languageCode == 'ar';
  String t(String a, String e) => ar ? a : e;
  double get price => double.tryParse('${settings?['unit_price']}') ?? 0;
  int get count => int.tryParse(quantity.text) ?? 0;
  bool get canBuy =>
      settings?['enabled'] == true && widget.subscription != null;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    transferReference.dispose();
    quantity.dispose();
    note.dispose();
    for (final c in fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> load({bool more = false}) async {
    try {
      final response = await VendorWorkspace.instance.client
          .get(more ? nextPage! : '/api/v3/seller/packages/extra-ads');
      if (!mounted) return;
      final page = Map<String, dynamic>.from(response.data['purchases'] as Map);
      setState(() {
        settings = Map<String, dynamic>.from(response.data['settings'] as Map);
        final rows = (page['data'] as List)
            .map((v) => Map<String, dynamic>.from(v as Map))
            .toList();
        purchases = more ? [...purchases, ...rows] : rows;
        final next = page['next_page_url']?.toString();
        // Keep pagination on the configured authenticated API origin.
        nextPage = next == null
            ? null
            : '${Uri.parse(next).path}?${Uri.parse(next).query}';
        error = null;
      });
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void choose(SellerOfflinePaymentMethod? value) {
    for (final c in fields.values) {
      c.dispose();
    }
    fields.clear();
    for (final field
        in value?.methodInformations ?? <SellerOfflineMethodField>[]) {
      if (!const [
        'payment_screenshot',
        'transfer_reference',
        'transaction_reference',
        'transaction_id',
        'reference_number',
        'reference'
      ].contains(field.inputName)) {
        fields[field.inputName] = TextEditingController();
      }
    }
    setState(() {
      method = value;
      proof = null;
      requestKey = withdrawalRequestKey();
    });
  }

  Future<void> purchase() async {
    if (busy || !(form.currentState?.validate() ?? false)) return;
    if (method != null && proof == null) {
      setState(() => error = t('أرفق إثبات التحويل.', 'Attach payment proof.'));
      return;
    }
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text(t('تأكيد شراء الإضافات', 'Confirm extra slots')),
                content: Text(
                    '${t('العدد', 'Quantity')}: $count\n${t('الإجمالي النهائي', 'Final total')}: ${financeMoney(context, price * count)}\n${t('تنتهي مع الاشتراك', 'Expires with subscription')}: ${widget.subscription?['expires_at']}'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(t('رجوع', 'Back'))),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(t('تأكيد', 'Confirm')))
                ]));
    if (confirmed != true || !mounted) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final data = <String, dynamic>{
        'subscription_id': widget.subscription!['id'],
        'quantity': count,
        'request_key': requestKey,
        'expected_unit_price': price.toStringAsFixed(2),
        'payment_method':
            method == null ? 'operating_balance' : 'offline_payment'
      };
      if (method != null) {
        data.addAll({
          'method_id': method!.id,
          'transfer_reference': transferReference.text.trim(),
          'payment_note': note.text,
          'method_information':
              fields.map((k, v) => MapEntry(k, v.text.trim())),
          'payment_proof': MultipartFile.fromBytes(await proof!.readAsBytes(),
              filename: proof!.name)
        });
      }
      await VendorWorkspace.instance.client.post(
          '/api/v3/seller/packages/extra-ads',
          data: method == null ? data : FormData.fromMap(data));
      if (!mounted) return;
      requestKey = withdrawalRequestKey();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(t('تم تسجيل طلبك. تابع حالته في السجل.',
              'Your request was recorded. Follow its status below.'))));
      await load();
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String status(Map<String, dynamic> p) {
    switch (p['status']) {
      case 'paid':
        return DateTime.tryParse('${p['expires_at']}')
                    ?.isBefore(DateTime.now()) ==
                true
            ? t('منتهية', 'Expired')
            : t('مدفوعة', 'Paid');
      case 'manual_settlement':
        return t('معلقة لتسوية يدوية', 'Awaiting manual settlement');
      case 'payment_rejected':
        return t('التحويل غير مؤكد', 'Transfer not confirmed');
      default:
        return t('بانتظار تأكيد التحويل', 'Awaiting payment review');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: VendorFinanceAppBar(
          title: t('المساحات الإضافية', 'Extra advertising slots')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: load,
              child: Form(
                  key: form,
                  child: ListView(padding: const EdgeInsets.all(20), children: [
                    Text(
                        t('إضافات للدورة الحالية', 'More slots for this cycle'),
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    Text(t(
                        'سعر ثابت ونهائي للمساحة مهما كانت المدة المتبقية. تنتهي الإضافات مع الاشتراك ولا تتجدد تلقائيًا. لا تضمن موضعًا مميزًا في الرئيسية أو البحث.',
                        'A fixed final price per slot for the remaining subscription time. Extras expire with your subscription and do not renew automatically. Featured placement is not guaranteed.')),
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                      TextButton(
                          onPressed: busy ? null : load,
                          child: Text(t('تحديث', 'Refresh')))
                    ],
                    if (canBuy) ...[
                      const SizedBox(height: 20),
                      Text(
                          '${t('سعر المساحة', 'Unit price')}: ${financeMoney(context, price)}'),
                      Text(
                          '${t('النهاية', 'Expires')}: ${widget.subscription?['expires_at']}'),
                      const SizedBox(height: 16),
                      TextFormField(
                          controller: quantity,
                          enabled: !busy,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              labelText: t('عدد المساحات', 'Quantity'),
                              border: const OutlineInputBorder()),
                          onChanged: (_) => setState(
                              () => requestKey = withdrawalRequestKey()),
                          validator: (_) => count < 1 ||
                                  count >
                                      (settings?['max_slots'] as int? ?? 100)
                              ? t('أدخل عددًا ضمن الحد المسموح.',
                                  'Enter a quantity within the allowed limit.')
                              : null),
                      const SizedBox(height: 12),
                      Text(
                          '${t('الإجمالي النهائي', 'Final total')}: ${financeMoney(context, price * count)}',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                          initialValue: method?.id ?? 0,
                          isExpanded: true,
                          decoration: InputDecoration(
                              labelText: t('طريقة الدفع', 'Payment method')),
                          items: [
                            DropdownMenuItem(
                                value: 0,
                                child: Text(
                                    t('رصيد المدفوعات', 'Payments balance'))),
                            ...widget.overview.offlinePaymentMethods
                                .where((m) => ['wallet', 'instapay']
                                    .contains(m.paymentChannel))
                                .map((m) => DropdownMenuItem(
                                    value: m.id, child: Text(m.methodName)))
                          ],
                          onChanged: busy
                              ? null
                              : (id) => choose(id == null || id == 0
                                  ? null
                                  : widget.overview.offlinePaymentMethods
                                      .firstWhere((m) => m.id == id))),
                      if (method != null) ...[
                        const SizedBox(height: 16),
                        TransferAccountDetails(fields: method!.methodFields),
                        TextFormField(
                            controller: transferReference,
                            enabled: !busy,
                            maxLength: 191,
                            decoration: InputDecoration(
                                labelText: t(
                                    'رقم عملية التحويل', 'Transfer reference')),
                            validator: (value) => (value ?? '').trim().isEmpty
                                ? t('أدخل رقم التحويل.',
                                    'Enter transfer reference.')
                                : null),
                        for (final f
                            in method!.methodInformations.where((f) => !const [
                                  'payment_screenshot',
                                  'transfer_reference',
                                  'transaction_reference',
                                  'transaction_id',
                                  'reference_number',
                                  'reference'
                                ].contains(f.inputName)))
                          Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: TextFormField(
                                  controller: fields[f.inputName],
                                  enabled: !busy,
                                  maxLength: 1000,
                                  decoration: InputDecoration(
                                      labelText: f.placeholder.isEmpty
                                          ? f.inputName
                                          : f.placeholder),
                                  validator: (v) => f.isRequired &&
                                          (v == null || v.trim().isEmpty)
                                      ? t('هذا الحقل مطلوب.',
                                          'This field is required.')
                                      : null)),
                        TextFormField(
                            controller: note,
                            enabled: !busy,
                            maxLength: 1000,
                            decoration: InputDecoration(
                                labelText: t('ملاحظة', 'Note'))),
                        OutlinedButton.icon(
                            onPressed: busy
                                ? null
                                : () async {
                                    final file = await ImagePicker()
                                        .pickImage(source: ImageSource.gallery);
                                    if (file != null && mounted) {
                                      setState(() => proof = file);
                                    }
                                  },
                            icon: const Icon(Icons.attach_file),
                            label: Text(proof?.name ??
                                t('إرفاق إثبات التحويل', 'Attach proof'))),
                        Text(t(
                            'إذا انتهى الاشتراك قبل اعتماد التحويل يبقى المبلغ معلقًا لتسوية يدوية، دون رصيد أو مساحات تلقائية.',
                            'If your subscription expires before payment approval, the transfer stays pending for manual settlement. No credit or slots are added automatically.')),
                      ],
                      const SizedBox(height: 16),
                      FilledButton(
                          onPressed: busy ? null : purchase,
                          child: Text(busy
                              ? t('جارٍ الإرسال…', 'Submitting…')
                              : method == null
                                  ? t('شراء من رصيد المدفوعات',
                                      'Buy with payments balance')
                                  : t('إرسال التحويل للمراجعة',
                                      'Submit transfer'))),
                    ] else
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(t(
                              'يلزم اشتراك سارٍ وتفعيل الإدارة لسعر الإضافات.',
                              'An active subscription and an enabled extra-slot price are required.'))),
                    const SizedBox(height: 28),
                    Text(t('مشترياتي الإضافية', 'My extra purchases'),
                        style: Theme.of(context).textTheme.titleLarge),
                    if (purchases.isEmpty)
                      Text(t('لا توجد مشتريات إضافية.',
                          'No extra purchases yet.')),
                    for (final p in purchases)
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SelectableText('${p['admin_reference']}'),
                                Text(
                                    '${p['quantity']} × ${p['unit_price']} EGP — ${p['total_price']} EGP'),
                                Text(status(p)),
                                Text(
                                    '${t('النهاية', 'Expires')}: ${p['expires_at']}'),
                                if (p['review_note'] != null)
                                  Text('${p['review_note']}'),
                                const Divider()
                              ])),
                    if (nextPage != null)
                      TextButton(
                          onPressed: busy ? null : () => load(more: true),
                          child: Text(t('عرض المزيد', 'Load more'))),
                  ]))));
}
