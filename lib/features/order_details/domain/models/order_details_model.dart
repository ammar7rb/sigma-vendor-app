import 'package:sixvalley_vendor_app/data/model/image_full_url.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';

class OrderDetailsModel {
  int? id;
  int? orderId;
  int? productId;
  int? sellerId;
  String? digitalFileAfterSell;
  ProductDetails? productDetails;
  int? qty;
  double? price;
  double? tax;
  double? discount;
  String? taxModel;
  String? deliveryStatus;
  String? paymentStatus;
  String? createdAt;
  String? updatedAt;
  String? shippingMethodId;
  String? variant;
  List<ModifiedVariation>? variation;
  List<OrderEditHistory>? orderEditHistory;
  OrderEditHistory? latestEditHistory;
  String? discountType;
  int? refundRequest;
  List<VerificationImages>? verificationImages;
  ImageFullUrl? digitalFileAfterSellFullUrl;
  ImageFullUrl? digitalFileReadyFullUrl;
  Order? order;
  int? currentProductStock;
  double? currentProductPrice;
  Product? productAllStatus;
  List<EditOrderPaymentHistoryModel>? editOrderPaymentHistory;

  OrderDetailsModel(
      {this.id,
      this.orderId,
      this.productId,
      this.sellerId,
      this.digitalFileAfterSell,
      this.productDetails,
      this.qty,
      this.price,
      this.tax,
      this.discount,
      this.taxModel,
      this.deliveryStatus,
      this.paymentStatus,
      this.createdAt,
      this.updatedAt,
      this.shippingMethodId,
      this.variant,
      this.variation,
      this.discountType,
      this.refundRequest,
      this.verificationImages,
      this.digitalFileAfterSellFullUrl,
      this.digitalFileReadyFullUrl,
      this.order,
      this.currentProductStock,
      this.currentProductPrice,
      this.productAllStatus,
      this.orderEditHistory,
      this.latestEditHistory,
      this.editOrderPaymentHistory});

  OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = json['order_id'];
    productId = json['product_id'];
    sellerId = json['seller_id'];
    digitalFileAfterSell = json['digital_file_after_sell'];
    productDetails =
        (json['product_details'] != null && json['product_details'] is! String)
            ? ProductDetails.fromJson(json['product_details'])
            : null;
    qty = json['qty'];
    price = json['price'].toDouble();
    tax = json['tax'].toDouble();
    discount = json['discount'].toDouble();
    taxModel = json['tax_model'];
    deliveryStatus = json['delivery_status'];
    paymentStatus = json['payment_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    shippingMethodId = json['shipping_method_id'];
    variant = json['variant'];
    if (json['modified_variation'] != null) {
      variation = <ModifiedVariation>[];
      json['modified_variation'].forEach((v) {
        variation!.add(ModifiedVariation.fromJson(v));
      });
    }

    if (json['order_edit_history'] != null) {
      orderEditHistory = <OrderEditHistory>[];
      json['order_edit_history'].forEach((v) {
        orderEditHistory!.add(OrderEditHistory.fromJson(v));
      });
    }

    discountType = json['discount_type'];
    refundRequest = json['refund_request'];
    if (json['verification_images'] != null) {
      verificationImages = <VerificationImages>[];
      json['verification_images'].forEach((v) {
        verificationImages!.add(VerificationImages.fromJson(v));
      });
    }
    digitalFileAfterSellFullUrl =
        json['digital_file_after_sell_full_url'] != null
            ? ImageFullUrl.fromJson(json['digital_file_after_sell_full_url'])
            : null;

    order = json['order'] != null ? Order.fromJson(json['order']) : null;
    currentProductStock = json['current_stock'];
    currentProductPrice = json['current_price'] != null
        ? double.tryParse(json['current_price'].toString())
        : 0;
    productAllStatus = (json['product_all_status'] != null &&
            json['product_all_status'] is! String)
        ? Product.fromJson(json['product_all_status'])
        : null;
    latestEditHistory = json['latest_edit_history'] != null
        ? OrderEditHistory.fromJson(json['latest_edit_history'])
        : null;

    editOrderPaymentHistory = json['edit_order_payment_histories'] != null
        ? (json['edit_order_payment_histories'] as List)
            .map((e) => EditOrderPaymentHistoryModel.fromJson(e))
            .toList()
        : null;
  }
}

