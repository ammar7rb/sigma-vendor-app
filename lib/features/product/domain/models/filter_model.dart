class FilterModel {
  bool reload;
  List<String>? productType;
  double? minPrice;
  double? maxPrice;
  DateTime? startDate;
  DateTime? endDate;
  List<int>? brandIds;
  List<int>? categoryIds;
  List<int>? filterSubCategoryIds;
  List<int>? filterSubSubCategoryIds;
  bool isUpdate;
  List<int>? publishingHouseIds;
  List<int>? authorIds;
  List<String>? status;
  String? isApproved;
  String? sorting;

  FilterModel({
    this.reload = false,
    this.productType,
    this.minPrice,
    this.maxPrice,
    this.startDate,
    this.endDate,
    this.brandIds,
    this.categoryIds,
    this.filterSubCategoryIds,
    this.filterSubSubCategoryIds,
    this.isUpdate = false,
    this.publishingHouseIds,
    this.authorIds,
    this.status,
    this.isApproved,
    this.sorting,
  });

  FilterModel copyWith({
    bool? reload,
    List<String>? productType,
    double? minPrice,
    double? maxPrice,
    DateTime? startDate,
    DateTime? endDate,
    List<int>? brandIds,
    List<int>? categoryIds,
    List<int>? filterSubCategoryIds,
    List<int>? filterSubSubCategoryIds,
    bool? isUpdate,
    List<int>? publishingHouseIds,
    List<int>? authorIds,
    List<String>? status,
    String? isApproved,
    String? sorting,
  }) {
    return FilterModel(
      reload: reload ?? this.reload,
      productType: productType ?? this.productType,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      brandIds: brandIds ?? this.brandIds,
      categoryIds: categoryIds ?? this.categoryIds,
      filterSubCategoryIds: filterSubCategoryIds ?? this.filterSubCategoryIds,
      filterSubSubCategoryIds: filterSubSubCategoryIds ?? this.filterSubSubCategoryIds,
      isUpdate: isUpdate ?? this.isUpdate,
      publishingHouseIds: publishingHouseIds ?? this.publishingHouseIds,
      authorIds: authorIds ?? this.authorIds,
      status: status ?? this.status,
      isApproved: isApproved ?? this.isApproved,
      sorting: sorting ?? this.sorting,
    );
  }

  factory FilterModel.fromJson(Map<String, dynamic> json) {
    return FilterModel(
      reload: json['reload'] ?? true,
      productType: json['product_type'],
      minPrice: json['min_price']?.toDouble(),
      maxPrice: json['max_price']?.toDouble(),
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      brandIds: json['brand_ids'] != null ? List<int>.from(json['brand_ids']) : [],
      categoryIds: json['category_ids'] != null ? List<int>.from(json['category_ids']) : [],
      filterSubCategoryIds: json['filter_sub_category_ids'] != null ? List<int>.from(json['filter_sub_category_ids']) : [],
      filterSubSubCategoryIds: json['Filter_sub_sub_category_ids'] != null ? List<int>.from(json['Filter_sub_sub_category_ids']) : [],
      isUpdate: json['is_update'] ?? false,
      publishingHouseIds: json['publishing_house_ids'] != null ? List<int>.from(json['publishing_house_ids']) : [],
      authorIds: json['author_ids'] != null ? List<int>.from(json['author_ids']) : [],
      status: json['status'],
      isApproved: json['is_approved'],
      sorting: json['sorting'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reload': reload,
      'product_type': productType,
      'min_price': minPrice,
      'max_price': maxPrice,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'brand_ids': brandIds,
      'category_ids': categoryIds,
      'filter_sub_category_ids': filterSubCategoryIds,
      'Filter_sub_sub_category_ids': filterSubSubCategoryIds,
      'is_update': isUpdate,
      'publishing_house_ids': publishingHouseIds,
      'author_ids': authorIds,
      'status': status,
      'is_approved': isApproved,
      'sorting': sorting,
    };
  }
}