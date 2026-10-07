import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/features/wallet/widgets/vendor_finance_ui.dart';

class VendorSupportThreadScreen extends StatefulWidget {
  final int id;
  const VendorSupportThreadScreen({super.key, required this.id});
  @override
  State<VendorSupportThreadScreen> createState() => _SupportThreadState();
}

class _SupportThreadState extends State<VendorSupportThreadScreen> {
  Map? data;
  String? error;
  final reading = <int>{};
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final r = await VendorWorkspace.instance.client
          .get('/api/v3/seller/inbox/threads/${widget.id}');
      if (mounted) setState(() => data = r.data);
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    }
  }

  Future<void> read(Map item) async {
    final id = item['id'] as int;
    if (reading.contains(id)) return;
    setState(() => reading.add(id));
    try {
      await VendorWorkspace.instance.read(Map<String, dynamic>.from(item));
      await load();
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => reading.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: VendorFinanceAppBar(
          title:
              '${data?['subject'] ?? financeText(context, 'administration_messages')}'),
      body: data == null && error == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: load,
              child: ListView(padding: const EdgeInsets.all(16), children: [
                if (error != null) Text(error!),
                for (final message in data?['messages'] as List? ?? [])
                  Card(
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${message['body']}'),
                                const SizedBox(height: 8),
                                Text(
                                    financeDate(context, message['created_at']),
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                                if (message['unread'] == true)
                                  TextButton(
                                      onPressed: reading.contains(message['id'])
                                          ? null
                                          : () => read(message),
                                      child: Text(
                                          financeText(context, 'mark_as_read')))
                              ])))
              ])));
}
