class SellerStockViolation {
  final int id;
  final String alertType;
  final String decision;
  final String reason;
  final String? policyReference;
  final double? penaltyAmount;
  final String? decidedAt;
  final SellerStockViolationProduct? product;

  const SellerStockViolation({
    required this.id,
    required this.alertType,
    required this.decision,
    required this.reason,
    this.policyReference,
    this.penaltyAmount,
    this.decidedAt,
    this.product,
  });

  factory SellerStockViolation.fromJson(Map<String, dynamic> json) => SellerStockViolation(
    id: int.tryParse(json['id'].toString()) ?? 0,
    alertType: json['alert_type']?.toString() ?? 'low_stock',
    decision: json['decision']?.toString() ?? 'warning',
    reason: json['reason']?.toString() ?? '',
    policyReference: json['policy_reference']?.toString(),
    penaltyAmount: double.tryParse(json['penalty_amount']?.toString() ?? ''),
    decidedAt: json['decided_at']?.toString(),
    product: json['product'] is Map<String, dynamic>
      ? SellerStockViolationProduct.fromJson(json['product'] as Map<String, dynamic>)
      : null,
  );
}

class SellerStockViolationProduct {
  final int id;
  final String name;
  final String? code;

  const SellerStockViolationProduct({required this.id, required this.name, this.code});

  factory SellerStockViolationProduct.fromJson(Map<String, dynamic> json) => SellerStockViolationProduct(
    id: int.tryParse(json['id'].toString()) ?? 0,
    name: json['name']?.toString() ?? '',
    code: json['code']?.toString(),
  );
}
