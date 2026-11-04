import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/auth/controllers/auth_controller.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';

class CustomImageWidget extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit fit;
  final String? placeholder;
  const CustomImageWidget({super.key, required this.image, this.height, this.width, this.fit = BoxFit.cover, this.placeholder = Images.placeholderImage});

  @override
  Widget build(BuildContext context) {
    final url = Uri.tryParse(image);
    final base = Uri.parse(AppConstants.baseUrl);
    if (url != null &&
        url.scheme == base.scheme &&
        url.host == base.host &&
        url.port == base.port &&
        RegExp(r'/account-photos/(customer|seller)/[0-9]+$').hasMatch(url.path)) {
      final token = context.read<AuthController>().getUserToken();
      return Image.network(
        image,
        headers: {'Authorization': 'Bearer $token'},
        fit: fit,
        height: height,
        width: width,
        errorBuilder: (context, error, stack) =>
            Image.asset(placeholder!, height: height, width: width, fit: fit),
      );
    }

    return CachedNetworkImage(
      placeholder: (context, url) => Image.asset(placeholder?? Images.placeholderImage, height: height, width: width, fit: BoxFit.cover),
      imageUrl: image, fit: fit,
      height: height,width: width,
      errorWidget: (c, o, s) => Image.asset(placeholder?? Images.placeholderImage, height: height, width: width, fit: BoxFit.cover),
    );
  }
}
