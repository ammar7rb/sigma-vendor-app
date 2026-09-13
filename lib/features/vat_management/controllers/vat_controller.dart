import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/vat_management/domain/models/vat_report_model.dart';
import 'package:sixvalley_vendor_app/features/vat_management/domain/services/vat_service_interface.dart';
import 'package:sixvalley_vendor_app/helper/api_checker.dart';



class VatController extends ChangeNotifier {
  VatServiceInterface vatServiceInterface;

  VatController({required this.vatServiceInterface});


  VatReportModel?  _vatReportModel;
  VatReportModel? get vatReportModel => _vatReportModel;

  DateTime? _startDate;
  DateTime? get startDate => _startDate;

  DateTime? _endDate;
  DateTime? get endDate => _endDate;


  bool? _isLoading;
  bool? get isLoading => _isLoading;

  bool? _isFilterActive = false;
  bool? get isFilterActive => _isFilterActive;

  final DateFormat _dateFormat = DateFormat('d MMM yy');
  DateFormat get dateFormat => _dateFormat;






  Future<void> getVatReportList(int offset, {String? startDate, String? endDate}) async {
    if(offset <1 ) {
      _isLoading = true;
      notifyListeners();
    }

    ApiResponse apiResponse = await vatServiceInterface.getVatReport(10, 1, startDate, endDate);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _vatReportModel = VatReportModel.fromJson(apiResponse.response?.data);
    } else {
      ApiChecker.checkApi(apiResponse);
    }

    _isLoading = false;
    notifyListeners();
  }


  void selectDate(String type, BuildContext context) async {
    final bool isEnd = type == 'end';
    final DateTime firstDate = isEnd && _startDate != null ? _startDate! : DateTime(1900);
    final DateTime initialDate = isEnd && _startDate != null
        ? (_endDate != null && !_endDate!.isBefore(_startDate!) ? _endDate! : _startDate!)
        : (type == 'start' && _startDate != null ? _startDate! : DateTime.now());

    showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2030),
    ).then((date) async {
      if (date == null) return;

      final combinedDateTime = DateTime(date.year, date.month, date.day);

      if (type == 'start'){
        _startDate = combinedDateTime;
        if (_endDate != null && _endDate!.isBefore(combinedDateTime)) {
          _endDate = null;
        }
      } else {
        _endDate = combinedDateTime;
      }

      notifyListeners();
    });
  }


  void setInitialDateRange() {
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(const Duration(days: 7));
    _isFilterActive = true;
  }

  void resetReviewData({bool isUpdate = true}) {
    _startDate = null;
    _endDate = null;
    _isFilterActive = false;

    if(isUpdate) {
      notifyListeners();
    }
  }

  void setFilterActive(bool value) {
    _isFilterActive = value;
    notifyListeners();
  }


}