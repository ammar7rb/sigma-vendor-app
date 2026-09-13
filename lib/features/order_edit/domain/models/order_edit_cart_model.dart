import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';

class OrderEditCartModel {
  int? _id;
  double? _price;
  double? _discountAmount;
  int? _quantity;
  double? _taxAmount;
  String? _variant;
  Product? _product;
  String? _taxModel;
  bool? _isOrderProduct;
  String? _color;
  Map<String?, dynamic>? _choice;

  OrderEditCartModel(
      int? id,
      double? price,
      double? discountAmount,
      int? quantity,
      double? taxAmount,
      String? variant,
      Product? product,
      String? taxModel,
      bool? isOrderProduct,
      String? color,
      Map<String?, dynamic>? choice
    ) {
    _id = id;
    _price = price;
    _discountAmount = discountAmount;
    _quantity = quantity;
    _taxAmount = taxAmount;
    _variant = variant;
    _product = product;
    _taxModel = taxModel;
    _isOrderProduct = isOrderProduct;
    _color = color;
    _choice = choice;
  }

  int? get id => _id;
  double? get price => _price;
  double? get discountAmount => _discountAmount;
  int? get quantity => _quantity;
  set quantity(int? qty) => _quantity = qty;
  double? get taxAmount => _taxAmount;
  Product? get product => _product;
  String? get variant => _variant;
  String? get taxModel => _taxModel;
  bool? get isOrderProduct => _isOrderProduct;
  String? get getColor => _color;
  Map<String?, dynamic>?  get choice => _choice;

  OrderEditCartModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _price = (json['price'] != null) ? json['price'].toDouble() : null;
    _discountAmount = (json['discount_amount'] != null)
        ? json['discount_amount'].toDouble()
        : null;
    _quantity = json['quantity'];
    _taxAmount =
        (json['tax_amount'] != null) ? double.tryParse(json['tax_amount'].toString()) : null;
    _variant = json['variant'];
    _product = (json['product'] != null) ? Product.fromJson(json['product']) : null;
    _taxModel = json['tax_model'];
    _isOrderProduct = json['is_order_product'];
    _color = json['color'];
    if (json['choice'] != null) {
      _choice = {};
      json['choice'].forEach((v) {
        _choice!.addAll({v['key']: v['value']});
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id ?? 0;
    data['price'] = _price ?? 0;
    data['discount_amount'] = _discountAmount ?? 0;
    data['quantity'] = _quantity ?? 0;
    data['tax_amount'] = _taxAmount ?? 0;
    data['variant'] = _variant ?? '';
    // Safely handle nested Product

    data['product'] = _product != null ? _product!.toJson() : {};
    data['tax_model'] = _taxModel ?? '';
    data['is_order_product'] = _isOrderProduct ?? false;
    data['color'] = _color ?? '';
    data['choice'] = [];
    if (_choice != null) {
      _choice!.forEach((key, value) {
        data['choice'].add({'key': key, 'value': value});
      });
    }
    return data;
  }
}



class CartChoiceOptions {
  String? _name;
  String? _selectedTitle;

  CartChoiceOptions({String? name, String? selectedTitle}) {
    _name = name;
    _selectedTitle = selectedTitle;

  }

  String? get name => _name;
  String? get selectedTitle => _selectedTitle;


  CartChoiceOptions.fromJson(Map<String, dynamic> json) {
    _name = json['name'];
    _selectedTitle = json['selected_title'];
  }

  Map<String, dynamic> toJson() {
    return {
      'name': _name,
      'selected_title': _selectedTitle
    };
  }
}