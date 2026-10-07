import 'package:sixvalley_vendor_app/features/profile/screens/vendor_support_thread_screen.dart';
import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/features/order_details/screens/order_details_screen.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorInboxScreen extends StatefulWidget {
  final bool messages;
  final bool embedded;
  const VendorInboxScreen(
      {super.key, this.messages = false, this.embedded = false});
  @override
  State<VendorInboxScreen> createState() => _VendorInboxScreenState();
}

class _VendorInboxScreenState extends State<VendorInboxScreen> {
  final workspace = VendorWorkspace.instance;
  String? error;
  final Set<String> reading = {};
  @override
  void initState() {
    super.initState();
    workspace.refresh();
  }

  String text(String key) => getTranslated(key, context) ?? key;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: widget.embedded
            ? null
            : CustomAppBarWidget(
                title: text(widget.messages
                    ? 'administration_messages'
                    : 'notification')),
        body: AnimatedBuilder(
            animation: workspace,
            builder: (context, _) {
              final data = workspace.inbox;
              if (data == null) {
                if (workspace.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Center(
                    child: FilledButton(
                        onPressed: workspace.refresh,
                        child: Text(text('retry'))));
              }
              final items = (data[widget.messages ? 'threads' : 'notifications']
                          as List? ??
                      [])
                  .cast<Map>();
              return RefreshIndicator(
                  onRefresh: workspace.refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: AppDesign.pagePadding,
                    children: [
                      Text(text(widget.messages
                          ? 'vendor_messages_hint'
                          : 'vendor_notifications_hint')),
                      if (error != null)
                        Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(error!,
                                style:
                                    const TextStyle(color: AppDesign.danger))),
                      if (items.isEmpty)
                        Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(text('vendor_inbox_empty'),
                                textAlign: TextAlign.center)),
                      for (final raw in items)
                        widget.messages
                            ? Card(
                                child: ListTile(
                                    title: Text('${raw['title']}'),
                                    subtitle: Text('${raw['body']}',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    trailing: (raw['unread_count'] ?? 0) > 0
                                        ? Badge(
                                            backgroundColor: AppDesign.success,
                                            label:
                                                Text('+${raw['unread_count']}'))
                                        : const Icon(Icons.chevron_right),
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                VendorSupportThreadScreen(
                                                    id: raw['id'])))))
                            : _item(Map<String, dynamic>.from(raw)),
                    ],
                  ));
            }),
      );

  Widget _item(Map<String, dynamic> item) {
    final key = '${item['kind']}:${item['id']}';
    return Card(
        margin: const EdgeInsets.only(top: 16),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                      child: Text('${item['title'] ?? ''}',
                          style: Theme.of(context).textTheme.titleMedium)),
                  if (item['unread'] == true)
                    Badge(
                        backgroundColor: widget.messages
                            ? AppDesign.success
                            : AppDesign.danger,
                        label: const Text('+1'))
                ]),
                if (item['order_reference'] != null)
                  Text('${text('order_id')}: ${item['order_reference']}'),
                const SizedBox(height: 8),
                Text('${item['body'] ?? ''}'),
                const SizedBox(height: 8),
                Text('${item['created_at'] ?? ''}',
                    style: Theme.of(context).textTheme.bodySmall),
                for (final file in (item['attachments'] as List? ?? []))
                  TextButton(
                      onPressed: () async {
                        final uri = Uri.tryParse('${file['url']}');
                        if (uri != null &&
                            ['https', 'http'].contains(uri.scheme)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Text('${file['name']}')),
                Wrap(spacing: 8, children: [
                  if (item['kind'] == 'order_alert')
                    TextButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => OrderDetailsScreen(
                                    orderId: int.tryParse('${item['id']}'),
                                    accessToken:
                                        int.tryParse('${item['id']}') == null
                                            ? '${item['id']}'
                                            : null))),
                        child: Text(text('view_order'))),
                  if (item['unread'] == true)
                    TextButton(
                        onPressed: reading.contains(key)
                            ? null
                            : () async {
                                setState(() {
                                  reading.add(key);
                                  error = null;
                                });
                                try {
                                  await workspace.read(item);
                                } catch (_) {
                                  if (mounted) {
                                    setState(() =>
                                        error = text('vendor_save_error'));
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => reading.remove(key));
                                  }
                                }
                              },
                        child: Text(text('mark_as_read'))),
                ]),
              ],
            )));
  }
}
