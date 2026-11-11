import 'package:flutter/material.dart';

import 'package:sixvalley_vendor_app/features/seller_package/widgets/saved_advertisement_tile.dart';
import 'package:uuid/uuid.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_tab_view_screen.dart';
import 'package:sixvalley_vendor_app/features/seller_package/domain/models/seller_package_overview_model.dart';
import 'package:sixvalley_vendor_app/features/seller_package/screens/seller_package_screen.dart';
import 'package:sixvalley_vendor_app/features/seller_package/screens/seller_extra_ads_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/widgets/vendor_finance_ui.dart';

class SellerSlotsScreen extends StatefulWidget {
  final Future<void> Function(int slotId, String token)? openProductForm;
  final bool embedded;
  const SellerSlotsScreen(
      {super.key, this.openProductForm, this.embedded = false});
  @override
  State<SellerSlotsScreen> createState() => _SellerSlotsScreenState();
}

class _SellerSlotsScreenState extends State<SellerSlotsScreen> {
  Map<String, dynamic>? data;
  String? error;
  bool busy = false;
  String search = '';
  final Map<int, String> tokens = {};
  bool get ar => Localizations.localeOf(context).languageCode == 'ar';
  String tr(String arabic, String english) => ar ? arabic : english;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final response = await VendorWorkspace.instance.client
          .get('/api/v3/seller/packages/slots');
      if (mounted) {
        setState(() {
          data = Map<String, dynamic>.from(response.data);
          error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    }
  }

  Future<void> perform(Future<void> Function() action) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await action();
      await load();
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> create(Map slot) async {
    final id = (slot['id'] as num).toInt();
    final token = tokens.putIfAbsent(id, () => const Uuid().v4());
    await VendorWorkspace.instance.client.post(
        '/api/v3/seller/packages/slots/$id/reserve',
        data: {'reservation_token': token});
    if (!mounted) return;
    try {
      if (widget.openProductForm != null) {
        await widget.openProductForm!(id, token);
      } else {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddProductTabView(
                    fromHome: false, slotId: id, slotReservationToken: token)));
      }
    } finally {
      tokens.remove(id);
    }
  }

  Future<void> assign(Map slot, int? productId) async {
    await VendorWorkspace.instance.client
        .post('/api/v3/seller/packages/slots/${slot['id']}', data: {
      'product_id': productId,
      'slot_revision': slot['assignment_revision'] ?? 0
    });
  }

  Future<void> choose(Map slot) async {
    final products = (data?['products'] as List? ?? [])
        .where((p) => p['id'] != slot['product_id'])
        .toList();
    final selected = await showModalBottomSheet<int>(
        context: context,
        isScrollControlled: true,
        builder: (context) => SafeArea(
            child: SizedBox(
                height: MediaQuery.sizeOf(context).height * .65,
                child: ListView(padding: const EdgeInsets.all(20), children: [
                  Text(tr('اختر منتجًا محفوظًا', 'Choose a saved product'),
                      style: Theme.of(context).textTheme.titleLarge),
                  for (final p in products)
                    ListTile(
                        title: Text('${p['name']}'),
                        onTap: () =>
                            Navigator.pop(context, (p['id'] as num).toInt())),
                  if (products.isEmpty)
                    Text(tr('لا توجد إعلانات أخرى.', 'No other ads.'))
                ]))));
    if (selected != null) await perform(() => assign(slot, selected));
  }

  Future<void> remove(Map slot) async {
    final yes = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: Text(tr('إيقاف الإعلان؟', 'Stop this ad?')),
                content: Text(tr(
                    'يتوقف الإعلان وتبقى بياناته محفوظة. لا يتغير موعد نهاية الاشتراك.',
                    'The advertisement stops. The product is kept and slot expiry stays unchanged.')),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(tr('رجوع', 'Back'))),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(tr('إزالة', 'Remove')))
                ]));
    if (yes == true) await perform(() => assign(slot, null));
  }

  Future<void> buyExtra() async {
    final response =
        await VendorWorkspace.instance.client.get('/api/v3/seller/packages');
    final overview = SellerPackageOverviewModel.fromJson(
        Map<String, dynamic>.from(response.data));
    if (!mounted) return;
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => SellerExtraAdsScreen(
                subscription: data?['subscription'] == null
                    ? null
                    : Map<String, dynamic>.from(data!['subscription']),
                overview: overview)));
  }

  @override
  Widget build(BuildContext context) {
    final slots = data?['slots'] as List? ?? [];
    final cycle = data?['subscription'] as Map?;
    final capacity = data?['capacity'] as Map? ?? {};
    final settings = data?['extra_settings'] as Map? ?? {};
    final assigned =
        slots.map((slot) => slot['product']?['id']).whereType<num>().toSet();
    final saved = (data?['products'] as List? ?? [])
        .where((product) =>
            !assigned.contains(product['id']) &&
            '${product['name']}'.toLowerCase().contains(search.toLowerCase()))
        .toList();
    final body = data == null && error == null
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: load,
            child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  if (error != null) ...[
                    Text(error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                    TextButton(
                        onPressed: load,
                        child: Text(tr('إعادة المحاولة', 'Retry')))
                  ],
                  Text(
                      '${cycle?['package_name'] ?? tr('لا اشتراك مدفوع', 'No paid subscription')}',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text(
                      '${tr('صلاحية الإعلانات', 'Slot validity')}: ${financeDate(context, cycle?['starts_at'])} — ${financeDate(context, cycle?['expires_at'])}'),
                  Text(
                      '${capacity['used'] ?? 0} ${tr('نشطة', 'active')} · ${capacity['reserved'] ?? 0} ${tr('قيد الإضافة', 'being added')} · ${capacity['available'] ?? 0} ${tr('متاحة', 'available')} / ${capacity['total'] ?? 0}'),
                  TextButton(
                      onPressed: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SellerPackageScreen()));
                        await load();
                      },
                      child: Text(tr(
                          'الاشتراكات والتجديد', 'Subscriptions and renewal'))),
                  for (final raw in slots)
                    slotCard(Map<String, dynamic>.from(raw)),
                  Card(
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(tr('إعلان إضافي', 'Additional ad'),
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 8),
                                Text(tr('تنتهي مع الاشتراك ولا تنتقل للتجديد.',
                                    'Expires with this subscription and does not carry into renewal.')),
                                if (settings['enabled'] == true &&
                                    settings['unit_price'] != null)
                                  Text(financeMoney(
                                      context, settings['unit_price'])),
                                FilledButton(
                                    onPressed:
                                        busy || data?['can_buy_extra'] != true
                                            ? null
                                            : () => perform(buyExtra),
                                    child: Text(tr('شراء الآن', 'Buy now'))),
                                if (settings['enabled'] != true)
                                  Text(tr('بانتظار تفعيل الإدارة وتحديد السعر.',
                                      'Waiting for administration to enable and set a price.'))
                              ]))),
                  const SizedBox(height: 28),
                  Text(tr('إعلاناتك المحفوظة', 'Saved advertisements'),
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 14),
                  TextField(
                      key: const ValueKey('saved-ad-search'),
                      onChanged: (value) => setState(() => search = value),
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: tr(
                              'ابحث باسم الإعلان…', 'Search advertisements…'),
                          border: const OutlineInputBorder())),
                  const SizedBox(height: 16),
                  for (final product in saved)
                    SavedAdvertisementTile(
                        data: Map<String, dynamic>.from(product),
                        onReturn: load),
                  if (data != null && saved.isEmpty)
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(tr('لا توجد إعلانات تطابق اختيارك.',
                            'No advertisements match your selection.'))),
                  if (busy) const LinearProgressIndicator(),
                ]));
    if (widget.embedded) return body;
    return Scaffold(
      appBar: VendorFinanceAppBar(
          title: tr('الإعلانات', 'Advertising slots')),
      body: body,
    );
  }

  Widget slotCard(Map<String, dynamic> slot) {
    final state = slot['capacity_status'];
    final product = slot['product'] as Map?;
    final stateLabel = {
          'available': tr('متاحة', 'Available'),
          'reserved': tr('إضافة غير مكتملة', 'Unfinished addition'),
          'occupied': tr('نشط', 'Active'),
          'expired': tr('منتهية', 'Expired')
        }[state] ??
        '$state';
    final stats = slot['statistics'] as Map?;
    return Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(
                        child: Text(
                            '${tr('الإعلان', 'Ad')} ${slot['position']}',
                            style: Theme.of(context).textTheme.titleMedium)),
                    Chip(
                        label: Text(stateLabel),
                        side: BorderSide.none,
                        backgroundColor: state == 'occupied'
                            ? const Color(0xffe7f5ed)
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        labelStyle: TextStyle(
                            color: state == 'occupied'
                                ? const Color(0xff11613d)
                                : Theme.of(context).colorScheme.onSurface)),
                  ]),
                  Text(
                      '${slot['extra_ad_purchase_id'] == null ? tr('ضمن الباقة', 'Included') : tr('إضافية', 'Additional')} · ${tr('حتى', 'until')} ${financeDate(context, slot['expires_at'])}'),
                  if (product != null) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ColoredBox(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: product['thumbnail_url'] != null
                                ? Image.network('${product['thumbnail_url']}',
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) =>
                                        const SizedBox(
                                            height: 180,
                                            child: Icon(Icons.image_outlined,
                                                size: 40)))
                                : const SizedBox(
                                    height: 180,
                                    child:
                                        Icon(Icons.image_outlined, size: 40)))),
                    const SizedBox(height: 16),
                    Text('${product['name']}',
                        style: Theme.of(context).textTheme.titleMedium),
                    VendorProductViews(data: Map<String, dynamic>.from(product)),
                    const SizedBox(height: 12),
                    Wrap(spacing: 24, runSpacing: 12, children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tr('سعر المنتج', 'Product price')),
                            Text(financeMoney(context, product['unit_price']),
                                style: Theme.of(context).textTheme.titleLarge),
                          ]),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tr('الكمية المتبقية', 'Remaining quantity')),
                            Text('${product['current_stock'] ?? 0}',
                                style: Theme.of(context).textTheme.titleLarge),
                          ]),
                    ]),
                    const SizedBox(height: 12),
                    Wrap(spacing: 10, children: [
                      TextButton(
                          onPressed: busy
                              ? null
                              : () => perform(() => openSavedAdvertisement(
                                  context, Map<String, dynamic>.from(product))),
                          child: Text(tr('عرض الإعلان', 'View advertisement'))),
                      TextButton(
                          onPressed: busy
                              ? null
                              : () => perform(() => openSavedAdvertisement(
                                  context, Map<String, dynamic>.from(product),
                                  edit: true)),
                          child: Text(tr('تعديل', 'Edit')))
                    ]),
                    Text(
                        '${tr('إحصاءات المنتج خلال الاشتراك', 'Product during this subscription')}: ${stats?['visits'] ?? '—'} ${tr('زيارة', 'visits')} · ${stats?['orders'] ?? '—'} ${tr('طلب', 'orders')}')
                  ],
                  if (slot['editable'] == true) ...[
                    const SizedBox(height: 12),
                    if (state == 'available')
                      FilledButton(
                          onPressed:
                              busy ? null : () => perform(() => create(slot)),
                          child: Text(tr('إضافة منتج', 'Add product'))),
                    if (state == 'reserved')
                      OutlinedButton(
                          onPressed: busy
                              ? null
                              : () => perform(() async {
                                    await VendorWorkspace.instance.client.post(
                                        '/api/v3/seller/packages/slots/${slot['id']}/cancel-reservation');
                                    tokens.remove(slot['id']);
                                  }),
                          child: Text(tr('إلغاء الإضافة', 'Cancel addition')))
                    else if (product == null)
                      OutlinedButton(
                          onPressed: busy ? null : () => choose(slot),
                          child: Text(
                              tr('اختيار منتج محفوظ', 'Choose saved product'))),
                    if (product != null)
                      TextButton.icon(
                          onPressed: busy ? null : () => remove(slot),
                          icon: const Icon(Icons.delete_outline),
                          label:
                              Text(tr('إيقاف الإعلان', 'Stop ad'))),
                  ],
                ])));
  }
}
