class EditOrderValidationModel {
  final String status;
  final String message;
  final OrderData orderData;
  final double orderAmount;
  final double editDueAmount;
  final double orderReturnAmount;
  final TaxSummary taxSummary;

  EditOrderValidationModel({
    required this.status,
    required this.message,
    required this.orderData,
    required this.orderAmount,
    required this.editDueAmount,
    required this.orderReturnAmount,
    required this.taxSummary,
  });

  factory EditOrderValidationModel.fromJson(Map<String, dynamic> json) {
    return EditOrderValidationModel(
      status: json['status'],
      message: json['message'],
      orderData: OrderData.fromJson(json['order_data']),
      orderAmount: (json['order_amount'] ?? 0).toDouble(),
      editDueAmount: (json['edit_due_amount'] ?? 0).toDouble(),
      orderReturnAmount: (json['order_return_amount'] ?? 0).toDouble(),
      taxSummary: TaxSummary.fromJson(json['tax_summary']),
    );
  }
}

// ---------------- ORDER DATA ----------------

class OrderData {
  final double editDueAmount;
  final double editReturnAmount;
  final double totalTaxAmount;
  final double shippingCost;
  final double extraDiscount;
  final String? extraDiscountType;
  final String? freeDeliveryBearer;
  final int isShippingFree;
  final int editedStatus;
  final String updatedAt;
  final double orderAmount;

  OrderData({
    required this.editDueAmount,
    required this.editReturnAmount,
    required this.totalTaxAmount,
    required this.shippingCost,
    required this.extraDiscount,
    this.extraDiscountType,
    this.freeDeliveryBearer,
    required this.isShippingFree,
    required this.editedStatus,
    required this.updatedAt,
    required this.orderAmount,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      editDueAmount: (json['edit_due_amount'] ?? 0).toDouble(),
      editReturnAmount: (json['edit_return_amount'] ?? 0).toDouble(),
      totalTaxAmount: (json['total_tax_amount'] ?? 0).toDouble(),
      shippingCost: (json['shipping_cost'] ?? 0).toDouble(),
      extraDiscount: (json['extra_discount'] ?? 0).toDouble(),
      extraDiscountType: json['extra_discount_type'],
      freeDeliveryBearer: json['free_delivery_bearer'],
      isShippingFree: json['is_shipping_free'] ?? 0,
      editedStatus: json['edited_status'] ?? 0,
      updatedAt: json['updated_at'],
      orderAmount: (json['order_amount'] ?? 0).toDouble(),
    );
  }
}

// ---------------- TAX SUMMARY ----------------

class TaxSummary {
  final String editBy;
  final int editedUserId;
  final double shippingCost;
  final double orderAmount;
  final bool isShippingFree;
  final double couponDiscount;
  final double referAndEarnDiscount;
  final double freeDeliveryDiscount;
  final List<AppliedTaxCart> appliedTaxCartList;
  final double totalTaxAmount;
  final double orderAmountWithTax;

  TaxSummary({
    required this.editBy,
    required this.editedUserId,
    required this.shippingCost,
    required this.orderAmount,
    required this.isShippingFree,
    required this.couponDiscount,
    required this.referAndEarnDiscount,
    required this.freeDeliveryDiscount,
    required this.appliedTaxCartList,
    required this.totalTaxAmount,
    required this.orderAmountWithTax,
  });

  factory TaxSummary.fromJson(Map<String, dynamic> json) {
    return TaxSummary(
      editBy: json['edit_by'],
      editedUserId: json['edited_user_id'],
      shippingCost: (json['shipping_cost'] ?? 0).toDouble(),
      orderAmount: (json['order_amount'] ?? 0).toDouble(),
      isShippingFree: json['is_shipping_free'] ?? false,
      couponDiscount: (json['coupon_discount'] ?? 0).toDouble(),
      referAndEarnDiscount:
      (json['refer_and_earn_discount'] ?? 0).toDouble(),
      freeDeliveryDiscount:
      (json['free_delivery_discount'] ?? 0).toDouble(),
      appliedTaxCartList: (json['applied_tax_cart_list'] as List)
          .map((e) => AppliedTaxCart.fromJson(e))
          .toList(),
      totalTaxAmount: (json['total_tax_amount'] ?? 0).toDouble(),
      orderAmountWithTax:
      (json['order_amount_with_tax'] ?? 0).toDouble(),
    );
  }
}

