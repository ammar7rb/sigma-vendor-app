import 'dart:async';
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
  Timer? _messagePoller;
  bool _loading = false;
  bool sending = false;
  final reading = <int>{};
  final reply = TextEditingController();
  @override
  void initState() {
    super.initState();
    load();
    _messagePoller = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        load();
      }
    });
  }

  @override
  void dispose() {
    _messagePoller?.cancel();
    reply.dispose();
    super.dispose();
  }

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    try {
      final r = await VendorWorkspace.instance.client
          .get('/api/v3/seller/inbox/threads/${widget.id}');
      if (mounted) {
        setState(() {
          data = r.data;
          error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      _loading = false;
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

  Future<void> send() async {
    final body = reply.text.trim();
    if (sending || body.isEmpty) return;
    setState(() {
      sending = true;
      error = null;
    });
    try {
      final response = await VendorWorkspace.instance.client.post(
          '/api/v3/seller/inbox/threads/${widget.id}/reply',
          data: {'body': body});
      if (!mounted) return;
      setState(() => data = response.data);
      reply.clear();
      await VendorWorkspace.instance.refresh();
    } catch (e) {
      if (mounted) setState(() => error = financeError(context, e));
    } finally {
      if (mounted) setState(() => sending = false);
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
                                Text(message['author'] == 'seller'
                                    ? 'رسالتك'
                                    : 'الإدارة'),
                                const SizedBox(height: 6),
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
                              ]))),
                if (data?['status'] == 'open') ...[
                  const SizedBox(height: 12),
                  TextField(
                      controller: reply,
                      enabled: !sending,
                      minLines: 3,
                      maxLines: 6,
                      maxLength: 10000,
                      decoration: const InputDecoration(
                          labelText: 'الرد على الإدارة',
                          border: OutlineInputBorder())),
                  const SizedBox(height: 8),
                  FilledButton(
                      onPressed: sending ? null : send,
                      child: Text(sending ? 'جارٍ الإرسال' : 'إرسال الرد')),
                ]
              ])));
}
