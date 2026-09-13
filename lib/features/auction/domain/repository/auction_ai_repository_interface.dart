import 'package:image_picker/image_picker.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/interface/repository_interface.dart';

abstract class AuctionAiRepositoryInterface implements RepositoryInterface {
  Future<ApiResponse?> generateAuctionTitle({
    required String title,
    required String langCode,
  });

  Future<ApiResponse?> generateAuctionDescription({
    required String title,
    required String langCode,
  });

  Future<ApiResponse?> generateGeneralData({
    required String title,
    required String description,
    required String langCode,
  });

  Future<ApiResponse?> generateShippingData({
    required String title,
    required String description,
    required String langCode,
  });

  Future<ApiResponse?> generateMetaSeoData({
    required String title,
    required String description,
  });

  Future<ApiResponse?> generateAuctionInfoData({
    required String title,
    required String description,
    required String langCode,
  });

  Future<ApiResponse?> generateLimitCheck();

  Future<ApiResponse?> generateFromImage({required XFile image});

  Future<ApiResponse?> generateSetupAutoFill({
    required String name,
    required String langCode,
  });

  Future<ApiResponse?> generateTitleSuggestions({required List<String> keywords});
}
