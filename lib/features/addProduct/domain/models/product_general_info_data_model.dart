import 'package:flutter/foundation.dart';
import 'package:sixvalley_vendor_app/features/addProduct/domain/models/add_product_model.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';

class ProductGeneralInfoData {
  final String? categoryId;
  final String? subCategoryId;
  final String? subSubCategoryId;
  final String? brandId;
  final String? brandName;
  final String? unit;
  final String title;
  final String description;
  final Product? product;
  final AddProductModel? addProduct;

  ProductGeneralInfoData({
    required this.categoryId,
    required this.subCategoryId,
    required this.subSubCategoryId,
    this.brandId,
    this.brandName,
    this.unit,
    required this.title,
    required this.description,
    this.product,
    this.addProduct,
  });
}




class ProductCombinedData {

  // --- Data from General Info Screen (Tab 1) ---
  final String? categoryId;
  final String? subCategoryId;
  final String? subSubCategoryId;
  final String? brandId; // Corrected from 'brandyId'
  final String? brandName;
  final String? unit;
  final String? title;
  final String? description;
  final Product? product;          // Complex object: existing product details
  final AddProductModel? addProduct; // Complex object: existing partial product data

  // --- Data from Variation/Pricing Screen (Tab 2) ---
  final String? unitPrice; // Stored as String?
  final String? discount;  // Stored as String?
  final String? currentStock; // Stored as String?
  final String? minimumOrderQuantity; // Stored as String?
  final List<int?>? tax;   // Stored as List<int?>?
  final String? shippingCost; // Stored as String?

  // --- Control Field ---
  // A callback function; typically used to send status back up the tree.
  final ValueChanged<bool>? isSelected;

  ProductCombinedData({
    // General Info Fields
    this.categoryId,
    this.subCategoryId,
    this.subSubCategoryId,
    this.brandId,
    this.brandName,
    this.unit,
    this.title,
    this.description,
    this.product,
    this.addProduct,

    // Variation Fields
    this.unitPrice,
    this.discount,
    this.currentStock,
    this.minimumOrderQuantity,
    this.tax,
    this.shippingCost,

    // Control Field
    this.isSelected,
  });
}