class ProductDetails {
  int? _id;
  String? _addedBy;
  int? _userId;
  String? _name;
  String? _productType;
  List<CategoryIds>? _categoryIds;
  int? _brandId;
  String? _unit;
  int? _minQty;
  List<String>? _images;
  String? _thumbnail;
  List<Colores>? _colors;
  List<ChoiceOptions>? _choiceOptions;
  List<Variation>? _variation;
  double? _unitPrice;
  double? _purchasePrice;
  double? _tax;
  String? _taxModel;
  String? _taxType;
  double? _discount;
  String? _discountType;
  int? _currentStock;
  String? _details;
  int? _freeShipping;
  String? _createdAt;
  String? _updatedAt;
  String? _digitalProductType;
  String? _digitalFileReady;
  ImageFullUrl? _thumbnailFullUrl;
  List<DigitalVariation>? _digitalVariation;
  ImageFullUrl? digitalFileReadyFullUrl;
  ClearanceSale? _clearanceSale;
  int? _minimumOrderQty;

  ProductDetails({
    int? id,
    String? addedBy,
    int? userId,
    String? name,
    String? productType,
    List<CategoryIds>? categoryIds,
    int? brandId,
    String? unit,
    int? minQty,
    List<String>? images,
    String? thumbnail,
    ImageFullUrl? thumbnailFullUrl,
    List<Colores>? colors,
    List<String>? attributes,
    List<ChoiceOptions>? choiceOptions,
    List<Variation>? variation,
    double? unitPrice,
    double? purchasePrice,
    double? tax,
    String? taxModel,
    String? taxType,
    double? discount,
    String? discountType,
    int? currentStock,
    String? details,
    String? createdAt,
    String? updatedAt,
    String? digitalProductType,
    String? digitalFileReady,
    List<DigitalVariation>? digitalVariation,
    ClearanceSale? clearanceSale,
    int? minimumOrderQty,
  }) {
    _id = id;
    _addedBy = addedBy;
    _userId = userId;
    _name = name;
    _productType = productType;
    _categoryIds = categoryIds;
    _brandId = brandId;
    _unit = unit;
    _minQty = minQty;
    _images = images;
    _thumbnail = thumbnail;
    _colors = colors;
    _choiceOptions = choiceOptions;
    _variation = variation;
    _unitPrice = unitPrice;
    _purchasePrice = purchasePrice;
    _tax = tax;
    _taxModel = taxModel;
    _taxType = taxType;
    _discount = discount;
    _discountType = discountType;
    _currentStock = currentStock;
    _details = details;
    _freeShipping = freeShipping;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _thumbnailFullUrl = thumbnailFullUrl;
    if (digitalProductType != null) {
      _digitalProductType = digitalProductType;
    }
    if (digitalFileReady != null) {
      _digitalFileReady = digitalFileReady;
    }

    if (digitalVariation != null) {
      _digitalVariation = digitalVariation;
    }
    digitalFileReadyFullUrl;

    _clearanceSale = clearanceSale;
    _minimumOrderQty = minimumOrderQty;
  }

  int? get id => _id;
  String? get addedBy => _addedBy;
  int? get userId => _userId;
  String? get name => _name;
  String? get productType => _productType;
  List<CategoryIds>? get categoryIds => _categoryIds;
  int? get brandId => _brandId;
  String? get unit => _unit;
  int? get minQty => _minQty;
  List<String>? get images => _images;
  String? get thumbnail => _thumbnail;
  ImageFullUrl? get thumbnailFullUrl => _thumbnailFullUrl;
  List<Colores>? get colors => _colors;
  List<ChoiceOptions>? get choiceOptions => _choiceOptions;
  List<Variation>? get variation => _variation;
  double? get unitPrice => _unitPrice;
  double? get purchasePrice => _purchasePrice;
  double? get tax => _tax;
  String? get taxModel => _taxModel;
  String? get taxType => _taxType;
  double? get discount => _discount;
  String? get discountType => _discountType;
  int? get currentStock => _currentStock;
  String? get details => _details;
  int? get freeShipping => _freeShipping;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get digitalProductType => _digitalProductType;
  String? get digitalFileReady => _digitalFileReady;
  List<DigitalVariation>? get digitalVariation => _digitalVariation;
  ClearanceSale? get clearanceSale => _clearanceSale;
  int? get minimumOrderQty => _minimumOrderQty;

