import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/auction_transaction_model.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/services/auction_transaction_service_interface.dart';
import 'package:sixvalley_vendor_app/helper/api_checker.dart';

class AuctionTransactionController extends ChangeNotifier {
  final AuctionTransactionServiceInterface serviceInterface;
  AuctionTransactionController({required this.serviceInterface});

  AuctionTransactionListModel? _listModel;
  List<AuctionTransactionModel> _transactions = [];
  bool _isLoading = false;

  // Filter state
  List<String> _selectedTransactionTypes = [];
  String _filterDurationType = 'all';
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  bool _isFilterActive = false;

  final DateFormat _dateFormat = DateFormat('d MMM yy');
  DateFormat get dateFormat => _dateFormat;

  List<AuctionTransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  int? get totalSize => _listModel?.totalSize;
  int? get offset => _listModel?.offset;

  List<String> get selectedTransactionTypes => _selectedTransactionTypes;
  String get filterDurationType => _filterDurationType;
  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;
  bool get isFilterActive => _isFilterActive;

  void setFilterDurationType(String type) {
    _filterDurationType = type;
    if (type != 'custom_date') {
      _filterStartDate = null;
      _filterEndDate = null;
    }
    notifyListeners();
  }

  void toggleTransactionType(String type) {
    if (_selectedTransactionTypes.contains(type)) {
      _selectedTransactionTypes = List.from(_selectedTransactionTypes)..remove(type);
    } else {
      _selectedTransactionTypes = List.from(_selectedTransactionTypes)..add(type);
    }
    notifyListeners();
  }

  void selectFilterDate(String which, BuildContext context) {
    final bool isEnd = which == 'end';
    final DateTime firstDate = isEnd && _filterStartDate != null ? _filterStartDate! : DateTime(2000);
    final DateTime initialDate = isEnd && _filterStartDate != null
        ? (_filterEndDate != null && !_filterEndDate!.isBefore(_filterStartDate!) ? _filterEndDate! : _filterStartDate!)
        : (which == 'start' && _filterStartDate != null ? _filterStartDate! : DateTime.now());

    showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    ).then((date) {
      if (date == null) return;
      final day = DateTime(date.year, date.month, date.day);
      if (which == 'start') {
        _filterStartDate = day;
        if (_filterEndDate != null && _filterEndDate!.isBefore(day)) {
          _filterEndDate = null;
        }
      } else {
        _filterEndDate = day;
      }
      notifyListeners();
    });
  }

  void resetFilters({bool notify = true}) {
    _selectedTransactionTypes = [];
    _filterDurationType = 'all';
    _filterStartDate = null;
    _filterEndDate = null;
    _isFilterActive = false;
    if (notify) notifyListeners();
  }

  void _markFilterActive() {
    _isFilterActive = _selectedTransactionTypes.isNotEmpty ||
        _filterDurationType != 'all';
  }

  Future<void> getAuctionTransactionList(
    BuildContext context, {
    bool isRefresh = false,
    int offset = 1,
    int? searchAuctionId,
    List<String>? transactionTypes,
    String? filterDurationType,
    String? startDate,
    String? endDate,
  }) async {
    if (isRefresh) _transactions = [];
    _isLoading = true;
    notifyListeners();

    final ApiResponse response = await serviceInterface.getAuctionTransactionList(
      searchAuctionId: searchAuctionId,
      limit: 10,
      offset: offset,
      transactionTypes: transactionTypes,
      filterDurationType: filterDurationType,
      startDate: startDate,
      endDate: endDate,
    );

    if (response.response != null && response.response!.statusCode == 200) {
      _listModel = AuctionTransactionListModel.fromJson(response.response!.data);
      final List<AuctionTransactionModel> newItems = _listModel?.transactions ?? [];
      if (isRefresh || offset == 1) {
        _transactions = newItems;
      } else {
        _transactions.addAll(newItems);
      }
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Applies the current filter state and refreshes the list.
  Future<void> applyFilters(BuildContext context, {int? searchAuctionId}) async {
    _markFilterActive();
    final String? start = (_filterDurationType == 'custom_date' && _filterStartDate != null)
        ? DateFormat('yyyy-MM-dd').format(_filterStartDate!)
        : null;
    final String? end = (_filterDurationType == 'custom_date' && _filterEndDate != null)
        ? DateFormat('yyyy-MM-dd').format(_filterEndDate!)
        : null;

    await getAuctionTransactionList(
      context,
      isRefresh: true,
      offset: 1,
      searchAuctionId: searchAuctionId,
      transactionTypes: _selectedTransactionTypes.isEmpty ? null : _selectedTransactionTypes,
      filterDurationType: _filterDurationType == 'all' ? null : _filterDurationType,
      startDate: start,
      endDate: end,
    );
  }
}
