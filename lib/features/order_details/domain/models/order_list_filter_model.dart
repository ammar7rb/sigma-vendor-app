import 'dart:convert';

class OrderListFilterModel {
  String? filterDateType;
  String? startDate;
  String? endDate;
  int? onlyPosOrder;
  int? onlyWebsiteOrders;
  int? hasReturnAmount;
  int? hasDueAmount;
  List<String> orderStatus;
  int? paymentStatusPaid;
  int? paymentStatusUnpaid;
  String? selectedCustomerId;

  OrderListFilterModel({
    this.filterDateType = 'all_time',
    this.startDate,
    this.endDate,
    this.onlyPosOrder,
    this.onlyWebsiteOrders,
    this.hasReturnAmount,
    this.hasDueAmount,
    List<String>? orderStatus,
    this.paymentStatusPaid,
    this.paymentStatusUnpaid,
    this.selectedCustomerId,
  }) : orderStatus = orderStatus ?? [];

  factory OrderListFilterModel.fromJson(Map<String, dynamic> json) {
    return OrderListFilterModel(
      filterDateType: json['filter_type'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      onlyPosOrder: json['only_pos_order'],
      onlyWebsiteOrders: json['only_website_orders'],
      hasReturnAmount: json['has_return_amount'],
      hasDueAmount: json['has_due_amount'],
      orderStatus: json['order_status'] != null
          ? List<String>.from(json['order_status'])
          : [],
      paymentStatusPaid: json['payment_status_paid'],
      paymentStatusUnpaid: json['payment_status_unpaid'],
      selectedCustomerId: json['selected_customer_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filter_type': filterDateType,
      'start_date': startDate,
      'end_date': endDate,
      'only_pos_order': onlyPosOrder,
      'only_website_orders': onlyWebsiteOrders,
      'has_return_amount': hasReturnAmount,
      'has_due_amount': hasDueAmount,
      'order_status': orderStatus,
      'payment_status_paid': paymentStatusPaid,
      'payment_status_unpaid': paymentStatusUnpaid,
      'selected_customer_id': selectedCustomerId,
    };
  }

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {};

    if (filterDateType != null) {
      params['date_type'] = filterDateType!;
    }

    if (startDate != null) params['start_date'] = startDate!;
    if (endDate != null) params['end_date'] = endDate!;

    final List<String> orderTypes = [];
    if (onlyPosOrder == 1) orderTypes.add('POS');
    if (onlyWebsiteOrders == 1) orderTypes.add('default_type');
    if (orderTypes.isNotEmpty) params['order_types'] = jsonEncode(orderTypes);

    final List<String> settlements = [];
    if (hasReturnAmount == 1) settlements.add('return');
    if (hasDueAmount == 1) settlements.add('due');
    if (settlements.isNotEmpty)
      params['order_amount_settlement'] = jsonEncode(settlements);

    if (orderStatus.isNotEmpty) params['order_status'] = orderStatus;

    final List<String> paymentStatuses = [];
    if (paymentStatusPaid == 1) paymentStatuses.add('paid');
    if (paymentStatusUnpaid == 1) paymentStatuses.add('unpaid');
    if (paymentStatuses.isNotEmpty)
      params['payment_status'] = jsonEncode(paymentStatuses);

    if (selectedCustomerId != null)
      params['customer_id'] = selectedCustomerId.toString();

    return params;
  }

  OrderListFilterModel copyWith({
    String? filterDateType,
    String? startDate,
    String? endDate,
    int? onlyPosOrder,
    int? onlyWebsiteOrders,
    int? hasReturnAmount,
    int? hasDueAmount,
    List<String>? orderStatus,
    int? paymentStatusPaid,
    int? paymentStatusUnpaid,
    String? selectedCustomerId,
  }) {
    return OrderListFilterModel(
      filterDateType: filterDateType ?? this.filterDateType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      onlyPosOrder: onlyPosOrder ?? this.onlyPosOrder,
      onlyWebsiteOrders: onlyWebsiteOrders ?? this.onlyWebsiteOrders,
      hasReturnAmount: hasReturnAmount ?? this.hasReturnAmount,
      hasDueAmount: hasDueAmount ?? this.hasDueAmount,
      orderStatus: orderStatus ?? List<String>.from(this.orderStatus),
      paymentStatusPaid: paymentStatusPaid ?? this.paymentStatusPaid,
      paymentStatusUnpaid: paymentStatusUnpaid ?? this.paymentStatusUnpaid,
      selectedCustomerId: selectedCustomerId ?? this.selectedCustomerId,
    );
  }
}