  ProductDetails.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _addedBy = json['added_by'];
    _userId = json['user_id'];
    _name = json['name'];
    _productType = json['product_type'];
    if (json['category_ids'] != null) {
      _categoryIds = [];
      json['category_ids'].forEach((v) {
        _categoryIds!.add(CategoryIds.fromJson(v));
      });
    }
    _brandId = json['brand_id'];
    _unit = json['unit'];
    _minQty = json['min_qty'];
    if (json['images'] is List) {
      _images = json['images'].cast<String>();
    }
    _thumbnail = json['thumbnail'];
    if (json['colors_formatted'] != null) {
      _colors = [];
      json['colors_formatted'].forEach((v) {
        _colors!.add(Colores.fromJson(v));
      });
    }
    if (json['choice_options'] != null) {
      _choiceOptions = [];
      json['choice_options'].forEach((v) {
        _choiceOptions!.add(ChoiceOptions.fromJson(v));
      });
    }
    if (json['variation'] != null) {
      _variation = [];
      json['variation'].forEach((v) {
        _variation!.add(Variation.fromJson(v));
      });
    }
    _unitPrice = json['unit_price'].toDouble();
    _purchasePrice = json['purchase_price'].toDouble();
    // _tax = json['tax'].toDouble();
    if (json['tax_model'] == null) {
      _taxModel = 'exclude';
    } else {
      _taxModel = json['tax_model'];
    }
    _taxType = json['tax_type'];
    _discount = json['discount'].toDouble();
    _discountType = json['discount_type'];
    _currentStock = json['current_stock'];
    _details = json['details'];
    _freeShipping = json['free_shipping'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    if (json['digital_product_type'] != null) {
      _digitalProductType = json['digital_product_type'];
    }
    if (json['digital_file_ready'] != null) {
      _digitalFileReady = json['digital_file_ready'];
    }
    _thumbnailFullUrl = json['thumbnail_full_url'] != null
        ? ImageFullUrl.fromJson(json['thumbnail_full_url'])
        : null;
    if (json['digital_variation'] != null) {
      _digitalVariation = <DigitalVariation>[];
      json['digital_variation'].forEach((v) {
        _digitalVariation!.add(DigitalVariation.fromJson(v));
      });
    }
    digitalFileReadyFullUrl = json['digital_file_ready_full_url'] != null
        ? ImageFullUrl.fromJson(json['digital_file_ready_full_url'])
        : null;

    _clearanceSale = json['clearance_sale'] != null
        ? ClearanceSale.fromJson(json['clearance_sale'])
        : null;

    _minimumOrderQty = json['minimum_order_qty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['added_by'] = _addedBy;
    data['user_id'] = _userId;
    data['name'] = _name;
    data['product_type'] = productType;
    if (_categoryIds != null) {
      data['category_ids'] = _categoryIds!.map((v) => v.toJson()).toList();
    }
    data['brand_id'] = _brandId;
    data['unit'] = _unit;
    data['min_qty'] = _minQty;
    data['images'] = _images;
    data['thumbnail'] = _thumbnail;
    if (_colors != null) {
      data['colors_formatted'] = _colors!.map((v) => v.toJson()).toList();
    }
    if (_choiceOptions != null) {
      data['choice_options'] = _choiceOptions!.map((v) => v.toJson()).toList();
    }
    if (_variation != null) {
      data['variation'] = _variation!.map((v) => v.toJson()).toList();
    }
    data['unit_price'] = _unitPrice;
    data['purchase_price'] = _purchasePrice;
    data['tax'] = _tax;
    data['tax_model'] = _taxModel;
    data['tax_type'] = _taxType;
    data['discount'] = _discount;
    data['discount_type'] = _discountType;
    data['current_stock'] = _currentStock;
    data['details'] = _details;
    data['free_shipping'] = _freeShipping;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['digital_product_type'] = digitalProductType;
    data['digital_file_ready'] = digitalFileReady;
    data['clearance_sale'] = clearanceSale?.toJson();
    data['clearance_sale'] = clearanceSale?.toJson();
    data['minimum_order_qty'] = _minimumOrderQty;
    return data;
  }
}

class CategoryIds {
  String? _id;
  int? _position;

