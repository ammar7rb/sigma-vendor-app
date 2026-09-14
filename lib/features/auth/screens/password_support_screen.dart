import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';
import 'package:sixvalley_vendor_app/helper/egypt_phone_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class PasswordSupportScreen extends StatefulWidget {
  const PasswordSupportScreen({super.key});
  @override
  State<PasswordSupportScreen> createState() => _PasswordSupportScreenState();
}

class _PasswordSupportScreenState extends State<PasswordSupportScreen> {
  static const _storage = FlutterSecureStorage();
  static const _storageKey = 'seller_password_support_token';
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _email = TextEditingController(),
      _phone = TextEditingController(),
      _message = TextEditingController();
  // No request/response logger: replies may contain an admin-issued password.
  final _api = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      headers: {'Accept': 'application/json'},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30)));
  Timer? _timer;
  Map<String, dynamic>? _ticket;
  String? _token, _error;
  bool _loading = true, _busy = false, _fetching = false;
  final List<PlatformFile> _files = [];
  String tr(String key) => getTranslated(key, context) ?? key;
  String get _url => '/api/v3/seller/auth/support-conversation';

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    try {
      _token = await _storage.read(key: _storageKey);
      if (_token != null) await _load();
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (_ticket != null) _load();
      });
    } catch (_) {
      if (mounted) setState(() => _error = tr('support_connection_retry'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Options get _options => Options(headers: {'X-Support-Token': _token});
  Future<void> _load() async {
    if (_fetching || !mounted || _token == null) return;
    _fetching = true;
    try {
      final response = await _api.get(_url, options: _options);
      if (mounted) {
        setState(() {
          _ticket = Map<String, dynamic>.from(response.data);
          _error = null;
        });
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        await _storage.delete(key: _storageKey);
        _token = null;
        if (mounted) {
          setState(() {
            _ticket = null;
            _error = tr('support_ticket_closed_start_new');
          });
        }
      } else if (mounted) {
        setState(() => _error = tr('support_connection_retry'));
      }
    } finally {
      _fetching = false;
    }
  }

  Future<void> _send() async {
    if (_busy || !(_form.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_token == null) {
        final random = Random.secure();
        final newToken = List.generate(32,
                (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'))
            .join();
        await _storage.write(key: _storageKey, value: newToken);
        _token = newToken;
      }
      final formData = FormData.fromMap({
        if (_ticket == null) ...{
          'name': _name.text.trim(),
          'email': _email.text.trim(),
          'mobile_number': EgyptPhoneHelper.toInternational(_phone.text)
        },
        'message': _ticket == null
            ? tr('password_reset_auto_message')
            : _message.text.trim(),
        for (int i = 0; i < _files.length; i++)
          'attachments[$i]': await MultipartFile.fromFile(_files[i].path!,
              filename: _files[i].name),
      });
      final response = await _api.post(
          _ticket == null ? _url : '$_url/messages',
          options: _options,
          data: formData);
      if (!mounted) return;
      setState(() {
        _ticket = Map<String, dynamic>.from(response.data);
        _message.clear();
        _files.clear();
      });
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
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(tr('password_reset_support_title'))),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Form(
                    key: _form,
                    child: Column(children: [
                      if (_error != null)
                        MaterialBanner(content: Text(_error!), actions: [
                          TextButton(onPressed: _load, child: Text(tr('retry')))
                        ]),
                      Expanded(
                          child: ListView(
                              padding: const EdgeInsets.all(20),
                              children: [
                            Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                    color: AppDesign.primary
                                        .withValues(alpha: .09),
                                    borderRadius: BorderRadius.circular(18)),
                                child: Row(children: [
                                  Icon(Icons.verified_user_outlined,
                                      color: Theme.of(context).primaryColor),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: Text(
                                          tr('password_reset_support_identity_notice'),
                                          style: const TextStyle(height: 1.6)))
                                ])),
                            const SizedBox(height: 16),
                            if (_ticket == null) ...[
                              _field(_name, 'name', max: 100),
                              _field(_email, 'email',
                                  type: TextInputType.emailAddress, max: 255),
                              _field(_phone, 'phone',
                                  type: TextInputType.phone, max: 30),
                            ] else ...[
                              Text('${tr('support_ticket')} #${_ticket!['id']}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              _bubble('${_ticket!['initial_message']}', true),
                              for (final message
                                  in _ticket!['messages'] as List? ?? [])
                                Column(children: [
                                  _bubble('${message['body']}',
                                      message['sender'] == 'requester'),
                                  if ((message['attachments'] as List? ??
                                          const [])
                                      .isNotEmpty)
                                    Align(
                                        alignment: message['sender'] ==
                                                'requester'
                                            ? AlignmentDirectional.centerEnd
                                            : AlignmentDirectional.centerStart,
                                        child: Wrap(children: [
                                          for (final attachment
                                              in message['attachments'])
                                            TextButton.icon(
                                                onPressed: () =>
                                                    _openAttachment(
                                                        '${attachment['url']}'),
                                                icon: const Icon(
                                                    Icons.attach_file_rounded),
                                                label: Text(
                                                    '${attachment['name']}'))
                                        ])),
                                ]),
                            ],
                          ])),
                      Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                          decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              border: Border(
                                  top: BorderSide(
                                      color: Theme.of(context).dividerColor))),
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
                                                  : () => setState(() =>
                                                      _files.remove(file))))
                                          .toList())),
                            if (_ticket == null)
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: FilledButton.icon(
                                  onPressed: _busy ? null : _send,
                                  icon: _busy
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white))
                                      : const Icon(Icons.support_agent_rounded),
                                  label: Text(tr('send_to_password_support')),
                                ),
                              )
                            else
                              TextFormField(
                                  controller: _message,
                                  enabled: !_busy,
                                  minLines: 1,
                                  maxLines: 4,
                                  maxLength: 5000,
                                  decoration: InputDecoration(
                                      counterText: '',
                                      filled: true,
                                      fillColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      hintText: tr('write_activation_message'),
                                      prefixIcon: IconButton(
                                          onPressed: _busy ? null : _pickFiles,
                                          icon: const Icon(Icons
                                              .add_circle_outline_rounded)),
                                      suffixIcon: IconButton.filled(
                                          tooltip: tr('send'),
                                          onPressed: _busy ? null : _send,
                                          icon: _busy
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white))
                                              : const Icon(Icons.send_rounded)),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          borderSide: BorderSide.none)),
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty
                                          ? tr('required')
                                          : null),
                          ])),
                    ]))),
      );
  Widget _field(TextEditingController controller, String label,
          {TextInputType? type, required int max}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
              controller: controller,
              enabled: !_busy,
              keyboardType: type,
              maxLength: max,
              decoration: InputDecoration(
                  labelText: tr(label),
                  counterText: '',
                  border: const OutlineInputBorder()),
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return tr('required');
                if (label == 'email' &&
                    !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                  return tr('invalid_email');
                }
                if (label == 'phone' && !EgyptPhoneHelper.isValidLocal(value)) {
                  return tr('enter_valid_egyptian_mobile');
                }
                return null;
              }));
  Widget _bubble(String body, bool mine) => Align(
      alignment: mine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Card(
          color: mine
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).cardColor,
          child: Padding(
              padding: const EdgeInsets.all(14),
              child: SelectableText(body,
                  style: TextStyle(
                      color: mine
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurface)))));

  Future<void> _openAttachment(String value) async {
    final uri = Uri.tryParse(value);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
