import 'package:sixvalley_vendor_app/features/order_details/domain/models/order_list_filter_model.dart';

class ValidationHelper {


static  bool canOrderFilter(OrderListFilterModel filter) {
    if (filter.filterDateType != null) {
      return true;
    }

    if (filter.onlyPosOrder == 1 || filter.onlyWebsiteOrders == 1) {
      return true;
    }

    if (filter.hasReturnAmount == 1 || filter.hasDueAmount == 1) {
      return true;
    }

    if (filter.orderStatus.isNotEmpty) {
      return true;
    }

    if (filter.paymentStatusPaid == 1 || filter.paymentStatusUnpaid == 1) {
      return true;
    }

    if (filter.selectedCustomerId != null) {
      return true;
    }

    return false;
  }




}