import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/utill/app_constants.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';

/// A WebView payment screen used exclusively for the Auction entry-fee payment.
///
/// **Difference from [DigitalPaymentScreen]:**
/// On success/cancel/fail the router does NOT push to home. Instead it
/// pops all modal bottom-sheets then pops itself – landing the user back on
/// the Auction Details screen with the navigation stack intact.
class AuctionDigitalPaymentScreen extends StatefulWidget {
  final String url;

  const AuctionDigitalPaymentScreen({super.key, required this.url});

  @override
  State<AuctionDigitalPaymentScreen> createState() =>
      _AuctionDigitalPaymentScreenState();
}

class _AuctionDigitalPaymentScreenState
    extends State<AuctionDigitalPaymentScreen> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  bool _canRedirect = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initWebView();
      _isInitialized = true;
    }
  }

  void _initWebView() {
    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Theme.of(context).cardColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) setState(() => _isLoading = false);
          },
          onPageStarted: _checkRedirect,
          onPageFinished: _checkRedirect,
          onWebResourceError: (e) => debugPrint('WebView error: ${e.description}'),
          onNavigationRequest: (NavigationRequest req) {
            if (_isRedirectUrl(req.url)) {
              _checkRedirect(req.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  bool _isRedirectUrl(String url) {
    return ((url.contains('success') && url.contains('token')) ||
            url.contains('fail') ||
            url.contains('cancel')) &&
        url.contains(AppConstants.baseUrl);
  }

  void _checkRedirect(String url) {
    if (_canRedirect && _isRedirectUrl(url)) {
      _canRedirect = false;
      final bool isSuccess = url.contains('success');
      final bool isFailed = url.contains('fail');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handlePaymentResult(isSuccess: isSuccess, isFailed: isFailed);
      });
    }
  }

  /// After payment result: pop the WebView screen and any lingering sheets,
  /// then show a light result dialog on top of the auction details screen.
  void _handlePaymentResult({required bool isSuccess, required bool isFailed}) {
    if (isSuccess) {
      _popToAuctionDetails();
      Future.delayed(const Duration(milliseconds: 400), () {
        showCustomSnackBarWidget(
          getTranslated('payment_successful', Get.context!),
          Get.context!,
          isError: false,
        );
      });
    } else {
      _popToAuctionDetails();
      Future.delayed(const Duration(milliseconds: 400), () {
        showCustomSnackBarWidget(
          getTranslated(isFailed ? 'payment_failed' : 'payment_cancelled', Get.context!),
          Get.context!,
          isError: true,
        );
      });
    }
  }

  /// Pops this screen plus any stacked modal bottom-sheets so the user
  /// ends up on the auction detail screen without rebuilding the whole stack.
  void _popToAuctionDetails() {
    // Close the WebView screen itself; any bottom-sheets pushed before it
    // were already removed when the WebView was pushed (pushReplacement
    // handling is done in the controller before navigating here).
    if (Navigator.canPop(Get.context!)) {
      Navigator.of(Get.context!).pop();
    }
  }

  Future<void> _onBackPressed() async {
    if (!_canRedirect) return;
    _canRedirect = false;
    _popToAuctionDetails();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => _onBackPressed(),
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: AppBar(
          title: Text(getTranslated('payment', context) ?? 'Payment'),
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 18),
            onPressed: _onBackPressed,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _webViewController),
                  if (_isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: bottomPadding),
          ],
        ),
      ),
    );
  }
}
