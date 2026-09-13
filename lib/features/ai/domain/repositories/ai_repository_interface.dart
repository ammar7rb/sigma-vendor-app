import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/interface/repository_interface.dart';
import 'package:image_picker/image_picker.dart';

abstract class AiRepositoryInterface implements RepositoryInterface {

  Future<ApiResponse?>  generateTitle({required String title, required String langCode});
  Future<ApiResponse?>  generateDescription({required String title, required String langCode});
  Future<ApiResponse?>  generateAuctionTitle({required String title, required String langCode});
  Future<ApiResponse?>  generateAuctionDescription({required String title, required String langCode});
  Future<ApiResponse?> generateGeneralData({required String title,  required String description, required String langCode});

  Future<ApiResponse?> generateTitleSuggestions({required String keywords});
  Future<ApiResponse?> generateFromImage({required XFile image});

  Future<ApiResponse?>  generatePricing({required String title, required String langCode});

  Future<ApiResponse?> generateVariationData({required String title,  required String description});

  Future<ApiResponse?> generateMetaSeoData({required String title,  required String description});

  Future<ApiResponse?> generateLimitCheck();

}
