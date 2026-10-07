import 'package:sixvalley_vendor_app/features/profile/screens/vendor_withdrawal_methods_screen.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/vendor_workspace.dart';
import 'package:sixvalley_vendor_app/features/profile/screens/vendor_inbox_screen.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/app_design.dart';

class VendorAccountScreen extends StatefulWidget {
  const VendorAccountScreen({super.key});
  @override
  State<VendorAccountScreen> createState() => _VendorAccountScreenState();
}

class _VendorAccountScreenState extends State<VendorAccountScreen> {
  final form = GlobalKey<FormState>();
  final passwordForm = GlobalKey<FormState>();
  final fields = <String, TextEditingController>{};
  final phones = <TextEditingController>[];
  final addresses = <TextEditingController>[];
  final uploads = <String, XFile>{};
  Map<String, dynamic>? data;
  bool busy = false;
  String? error;
  String text(String key) => getTranslated(key, context) ?? key;
  @override
  void initState() {
    super.initState();
    for (final key in [
      'f_name',
      'l_name',
      'store_name',
      'email',
      'commercial_registration',
      'tax_card',
      'current_password',
      'password',
      'password_confirmation'
    ]) {
      fields[key] = TextEditingController();
    }
    load();
  }

  @override
  void dispose() {
    for (final c in [...fields.values, ...phones, ...addresses]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> load() async {
    try {
      final response =
          await VendorWorkspace.instance.client.get('/api/v3/seller/account');
      if (!mounted) return;
      final result = Map<String, dynamic>.from(response.data as Map);
      for (final key in fields.keys.where((k) => !k.contains('password'))) {
        fields[key]!.text = '${result[key] ?? ''}';
      }
      for (final c in [...phones, ...addresses]) {
        c.dispose();
      }
      phones.clear();
      addresses.clear();
      phones.addAll((result['phone_numbers'] as List)
          .map((v) => TextEditingController(text: '$v')));
      addresses.addAll((result['store_addresses'] as List)
          .map((v) => TextEditingController(text: '$v')));
      if (addresses.isEmpty) addresses.add(TextEditingController());
      setState(() {
        data = result;
        error = null;
      });
    } catch (_) {
      if (mounted) setState(() => error = text('vendor_save_error'));
    }
  }

  Future<void> pick(String key) async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null || !mounted) return;
    if (await file.length() > 5 * 1024 * 1024) {
      if (mounted) setState(() => error = text('vendor_document_limit'));
      return;
    }
    if (mounted) setState(() => uploads[key] = file);
  }

