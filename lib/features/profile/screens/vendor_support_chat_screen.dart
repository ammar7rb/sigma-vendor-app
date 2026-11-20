import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';

/// Technical support is a single chat with administration (no tickets).
/// GET /api/v3/seller/inbox/support opens or creates the conversation;
/// messages are sent with POST /api/v3/seller/inbox/threads/{id}/reply.
class VendorSupportChatScreen extends StatefulWidget {
  const VendorSupportChatScreen({super.key});

  @override
  State<VendorSupportChatScreen> createState() => _VendorSupportChatScreenState();
}

class _VendorSupportChatScreenState extends State<VendorSupportChatScreen> {
  final message = TextEditingController();
  final scroll = ScrollController();
  Map? data;
  String? error;
  bool loading = false, sending = false;
  int conversationRevision = 0;
  Timer? poller;

  String tr(String key) => getTranslated(key, context) ?? key;

  @override
  void initState() {
    super.initState();
    load();
    poller = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) load();
    });
  }

  @override
  void dispose() {
    poller?.cancel();
    message.dispose();
    scroll.dispose();
    super.dispose();
  }

  Future<void> load() async {
    if (loading || sending) return;
    loading = true;
    final revision = conversationRevision;
    try {
      final response = await VendorWorkspace.instance.client.get('/api/v3/seller/inbox/support');
      if (!mounted || revision != conversationRevision) return;
      final before = (data?['messages'] as List?)?.length ?? 0;
      setState(() {
        data = Map.from(response.data as Map);
        error = null;
      });
      if (((data?['messages'] as List?)?.length ?? 0) != before) toBottom();
    } catch (_) {
      if (mounted && data == null) setState(() => error = tr('support_chat_load_error'));
    } finally {
      loading = false;
    }
  }

  void toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) scroll.animateTo(scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  Future<void> send() async {
    final body = message.text.trim();
    if (body.isEmpty || sending || data == null) return;
    conversationRevision++;
    setState(() => sending = true);
    try {
      final response = await VendorWorkspace.instance.client.post('/api/v3/seller/inbox/threads/${data!['id']}/reply', data: {'body': body});
      if (!mounted) return;
      if (message.text.trim() == body) message.clear();
      setState(() => data = Map.from(response.data as Map));
      toBottom();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('support_chat_send_error'))));
      }
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = (data?['messages'] as List? ?? []).cast<Map>();
    return Scaffold(
      appBar: AppBar(title: Text(tr('technical_support'))),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: data == null
                ? Center(child: error == null ? const CircularProgressIndicator() : TextButton(onPressed: load, child: Text(error!)))
                : messages.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(tr('support_chat_empty'), textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).hintColor)),
                        ),
                      )
                    : ListView.builder(
                        controller: scroll,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final item = messages[index];
                          final mine = item['author'] == 'seller';
                          return Align(
                            alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
                            child: Container(
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .78),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: mine ? AppDesign.primary : Theme.of(context).cardColor,
                                border: mine ? null : Border.all(color: Theme.of(context).dividerColor),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                if (!mine)
                                  Text(tr('administration'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppDesign.primary)),
                                Text('${item['body'] ?? ''}', style: TextStyle(color: mine ? Colors.white : null)),
                              ]),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, border: Border(top: BorderSide(color: Theme.of(context).dividerColor))),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: message,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: 10000,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(hintText: tr('support_chat_hint'), counterText: '', border: const OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: tr('send'),
                onPressed: sending ? null : send,
                icon: sending
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
