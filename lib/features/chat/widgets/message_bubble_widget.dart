import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/features/chat/domain/models/message_model.dart';
import 'package:sixvalley_vendor_app/features/chat/screens/media_viewer_screen.dart';
import 'package:sixvalley_vendor_app/features/chat/controllers/chat_controller.dart';
import 'package:sixvalley_vendor_app/localization/controllers/localization_controller.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class MessageBubbleWidget extends StatelessWidget {
  final Message message;
  final Message? previous;
  final Message? next;
  const MessageBubbleWidget({super.key, required this.message, this.previous, this.next});

  @override
  Widget build(BuildContext context) {

    return Consumer<ChatController>(
        builder: (context, chatProvider,child) {
          bool isMe = message.sentBySeller!;



          String? image =  _getAvatarImage(userTypeIndex: Provider.of<ChatController>(context, listen: false).userTypeIndex);

          String chatTime  = chatProvider.getChatTime(message.createdAt!, message.createdAt);
          bool isSameUserWithPreviousMessage = chatProvider.isSameUserWithPreviousMessage(previous, message);
          bool isSameUserWithNextMessage = chatProvider.isSameUserWithNextMessage(message, next);
          bool isLTR = Provider.of<LocalizationController>(context, listen: false).isLtr;
          String previousMessageHasChatTime = previous != null ? chatProvider.getChatTime(previous!.createdAt!, message.createdAt) : "";

          final List<Attachment> images = message.attachment?.where((a) => a.type == 'media').toList() ?? [];
          final List<Attachment> files = message.attachment?.where((a) => a.type == 'file').toList() ?? [];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingEye),
            child: Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Row( crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (_isUserAvatarActive(isMe, isSameUserWithPreviousMessage, chatProvider))
                    _UserAvatar(image: image),

                    !(_isUserAvatarActive(isMe, isSameUserWithPreviousMessage, chatProvider)) &&
                    !isMe ? const SizedBox(width: Dimensions.paddingSizeExtraLarge + 5) : const SizedBox(),

                    if (message.message?.isNotEmpty ?? false)
                      _MessageText(
                        message: message,
                        isMe: isMe,
                        isLTR: isLTR,
                        isSameUserWithNextMessage: isSameUserWithNextMessage,
                        isSameUserWithPreviousMessage: isSameUserWithPreviousMessage,
                        chatTime: chatTime,
                        previousMessageHasChatTime: previousMessageHasChatTime,
                        chatProvider: chatProvider,
                        isProfileAvatarActive: _isUserAvatarActive(isMe, isSameUserWithPreviousMessage, chatProvider),
                      ),

                  ],
                ),

                _MessageTime(chatProvider: chatProvider, message: message),

                if(images.isNotEmpty) const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isMe && images.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          child: InkWell(
                            onTap: () => _downloadMediaForAll(context, images),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.01),
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                child: Icon(Icons.file_download_outlined, color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                        ),
                      ],

                      _MediaGridWidget(images: images, isMe: isMe),

                      if (!isMe && images.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          child: InkWell(
                            onTap: () => _downloadMediaForAll(context, images),
                            child: Container(
                              decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha: 0.01),
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              ),
                              child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                child: Icon(Icons.file_download_outlined, color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  )
                ),


                if (files.isNotEmpty) _FileGridWidget(files: files, isMe: isMe, isLTR: isLTR),


              ],
            ),
          );
        }
    );
  }

  String? _getAvatarImage({required int userTypeIndex}) {
    return userTypeIndex == 0 ?
    message.customer != null? message.customer?.imageFullUrl?.path :'' : message.deliveryMan?.imageFullUrl?.path;
  }

  bool _isUserAvatarActive(bool isMe, bool isSameUserWithPreviousMessage, ChatController chatProvider) =>
      !isMe && (!isSameUserWithPreviousMessage || chatProvider.getChatTimeWithPrevious(message, previous).isNotEmpty);

  Future<void> _downloadMediaForAll(BuildContext context, List<Attachment> mediaList) async {
    if (mediaList.isEmpty) return;

    final ChatController chatController = Provider.of<ChatController>(context, listen: false);

    final status = await Permission.notification.request();

    if (status.isGranted) {
      Directory? directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = Platform.isAndroid ? await getExternalStorageDirectory() : await getApplicationSupportDirectory();
      }

      if (directory == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloading ${mediaList.length} files...'), backgroundColor: Colors.black54, duration: const Duration(seconds: 3)),
      );

      for (var media in mediaList) {
        if (media.path == null || media.path!.isEmpty) continue;

        String fileName = Uri.parse(media.path!).pathSegments.last;

        chatController.downloadFile(media.path!, directory.path, "${directory.path}/$fileName", fileName);
      }
    } else if (status.isDenied || status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }



}

