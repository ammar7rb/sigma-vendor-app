import 'package:sixvalley_vendor_app/features/product/domain/repositories/category_repository_interface.dart';
import 'package:sixvalley_vendor_app/features/product/domain/services/category_service_interface.dart';

class CategoryService implements CategoryServiceInterface{
  final CategoryRepositoryInterface categoryRepositoryInterface;
  CategoryService({required this.categoryRepositoryInterface});


  @override
  Future getCategoryList(String languageCode) {
    return categoryRepositoryInterface.getCategoryList(languageCode);
  }


}