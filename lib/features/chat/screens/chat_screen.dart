import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_asset_image_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/paginated_list_view_widget.dart';
import 'package:sixvalley_vendor_app/features/chat/controllers/chat_controller.dart';
import 'package:sixvalley_vendor_app/features/chat/domain/models/chat_model.dart';
import 'package:sixvalley_vendor_app/features/chat/domain/models/message_model.dart';
import 'package:sixvalley_vendor_app/features/chat/screens/media_viewer_screen.dart';
import 'package:sixvalley_vendor_app/features/chat/widgets/chat_shimmer_widget.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/helper/date_converter.dart';
import 'package:sixvalley_vendor_app/helper/image_size_checker.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/features/chat/widgets/message_bubble_widget.dart';
import 'package:sixvalley_vendor_app/features/chat/widgets/send_message_widget.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

import '../../../main.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final int? userId;
  final Chat chat;
  const ChatScreen({super.key, required this.userId, this.name = '', required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ImagePicker picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  String? image;

  @override
  void initState() {
    super.initState();

    final chatController = Provider.of<ChatController>(context, listen: false);
    image = chatController.userTypeIndex == 0 ? (widget.chat.customer?.imageFullUrl?.path ?? '') : (widget.chat.deliveryMan?.imageFullUrl?.path ?? '');

    chatController.getMessageList(widget.userId, 1);
    chatController.setEmojiPickerValue(false, notify: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar:  AppBar(backgroundColor: Theme.of(context).cardColor,
          titleSpacing: 0,
          elevation: 1,
          leading: InkWell(onTap: ()=> Navigator.pop(context),
              child: Icon(CupertinoIcons.back, color: Theme.of(context).textTheme.bodyLarge?.color)),
          title: Row(children: [

            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.chatImage),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.chatImage),
                  border: Border.all(width: 0.5, color: Theme.of(context).primaryColor.withValues(alpha: 0.125)),
                ),
                height: 40,
                width: 40,
                child: CachedNetworkImage(imageUrl: image ?? '', fit: BoxFit.cover,
                  placeholder: (context, url) => Image.asset(Images.placeholderImage, fit: BoxFit.cover),
                  errorWidget: (context, url, error) => Image.asset(Images.placeholderImage, fit: BoxFit.cover),
                ),
              ),
            ),

            Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: Text(widget.name, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color)))]),
          ),
      body: Consumer<ChatController>(builder: (context, chatController, child) {
        return Column(children: [
          const SizedBox(height: 2),
          chatController.messageModel != null ?
          Expanded(child: (chatController.messageModel!.message != null && chatController.messageModel!.message!.isNotEmpty) ?
          SingleChildScrollView(
            reverse: true,
            controller : _scrollController,
            child: PaginatedListViewWidget(
              reverse: true,
              scrollController: _scrollController,
              totalSize: chatController.messageModel?.totalSize,
              offset: chatController.messageModel?.offset,
              onPaginate: (int? offset) async => await chatController.getMessageList( widget.userId, offset!, reload: false),

              itemView : ListView.builder(
                itemCount: chatController.messageModel?.message?.length,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                reverse: true,
                itemBuilder: (context, index) {

                  return Column(
                      crossAxisAlignment: chatController.messageModel?.message?[index].sentBySeller ?? false ? CrossAxisAlignment.end : CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                      children: [
                        if(_willShowDate(index, chatController.messageModel) != null)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeExtraSmall,
                                vertical: Dimensions.paddingSizeSmall,
                              ),
                              // DateConverter.customTime(DateTime.parse(chat!.createdAt!))
                              child: Text( DateConverter.dateStringMonthYear(DateTime.tryParse(chatController.messageModel!.message![index].createdAt!)),
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.5)),
                                  textDirection: TextDirection.ltr),
                            ),
                          ),

                        MessageBubbleWidget(
                          message: chatController.messageModel!.message![index],
                          previous: (index != 0) ? chatController.messageModel!.message![index -1 ] : null,
                          next: index == (chatController.messageModel!.message!.length -1) ?  null : chatController.messageModel!.message![index + 1],
                        )

                      ]);
                },
              ),
            ),
          ) : const SizedBox.shrink()) : const Expanded(child: ChatShimmerWidget()),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          chatController.isLoading ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                child: AnimatedContainer(
                  curve: Curves.fastOutSlowIn,
                  duration: const Duration(milliseconds: 500),
                  height: chatController.isLoading ? 25.0 : 0.0,
                  child: Text(getTranslated('sending', context)!, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor.withValues(alpha:.75)),),
                ),
              ),
            ],
          ) : const SizedBox(),



          chatController.hasPicked ?
          Container(
            color: chatController.isLoading == false && ((chatController.pickedMediaFileModelList != null && chatController.pickedMediaFileModelList!.isNotEmpty) || (chatController.pickedFiles != null && chatController.pickedFiles!.isNotEmpty)) ?
            Theme.of(context).primaryColor.withValues(alpha:0.1) : null,
            height: (chatController.pickedFIleCrossMaxLimit || chatController.pickedFIleCrossMaxLength || chatController.singleFIleCrossMaxLimit) ? 130 : 110,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: Dimensions.paddingSizeDefault),
            child: const Center(child: CircularProgressIndicator()),
          ) : chatController.pickedMediaFileModelList != null && chatController.pickedMediaFileModelList!.isNotEmpty && chatController.isLoading == false ?
          Container(
            color:  chatController.isLoading == false && ((chatController.pickedMediaFileModelList != null && chatController.pickedMediaFileModelList!.isNotEmpty) || (chatController.pickedFiles != null && chatController.pickedFiles!.isNotEmpty)) ?
            Theme.of(context).primaryColor.withValues(alpha:0.1) : null,
            height:  (chatController.pickedFIleCrossMaxLimit || chatController.pickedFIleCrossMaxLength || chatController.singleFIleCrossMaxLimit) ? 130 : 110, width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: Dimensions.paddingSizeExtraSmall),
            child: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 80,
                  child: ListView.builder(scrollDirection: Axis.horizontal,
                    itemBuilder: (context,index){
                      return  Stack(children: [
                        Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall, left: Dimensions.paddingSizeVeryTiny, right: Dimensions.paddingSize, bottom: Dimensions.paddingSizeVeryTiny),
                            child: ClipRRect(borderRadius: BorderRadius.circular(10),
                                child: SizedBox(height: 80, width: 80,
                                    child: Image.file(File(chatController.pickedMediaFileModelList![index].thumbnailPath ?? ''), fit: BoxFit.cover),
                                ),
                            ),
                        ),


                        if(chatController.pickedMediaFileModelList?[index].isVideo ?? false)
                          Positioned.fill(
                            child: Align(alignment: Alignment.center, child: InkWell(
                              onTap: () => Navigator.push(context, MaterialPageRoute(
                                builder: (_) => MediaViewerScreen(
                                  clickedIndex: index,
                                  localMedia: chatController.getXFileFromMediaFileModel(chatController.pickedMediaFileModelList ?? []),
                                ),
                              )),
                              child: Container(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.play_arrow, color: Theme.of(context).primaryColor, size: 30),
                              ),
                            )),
                          ),

                        Positioned(
                          right: 5,
                          top: 0,
                          child: InkWell(
                              splashColor: Colors.transparent,
                              child: const CustomAssetImageWidget(Images.crossImageChat),
                              onTap: () => chatController.pickMultipleMedia(true,index: index)),
                        ),
                      ],
                      );},
                    itemCount: chatController.pickedMediaFileModelList!.length,
                  ),
                ),

                if(chatController.pickedFIleCrossMaxLimit || chatController.pickedImageCrossMaxLength || chatController.singleFIleCrossMaxLimit)
                  Text( "${chatController.pickedImageCrossMaxLength ? "• ${getTranslated('can_not_select_more_than', context)!} ${AppConstants.maxLimitOfTotalFileSent.floor()} 'files' " :""} "
                      "${chatController.pickedFIleCrossMaxLimit ? "• ${getTranslated('total_images_size_can_not_be_more_than', context)!} ${AppConstants.maxLimitOfFileSentINConversation.floor()} MB" : ""} "
                      "${chatController.singleFIleCrossMaxLimit ? "• ${getTranslated('single_file_size_can_not_be_more_than', context)!} "
                      "${(Provider.of<SplashController>(Get.context!, listen: false).configModel?.systemGeneralFileUploadMaxSize ?? AppConstants.maxSizeOfASingleFile)} MB" : ""} ",
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            )
          ) : const SizedBox(),

          chatController.pickedFiles != null && chatController.pickedFiles!.isNotEmpty && chatController.isLoading == false ?
          ColoredBox(
            color: Theme.of(context).primaryColor.withValues(alpha:0.1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: []),
                  SizedBox(height: 70,
                    child: ListView.separated(
                      shrinkWrap: true, scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(bottom: 5),
                      separatorBuilder: (context, index) => const SizedBox(width: Dimensions.paddingSizeDefault),
                      itemCount: chatController.pickedFiles!.length,
                      itemBuilder: (context, index){
                        String fileSize =  ImageValidationHelper.getFileSizeFromPlatformFileToString(chatController.pickedFiles![index]);
                        return Container(width: 180,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          ),
                          padding: const EdgeInsets.only(left: 10, right: 5),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.center,children: [

                            Image.asset(Images.fileIcon,height: 30, width: 30,),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall,),

                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(chatController.pickedFiles![index].name,
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                              ),

                              Text(fileSize, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).hintColor,
                              )),
                            ])),


                            InkWell(
                              onTap: () {
                                chatController.pickOtherFile(true, index: index);
                              },
                              child: Padding(padding: const EdgeInsets.only(top: 5),
                                child: Align(alignment: Alignment.topRight,
                                  child: Icon(Icons.close,
                                    size: Dimensions.paddingSizeLarge,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ),
                            )
                          ]),
                        );
                      },
                    ),
                  ),

                  if(chatController.pickedFIleCrossMaxLimit || chatController.pickedFIleCrossMaxLength || chatController.singleFIleCrossMaxLimit)
                    Text( "${chatController.pickedFIleCrossMaxLength ? "• ${getTranslated('can_not_select_more_than', context)!} ${AppConstants.maxLimitOfTotalFileSent.floor()} 'files' " :""} "
                        "${chatController.pickedFIleCrossMaxLimit ? "• ${getTranslated('total_images_size_can_not_be_more_than', context)!} ${Provider.of<SplashController>(Get.context!, listen: false).configModel?.systemGeneralFileUploadMaxSize ?? AppConstants.maxLimitOfFileSentINConversation.floor()} MB" : ""} "
                        "${chatController.singleFIleCrossMaxLimit ? "• ${getTranslated('single_file_size_can_not_be_more_than', context)!} ${Provider.of<SplashController>(Get.context!, listen: false).configModel?.systemGeneralFileUploadMaxSize ?? AppConstants.maxSizeOfASingleFile.floor()} MB" : ""} ",
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
          ) : const SizedBox(),

          SafeArea(top: false, child: SizedBox(
            height: chatController.openEmojiPicker ? 360 : 60,
            child: SendMessageWidget(id: widget.userId),
          )),
        ]);
      }),
    );
  }


  String? _willShowDate(int index, MessageModel? messageModel) {

    if(messageModel?.message == null) return null;

    final Message currentMessage = messageModel!.message![index];
    final nextMessage = index < ((messageModel.message?.length ?? 0) - 1) ? messageModel.message![index + 1] : null;

    DateTime? currentMessageDate = currentMessage.createdAt == null ? null : DateTime.tryParse(currentMessage.createdAt!);
    DateTime? nextMessageDate = nextMessage?.createdAt == null ? null : DateTime.tryParse(nextMessage!.createdAt!);
    bool isFirst = index == ((messageModel.message?.length ?? 0) - 1);

    if (isFirst || (nextMessageDate?.day != currentMessageDate?.day)) {
      return DateConverter.dateStringMonthYear(currentMessageDate);
    }
    return null;
  }
}