class _UserAvatar extends StatelessWidget {
  final String? image;

  const _UserAvatar({required this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Container(
        height: 30, width: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), width: 1), // Blue border with 2px width
        ),
        child: ClipOval(child: CustomImageWidget(image: '$image', width: 30, height: 30)),
      ),
    );
  }
}

class _MessageText extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool isLTR;
  final bool isSameUserWithNextMessage;
  final bool isSameUserWithPreviousMessage;
  final String chatTime;
  final String previousMessageHasChatTime;
  final ChatController chatProvider;
  final bool isProfileAvatarActive;

  const _MessageText({
    required this.message,
    required this.isMe,
    required this.isLTR,
    required this.isSameUserWithNextMessage,
    required this.isSameUserWithPreviousMessage,
    required this.chatTime,
    required this.previousMessageHasChatTime,
    required this.chatProvider,
    required this.isProfileAvatarActive,
  });

  @override
  Widget build(BuildContext context) {

    return Flexible(child: Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
      if(message.message != null && message.message!.isNotEmpty)
        InkWell(
          onTap: (){
            chatProvider.toggleOnClickMessage(onMessageTimeShowID :
            message.id.toString());
          },
          child: Container(
            margin: isMe && isLTR ? const EdgeInsets.fromLTRB(70, 2, 2, 2) : EdgeInsets.fromLTRB(10, 2, isLTR ? 70 : 2, 2),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: _getBorderRadius(),
              color: isMe ? Provider.of<ThemeController>(context).darkTheme ?
              Theme.of(context).cardColor : Theme.of(context).primaryColor : Theme.of(context).primaryColor.withValues(alpha: 0.15),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              (message.message != null && message.message!.isNotEmpty) ? Text(message.message!,
                  style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                      color: isMe ? Theme.of(context).cardColor: Theme.of(context).textTheme.bodyLarge?.color)
              ) : const SizedBox.shrink(),
            ]),
          ),
        ),

    ]));
  }

  BorderRadius _getBorderRadius() {

    if (isMe && (isSameUserWithNextMessage || isSameUserWithPreviousMessage)) {
      return BorderRadius.only(
        topRight: Radius.circular(isSameUserWithNextMessage && isLTR && chatTime == "" ? Dimensions.radiusSmall : Dimensions.radiusExtraLarge + 5),
        bottomRight: Radius.circular(isSameUserWithPreviousMessage && isLTR && previousMessageHasChatTime == "" ? Dimensions.radiusSmall : Dimensions.radiusExtraLarge + 5),
        topLeft: Radius.circular(isSameUserWithNextMessage && !isLTR && chatTime == "" ? Dimensions.radiusSmall : Dimensions.radiusExtraLarge + 5),
        bottomLeft: Radius.circular(isSameUserWithPreviousMessage && !isLTR && previousMessageHasChatTime == "" ? Dimensions.radiusSmall :Dimensions.radiusExtraLarge + 5),
      );

    } else if (!isMe && (isSameUserWithNextMessage || isSameUserWithPreviousMessage)) {
      return BorderRadius.only(
        topLeft: Radius.circular(isSameUserWithNextMessage && isLTR && chatTime == "" ? Dimensions.radiusSmall : Dimensions.radiusExtraLarge + 5),
        bottomLeft: Radius.circular( isSameUserWithPreviousMessage && isLTR && previousMessageHasChatTime == "" ? Dimensions.radiusSmall : Dimensions.radiusExtraLarge + 5),
        topRight: Radius.circular(isSameUserWithNextMessage && !isLTR && chatTime == "" ? Dimensions.radiusSmall : Dimensions.radiusExtraLarge + 5),
        bottomRight: Radius.circular(isSameUserWithPreviousMessage && !isLTR && previousMessageHasChatTime == "" ? Dimensions.radiusSmall :Dimensions.radiusExtraLarge + 5),
      );

    } else {
      return BorderRadius.circular(Dimensions.radiusExtraLarge + 5);
    }
  }
}

class _MessageTime extends StatelessWidget {
  final ChatController chatProvider;
  final Message message;

  const _MessageTime({required this.chatProvider, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: AnimatedContainer(
        curve: Curves.fastOutSlowIn,
        duration: const Duration(milliseconds: 500),
        height: chatProvider.onMessageTimeShowID == message.id.toString() ? 25.0 : 0.0,
        child: Padding(
          padding: EdgeInsets.only(
            top: chatProvider.onMessageTimeShowID == message.id.toString() ? Dimensions.paddingSizeExtraSmall : 0.0,
          ),
          child: Text(
            chatProvider.getOnPressChatTime(message) ?? "",
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
          ),
        ),
      ),
    );
  }
}


