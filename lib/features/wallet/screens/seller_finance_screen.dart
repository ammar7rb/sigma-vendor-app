import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/di_container.dart' as di;
import 'package:sixvalley_vendor_app/data/datasource/remote/dio/dio_client.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/controllers/wallet_controller.dart';
import 'package:sixvalley_vendor_app/features/wallet/screens/seller_balance_funding_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/widgets/withdraw_balance_widget.dart';
import 'package:sixvalley_vendor_app/features/transaction/screens/transaction_screen.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';
import 'package:sixvalley_vendor_app/features/order_details/screens/order_details_screen.dart';
import 'package:sixvalley_vendor_app/features/order_details/screens/seller_shipping_support_screen.dart';

class SellerFinanceScreen extends StatefulWidget {
  final bool fromNotification;
  final String initialSection;
  const SellerFinanceScreen({
    super.key,
    this.fromNotification = false,
    this.initialSection = 'orders',
  });
  @override
  State<SellerFinanceScreen> createState() => _SellerFinanceScreenState();
}

class _SellerFinanceScreenState extends State<SellerFinanceScreen>
    with WidgetsBindingObserver {
  Map<String, dynamic>? data;
  String? error;
  bool busy = false;
  int page = 1, generation = 0;
  String section = 'orders', category = 'balance';
  String tr(String key) => getTranslated(key, context) ?? key;
  String money(dynamic value) => value == null
      ? tr('finance_not_set')
      : PriceConverter.convertPrice(context, double.tryParse('$value') ?? 0);
  String date(dynamic value) {
    final parsed = DateTime.tryParse('$value');
    return parsed == null
        ? tr('finance_not_set')
        : DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
            .add_jm()
            .format(parsed.toLocal());
  }

  @override
  void initState() {
    super.initState();
    section = widget.initialSection;
    category =
        section == 'insurance' || section == 'shipping' ? section : 'balance';
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) load();
  }

  Future<void> load() async {
    final request = ++generation;
    if (!mounted) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final response = await di
          .sl<DioClient>()
          .get(AppConstants.sellerBalanceUri, queryParameters: {
        'page': page,
        'records_page': page,
        'orders_page': page,
        'records_limit': 20,
        'limit': 20,
        'category': category
      });
      if (!mounted || request != generation) return;
      setState(() => data = Map<String, dynamic>.from(response.data));
      await context.read<WalletController>().getSellerBalance(context);
      if (mounted) {
        await context.read<WalletController>().getSellerDashboardOverview();
      }
    } catch (_) {
      if (mounted && request == generation) {
        setState(() => error = tr('finance_load_failed'));
      }
    } finally {
      if (mounted && request == generation) setState(() => busy = false);
    }
  }

  Future<void> _openFunding(String walletTarget) async {
    await context.read<WalletController>().getSellerBalance(context);
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            SellerBalanceFundingScreen(walletTarget: walletTarget)));
    if (mounted) await load();
  }

  @override
  Widget build(BuildContext context) {
    final summary = data?['financial_summary'] as Map? ?? {};
    final rows = section == 'orders'
        ? (data?['order_dues']?['data'] as List? ?? [])
        : section == 'deposits'
            ? (data?['deposits']?['data'] as List? ?? [])
            : (data?['financial_tabs']?[section] as List? ?? []);
    final pagination = section == 'orders'
        ? (data?['order_dues'])
        : section == 'deposits'
            ? (data?['deposits'])
            : (data?['records_pagination']);
    return Scaffold(
      appBar: AppBar(
          title: Text(tr('finance_my_wallet')),
          leading: BackButton(onPressed: () {
            if (widget.fromNotification) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  (_) => false);
            } else {
              Navigator.of(context).maybePop();
            }
          }),
          actions: [
            IconButton(
                tooltip: tr('refresh'),
                onPressed: busy ? null : load,
                icon: const Icon(Icons.refresh))
          ]),
      body: data == null && busy
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: load,
              child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (error != null)
                      Card(
                          child: ListTile(
                              title: Text(error!),
                              trailing: IconButton(
                                  onPressed: load,
                                  icon: const Icon(Icons.refresh)))),
                    if (data != null) ...[
                      _sectionTitle(Icons.account_balance_wallet_outlined,
                          tr('finance_balances')),
                      const SizedBox(height: 14),
                      LayoutBuilder(
                          builder: (context, constraints) =>
                              Wrap(spacing: 12, runSpacing: 12, children: [
                                for (final item in const [
                                  (
                                    'operating',
                                    'seller_purchase_balance_total',
                                    Icons.shopping_bag_outlined
                                  ),
                                  (
                                    'available',
                                    'seller_withdrawable_balance',
                                    Icons.account_balance_wallet_outlined
                                  ),
                                  (
                                    'pending',
                                    'seller_due_balance_total',
                                    Icons.hourglass_top_rounded
                                  ),
                                  (
                                    'order_insurance_credit',
                                    'seller_insurance_available',
                                    Icons.shield_outlined
                                  ),
                                  (
                                    'shipping_due_total',
                                    'seller_shipping_due_total',
                                    Icons.local_shipping_outlined
                                  ),
                                  (
                                    'sales_total',
                                    'total_sales',
                                    Icons.payments_outlined
                                  )
                                ])
                                  SizedBox(
                                      width: constraints.maxWidth < 340
                                          ? constraints.maxWidth
                                          : (constraints.maxWidth - 12) / 2,
                                      child: Container(
                                          decoration: _cardDecoration(),
                                          child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Icon(item.$3,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary),
                                                    const SizedBox(height: 8),
                                                    Text(tr(item.$2)),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                        money(summary[item.$1]),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium
                                                            ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900))
                                                  ])))),
                              ])),
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(tr('finance_balance_notice'))),
                      Container(
                          decoration: _cardDecoration(),
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(children: [
                                line('seller_insurance_available',
                                    money(summary['order_insurance_credit'])),
                                line(
                                    'finance_insurance_locked',
                                    money(data?['insurance_wallet']
                                        ?['locked_amount'])),
                                line(
                                    'finance_insurance_review',
                                    money(data?['insurance_wallet']
                                        ?['under_review_amount'])),
                                line(
                                    'finance_insurance_reuse',
                                    date(data?['insurance_wallet']
                                        ?['next_reusable_at'])),
                              ]))),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                            child: FilledButton.icon(
                                onPressed: busy
                                    ? null
                                    : () => _openFunding('operating'),
                                icon: const Icon(Icons.shopping_bag_outlined),
                                label: Text(tr('fund_purchase_balance')))),
                        const SizedBox(width: 10),
                        Expanded(
                            child: OutlinedButton.icon(
                                onPressed: busy
                                    ? null
                                    : () => _openFunding('insurance'),
                                icon: const Icon(Icons.shield_outlined),
                                label: Text(tr('fund_insurance_balance')))),
                      ]),
                      WithdrawBalanceWidget(onChanged: load),
                      TextButton.icon(
                          onPressed: () async {
                            await Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const TransactionScreen()));
                            if (mounted) await load();
                          },
                          icon: const Icon(Icons.history),
                          label: Text(tr('finance_withdraw_history'))),
                      const SizedBox(height: 20),
                      _sectionTitle(
                          Icons.receipt_long_outlined, _sectionLabel()),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(children: [
                            for (final item in const [
                              ('balance', 'finance_purchase_records'),
                              ('orders', 'finance_order_records'),
                              ('insurance', 'finance_insurance_records'),
                              ('shipping', 'finance_shipping_records'),
                              ('deposits', 'finance_deposits')
                            ])
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(end: 8),
                                child: ChoiceChip(
                                    label: Text(tr(item.$2)),
                                    selected: section == item.$1,
                                    selectedColor:
                                        Theme.of(context).primaryColor,
                                    labelStyle: TextStyle(
                                        color: section == item.$1
                                            ? Colors.white
                                            : null,
                                        fontWeight: FontWeight.w700),
                                    onSelected: busy
                                        ? null
                                        : (_) {
                                            setState(() {
                                              section = item.$1;
                                              category =
                                                  item.$1 == 'insurance' ||
                                                          item.$1 == 'shipping'
                                                      ? item.$1
                                                      : 'balance';
                                              page = 1;
                                            });
                                            load();
                                          }),
                              ),
                          ])),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(children: [
                          Text('${tr('finance_records_count')}: '),
                          Text('${pagination?['total'] ?? rows.length}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w900)),
                        ]),
                      ),
                      if (busy) const LinearProgressIndicator(),
                      if (rows.isEmpty && !busy)
                        Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(tr('finance_empty'),
                                textAlign: TextAlign.center)),
                      for (final row in rows)
                        section == 'orders'
                            ? orderCard(Map<String, dynamic>.from(row))
                            : recordCard(Map<String, dynamic>.from(row)),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                                onPressed: busy || page <= 1
                                    ? null
                                    : () {
                                        setState(() => page--);
                                        load();
                                      },
                                child: Text(tr('previous'))),
                            Text('$page / ${pagination?['last_page'] ?? 1}'),
                            TextButton(
                                onPressed: busy ||
                                        page >= (pagination?['last_page'] ?? 1)
                                    ? null
                                    : () {
                                        setState(() => page++);
                                        load();
                                      },
                                child: Text(tr('next')))
                          ]),
                    ],
                  ])),
    );
  }

  Widget line(String key, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Text(tr(key))),
        const SizedBox(width: 12),
        Flexible(child: Text(value, textAlign: TextAlign.end))
      ]));
  Widget orderCard(Map<String, dynamic> row) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration(),
      child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          leading: _iconBox(Icons.receipt_long_outlined),
          title: Text('${tr('order')} #${row['order_id']}'),
          subtitle: Text(tr('${row['status']}')),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            line('finance_sales_due', money(row['sales_amount'])),
            line('sales_due_date', date(row['sales_due_at'])),
            line('finance_shipping_due', money(row['shipping_amount'])),
            line('shipping_due_date', date(row['shipping_due_at'])),
            line(
                'order_insurance',
                (double.tryParse('${row['insurance_amount'] ?? 0}') ?? 0) <= 0
                    ? tr('no_order_insurance_required')
                    : money(row['insurance_amount'])),
            line(
                'status',
                row['insurance_status'] == null
                    ? tr('finance_not_set')
                    : tr('${row['insurance_status']}')),
            line('finance_insurance_reuse', date(row['insurance_reuse_at'])),
            if (row['insurance_released_at'] != null)
              line('finance_released_at', date(row['insurance_released_at'])),
            Text(tr('finance_due_notice'),
                style: Theme.of(context).textTheme.bodySmall),
            Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => OrderDetailsScreen(
                                orderId: int.tryParse('${row['order_id']}')))),
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: Text(tr('finance_open_order')))),
          ]));
  Widget recordCard(Map<String, dynamic> row) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration(),
      child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _iconBox(section == 'insurance'
                ? Icons.shield_outlined
                : section == 'shipping'
                    ? Icons.local_shipping_outlined
                    : Icons.account_balance_wallet_outlined),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(money(row['amount']),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900)),
                  Text(section == 'deposits'
                      ? tr('${row['status']}')
                      : '${tr('${row['bucket']}')} • ${tr('${row['direction']}')}'),
                  Text(date(row['created_at'])),
                  if (row['order_id'] != null)
                    Text('${tr('order')} #${row['order_id']}'),
                  if (section == 'shipping' && row['shipping_due_at'] != null)
                    Text(
                        '${tr('shipping_due_date')}: ${date(row['shipping_due_at'])}'),
                  if (section == 'insurance' &&
                      row['seller_insurance_reuse_at'] != null)
                    Text(
                        '${tr('finance_insurance_reuse')}: ${date(row['seller_insurance_reuse_at'])}'),
                  if (section == 'deposits' && row['metadata'] is Map)
                    Text(tr(
                        (row['metadata'] as Map)['wallet_target'] == 'insurance'
                            ? 'seller_insurance_available'
                            : 'operating_balance')),
                  if (row['reference_code'] != null)
                    SelectableText('${row['reference_code']}'),
                  if (row['review_note'] != null) Text('${row['review_note']}'),
                  if (row['rejection_reason'] != null)
                    Text('${row['rejection_reason']}'),
                  if (row['order_id'] != null)
                    Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton.icon(
                            onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => OrderDetailsScreen(
                                        orderId: int.tryParse(
                                            '${row['order_id']}')))),
                            icon: const Icon(Icons.open_in_new_rounded),
                            label: Text(tr('finance_open_order')))),
                  if (section == 'shipping' && row['order_id'] != null)
                    Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton.icon(
                            onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => SellerShippingSupportScreen(
                                        orderId: int.tryParse(
                                                '${row['order_id']}') ??
                                            0,
                                        shippingEntitlement: double.tryParse(
                                                '${row['shipping_seller_entitlement'] ?? row['amount'] ?? 0}') ??
                                            0))),
                            icon: const Icon(Icons.report_problem_outlined),
                            label: Text(tr('shipping_due_support_action')))),
                ]))
          ])));

  String _sectionLabel() => tr(section == 'orders'
      ? 'finance_order_records'
      : section == 'insurance'
          ? 'finance_insurance_records'
          : section == 'shipping'
              ? 'finance_shipping_records'
              : 'finance_deposits');

  Widget _sectionTitle(IconData icon, String title) => Row(children: [
        _iconBox(icon),
        const SizedBox(width: 10),
        Expanded(
            child: Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900))),
      ]);

  Widget _iconBox(IconData icon) => Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      );

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: AppDesign.softShadow(Theme.of(context).brightness),
      );
}
