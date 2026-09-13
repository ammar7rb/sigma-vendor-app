import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/order_details/controllers/order_details_controller.dart';
import 'package:sixvalley_vendor_app/features/order_details/domain/models/order_details_model.dart';
import 'package:sixvalley_vendor_app/features/order_edit/domain/models/order_edit_cart_model.dart';
import 'package:sixvalley_vendor_app/features/order_edit/domain/services/order_edit_service_interface.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/helper/api_checker.dart';

import '../../../main.dart';


class OrderEditController with ChangeNotifier {
  final OrderEditServiceInterface orderEditServiceInterface;
  OrderEditController({required this.orderEditServiceInterface});

  final List<Product> _orderDetails = [];
  List<Product> get orderDetails => _orderDetails;

  ProductModel? _sellerProductModel;
  ProductModel? get sellerProductModel => _sellerProductModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<OrderEditCartModel> _cartList = [];
  List<OrderEditCartModel> get cartList => _cartList;


  bool _isUpdateCartLoading = false;
  bool get isUpdateCartLoading => _isUpdateCartLoading;


  int? _variantIndex;
  List<int>? _variationIndex;
  int? get variantIndex => _variantIndex;
  List<int>? get variationIndex => _variationIndex;
  int? _quantity = 0;
  int? get quantity => _quantity;

  bool _isUpdateQuantity = true;
  bool get isUpdateQuantity => _isUpdateQuantity;

  double? orderAmount = 0;



  Future<void> setProductToCart(List<OrderDetailsModel>? orderDetails) async {
    if(orderDetails != null) {
      _cartList.clear();

      _cartList.addAll(orderDetails.map((orderDetails) {
        String? color;
        Map<String?, dynamic> choice = {};



        if(orderDetails.variation != null && orderDetails.variation!.isNotEmpty) {
          color = getColorCode(orderDetails);
          choice = getChoiceOptions(orderDetails) ?? {};
        }

        Product  product = orderDetails.productDetails!.toProduct();
        product.currentStock = orderDetails.currentProductStock;

        product.discount = orderDetails.productAllStatus?.discount;
        product.discountType = orderDetails.productAllStatus?.discountType;
        product.clearanceSale = orderDetails.productAllStatus?.clearanceSale;

        return OrderEditCartModel(
          orderDetails.productDetails!.id,
          orderDetails.currentProductPrice,
          orderDetails.discount,
          orderDetails.qty!,
          orderDetails.tax,
          orderDetails.variant,
          product,
          orderDetails.taxModel,
          true,
          color,
          choice,
        );

      }));
    }
  }

  Map<String?, dynamic>? getChoiceOptions(OrderDetailsModel orderDetails) {
    Map<String?, dynamic>? choice = {};
    for (var variation in orderDetails.variation!) {
      if(variation.key != 'color') {
        for (var option in orderDetails.productDetails!.choiceOptions!) {
          if(option.title == variation.key) {
            choice.addAll({option.name : variation.value});
          }
        }
      }
    }

    return choice;
  }

  String? getColorCode(OrderDetailsModel orderDetails) {
    String? colorName;
    String? colorCode;

    for (var variation in orderDetails.variation!) {
      if(variation.key == 'color') {
        colorName = variation.value;
      }
    }

    for (var colorModel in orderDetails.productDetails!.colors!) {
      if(colorModel.name == colorName) {
        colorCode = colorModel.code;
      }
    }
    return colorCode;
  }

  void addToCart(Product? product, {OrderEditCartModel? orderEditCartModel}) {
    if(product != null) {
      _cartList.add(
        OrderEditCartModel(
          product.id,
          product.unitPrice,
          0,
          1,
          0,
          null,
          product,
          null,
          false,
          null,
          {},
        )
      );
    }


    if(orderEditCartModel != null) {
      _cartList.add(orderEditCartModel);
    }

    notifyListeners();
  }



