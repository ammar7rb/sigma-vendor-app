import 'package:sixvalley_vendor_app/features/order_details/domain/models/order_list_filter_model.dart';

abstract class OrderServiceInterface {
  Future<dynamic> getOrderList(int offset, String status, OrderListFilterModel ? filter);
  Future<dynamic> orderAddressEdit({String? orderID, String? addressType, String? contactPersonName, String? phone, String? city, String? zip,
    String? address, String? email, String? latitude, String? longitude,
  });
}