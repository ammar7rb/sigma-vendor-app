import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/features/wallet/widgets/vendor_finance_ui.dart';

class VendorWithdrawalMethodsScreen extends StatefulWidget {
  const VendorWithdrawalMethodsScreen({super.key});
  @override
  State<VendorWithdrawalMethodsScreen> createState() =>
      _VendorWithdrawalMethodsState();
}

class _VendorWithdrawalMethodsState
    extends State<VendorWithdrawalMethodsScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final fields = <String, TextEditingController>{};
  List<Map<String, dynamic>> methods = [], definitions = [];
  int? definition, id;
  bool loading = true, busy = false;
  String? error;
  String tr(String key) => financeText(context, key);
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    name.dispose();
    for (final c in fields.values) c.dispose();
    super.dispose();
  }

  Future<void> load() async {
    try {
      final r = await VendorWorkspace.instance.client
          .get('/api/v3/seller/withdrawal-methods');
      if (!mounted) return;
      setState(() {
        methods = (r.data['methods'] as List)
            .map((v) => Map<String, dynamic>.from(v))
            .toList();
        definitions = (r.data['definitions'] as List)
            .map((v) => Map<String, dynamic>.from(v))
            .toList();
        error = null;
      });
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void choose(int? value, {Map<String, dynamic>? edit}) {
    for (final c in fields.values) c.dispose();
    fields.clear();
    final match = definitions.where((v) => v['id'] == value).firstOrNull;
    for (final f in (match?['method_fields'] as List? ?? [])) {
      final key = '${f['input_name']}';
      fields[key] =
          TextEditingController(text: '${edit?['method_info']?[key] ?? ''}');
    }
    setState(() {
      definition = value;
      id = edit?['id'];
      if (edit != null) name.text = '${edit['method_name'] ?? ''}';
      if (value == null) name.clear();
    });
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await VendorWorkspace.instance.client
          .post('/api/v3/seller/withdrawal-methods', data: {
        if (id != null) 'id': id,
        'withdraw_method_id': definition,
        'method_name': name.text.trim(),
        'method_info': {
          for (final e in fields.entries) e.key: e.value.text.trim()
        }
      });
      if (!mounted) return;
      choose(null);
      await load();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tr('withdrawal_method_pending_review'))));
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> disable(int method) async {
    setState(() => busy = true);
    try {
      await VendorWorkspace.instance.client
          .post('/api/v3/seller/withdrawal-methods/$method/disable');
      await load();
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = definitions.where((v) => v['id'] == definition).firstOrNull;
    return Scaffold(
        appBar: VendorFinanceAppBar(title: tr('manage_withdrawal_methods')),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: load,
                child: Center(
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              Text(tr('withdrawal_method_review_hint')),
                              if (error != null)
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    child: Text(error!,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error))),
                              const SizedBox(height: 20),
                              FinancePanel(
                                  title: tr(id == null
                                      ? 'add_withdrawal_method'
                                      : 'edit'),
                                  child: Form(
                                      key: form,
                                      child: Column(children: [
                                        TextFormField(
                                            controller: name,
                                            enabled: !busy,
                                            decoration: InputDecoration(
                                                labelText: tr('method_label')),
                                            maxLength: 100,
                                            validator: (v) =>
                                                v?.trim().isNotEmpty == true
                                                    ? null
                                                    : tr('required_field')),
                                        const SizedBox(height: 16),
                                        DropdownButtonFormField<int>(
                                            key: ValueKey(definition),
                                            initialValue: definition,
                                            isExpanded: true,
                                            decoration: InputDecoration(
                                                labelText:
                                                    tr('withdrawal_method')),
                                            items: [
                                              for (final d in definitions)
                                                DropdownMenuItem(
                                                    value: d['id'] as int,
                                                    child: Text(
                                                        '${d['method_name']}',
                                                        overflow: TextOverflow
                                                            .ellipsis))
                                            ],
                                            onChanged:
                                                busy ? null : (v) => choose(v),
                                            validator: (v) => v == null
                                                ? tr('required_field')
                                                : null),
                                        for (final raw
                                            in current?['method_fields']
                                                    as List? ??
                                                [])
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 16),
                                              child: TextFormField(
                                                  controller: fields[
                                                      '${raw['input_name']}'],
                                                  enabled: !busy,
                                                  maxLength: 191,
                                                  decoration: InputDecoration(
                                                      labelText: tr(
                                                          '${raw['input_name']}')),
                                                  validator: (v) =>
                                                      (raw['is_required'] ==
                                                                      true ||
                                                                  raw['is_required'] ==
                                                                      1) &&
                                                              (v
                                                                      ?.trim()
                                                                      .isEmpty ??
                                                                  true)
                                                          ? tr('required_field')
                                                          : null)),
                                        const SizedBox(height: 16),
                                        Row(children: [
                                          Expanded(
                                              child: FilledButton(
                                                  onPressed: busy ? null : save,
                                                  child: Text(tr('save')))),
                                          if (id != null)
                                            TextButton(
                                                onPressed: busy
                                                    ? null
                                                    : () => choose(null),
                                                child: Text(tr('cancel')))
                                        ])
                                      ]))),
                              const SizedBox(height: 24),
                              Text(tr('saved_withdrawal_methods'),
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              for (final m in methods)
                                Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: FinancePanel(
                                        title: '${m['method_name']}',
                                        hint:
                                            '${tr('${m['approval_status']}')} · ${tr(m['is_active'] == true ? 'active' : 'disabled')}',
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              for (final e in (m['method_info']
                                                          as Map? ??
                                                      {})
                                                  .entries)
                                                Text(
                                                    '${tr('${e.key}')}: ${e.value}'),
                                              if (m['approval_reason'] != null)
                                                Text('${m['approval_reason']}'),
                                              Wrap(spacing: 12, children: [
                                                TextButton.icon(
                                                    onPressed: busy
                                                        ? null
                                                        : () => choose(
                                                            m[
                                                                'withdraw_method_id'],
                                                            edit: m),
                                                    icon: const Icon(
                                                        Icons.edit_outlined),
                                                    label: Text(tr('edit'))),
                                                TextButton.icon(
                                                    onPressed: busy ||
                                                            m['is_active'] !=
                                                                true
                                                        ? null
                                                        : () =>
                                                            disable(m['id']),
                                                    icon: const Icon(Icons
                                                        .pause_circle_outline),
                                                    label: Text(tr('disable')))
                                              ])
                                            ])))
                            ])))));
  }
}
