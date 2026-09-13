import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/auction/domain/models/add_auction_product_model.dart';
import 'package:sixvalley_vendor_app/interface/repository_interface.dart';
import 'package:image_picker/image_picker.dart';

abstract class AddAuctionProductRepositoryInterface implements RepositoryInterface {

  Future<ApiResponse> addAuctionProduct({
    required AddAuctionProductModel addAuctionProduct,
    required int categoryId,
    int? brandId,
    required String productType,
    required String itemCondition,
    required double entryFee,
    required double startingPrice,
    required double minimumIncrementAmount,
    required double maximumDecrementAmount,
    required String startTime,
    required String endTime,
    int? duration,
    required int status,
    required double shippingFee,
    String? returnPolicy,
    // For update operations thumbnail/images can be null to keep existing media
    XFile? thumbnail,
    List<XFile>? images,
    String? videoType,
    String? youtubeVideo,
    XFile? customerVideo,
    List<int>? taxIds,
    String? metaTitle,
    String? metaDescription,
    String? metaIndex,
    String? metaNoFollow,
    String? metaNoImageIndex,
    String? metaNoArchive,
    String? metaNoSnippet,
    String? metaMaxSnippet,
    String? metaMaxSnippetValue,
    String? metaMaxVideoPreview,
    String? metaMaxVideoPreviewValue,
    String? metaMaxImagePreview,
    String? metaMaxImagePreviewValue,
    XFile? metaImageFile,
    String? metaImage,
    bool update = false,
    int? auctionId,
    // null → omit field (keep all existing). Empty list → delete all. Subset → keep only listed filenames.
    List<String>? retainedImages,
    String? currentCurrencyCode,
    String? tags,
    bool isRelaunch = false,
  });
}
