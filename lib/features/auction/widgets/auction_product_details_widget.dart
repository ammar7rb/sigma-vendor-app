import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/theme/controllers/theme_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AuctionProductDetailsWidget extends StatefulWidget {
  final String title;
  final String description;
  final String? videoProvider;
  final String? videoUrl;
  final String? customVideoUrl;

  const AuctionProductDetailsWidget({
    super.key,
    required this.title,
    required this.description,
    this.videoProvider,
    this.videoUrl,
    this.customVideoUrl,
  });

  @override
  State<AuctionProductDetailsWidget> createState() => _AuctionProductDetailsWidgetState();
}

class _AuctionProductDetailsWidgetState extends State<AuctionProductDetailsWidget> {
  bool _isExpanded = false;

  bool get _isLong => widget.description.isNotEmpty && widget.description.length > 400;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;

    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getTranslated('details', context) ?? '',
            style: titilliumBold.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Text(
            widget.title,
            style: titilliumBold.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: (_isLong && !_isExpanded) ? 150 : null,
                    child: ClipRect(
                      child: Html(
                        data: widget.description,
                        style: {
                          'body': Style(
                            fontSize: FontSize(Dimensions.fontSizeSmall),
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                          ),
                        },
                        onAnchorTap: (url, _, __) {
                          if (url != null) {
                            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    ),
                  ),

                  if (_isLong && !_isExpanded)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                          onTap: () => setState(() => _isExpanded = true),
                          child: Container(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            color: Theme.of(context).cardColor,
                            child: Text(
                              getTranslated('see_more...', context) ?? 'See more...',
                              style: titilliumRegular.copyWith(
                                height: 0.8,
                                fontSize: Dimensions.fontSizeDefault,
                                color: isDark ? Colors.white : Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              if (_isLong && _isExpanded)
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => setState(() => _isExpanded = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall,
                        vertical: Dimensions.paddingSizeExtraSmall,
                      ),
                      child: Text(
                        getTranslated('see_less...', context) ?? 'See less...',
                        style: titilliumRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: isDark ? Colors.white : Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          if (widget.videoProvider == 'youtube_link' && (widget.videoUrl?.isNotEmpty ?? false)) ...[
            const SizedBox(height: Dimensions.paddingSizeDefault),
            YoutubeVideoWidget(url: widget.videoUrl),
          ],

          if (widget.videoProvider == 'custom_video' && (widget.customVideoUrl?.isNotEmpty ?? false)) ...[
            const SizedBox(height: Dimensions.paddingSizeDefault),
            AuctionCustomVideoPlayerWidget(url: widget.customVideoUrl!),
          ],

          const SizedBox(height: Dimensions.paddingSizeDefault),
        ],
      ),
    );
  }
}

class YoutubeVideoWidget extends StatefulWidget {
  final String? url;
  const YoutubeVideoWidget({super.key, this.url});

  @override
  State<YoutubeVideoWidget> createState() => _YoutubeVideoWidgetState();
}

class _YoutubeVideoWidgetState extends State<YoutubeVideoWidget> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: SizedBox(
        height: 220,
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}

class AuctionCustomVideoPlayerWidget extends StatefulWidget {
  final String url;
  const AuctionCustomVideoPlayerWidget({super.key, required this.url});

  @override
  State<AuctionCustomVideoPlayerWidget> createState() => _AuctionCustomVideoPlayerWidgetState();
}

class _AuctionCustomVideoPlayerWidgetState extends State<AuctionCustomVideoPlayerWidget> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        aspectRatio: _videoController!.value.aspectRatio,
        autoPlay: false,
        looping: false,
        showOptions: false,
      );
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Theme.of(context).hintColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        ),
        child: Center(
          child: Icon(Icons.error_outline, color: Theme.of(context).hintColor, size: 40),
        ),
      );
    }

    if (_chewieController == null || !(_videoController?.value.isInitialized ?? false)) {
      return SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor)),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: Chewie(controller: _chewieController!),
      ),
    );
  }
}