  CategoryIds({String? id, int? position}) {
    _id = id;
    _position = position;
  }

  String? get id => _id;
  int? get position => _position;

  CategoryIds.fromJson(Map<String, dynamic> json) {
    _id = json['id'].toString();
    _position = json['position'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['position'] = _position;
    return data;
  }
}

class Colores {
  String? _name;
  String? _code;

  Colores({String? name, String? code}) {
    _name = name;
    _code = code;
  }

  String? get name => _name;
  String? get code => _code;

  Colores.fromJson(Map<String, dynamic> json) {
    _name = json['name'];
    _code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = _name;
    data['code'] = _code;
    return data;
  }
}

class Shipping {
  int? _id;
  int? _creatorId;
  String? _creatorType;
  String? _title;
  int? _cost;
  String? _duration;
  int? _status;
  String? _createdAt;
  String? _updatedAt;

  Shipping(
      {int? id,
      int? creatorId,
      String? creatorType,
      String? title,
      int? cost,
      String? duration,
      int? status,
      String? createdAt,
      String? updatedAt}) {
    _id = id;
    _creatorId = creatorId;
    _creatorType = creatorType;
    _title = title;
    _cost = cost;
    _duration = duration;
    _status = status;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  int? get id => _id;
  int? get creatorId => _creatorId;
  String? get creatorType => _creatorType;
  String? get title => _title;
  int? get cost => _cost;
  String? get duration => _duration;
  int? get status => _status;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Shipping.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _creatorId = json['creator_id'];
    _creatorType = json['creator_type'];
    _title = json['title'];
    _cost = json['cost'];
    _duration = json['duration'];
    _status = json['status'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['creator_id'] = _creatorId;
    data['creator_type'] = _creatorType;
    data['title'] = _title;
    data['cost'] = _cost;
    data['duration'] = _duration;
    data['status'] = _status;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    return data;
  }
}

class VerificationImages {
  int? id;
  int? orderId;
  String? image;
  ImageFullUrl? imageFullUrl;
  String? createdAt;
  String? updatedAt;

  VerificationImages(
      {this.id,
      this.orderId,
      this.image,
      this.imageFullUrl,
      this.createdAt,
      this.updatedAt});

  VerificationImages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderId = int.parse(json['order_id'].toString());
    image = json['image'];
    imageFullUrl = json['image_full_url'] != null
        ? ImageFullUrl.fromJson(json['image_full_url'])
        : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}

extension ProductDetailsExtension on ProductDetails {
  Product toProduct() {
    return Product(
        digitalVariation: digitalVariation,
        id: id,
        addedBy: addedBy,
        userId: userId,
        name: name,
        productType: productType,
        brandId: brandId,
        unit: unit,
        minQty: minQty,
        images: images,
        thumbnail: thumbnail,
        thumbnailFullUrl: thumbnailFullUrl,
        colors: colors
            ?.map((c) => ProductColors(name: c.name, code: c.code))
            .toList(),
        choiceOptions: choiceOptions,
        variation: variation,
        unitPrice: unitPrice,
        purchasePrice: purchasePrice,
        tax: tax,
        taxModel: taxModel,
        taxType: taxType,
        discount: discount,
        discountType: discountType,
        currentStock: currentStock,
        details: details,
        createdAt: createdAt,
        updatedAt: updatedAt,
        digitalProductType: digitalProductType,
        digitalFileReady: digitalFileReady,
        clearanceSale: clearanceSale,
        digitalFileReadyFullUrl: digitalFileReadyFullUrl,
        minimumOrderQty: minimumOrderQty);
  }
}

class ModifiedVariation {
  String? key;
  String? value;

