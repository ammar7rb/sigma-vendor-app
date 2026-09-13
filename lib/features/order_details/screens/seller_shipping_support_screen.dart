import 'dart:async';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

class SellerShippingSupportScreen extends StatefulWidget {
  final int orderId;
  final double shippingEntitlement;

  const SellerShippingSupportScreen({
    super.key,
    required this.orderId,
    required this.shippingEntitlement,
  });

  @override
  State<SellerShippingSupportScreen> createState() =>
      _SellerShippingSupportScreenState();
}

class _SellerShippingSupportScreenState
    extends State<SellerShippingSupportScreen> {
  late final Dio _api;
  final _message = TextEditingController();
  Timer? _timer;
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;
  bool _busy = false;
  bool _polling = false;
  final List<PlatformFile> _files = [];

  String tr(String key) => getTranslated(key, context) ?? key;
  String get _url => '/api/v3/seller/orders/${widget.orderId}/shipping-support';

  @override
  void initState() {
    super.initState();
    final token = context.read<AuthController>().getUserToken();
    _api = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    _open();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _load());
  }

  Future<void> _open() async {
    try {
      final response = await _api.post(_url);
      if (mounted) {
        setState(() {
          _data = Map<String, dynamic>.from(response.data);
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = tr('support_connection_retry'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _load() async {
    if (_polling || !mounted) return;
    _polling = true;
    try {
      final response = await _api.get(_url);
      if (mounted) {
        setState(() {
          _data = Map<String, dynamic>.from(response.data);
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = tr('support_connection_retry'));
    } finally {
      _polling = false;
    }
  }

  Future<void> _send() async {
    final text = _message.text.trim();
    if (_busy || (text.isEmpty && _files.isEmpty)) return;
    setState(() => _busy = true);
    try {
      final form = FormData.fromMap({
        'message': text,
        for (int i = 0; i < _files.length; i++)
          'attachments[$i]': await MultipartFile.fromFile(_files[i].path!,
              filename: _files[i].name),
      });
      final response = await _api.post('$_url/messages', data: form);
      if (mounted) {
        setState(() {
          _data = Map<String, dynamic>.from(response.data);
          _message.clear();
          _files.clear();
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = tr('support_send_failed'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
    );
    if (!mounted || result == null) return;
    final selected = result.files
        .where((file) => file.path != null && file.size <= 6 * 1024 * 1024)
        .take(5 - _files.length);
    setState(() => _files.addAll(selected));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _api.close();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(tr('shipping_support_title')),
        ),
        body: SafeArea(
          child: Column(children: [
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius:
                                BorderRadius.circular(AppDesign.radiusLarge),
                            border: Border.all(
                                color: Theme.of(context).dividerColor),
                            boxShadow: AppDesign.softShadow(
                                Theme.of(context).brightness),
                          ),
                          child: Row(children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withValues(alpha: .1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(Icons.support_agent_rounded,
                                  color: Theme.of(context).primaryColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${tr('order')} #${widget.orderId}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w800)),
                                  Text(
                                    '${tr('finance_shipping_due')}: ${PriceConverter.convertPrice(context, widget.shippingEntitlement)}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(height: 12),
                        Text(tr('shipping_support_intro'),
                            style: const TextStyle(height: 1.6)),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TextButton.icon(
                              onPressed: _load,
                              icon: const Icon(Icons.refresh_rounded),
                              label: Text(_error!),
                            ),
                          ),
                        if ('${_data?['initial_message'] ?? ''}'.isNotEmpty)
                          _bubble('${_data!['initial_message']}', true),
                        for (final message
                            in _data?['messages'] as List? ?? []) ...[
                          _bubble('${message['body']}',
                              message['sender'] == 'requester'),
                          if ((message['attachments'] as List? ?? [])
                              .isNotEmpty)
                            Align(
                              alignment: message['sender'] == 'requester'
                                  ? AlignmentDirectional.centerEnd
                                  : AlignmentDirectional.centerStart,
                              child: Wrap(children: [
                                for (final attachment in message['attachments'])
                                  TextButton.icon(
                                    onPressed: () =>
                                        _openAttachment('${attachment['url']}'),
                                    icon: const Icon(Icons.attach_file_rounded),
                                    label: Text('${attachment['name']}'),
                                  ),
                              ]),
                            ),
                        ],
                      ],
                    ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Column(children: [
                if (_files.isNotEmpty)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Wrap(
                      spacing: 6,
                      children: _files
                          .map((file) => InputChip(
                              label: Text(file.name),
                              onDeleted: _busy
                                  ? null
                                  : () => setState(() => _files.remove(file))))
                          .toList(),
                    ),
                  ),
                TextField(
                  controller: _message,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: 5000,
                  enabled: !_busy,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: tr('shipping_support_message_hint'),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    contentPadding:
                        const EdgeInsetsDirectional.fromSTEB(8, 14, 8, 14),
                    prefixIcon: IconButton(
                      tooltip: tr('attachment'),
                      onPressed: _busy ? null : _pickFiles,
                      icon: const Icon(Icons.add_circle_outline_rounded),
                    ),
                    suffixIcon: IconButton.filled(
                      tooltip: tr('send'),
                      onPressed: _busy ? null : _send,
                      icon: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send_rounded),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      );

  Widget _bubble(String body, bool mine) {
    if (body.trim().isEmpty) return const SizedBox.shrink();
    return Align(
      alignment: mine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: mine
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border:
              mine ? null : Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Text(body,
            style: TextStyle(color: mine ? Colors.white : null, height: 1.5)),
      ),
    );
  }

  Future<void> _openAttachment(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