class _DownloadButtonWidget extends StatelessWidget {
  const _DownloadButtonWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        child: Icon(Icons.file_download_outlined, color: Theme.of(context).primaryColor),
      ),
    );
  }
}


class _FileGridWidget extends StatelessWidget {
  final List<Attachment> files;
  final bool isMe;
  final bool isLTR;

  const _FileGridWidget({required this.files, required this.isMe, required this.isLTR});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Directionality(
          textDirection: isMe && isLTR ? TextDirection.rtl : !isLTR && !isMe ? TextDirection.rtl : TextDirection.ltr,
          child: Padding(
            padding: EdgeInsets.only(left: (!isMe && isLTR) ? 40 : 0, right: (!isMe && !isLTR) ? 40 : 0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: files.length,
              padding: files.isNotEmpty ? const EdgeInsets.only(top: Dimensions.paddingSizeSmall) : EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisExtent: 60,
                crossAxisCount: 2,
                mainAxisSpacing: Dimensions.paddingSizeExtraSmall,
                crossAxisSpacing: Dimensions.paddingSizeExtraSmall,
              ),
              itemBuilder: (context, index) => _FileItem(file: files[index]),
            ),
          ),
        ),

        const SizedBox(height: Dimensions.paddingSizeSmall),
      ],
    );
  }
}

class _FileItem extends StatelessWidget {
  final Attachment file;

  const _FileItem({required this.file});

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = Provider.of<ChatController>(context, listen: false);

    return InkWell(
      onTap: () async {
        final status = await Permission.notification.request();
        if (kDebugMode) {
          print("Status is $status");
        }
        if (status.isGranted) {
          Directory? directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = Platform.isAndroid
                ? await getExternalStorageDirectory() // FOR ANDROID
                : await getApplicationSupportDirectory();
          }
          chatController.downloadFile(file.path!, directory!.path, "${directory.path}/${file.key}", "${file.key}");

        } else if (status.isDenied || status.isPermanentlyDenied) {
          await openAppSettings();
        }
      },
      child: Container(
        width: 180, height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).hintColor.withValues(alpha:0.2),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Directionality(textDirection: TextDirection.ltr, child: Row(
            children: [
              const Image(image: AssetImage(Images.fileIcon), height: 30, width: 30),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

              Expanded(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.key.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                  Text(
                    "${file.size}",
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor),
                  ),
                ],
              )),
              const _DownloadButtonWidget(),
            ],
          )),
        ),
      ),
    );
  }
}

class _MediaGridWidget extends StatefulWidget {
  final List<Attachment> images;
  final bool isMe;

  const _MediaGridWidget({
    required this.images,
    required this.isMe,
  });

  @override
  State<_MediaGridWidget> createState() => _MediaGridWidgetState();
}

class _MediaGridWidgetState extends State<_MediaGridWidget> {
  List<String> _videoThumbnails = [];
  final Map<String, String?> _thumbnailCache = {};

  @override
  void initState() {
    super.initState();
    _generateThumbnails();
  }

  @override
  void didUpdateWidget(covariant _MediaGridWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.images != widget.images) {
      _generateThumbnails();
    }
  }

  Future<void> _generateThumbnails() async {
    final chatController = Provider.of<ChatController>(context, listen: false);

    final List<String> thumbnails = [];
    for (var image in widget.images) {
      if (chatController.isVideoExtension(image.path ?? '')) {
        if (_thumbnailCache.containsKey(image.path)) {
          thumbnails.add(_thumbnailCache[image.path] ?? '');
        } else {
          final thumbnail = await chatController.generateThumbnail(image.path ?? '');
          _thumbnailCache[image.path ?? ''] = thumbnail;
          thumbnails.add(thumbnail ?? '');
        }
      } else {
        thumbnails.add('');
      }
    }

    if (mounted) setState(() => _videoThumbnails = thumbnails);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    final chatController = Provider.of<ChatController>(context, listen: false);
    final isLtr = Provider.of<LocalizationController>(context, listen: false).isLtr;

    final hasVideo = widget.images.any((a) => chatController.isVideoExtension(a.path ?? ''));

    return hasVideo ? VideoLayout(images: widget.images, isMe: widget.isMe, videoThumbnails: _videoThumbnails,)
        : ImageGridLayout(images: widget.images, isMe: widget.isMe, isLtr: isLtr);
  }
}

class VideoLayout extends StatelessWidget {
  final List<Attachment> images;
  final bool isMe;
  final List<String> videoThumbnails;