  Future<void> getSearchProductList(String sellerId, String orderId, int offset, String languageCode, String search, {bool reload = false}) async {
    if(reload || offset == 1) {
      _sellerProductModel = null;
      if(reload) {
        notifyListeners();
      }
    }

    _isLoading = true;
    notifyListeners();

    ApiResponse apiResponse = await orderEditServiceInterface.getSellerProductList(
      sellerId: sellerId, offset: offset, languageCode: languageCode, search: search, orderId: orderId
    );

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      if(offset == 1) {
        _sellerProductModel = ProductModel.fromJson(apiResponse.response!.data, fromGetProducts: true);
      } else {
        _sellerProductModel?.products?.addAll(ProductModel.fromJson(apiResponse.response!.data, fromGetProducts: true).products ?? []);
        _sellerProductModel?.offset = ProductModel.fromJson(apiResponse.response!.data).offset;
        _sellerProductModel?.totalSize = ProductModel.fromJson(apiResponse.response!.data).totalSize;
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }

    _isLoading = false;
    notifyListeners();
  }

  void emptySearchListAddList() {
    _sellerProductModel = null;
    notifyListeners();
  }

  void removeFormCart(int index) {
    _cartList.remove(_cartList[index]);
    notifyListeners();
  }


  Future<ApiResponse> editOrderSubmit(Map<String, dynamic> data) async {
    _isUpdateCartLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await orderEditServiceInterface.editOrderSubmit(data: data);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      Provider.of<OrderDetailsController>(Get.context!, listen: false).getOrderDetails(data['order_id']);
    } else {
      ApiChecker.checkApi(apiResponse);
    }

    _isUpdateCartLoading = false;
    notifyListeners();
    return apiResponse;
  }

  void setQuantity(int index, int quantity, {bool isUpdate = true}) {
    _cartList[index].quantity = quantity;
    if(isUpdate) {
      notifyListeners();
    }
  }

  void initData(Product product, int? minimumOrderQuantity, BuildContext context) {
    _variantIndex = 0;
    _quantity = 1;
    _variationIndex = [];

    for (int i= 0; i<= product.choiceOptions!.length; i++) {
      _variationIndex!.add(0);
    }
  }



  void updateQuantity(bool value, {bool isUpdate = true}) {
    _isUpdateQuantity = value;
    if(isUpdate){
      notifyListeners();
    }
  }


  void setCartVariationIndex(int? minimumOrderQuantity, int index, int i, BuildContext context) {
    _variationIndex![index] = i;
    _quantity = 1;
    _isUpdateQuantity = true;
    notifyListeners();
  }

  void setCartVariantIndex(int? minimumOrderQuantity,int index, BuildContext context) {
    _variantIndex = index;
    _quantity = 1;
    _isUpdateQuantity = true;
    notifyListeners();
  }


  void setQuantityBottomSheet(int quantity, {bool isUpdate = true}) {
    _quantity = quantity;
    if(isUpdate) {
      notifyListeners();
    }
  }


  Future<ApiResponse> switchToCod(int orderId) async {
    _isLoading = true;
    notifyListeners();

    ApiResponse apiResponse = await orderEditServiceInterface.switchToCod(orderId);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      Provider.of<OrderDetailsController>(Get.context!, listen: false).getOrderDetails(orderId.toString());
    } else {
      ApiChecker.checkApi(apiResponse);
    }

    _isLoading = false;
    notifyListeners();
    return apiResponse;
  }



  int apiHitCount = 0;
  Future<ApiResponse> editOrderValidation(int orderId) async {
    _isLoading = true;

    apiHitCount ++;
    ApiResponse apiResponse = await orderEditServiceInterface.editOrderValidation(
      data : {'order_id' : orderId.toString(), 'products' : jsonEncode(cartList)},
    );
    apiHitCount --;


    if(apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      orderAmount = apiResponse.response?.data['order_amount'] != null ? double.tryParse(apiResponse.response!.data['order_amount'].toString()) : 0;
    } else {
      ApiChecker.checkApi(apiResponse);
    }

    if(apiHitCount == 0) {
      _isLoading = false;
      notifyListeners();
    }
    return apiResponse;
  }




}