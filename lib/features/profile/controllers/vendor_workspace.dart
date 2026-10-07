import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sixvalley_vendor_app/data/datasource/remote/dio/dio_client.dart';
import 'package:sixvalley_vendor_app/di_container.dart' as di;

/// Counts are calculated by the server. Reading an alert does not accept orders.
class VendorWorkspace extends ChangeNotifier {
  VendorWorkspace._();
  static final instance = VendorWorkspace._();
  final Map<String, int> counts = {
    'orders': 0,
    'notifications': 0,
    'messages': 0
  };
  Map<String, dynamic>? inbox;
  Timer? _timer;
  bool _refreshing = false;
  bool get loading => _refreshing;
  int _generation = 0;
  DioClient get client => di.sl<DioClient>();

  void start() {
    refresh();
    _timer ??= Timer.periodic(const Duration(seconds: 30), (_) => refresh());
  }

  void stop() {
    _generation++;
    _refreshing = false;
    _timer?.cancel();
    _timer = null;
    inbox = null;
    counts.updateAll((key, value) => 0);
  }

  Future<void> refresh() async {
    if (_refreshing) return;
    final generation = _generation;
    _refreshing = true;
    try {
      final response = await client.get('/api/v3/seller/inbox');
      if (generation != _generation) return;
      inbox = Map<String, dynamic>.from(response.data as Map);
      final values = Map<String, dynamic>.from(inbox!['counts'] as Map);
      counts.updateAll((key, _) => int.tryParse('${values[key]}') ?? 0);
    } catch (_) {
      // Preserve the last server-confirmed counts during connectivity loss.
    } finally {
      if (generation == _generation) {
        _refreshing = false;
        notifyListeners();
      }
    }
  }

  Future<void> read(Map<String, dynamic> item) async {
    await client.post('/api/v3/seller/inbox/read',
        data: {'kind': item['kind'], 'id': '${item['id']}'});
    await refresh();
  }
}