  Future<void> save({bool password = false}) async {
    if (!(password ? passwordForm : form).currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final client = VendorWorkspace.instance.client;
      if (password) {
        await client.post('/api/v3/seller/account/password', data: {
          for (final k in [
            'current_password',
            'password',
            'password_confirmation'
          ])
            k: fields[k]!.text
        });
        for (final k in [
          'current_password',
          'password',
          'password_confirmation'
        ]) {
          fields[k]!.clear();
        }
      } else {
        final payload = <String, dynamic>{
          for (final k in fields.keys.where((k) => !k.contains('password')))
            k: fields[k]!.text.trim(),
          'phone_numbers':
              jsonEncode(phones.map((c) => c.text.trim()).toList()),
          'store_addresses':
              jsonEncode(addresses.map((c) => c.text.trim()).toList()),
        };
        for (final entry in uploads.entries) {
          payload[entry.key] = MultipartFile.fromBytes(
              await entry.value.readAsBytes(),
              filename: entry.value.name);
        }
        await client.post('/api/v3/seller/account',
            data: FormData.fromMap(payload),
            options: Options(contentType: 'multipart/form-data'));
        uploads.clear();
        if (mounted) await context.read<ProfileController>().getSellerInfo();
        await load();
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(text('vendor_saved'))));
      }
    } on DioException catch (e) {
      final response = e.response?.data;
      final errors = response is Map ? response['errors'] : null;
      if (mounted) {
        setState(() => error = errors is Map
            ? errors.values.expand((v) => v is List ? v : [v]).join('\n')
            : text('vendor_save_error'));
      }
    } catch (_) {
      if (mounted) setState(() => error = text('vendor_save_error'));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> document(String kind) async {
    try {
      final response = await VendorWorkspace.instance.client.get(
          '/api/v3/seller/account/document/$kind',
          options: Options(responseType: ResponseType.bytes));
      if (mounted) {
        showDialog(
            context: context,
            builder: (_) => Dialog(
                child: InteractiveViewer(
                    child: Image.memory(Uint8List.fromList(
                        (response.data as List).cast<int>())))));
      }
    } catch (_) {
      if (mounted) setState(() => error = text('vendor_save_error'));
    }
  }

  Widget input(String key, String label,
          {bool secret = false, bool required = true}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
              controller: fields[key],
              obscureText: secret,
              enabled: !busy,
              maxLines: secret ? 1 : (required ? 1 : 3),
              keyboardType: key == 'email'
                  ? TextInputType.emailAddress
                  : TextInputType.text,
              decoration: InputDecoration(labelText: text(label)),
              validator: (v) => required && (v?.trim().isEmpty ?? true)
                  ? text('required_field')
                  : key == 'password_confirmation' &&
                          v != fields['password']!.text
                      ? text('password_mismatch')
                      : null));
  Widget repeated(List<TextEditingController> list, String label) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(text(label), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(text('vendor_primary_contact_hint')),
        for (var i = 0; i < list.length; i++)
          Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(children: [
                Expanded(
                    child: TextFormField(
                        controller: list[i],
                        enabled: !busy,
                        keyboardType: label == 'vendor_phone_numbers'
                            ? TextInputType.phone
                            : TextInputType.streetAddress,
                        decoration: InputDecoration(
                            labelText: '${text(label)} ${i + 1}'),
                        validator: (v) => v?.trim().isNotEmpty == true
                            ? null
                            : text('required_field'))),
                IconButton(
                    tooltip: text('delete'),
                    onPressed: busy || list.length == 1
                        ? null
                        : () => setState(() {
                              list.removeAt(i).dispose();
                            }),
                    icon: const Icon(Icons.delete_outline)),
              ])),
        TextButton.icon(
            onPressed: busy || list.length >= 10
                ? null
                : () => setState(() => list.add(TextEditingController())),
            icon: const Icon(Icons.add),
            label: Text(text('add'))),
        const SizedBox(height: 20),
      ]);
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: CustomAppBarWidget(title: text('vendor_account')),
      body: data == null
          ? Center(
              child: error == null
                  ? const CircularProgressIndicator()
                  : FilledButton(onPressed: load, child: Text(text('retry'))))
          : ListView(padding: AppDesign.pagePadding, children: [
              if (error != null)
                Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(error!,
                        style: const TextStyle(color: AppDesign.danger))),
              Wrap(spacing: 12, children: [
                TextButton.icon(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const VendorInboxScreen(messages: true))),
                    icon: const Icon(Icons.mail_outline),
                    label: Text(text('administration_messages'))),
                TextButton.icon(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const VendorInboxScreen())),
                    icon: const Icon(Icons.notifications_outlined),
                    label: Text(text('notification'))),
              ]),
              TextButton.icon(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const VendorWithdrawalMethodsScreen())),
                  icon: const Icon(Icons.account_balance_outlined),
                  label: Text(text('manage_withdrawal_methods'))),
              Form(
                  key: form,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(children: [
                          if (data!['image'] is Map &&
                              data!['image']['path'] != null)
                            ClipOval(
                                child: Image.network(
                                    '${data!['image']['path']}',
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) =>
                                        const Icon(Icons.person_outline,
                                            size: 64))),
                          Expanded(
                              child: TextButton.icon(
                                  onPressed: busy ? null : () => pick('image'),
                                  icon: const Icon(Icons.add_a_photo_outlined),
                                  label: Text(uploads['image']?.name ??
                                      text('profile_picture'))))
                        ]),
                        const SizedBox(height: 20),
                        TextFormField(
                            initialValue: '${data!['account_id']}',
                            readOnly: true,
                            decoration: InputDecoration(
                                labelText: text('vendor_account_id'))),
                        const SizedBox(height: 16),
                        input('f_name', 'first_name'),
                        input('l_name', 'last_name'),
                        input('store_name', 'store_name'),
                        input('email', 'email'),
                        LayoutBuilder(
                            builder: (context, constraints) =>
                                Wrap(spacing: 16, runSpacing: 16, children: [
                                  SizedBox(
                                      width: constraints.maxWidth >= 700
                                          ? (constraints.maxWidth - 16) / 2
                                          : constraints.maxWidth,
                                      child: Card(
                                          child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: repeated(phones,
                                                  'vendor_phone_numbers')))),
                                  SizedBox(
                                      width: constraints.maxWidth >= 700
                                          ? (constraints.maxWidth - 16) / 2
                                          : constraints.maxWidth,
                                      child: Card(
                                          child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: repeated(addresses,
                                                  'vendor_store_addresses'))))
                                ])),
                        for (final entry in {
                          'commercial': 'commercial_registration',
                          'tax': 'tax_card'
                        }.entries) ...[
                          input(entry.value, entry.value, required: false),
                          OutlinedButton.icon(
                              onPressed: busy
                                  ? null
                                  : () => pick('${entry.key}_document'),
                              icon: const Icon(Icons.upload_file_outlined),
                              label: Text(
                                  uploads['${entry.key}_document']?.name ??
                                      text('vendor_document_upload'))),
                          Text(text('vendor_document_limit'),
                              style: Theme.of(context).textTheme.bodySmall),
                          if (data!['${entry.key}_document_uploaded'] == true)
                            TextButton(
                                onPressed: () => document(entry.key),
                                child: Text(text('view_uploaded_document'))),
                          const SizedBox(height: 24),
                        ],
                        FilledButton(
                            onPressed: busy ? null : save,
                            child: Text(text(busy ? 'loading' : 'save'))),
                      ])),
              const SizedBox(height: 24),
              ExpansionTile(title: Text(text('change_password')), children: [
                Form(
                    key: passwordForm,
                    child: Column(children: [
                      input('current_password', 'current_password',
                          secret: true),
                      input('password', 'new_password', secret: true),
                      input('password_confirmation', 'confirm_password',
                          secret: true),
                      Text(text('vendor_password_hint')),
                      const SizedBox(height: 16),
                      FilledButton(
                          onPressed: busy ? null : () => save(password: true),
                          child: Text(text('change_password')))
                    ])),
              ]),
              const SizedBox(height: 24),
            ]));
}