  ModifiedVariation({this.key, this.value});

  ModifiedVariation.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['value'] = value;
    return data;
  }
}

class OrderEditHistory {
  int? id;
  int? uId;
  int? orderId;
  String? editBy;
  int? editedUserId;
  String? editedUserName;
  double? orderAmount;
  double? orderDueAmount;
  String? orderDuePaymentStatus;
  OfflinePaymentsEdit? orderDuePaymentInfo;
  String? orderDuePaymentMethod;
  String? orderDueTransactionRef;
  String? orderDuePaymentNote;
  double? orderReturnAmount;
  String? orderReturnPaymentStatus;
  String? orderReturnPaymentMethod;
  OfflinePaymentsEdit? orderReturnPaymentInfo;
  String? orderReturnTransactionRef;
  String? orderReturnPaymentNote;
  String? createdAt;
  String? updatedAt;

  OrderEditHistory(
      {this.id,
      this.uId,
      this.orderId,
      this.editBy,
      this.editedUserId,
      this.editedUserName,
      this.orderAmount,
      this.orderDueAmount,
      this.orderDuePaymentStatus,
      this.orderDuePaymentInfo,
      this.orderDuePaymentMethod,
      this.orderDueTransactionRef,
      this.orderDuePaymentNote,
      this.orderReturnAmount,
      this.orderReturnPaymentStatus,
      this.orderReturnPaymentMethod,
      this.orderReturnPaymentInfo,
      this.orderReturnTransactionRef,
      this.orderReturnPaymentNote,
      this.createdAt,
      this.updatedAt});

  OrderEditHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uId = json['u_id'];
    orderId = json['order_id'];
    editBy = json['edit_by'];
    editedUserId = json['edited_user_id'];
    editedUserName = json['edited_user_name'];
    orderAmount = json['order_amount'] != null
        ? double.tryParse(json['order_amount'].toString())
        : 0;
    orderDueAmount = json['order_due_amount'] != null
        ? double.tryParse(json['order_due_amount'].toString())
        : 0;
    orderDuePaymentStatus = json['order_due_payment_status'];
    orderDuePaymentInfo = json['order_due_payment_info'] != null
        ? OfflinePaymentsEdit.fromJson(json['order_due_payment_info'])
        : null;
    orderDuePaymentMethod = json['order_due_payment_method'];
    orderDueTransactionRef = json['order_due_transaction_ref'];
    orderDuePaymentNote = json['order_due_payment_note'];
    orderReturnAmount = json['order_return_amount'] != null
        ? double.tryParse(json['order_return_amount'].toString())
        : 0;
    orderReturnPaymentStatus = json['order_return_payment_status'];
    orderReturnPaymentMethod = json['order_return_payment_method'];
    orderReturnPaymentInfo = json['order_return_payment_info'];
    orderReturnTransactionRef = json['order_return_transaction_ref'];
    orderReturnPaymentNote = json['order_return_payment_note'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['u_id'] = uId;
    data['order_id'] = orderId;
    data['edit_by'] = editBy;
    data['edited_user_id'] = editedUserId;
    data['edited_user_name'] = editedUserName;
    data['order_amount'] = orderAmount;
    data['order_due_amount'] = orderDueAmount;
    data['order_due_payment_status'] = orderDuePaymentStatus;
    data['order_due_payment_info'] = orderDuePaymentInfo;
    data['order_due_payment_method'] = orderDuePaymentMethod;
    data['order_due_transaction_ref'] = orderDueTransactionRef;
    data['order_due_payment_note'] = orderDuePaymentNote;
    data['order_return_amount'] = orderReturnAmount;
    data['order_return_payment_status'] = orderReturnPaymentStatus;
    data['order_return_payment_method'] = orderReturnPaymentMethod;
    data['order_return_payment_info'] = orderReturnPaymentInfo;
    data['order_return_transaction_ref'] = orderReturnTransactionRef;
    data['order_return_payment_note'] = orderReturnPaymentNote;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class EditOrderPaymentHistoryModel {
  int? id;
  int? uId;
  int? orderId;
  String? editBy;
  int? editedUserId;
  String? editedUserName;
  double? orderAmount;
  double? orderDueAmount;
  String? orderDuePaymentStatus;
  OfflinePaymentsEdit? orderDuePaymentInfo;
  String? orderDuePaymentMethod;
  String? orderDueTransactionRef;
  String? orderDuePaymentNote;
  double? orderReturnAmount;
  String? orderReturnPaymentStatus;
  String? orderReturnPaymentMethod;
  OfflinePaymentsEdit? orderReturnPaymentInfo;
  String? orderReturnTransactionRef;
  String? orderReturnPaymentNote;
  String? createdAt;
  String? updatedAt;

  EditOrderPaymentHistoryModel({
    this.id,
    this.uId,
    this.orderId,
    this.editBy,
    this.editedUserId,
    this.editedUserName,
    this.orderAmount,
    this.orderDueAmount,
    this.orderDuePaymentStatus,
    this.orderDuePaymentInfo,
    this.orderDuePaymentMethod,
    this.orderDueTransactionRef,
    this.orderDuePaymentNote,
    this.orderReturnAmount,
    this.orderReturnPaymentStatus,
    this.orderReturnPaymentMethod,
    this.orderReturnPaymentInfo,
    this.orderReturnTransactionRef,
    this.orderReturnPaymentNote,
    this.createdAt,
    this.updatedAt,
  });

  factory EditOrderPaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    return EditOrderPaymentHistoryModel(
      id: json['id'],
      uId: json['u_id'],
      orderId: json['order_id'],
      editBy: json['edit_by'],
      editedUserId: json['edited_user_id'],
      editedUserName: json['edited_user_name'],
      orderAmount: json['order_amount'] != null
          ? (json['order_amount'] as num).toDouble()
          : null,
      orderDueAmount: json['order_due_amount'] != null
          ? (json['order_due_amount'] as num).toDouble()
          : null,
      orderDuePaymentStatus: json['order_due_payment_status'],
      orderDuePaymentInfo: json['order_due_payment_info'] != null
          ? OfflinePaymentsEdit.fromJson(json['order_due_payment_info'])
          : null,
      orderDuePaymentMethod: json['order_due_payment_method'],
      orderDueTransactionRef: json['order_due_transaction_ref'],
      orderDuePaymentNote: json['order_due_payment_note'],
      orderReturnAmount: json['order_return_amount'] != null
          ? (json['order_return_amount'] as num).toDouble()
          : null,
      orderReturnPaymentStatus: json['order_return_payment_status'],
      orderReturnPaymentMethod: json['order_return_payment_method'],
      orderReturnPaymentInfo: json['order_return_payment_info'] != null
          ? OfflinePaymentsEdit.fromJson(json['order_return_payment_info'])
          : null,
      orderReturnTransactionRef: json['order_return_transaction_ref'],
      orderReturnPaymentNote: json['order_return_payment_note'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'u_id': uId,
      'order_id': orderId,
      'edit_by': editBy,
      'edited_user_id': editedUserId,
      'edited_user_name': editedUserName,
      'order_amount': orderAmount,
      'order_due_amount': orderDueAmount,
      'order_due_payment_status': orderDuePaymentStatus,
      'order_due_payment_info': orderDuePaymentInfo,
      'order_due_payment_method': orderDuePaymentMethod,
      'order_due_transaction_ref': orderDueTransactionRef,
      'order_due_payment_note': orderDuePaymentNote,
      'order_return_amount': orderReturnAmount,
      'order_return_payment_status': orderReturnPaymentStatus,
      'order_return_payment_method': orderReturnPaymentMethod,
      'order_return_payment_info': orderReturnPaymentInfo,
      'order_return_transaction_ref': orderReturnTransactionRef,
      'order_return_payment_note': orderReturnPaymentNote,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
