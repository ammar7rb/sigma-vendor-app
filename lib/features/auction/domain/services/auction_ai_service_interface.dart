import 'package:image_picker/image_picker.dart';

abstract class AuctionAiServiceInterface {
  Future<dynamic> generateAuctionTitle({
    required String title,
    required String langCode,
  });

  Future<dynamic> generateAuctionDescription({
    required String title,
    required String langCode,
  });

  Future<dynamic> generateGeneralData({
    required String title,
    required String description,
    required String langCode,
  });

  Future<dynamic> generateShippingData({
    required String title,
    required String description,
    required String langCode,
  });

  Future<dynamic> generateMetaSeoData({
    required String title,
    required String description,
  });

  Future<dynamic> generateAuctionInfoData({
    required String title,
    required String description,
    required String langCode,
  });

  Future<dynamic> generateLimitCheck();

  Future<dynamic> generateFromImage({required XFile image});

  Future<dynamic> generateSetupAutoFill({
    required String name,
    required String langCode,
  });

  Future<dynamic> generateTitleSuggestions({required List<String> keywords});
}
