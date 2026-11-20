import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/sigma_chat_bubble.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';

/// Live chat with the administration.
/// - Without [threadId]: the technical support conversation
///   (GET /api/v3/seller/inbox/support opens or creates it).
/// - With [threadId]: any administration conversation
///   (GET /api/v3/seller/inbox/threads/{id}).
/// Messages are sent with POST /api/v3/seller/inbox/threads/{id}/reply and appear
/// immediately; new replies arrive every few seconds without leaving the screen.
class VendorSupportChatScreen extends StatefulWidget {
  final int? threadId;
  final String? title;
  const VendorSupportChatScreen({super.key, this.threadId, this.title});

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
  final List<Map> pending = [];

  String tr(String key) => getTranslated(key, context) ?? key;

  String get feedPath => widget.threadId == null ? '/api/v3/seller/inbox/support' : '/api/v3/seller/inbox/threads/${widget.threadId}';

  @override
  void initState() {
    super.initState();
    load(scrollToEnd: true);
    poller = Timer.periodic(const Duration(seconds: 4), (_) {
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

  bool get nearBottom => !scroll.hasClients || scroll.position.maxScrollExtent - scroll.position.pixels < 140;

  Future<void> load({bool scrollToEnd = false}) async {
    if (loading || sending) return;
    loading = true;
    final revision = conversationRevision;
    try {
      final response = await VendorWorkspace.instance.client.get(feedPath);
      if (!mounted || revision != conversationRevision) return;
      final before = (data?['messages'] as List?)?.length ?? 0;
      final stick = scrollToEnd || nearBottom;
      setState(() {
        data = Map.from(response.data as Map);
        error = null;
      });
      if (((data?['messages'] as List?)?.length ?? 0) != before && stick) toBottom();
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

  bool get closed => const ['closed', 'archived'].contains(data?['status']);

  Future<void> send({Map? failedDraft}) async {
    final body = (failedDraft?['body'] as String? ?? message.text).trim();
    if (body.isEmpty || sending || data == null || closed) return;
    conversationRevision++;
    final draft = {'body': body, 'author': 'seller', 'created_at': DateTime.now().toIso8601String(), 'pending': true};
    setState(() {
      sending = true;
      if (failedDraft != null) pending.remove(failedDraft);
      pending.add(draft);
      if (failedDraft == null) message.clear();
    });
    toBottom();
    try {
      final response = await VendorWorkspace.instance.client.post('/api/v3/seller/inbox/threads/${data!['id']}/reply', data: {'body': body});
      if (!mounted) return;
      setState(() {
        pending.remove(draft);
        data = Map.from(response.data as Map);
      });
      toBottom();
    } catch (_) {
      if (mounted) {
        setState(() => draft['failed'] = true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('support_chat_send_error'))));
      }
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  List<Widget> buildMessages() {
    final items = [...(data?['messages'] as List? ?? []).cast<Map>(), ...pending];
    final widgets = <Widget>[];
    DateTime? lastDay;
    for (final item in items) {
      final time = SigmaChatBubble.parse(item['created_at']);
      if (time != null) {
        final day = DateTime(time.year, time.month, time.day);
        if (lastDay == null || day != lastDay) {
          widgets.add(SigmaChatDay(day: day));
          lastDay = day;
        }
      }
      final mine = item['author'] == 'seller';
      final failed = item['failed'] == true;
      final bubble = SigmaChatBubble(
        body: '${item['body'] ?? ''}',
        mine: mine,
        sender: mine ? tr('support_chat_you') : tr('administration'),
        time: time,
        pending: item['pending'] == true && !failed,
        failed: failed,
        primary: AppDesign.primary,
      );
      widgets.add(failed && !closed ? GestureDetector(onTap: () => send(failedDraft: item), child: bubble) : bubble);
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final children = buildMessages();
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? '${data?['subject'] ?? tr('technical_support')}')),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: data == null
                  ? Center(child: error == null ? const CircularProgressIndicator() : TextButton(onPressed: () => load(scrollToEnd: true), child: Text(error!)))
                  : children.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(tr('support_chat_empty'), textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).hintColor)),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => load(),
                          child: ListView(controller: scroll, padding: const EdgeInsets.fromLTRB(12, 12, 12, 16), children: children),
                        ),
            ),
          ),
          if (closed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              color: Theme.of(context).cardColor,
              child: Text(tr('support_chat_closed'), textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).hintColor)),
            )
          else
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, border: Border(top: BorderSide(color: Theme.of(context).dividerColor))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                  child: TextField(
                    controller: message,
                    minLines: 1,
                    maxLines: 5,
                    maxLength: 10000,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: tr('support_chat_hint'),
                      counterText: '',
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
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
