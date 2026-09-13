class SellerOrderInsuranceEnvelope {
  final bool enabled;
  final SellerOrderInsuranceModel? insurance;
  final SellerOrderInsurancePaymentOptions paymentOptions;

  SellerOrderInsuranceEnvelope(
      {required this.enabled, this.insurance, required this.paymentOptions});

  factory SellerOrderInsuranceEnvelope.fromJson(Map<String, dynamic> json) =>
      SellerOrderInsuranceEnvelope(
        enabled: json['enabled'] == true,
        insurance: json['seller_order_insurance'] is Map<String, dynamic>
            ? SellerOrderInsuranceModel.fromJson(json['seller_order_insurance'])
            : null,
        paymentOptions: SellerOrderInsurancePaymentOptions.fromJson(
          json['payment_options'] is Map<String, dynamic>
              ? json['payment_options']
              : const {},
        ),
      );
}

class SellerOrderInsuranceModel {
  final int id;
  final int orderId;
  final String orderReference;
  final double orderAmount;
  final double amount;
  final String calculationType;
  final double calculationValue;
  final String status;
  final String paymentStatus;
  final String? paymentMethod;
  final int pendingDays;
  final int reuseAfterDays;
  final String? expiresAt;
  final String? reusableAt;
  final bool canViewOrderDetails;
  final bool detailsHidden;
  final String? adminNote;
  final double operatingBalance;
  final double reusableInsuranceCredit;

  SellerOrderInsuranceModel({
    required this.id,
    required this.orderId,
    required this.orderReference,
    required this.orderAmount,
    required this.amount,
    required this.calculationType,
    required this.calculationValue,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod,
    required this.pendingDays,
    required this.reuseAfterDays,
    this.expiresAt,
    this.reusableAt,
    required this.canViewOrderDetails,
    required this.detailsHidden,
    this.adminNote,
    required this.operatingBalance,
    required this.reusableInsuranceCredit,
  });

  factory SellerOrderInsuranceModel.fromJson(Map<String, dynamic> json) {
    final balances = json['balances'] is Map<String, dynamic>
        ? json['balances'] as Map<String, dynamic>
        : <String, dynamic>{};
    return SellerOrderInsuranceModel(
      id: int.tryParse('${json['id']}') ?? 0,
      orderId: int.tryParse('${json['order_id']}') ?? 0,
      orderReference: '${json['order_reference'] ?? 'ORD-${json['order_id']}'}',
      orderAmount: double.tryParse('${json['order_amount'] ?? 0}') ?? 0,
      amount: double.tryParse('${json['amount'] ?? 0}') ?? 0,
      calculationType: '${json['calculation_type'] ?? 'percentage'}',
      calculationValue:
          double.tryParse('${json['calculation_value'] ?? 0}') ?? 0,
      status: '${json['status'] ?? 'pending_payment'}',
      paymentStatus: '${json['payment_status'] ?? 'unpaid'}',
      paymentMethod: json['payment_method']?.toString(),
      pendingDays: int.tryParse('${json['pending_days'] ?? 0}') ?? 0,
      reuseAfterDays: int.tryParse('${json['reuse_after_days'] ?? 0}') ?? 0,
      expiresAt: json['expires_at']?.toString(),
      reusableAt: json['reusable_at']?.toString(),
      canViewOrderDetails: json['can_view_order_details'] == true,
      detailsHidden: json['details_hidden'] == true,
      adminNote: json['admin_note']?.toString(),
      operatingBalance: double.tryParse('${balances['operating'] ?? 0}') ?? 0,
      reusableInsuranceCredit:
          double.tryParse('${balances['reusable_insurance_credit'] ?? 0}') ?? 0,
    );
  }
}

class SellerOrderInsurancePaymentOptions {
  final bool operatingBalance;
  final bool reusableInsuranceCredit;
  final bool digitalPayment;
  final bool offlinePayment;
  final List<InsurancePaymentMethod> digitalGateways;
  final List<InsurancePaymentMethod> offlineMethods;

  SellerOrderInsurancePaymentOptions({
    required this.operatingBalance,
    required this.reusableInsuranceCredit,
    required this.digitalPayment,
    required this.offlinePayment,
    required this.digitalGateways,
    required this.offlineMethods,
  });

  factory SellerOrderInsurancePaymentOptions.fromJson(
          Map<String, dynamic> json) =>
      SellerOrderInsurancePaymentOptions(
        operatingBalance: json['operating_balance'] == true,
        reusableInsuranceCredit: json['reusable_insurance_credit'] == true,
        digitalPayment: json['digital_payment'] == true,
        offlinePayment: json['offline_payment'] == true,
        digitalGateways: (json['digital_gateways'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => InsurancePaymentMethod.fromJson(
                Map<String, dynamic>.from(e),
                digital: true))
            .toList(),
        offlineMethods: (json['offline_methods'] as List? ?? const [])
            .whereType<Map>()
            .map((e) =>
                InsurancePaymentMethod.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class InsurancePaymentMethod {
  final String id;
  final String title;
  final List<Map<String, dynamic>> fields;
  InsurancePaymentMethod(
      {required this.id, required this.title, this.fields = const []});
  factory InsurancePaymentMethod.fromJson(Map<String, dynamic> json,
          {bool digital = false}) =>
      InsurancePaymentMethod(
        id: '${digital ? json['key'] : json['id']}',
        title: '${digital ? json['title'] : json['method_name']}',
        fields: (json['method_fields'] as List? ?? [])
            .whereType<Map>()
            .map((f) => Map<String, dynamic>.from(f))
            .toList(),
      );
}