  const VideoLayout({
    required this.images,
    required this.isMe,
    required this.videoThumbnails,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final chatController = Provider.of<ChatController>(context, listen: false);
    final isLtr = Provider.of<LocalizationController>(context, listen: false).isLtr;
    final videoIndex = images.indexWhere((a) => chatController.isVideoExtension(a.path ?? ''));
    final mainVideo = images[videoIndex];
    final remainingEntries = images.asMap().entries.where((e) => e.key != videoIndex).toList();
    final extraCount = remainingEntries.length > 2 ? remainingEntries.length - 2 : 0;
    final visibleItems = remainingEntries.take(2).toList();
    final mainThumbnail = videoThumbnails.isNotEmpty && videoIndex < videoThumbnails.length ? videoThumbnails[videoIndex] : null;

    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall, left: (!isMe && isLtr) ? 40 : 0, right: (!isMe && !isLtr) ? 40 : 0,
      ),
      child: SizedBox(width: MediaQuery.of(context).size.width / 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MediaViewerScreen(clickedIndex: videoIndex, serverMedia: images)),),
              child: ClipRRect(borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                child: AspectRatio(aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (mainThumbnail != null && mainThumbnail.isNotEmpty) Image.file(File(mainThumbnail), fit: BoxFit.cover)
                      else CustomImageWidget(image: mainVideo.path ?? '', fit: BoxFit.cover),

                      Center(child: Icon(Icons.play_circle_fill, size: 50, color: Theme.of(context).cardColor)),
                    ],
                  ),
                ),
              ),
            ),

            if (visibleItems.isNotEmpty) ...[
              const SizedBox(height: Dimensions.paddingSizeSmall),

              SizedBox(height: MediaQuery.of(context).size.width / 4.5,
                child: Row(
                  children: List.generate(visibleItems.length, (i) {
                      final originalIndex = visibleItems[i].key;
                      final attachment = visibleItems[i].value;

                      final isVideo = chatController.isVideoExtension(attachment.path ?? '');
                      final thumbnail = isVideo && originalIndex < videoThumbnails.length ? videoThumbnails[originalIndex] : null;
                      final isLast = i == visibleItems.length - 1;
                      final showOverlay = isLast && extraCount > 0;

                      return Expanded(
                        child: Padding(padding: EdgeInsets.only(left: i == 0 ? 0 : Dimensions.paddingSizeSmall),
                          child: InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MediaViewerScreen(clickedIndex: originalIndex, serverMedia: images))),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              child: Stack(fit: StackFit.expand,
                                children: [
                                  if (isVideo && thumbnail != null && thumbnail.isNotEmpty) Image.file(File(thumbnail), fit: BoxFit.cover)
                                  else CustomImageWidget(image: attachment.path ?? '', fit: BoxFit.cover),

                                  if (isVideo) Center(child: Icon(Icons.play_circle_fill, color: Theme.of(context).cardColor, size: Dimensions.iconSizeExtraLarge)),

                                  if (showOverlay)
                                    Container(color: Theme.of(context).disabledColor.withValues(alpha: 0.6),
                                      child: Center(
                                        child: Text('+$extraCount',
                                          style: robotoRegular.copyWith(color: Theme.of(context).cardColor, fontSize: Dimensions.fontSizeLarge),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ImageGridLayout extends StatelessWidget {
  final List<Attachment> images;
  final bool isMe;
  final bool isLtr;

  const ImageGridLayout({
    required this.images,
    required this.isMe,
    required this.isLtr,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: Dimensions.paddingSizeExtraSmall,
        left: (!isMe && isLtr) ? 40 : 0,
        right: (!isMe && !isLtr) ? 40 : 0,
      ),
      child: Directionality(textDirection: isLtr ? (isMe ? TextDirection.rtl : TextDirection.ltr) : (isMe ? TextDirection.ltr : TextDirection.rtl),
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1,
              crossAxisCount: 2,
              mainAxisSpacing: Dimensions.paddingSizeSmall,
              crossAxisSpacing: Dimensions.paddingSizeSmall,
            ),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: min(images.length, 4),
            itemBuilder: (context, index) {
              final isShowMore = images.length > 4 && index == (isMe ? 2 : 3);

              return Stack(
                children: [
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MediaViewerScreen(clickedIndex: index, serverMedia: images))),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: CustomImageWidget(
                        height: 200, width: 200, fit: BoxFit.cover,
                        image: images[index].path ?? '',
                      ),
                    ),
                  ),
                  if (isShowMore)
                    Positioned.fill(
                      child: InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MediaViewerScreen(clickedIndex: index, serverMedia: images))),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 4.2,
                            height: MediaQuery.of(context).size.width / 4.2,
                            decoration: BoxDecoration(
                              color: Theme.of(context).disabledColor.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                            ),
                            child: Center(
                              child: Text('+${images.length - 3}', style: robotoRegular.copyWith(color: Theme.of(context).cardColor)),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}