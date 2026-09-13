import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/features/chat/domain/models/media_file_model.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

enum VideoUploadType { link, file }

class AuctionProductVideoWidget extends StatefulWidget {
  final TextEditingController videoLinkController;
  final void Function(VideoUploadType type)? onTypeChanged;
  final VoidCallback? onFileTap;

  final MediaFileModel? pickedMediaFile;
  final bool isPickingMedia;
  final VoidCallback? onFileRemove;

  final VideoUploadType initialType;
  final String? existingVideoFilename;
  final VoidCallback? onExistingVideoRemove;

  const AuctionProductVideoWidget({
    super.key,
    required this.videoLinkController,
    this.onTypeChanged,
    this.onFileTap,
    this.pickedMediaFile,
    this.isPickingMedia = false,
    this.onFileRemove,
    this.initialType = VideoUploadType.link,
    this.existingVideoFilename,
    this.onExistingVideoRemove,
  });

  @override
  State<AuctionProductVideoWidget> createState() => _AuctionProductVideoWidgetState();
}

class _AuctionProductVideoWidgetState extends State<AuctionProductVideoWidget> {
  late VideoUploadType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(color: Color(0x0D1B7FED), offset: Offset(0, 6), blurRadius: 12, spreadRadius: -3),
          BoxShadow(color: Color(0x0D1B7FED), offset: Offset(0, -6), blurRadius: 12, spreadRadius: -3),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeMedium),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(getTranslated('product_video', context) ?? "",
                style: titilliumBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Text(getTranslated('product_video_description', context) ?? "",
                style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
            const SizedBox(height: Dimensions.paddingSizeMedium),

            RadioGroup<VideoUploadType>(
              groupValue: _selectedType,
              onChanged: _onTypeChanged,
              child: Row(children: [
                Expanded(
                  child: VideoTypeRadio(
                    label: getTranslated('upload_video_link', context) ?? "",
                    value: VideoUploadType.link,
                    onChanged: _onTypeChanged,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                Expanded(
                  child: VideoTypeRadio(
                    label: getTranslated('upload_video_file', context) ?? "",
                    value: VideoUploadType.file,
                    onChanged: _onTypeChanged,
                  ),
                ),
              ]),
            ),
            const SizedBox(height: Dimensions.paddingSizeMedium),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _selectedType == VideoUploadType.link
                  ? VideoLinkField(key: const ValueKey('link'), controller: widget.videoLinkController)
                  : _buildFileSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSection() {
    if (widget.isPickingMedia) {
      return SizedBox(
        key: const ValueKey('file-loading'),
        width: 160,
        height: 130,
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (widget.pickedMediaFile != null) {
      return VideoFilePreview(
        key: const ValueKey('file-preview'),
        mediaFile: widget.pickedMediaFile!,
        onRemove: widget.onFileRemove,
      );
    }

    if (widget.existingVideoFilename != null && widget.existingVideoFilename!.isNotEmpty) {
      return ExistingVideoFileChip(
        key: const ValueKey('file-existing'),
        filename: widget.existingVideoFilename!,
        onRemove: widget.onExistingVideoRemove,
        onTap: widget.onFileTap,
      );
    }

    return VideoFileUploadZone(
      key: const ValueKey('file-empty'),
      onTap: widget.onFileTap,
    );
  }

  void _onTypeChanged(VideoUploadType? value) {
    if (value == null) return;
    setState(() => _selectedType = value);
    widget.onTypeChanged?.call(value);
  }
}

class VideoTypeRadio extends StatelessWidget {
  final String label;
  final VideoUploadType value;
  final ValueChanged<VideoUploadType?> onChanged;

  const VideoTypeRadio({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Row(mainAxisSize: MainAxisSize.min,
        children: [
          Radio<VideoUploadType>(
            value: value,
            activeColor: Theme.of(context).primaryColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Flexible(
            child: Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoLinkField extends StatelessWidget {
  final TextEditingController controller;
  const VideoLinkField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.done,
      style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeMedium, vertical: Dimensions.paddingSizeMedium),
        hintText: 'Ex : https://www.youtube.com/embed/...',
        hintStyle: titilliumRegular.copyWith(color: Theme.of(context).hintColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: .25)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: .25), width: .75),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}

class VideoFileUploadZone extends StatelessWidget {
  final VoidCallback? onTap;
  const VideoFileUploadZone({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          dashPattern: const [4, 5],
          color: Theme.of(context).hintColor,
          radius: const Radius.circular(Dimensions.radiusDefault),
        ),
        child: Container(
          width: 160,
          height: 130,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), color: Theme.of(context).cardColor),
          child: Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(alignment: Alignment.bottomRight,
                children: [
                  Icon(Icons.play_circle_fill_rounded, size: 48, color: Theme.of(context).hintColor.withValues(alpha: .5)),
                  Container(
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
                    child: Icon(Icons.upload_rounded, size: 18, color: Theme.of(context).hintColor),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(getTranslated('click_to_add', context) ?? "",
                  style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
            ],
          ),
        ),
      ),
    );
  }
}

class VideoFilePreview extends StatelessWidget {
  final MediaFileModel mediaFile;
  final VoidCallback? onRemove;
  const VideoFilePreview({super.key, required this.mediaFile, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: mediaFile.thumbnailPath != null
              ? Image.file(
            File(mediaFile.thumbnailPath!),
            width: 160,
            height: 130,
            fit: BoxFit.cover,
          )
              : Container(
            width: 160,
            height: 130,
            color: Theme.of(context).hintColor.withValues(alpha: .1),
            child: Icon(Icons.video_file_rounded, size: 48, color: Theme.of(context).hintColor.withValues(alpha: .5)),
          ),
        ),

        if (mediaFile.isVideo == true)
          Positioned(
            bottom: Dimensions.paddingSizeExtraSmall,
            left: Dimensions.paddingSizeExtraSmall,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(mainAxisSize: MainAxisSize.min,
                children: [
                   Icon(Icons.videocam, size: 12, color: Theme.of(context).cardColor),
                  const SizedBox(width: 3),
                  Text('Video', style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor)),
                ],
              ),
            ),
          ),

        Positioned(
          top: Dimensions.paddingSizeExtraSmall,
          right: Dimensions.paddingSizeExtraSmall,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, shape: BoxShape.circle),
              child: Icon(Icons.close, size: 14, color: Theme.of(context).cardColor),
            ),
          ),
        ),
      ],
    );
  }
}

class ExistingVideoFileChip extends StatelessWidget {
  final String filename;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  const ExistingVideoFileChip({
    super.key,
    required this.filename,
    this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 160,
            height: 130,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              color: Theme.of(context).hintColor.withValues(alpha: .07),
              border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: .25)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_file_rounded, size: 40, color: Theme.of(context).hintColor.withValues(alpha: .5)),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: Text(
                    filename,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: titilliumRegular.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: Dimensions.paddingSizeExtraSmall,
          right: Dimensions.paddingSizeExtraSmall,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, shape: BoxShape.circle),
              child: Icon(Icons.close, size: 14, color: Theme.of(context).cardColor),
            ),
          ),
        ),
      ],
    );
  }
}