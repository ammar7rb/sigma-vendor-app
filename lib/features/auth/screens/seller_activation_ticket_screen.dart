import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';

class SellerActivationTicketScreen extends StatefulWidget {
  const SellerActivationTicketScreen({super.key});
  @override
  State<SellerActivationTicketScreen> createState() =>
      _SellerActivationTicketScreenState();
}

class _SellerActivationTicketScreenState
    extends State<SellerActivationTicketScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<dynamic> _messages = [];
  int? _ticketId;
  Timer? _poller;
  bool _loading = true;
  bool _fetching = false,
      _sending = false,
      _opened = false,
      _finished = false,
      _closed = false;
  String? _error;
  final List<XFile> _files = [];
  String tr(String key) => getTranslated(key, context) ?? key;

  void _complete() {
    if (!mounted || _finished) return;
    _finished = true;
    _poller?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppDesign.success,
      content: Row(children: [
        const Icon(Icons.verified_rounded, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(
            child: Text(tr('seller_account_activated'),
                style: const TextStyle(color: Colors.white)))
      ]),
    ));
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
            (_) => false);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
    _poller =
        Timer.periodic(const Duration(seconds: 4), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _poller?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (_fetching || _finished) return;
    _fetching = true;
    final auth = Provider.of<AuthController>(context, listen: false);
    try {
      final status = await auth.loadActivationStatus();
      if (!mounted) return;
      if (status.response?.statusCode != 200) throw StateError('status');
      if (auth.activation?['status'] == 'active') {
        _complete();
        return;
      }
      if (!_opened) {
        final opened = await auth.openActivationTicket();
        if (!mounted) return;
        if (auth.activation?['status'] == 'active') {
          _complete();
          return;
        }
        if (opened.response?.statusCode != 200) throw StateError('ticket');
        _opened = true;
      }
      final response = await auth.activationTicketMessages(ticketId: _ticketId);
      if (!mounted) return;
      if (response.response?.statusCode == 200 &&
          response.response?.data is Map) {
        final data = response.response!.data as Map;
        if (data['activation_completed'] == true) {
          await auth.loadActivationStatus();
          _complete();
          return;
        }
        _ticketId = data['activation_ticket']?['id'] as int?;
        setState(() {
          _messages = List<dynamic>.from(data['messages'] ?? []);
          _loading = false;
          _error = null;
          _closed = ['approved', 'closed', 'rejected']
              .contains(data['activation_ticket']?['status']);
        });
      } else {
        throw StateError('messages');
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = tr('support_connection_retry');
        });
      }
    } finally {
      _fetching = false;
    }
  }

  Future<void> _send() async {
    final body = _messageController.text.trim();
    if (_sending || _finished || _closed || (body.isEmpty && _files.isEmpty)) {
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final response = await Provider.of<AuthController>(context, listen: false)
          .sendActivationTicketMessage(body,
              ticketId: _ticketId, attachments: List.of(_files));
      if (!mounted) return;
      if (response.response?.statusCode == 201) {
        _messageController.clear();
        setState(_files.clear);
        await _load();
      } else {
        await _load();
        if (mounted && !_finished) {
          setState(() => _error = tr('support_send_failed'));
        }
      }
    } catch (_) {
      if (mounted) setState(() => _error = tr('support_send_failed'));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pick() async {
    try {
      final result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
          allowMultiple: true);
      if (!mounted || result == null) return;
      if (_files.length + result.files.length > 5 ||
          result.files.any((file) => file.size > 6 * 1024 * 1024)) {
        setState(() => _error = tr('support_attachment_limits'));
        return;
      }
      setState(() => _files.addAll(result.files.map((file) => file.xFile)));
    } catch (_) {
      if (mounted) setState(() => _error = tr('support_attachment_failed'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(getTranslated('activation_support', context) ?? '')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              if (_error != null)
                MaterialBanner(content: Text(_error!), actions: [
                  TextButton(onPressed: _load, child: Text(tr('retry')))
                ]),
              Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow:
                          AppDesign.softShadow(Theme.of(context).brightness)),
                  child: Row(children: [
                    Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                            color: AppDesign.primary.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(14)),
                        child: Icon(Icons.support_agent_rounded,
                            color: Theme.of(context).primaryColor)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(tr('activation_support'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 3),
                          Text(tr('activation_chat_notice'),
                              style: TextStyle(
                                  height: 1.45,
                                  fontSize: 11,
                                  color: Theme.of(context).hintColor)),
                        ])),
                    const Icon(Icons.circle,
                        color: AppDesign.success, size: 10),
                  ])),
              Expanded(
                  child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _messages.length,
                      itemBuilder: (_, index) {
                        final message = _messages[index] as Map;
                        final mine = message['sender_type'] == 'seller';
                        final isRtl =
                            Directionality.of(context) == TextDirection.rtl;
                        final attachments = List<Map<String, dynamic>>.from(
                            message['attachments'] ?? const []);
                        return Align(
                          alignment: mine
                              ? (isRtl
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight)
                              : (isRtl
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.sizeOf(context).width * .78),
                            child: Card(
                                color: mine
                                    ? Theme.of(context).primaryColor
                                    : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(17),
                                  side: BorderSide(
                                      color: mine
                                          ? Colors.transparent
                                          : Theme.of(context).dividerColor),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if ('${message['body'] ?? ''}'.isNotEmpty)
                                        Text('${message['body']}',
                                            style: TextStyle(
                                                color:
                                                    mine ? Colors.white : null,
                                                height: 1.45)),
                                      if (attachments.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        ...attachments.map((attachment) =>
                                            TextButton.icon(
                                              onPressed: () => _openAttachment(
                                                  '${attachment['url'] ?? ''}'),
                                              icon:
                                                  const Icon(Icons.attach_file),
                                              label: Text(
                                                  '${attachment['name'] ?? getTranslated('attachment', context) ?? ''}'),
                                            )),
                                      ],
                                      if (message['created_at'] != null)
                                        Text('${message['created_at']}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall),
                                    ],
                                  ),
                                )),
                          ),
                        );
                      })),
              if (_files.isNotEmpty)
                Wrap(
                    children: _files
                        .map((file) => InputChip(
                            label: Text(file.name),
                            onDeleted: _sending
                                ? null
                                : () => setState(() => _files.remove(file))))
                        .toList()),
              if (_closed)
                Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(tr('support_ticket_closed'))),
              if (!_closed)
                SafeArea(
                    child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            border: Border(
                                top: BorderSide(
                                    color: Theme.of(context).dividerColor))),
                        child: TextField(
                            enabled: !_sending,
                            controller: _messageController,
                            maxLength: 2000,
                            minLines: 1,
                            maxLines: 4,
                            decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor:
                                    Theme.of(context).scaffoldBackgroundColor,
                                hintText: getTranslated(
                                    'write_activation_message', context),
                                prefixIcon: IconButton(
                                    tooltip: tr('attachment'),
                                    onPressed: _sending ? null : _pick,
                                    icon: const Icon(
                                        Icons.add_circle_outline_rounded)),
                                suffixIcon: IconButton.filled(
                                    onPressed: _sending ? null : _send,
                                    icon: _sending
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white))
                                        : const Icon(Icons.send_rounded)),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none))))),
            ]),
    );
  }

  Future<void> _openAttachment(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
