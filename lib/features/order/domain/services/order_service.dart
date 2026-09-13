

import 'package:sixvalley_vendor_app/features/order/domain/repositories/order_repository_interface.dart';
import 'package:sixvalley_vendor_app/features/order/domain/services/order_service_interface.dart';
import 'package:sixvalley_vendor_app/features/order_details/domain/models/order_list_filter_model.dart';

class OrderService implements OrderServiceInterface{
  final OrderRepositoryInterface orderRepoInterface;
  OrderService({required this.orderRepoInterface});

  @override
  Future getOrderList(int offset, String status, OrderListFilterModel ? filter) {
    return orderRepoInterface.getOrderList(offset, status, filter);
  }

  @override
  Future orderAddressEdit({String? orderID, String? addressType, String? contactPersonName, String? phone, String? city, String? zip, String? address, String? email, String? latitude, String? longitude}) {
    return orderRepoInterface.orderAddressEdit(orderID: orderID, addressType: addressType, contactPersonName: contactPersonName, phone: phone, city: city,
    zip: zip, address: address, email: email, latitude: latitude, longitude: longitude);
  }


}