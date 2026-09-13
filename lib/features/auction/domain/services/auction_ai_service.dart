import 'package:image_picker/image_picker.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/repository/auction_ai_repository_interface.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/services/auction_ai_service_interface.dart';

class AuctionAiService implements AuctionAiServiceInterface {
  final AuctionAiRepositoryInterface auctionAiRepositoryInterface;

  AuctionAiService({required this.auctionAiRepositoryInterface});

  @override
  Future<dynamic> generateAuctionTitle({
    required String title,
    required String langCode,
  }) async {
    return await auctionAiRepositoryInterface.generateAuctionTitle(
      title: title,
      langCode: langCode,
    );
  }

  @override
  Future<dynamic> generateAuctionDescription({
    required String title,
    required String langCode,
  }) async {
    return await auctionAiRepositoryInterface.generateAuctionDescription(
      title: title,
      langCode: langCode,
    );
  }

  @override
  Future<dynamic> generateGeneralData({
    required String title,
    required String description,
    required String langCode,
  }) async {
    return await auctionAiRepositoryInterface.generateGeneralData(
      title: title,
      description: description,
      langCode: langCode,
    );
  }

  @override
  Future<dynamic> generateShippingData({
    required String title,
    required String description,
    required String langCode,
  }) async {
    return await auctionAiRepositoryInterface.generateShippingData(
      title: title,
      description: description,
      langCode: langCode,
    );
  }

  @override
  Future<dynamic> generateMetaSeoData({
    required String title,
    required String description,
  }) async {
    return await auctionAiRepositoryInterface.generateMetaSeoData(
      title: title,
      description: description,
    );
  }

  @override
  Future<dynamic> generateAuctionInfoData({
    required String title,
    required String description,
    required String langCode,
  }) async {
    return await auctionAiRepositoryInterface.generateAuctionInfoData(
      title: title,
      description: description,
      langCode: langCode,
    );
  }

  @override
  Future<dynamic> generateLimitCheck() async {
    return await auctionAiRepositoryInterface.generateLimitCheck();
  }

  @override
  Future<dynamic> generateFromImage({required XFile image}) async {
    return await auctionAiRepositoryInterface.generateFromImage(image: image);
  }

  @override
  Future<dynamic> generateSetupAutoFill({
    required String name,
    required String langCode,
  }) async {
    return await auctionAiRepositoryInterface.generateSetupAutoFill(
      name: name,
      langCode: langCode,
    );
  }

  @override
  Future<dynamic> generateTitleSuggestions({required List<String> keywords}) async {
    return await auctionAiRepositoryInterface.generateTitleSuggestions(keywords: keywords);
  }
}