// ---------------- APPLIED TAX CART ----------------

class AppliedTaxCart {
  final int productId;
  final String variant;
  final int quantity;
  final double price;
  final double discount;
  final int sellerId;
  final String sellerIs;
  final double discountedPrice;
  final double totalDiscountedPrice;
  final double appliedDiscountedAmount;
  final double appliedTaxAmount;
  final double appliedShippingCostTax;
  final Map<String, TaxInfo> appliedTaxIds;
  final List<ShippingCostTax> appliedShippingCostTaxIds;

  AppliedTaxCart({
    required this.productId,
    required this.variant,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.sellerId,
    required this.sellerIs,
    required this.discountedPrice,
    required this.totalDiscountedPrice,
    required this.appliedDiscountedAmount,
    required this.appliedTaxAmount,
    required this.appliedShippingCostTax,
    required this.appliedTaxIds,
    required this.appliedShippingCostTaxIds,
  });

  factory AppliedTaxCart.fromJson(Map<String, dynamic> json) {
    final taxIds = <String, TaxInfo>{};
    if (json['applied_tax_ids'] != null) {
      json['applied_tax_ids'].forEach((key, value) {
        taxIds[key] = TaxInfo.fromJson(value);
      });
    }

    return AppliedTaxCart(
      productId: json['product_id'],
      variant: json['variant'],
      quantity: json['quantity'],
      price: (json['price'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      sellerId: json['seller_id'],
      sellerIs: json['seller_is'],
      discountedPrice: (json['discounted_price'] ?? 0).toDouble(),
      totalDiscountedPrice:
      (json['total_discounted_price'] ?? 0).toDouble(),
      appliedDiscountedAmount:
      (json['applied_discounted_amount'] ?? 0).toDouble(),
      appliedTaxAmount: (json['applied_tax_amount'] ?? 0).toDouble(),
      appliedShippingCostTax:
      (json['applied_shipping_cost_tax'] ?? 0).toDouble(),
      appliedTaxIds: taxIds,
      appliedShippingCostTaxIds:
      (json['applied_shipping_cost_tax_ids'] as List)
          .map((e) => ShippingCostTax.fromJson(e))
          .toList(),
    );
  }
}

// ---------------- TAX INFO ----------------

class TaxInfo {
  final int id;
  final String name;
  final double taxRate;
  final String? countryCode;
  final int isDefault;
  final int isActive;
  final String? createdAt;
  final String? updatedAt;

  TaxInfo({
    required this.id,
    required this.name,
    required this.taxRate,
    this.countryCode,
    required this.isDefault,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory TaxInfo.fromJson(Map<String, dynamic> json) {
    return TaxInfo(
      id: json['id'],
      name: json['name'],
      taxRate: (json['tax_rate'] ?? 0).toDouble(),
      countryCode: json['country_code'],
      isDefault: json['is_default'],
      isActive: json['is_active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

// ---------------- SHIPPING COST TAX ----------------

class ShippingCostTax {
  final int id;
  final String name;
  final int systemTaxSetupId;
  final List<int> taxIds;
  final int isActive;
  final String createdAt;
  final String updatedAt;

  ShippingCostTax({
    required this.id,
    required this.name,
    required this.systemTaxSetupId,
    required this.taxIds,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShippingCostTax.fromJson(Map<String, dynamic> json) {
    return ShippingCostTax(
      id: json['id'],
      name: json['name'],
      systemTaxSetupId: json['system_tax_setup_id'],
      taxIds: List<int>.from(json['tax_ids']),
      isActive: json['is_active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
