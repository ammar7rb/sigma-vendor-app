import 'package:sixvalley_vendor_app/features/seller_package/domain/models/seller_package_overview_model.dart';

class SellerBalanceModel {
  final Map<String, double> summary;
  final List<SellerFinancialRecord> records;
  final List<SellerBalanceDepositRecord> deposits;
  final Map<String, List<SellerFinancialRecord>> financialTabs;
  final Map<String, dynamic> settlements;
  final bool digitalPaymentAvailable;
  final bool offlinePaymentAvailable;
  final List<SellerPaymentGateway> paymentGateways;
  final List<SellerOfflinePaymentMethod> offlinePaymentMethods;
  final Map<String, dynamic> fundingSettings;

  const SellerBalanceModel({
    required this.summary,
    required this.records, required this.financialTabs,
    required this.deposits,
    required this.settlements, required this.digitalPaymentAvailable,
    required this.offlinePaymentAvailable, required this.paymentGateways,
    required this.offlinePaymentMethods, required this.fundingSettings,
  });

  factory SellerBalanceModel.fromJson(Map<String, dynamic> json) {
    final rawSummary = {...(json['summary'] as Map? ?? {}), ...(json['financial_summary'] as Map? ?? {})};
    final rawRecords = (json['financial_records'] as List?) ?? const [];
    final rawDeposits = ((json['deposits'] is Map)
        ? ((json['deposits'] as Map)['data'] as List? ?? const [])
        : (json['deposits'] as List? ?? const []));
    final rawTabs = (json['financial_tabs'] as Map?) ?? const {};
    return SellerBalanceModel(
      summary: rawSummary.map((key, value) => MapEntry(key.toString(), _number(value))),
      records: rawRecords.whereType<Map>().map((item) => SellerFinancialRecord.fromJson(Map<String, dynamic>.from(item))).toList(),
      financialTabs: rawTabs.map((key, value) => MapEntry(key.toString(), (value as List? ?? const []).whereType<Map>().map((item) => SellerFinancialRecord.fromJson(Map<String, dynamic>.from(item))).toList())),
      deposits: rawDeposits.whereType<Map>().map((item) => SellerBalanceDepositRecord.fromJson(Map<String, dynamic>.from(item))).toList(),
      settlements: Map<String, dynamic>.from((json['settlements'] as Map?) ?? const {}),
      digitalPaymentAvailable: _bool(json['digital_payment_available']),
      offlinePaymentAvailable: _bool(json['offline_payment_available']),
      paymentGateways: (json['payment_gateways'] as List? ?? const [])
          .whereType<Map>().map((item) => SellerPaymentGateway.fromJson(Map<String, dynamic>.from(item))).toList(),
      offlinePaymentMethods: (json['offline_payment_methods'] as List? ?? const [])
          .whereType<Map>().map((item) => SellerOfflinePaymentMethod.fromJson(Map<String, dynamic>.from(item))).toList(),
      fundingSettings: Map<String, dynamic>.from((json['funding_settings'] as Map?) ?? const {}),
    );
  }

  static double _number(dynamic value) => double.tryParse(value?.toString() ?? '') ?? 0;
  static bool _bool(dynamic value) => value == true || value == 1 || value?.toString() == '1';
}

class SellerFinancialRecord {
  final String bucket;
  final String direction;
  final double amount;
  final String eventType;
  final String createdAt;
  final String category;
  final String referenceCode;
  final String shipmentReference;
  final String dueAt;
  final double sellerInsuranceAmount;
  final String sellerInsuranceStatus;
  final String sellerInsurancePaidAt;
  final String sellerInsuranceReuseAt;
  final bool shippingResponsible;

  const SellerFinancialRecord({required this.bucket, required this.direction, required this.amount, required this.eventType, required this.createdAt, required this.category, required this.referenceCode, required this.shipmentReference, required this.dueAt, required this.sellerInsuranceAmount, required this.sellerInsuranceStatus, required this.sellerInsurancePaidAt, required this.sellerInsuranceReuseAt, required this.shippingResponsible});

  factory SellerFinancialRecord.fromJson(Map<String, dynamic> json) => SellerFinancialRecord(
    bucket: json['bucket']?.toString() ?? '',
    direction: json['direction']?.toString() ?? '',
    amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0,
    eventType: json['event_type']?.toString() ?? '',
    createdAt: json['created_at']?.toString() ?? '',
    category: json['category']?.toString() ?? json['reporting_category']?.toString() ?? 'balance',
    referenceCode: json['reference_code']?.toString() ?? '',
    shipmentReference: json['shipment_reference']?.toString() ?? '',
    dueAt: json['due_at']?.toString() ?? '',
    sellerInsuranceAmount: double.tryParse(json['seller_insurance_amount']?.toString() ?? '') ?? 0,
    sellerInsuranceStatus: json['seller_insurance_status']?.toString() ?? '',
    sellerInsurancePaidAt: json['seller_insurance_paid_at']?.toString() ?? '',
    sellerInsuranceReuseAt: json['seller_insurance_reuse_at']?.toString() ?? '',
    shippingResponsible: json['shipping_responsible'] == true || json['shipping_responsible']?.toString() == '1',
  );
}

class SellerBalanceDepositRecord {
  final double amount;
  final String status;
  final String source;
  final String createdAt;

  const SellerBalanceDepositRecord({required this.amount, required this.status, required this.source, required this.createdAt});

  factory SellerBalanceDepositRecord.fromJson(Map<String, dynamic> json) => SellerBalanceDepositRecord(
    amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0,
    status: json['status']?.toString() ?? '',
    source: json['source']?.toString() ?? '',
    createdAt: json['created_at']?.toString() ?? '',
  );
}
