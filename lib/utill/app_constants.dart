import 'package:sixvalley_vendor_app/localization/models/language_model.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';
import '../features/shop/domain/models/guideline_model.dart';

class AppConstants {
  static const String appName = 'Sigma Vendor'; ///Flutter SDK 3.44.2
  static const String appVersion = '16.3';
  static const String companyName = '6Valley';
  static const bool demo = false;
  static const int imageQuality = 100;


  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://sigma-eg.net',
  );

  static const String loginUri = '/api/v3/seller/auth/login';
  static const String configUri = '/api/v1/config';
  static const String sellerUri = '/api/v3/seller/seller-info';
  static const String sellerAndBankUpdate = '/api/v3/seller/seller-update';
  static const String shopUri = '/api/v3/seller/shop-info';
  static const String sellerBalanceUri = '/api/v3/seller/balance';
  static const String sellerBalancePayUri = '/api/v3/seller/balance/pay';
  static const String sellerBalanceOfflinePaymentUri = '/api/v3/seller/balance/offline-payment';
  static const String sellerDashboardOverviewUri = '/api/v3/seller/dashboard-overview';

  static const String shopUpdate = '/api/v3/seller/shop-update';
  static const String cartUri = '/api/v3/seller/messages/list/';
  static const String chatSearchUri = '/api/v3/seller/messages/search/';
  static const String messageUri = '/api/v3/seller/messages/get-message/';
  static const String sendMessageUri = '/api/v3/seller/messages/send/';
  static const String seenMessageUri = '/api/v3/seller/messages/seen/';
  static const String orderListUri = '/api/v3/seller/orders/list';
  static const String insurancePendingOrdersUri = '/api/v3/seller/orders/insurance-pending';
  static const String orderDetails = '/api/v3/seller/orders/';
  static const String sellerOrderInsuranceSuffix = '/insurance';
  static const String updateOrderStatus = '/api/v3/seller/orders/order-detail-status/';
  static const String balanceWithdraw = '/api/v3/seller/balance-withdraw';
  static const String balanceWithdrawUpdate = '/api/v3/seller/balance-withdraw-update';
  static const String cancelBalanceRequest = '/api/v3/seller/close-withdraw-request';
  static const String transactionUri = '/api/v3/seller/transactions?status=';
  static const String sellerProductUri = '/api/v3/seller/products/';
  static const String stockOutProductUri = '/api/v3/seller/products/stock-out-list?limit=10&offset=';
  static const String stockViolationsUri = '/api/v3/seller/products/stock-violations?limit=50&offset=1';
  static const String productReviewUri = '/api/v3/seller/shop-product-reviews';
  static const String productReviewStatusOnOff = '/api/v3/seller/shop-product-reviews-status';
  static const String attributeUri = '/api/v1/attributes';
  static const String brandUri = '/api/v3/seller/brands';
  static const String categoryUri = '/api/v3/seller/categories';
  static const String subCategoryUri = '/api/v1/categories/childes/';
  static const String subSubCategoryUri = '/api/v1/categories/childes/childes/';
  static const String addProductUri = '/api/v3/seller/products/add';
  static const String uploadProductImageUri = '/api/v3/seller/products/upload-images';
  static const String updateProductUri = '/api/v3/seller/products/update';
  static const String deleteProductUri = '/api/v3/seller/products/delete';
  static const String editProductUri = '/api/v3/seller/products/edit';
  static const String addShippingUri = '/api/v3/seller/shipping-method/add';
  static const String updateShippingUri = '/api/v3/seller/shipping-method/update';
  static const String editShippingUri = '/api/v3/seller/shipping-method/edit';
  static const String deleteShippingUri = '/api/v3/seller/shipping-method/delete';
  static const String getShippingUri = '/api/v3/seller/shipping-method/list';
  static const String getDeliveryManUri = '/api/v3/seller/seller-delivery-man';
  static const String assignDeliveryManUri = '/api/v3/seller/orders/assign-delivery-man';
  static const String tokenUri = '/api/v3/seller/cm-firebase-token';
  static const String refundListUri = '/api/v3/seller/refund/list';
  static const String refundItemDetails = '/api/v3/seller/refund/refund-details';
  static const String refundReqStatusUpdate = '/api/v3/seller/refund/refund-status-update';
  static const String showShippingCostUri = '/api/v3/seller/shipping/all-category-cost';
  static const String setCategoryWiseShippingCost = '/api/v3/seller/shipping/set-category-cost';
  static const String setShippingMethodTypeUri = '/api/v3/seller/shipping/selected-shipping-method';
  static const String getShippingMethodTypeUri = '/api/v3/seller/shipping/get-shipping-method';
  static const String thirdPartyDeliveryManAssign = '/api/v3/seller/orders/assign-third-party-delivery';
  static const String forgotPasswordUri = '/api/v3/seller/auth/forgot-password';
  static const String verifyOtpUri = '/api/v3/seller/auth/verify-otp';
  static const String resetPasswordUri = '/api/v3/seller/auth/reset-password';
  static const String paymentStatusUpdate = '/api/v3/seller/orders/update-payment-status';
  static const String barCodeGenerateUri = '/api/v3/seller/products/barcode/generate';
  static const String digitalProductUpload = '/api/v3/seller/products/upload-digital-product';
  static const String digitalProductUploadAfterSell = '/api/v3/seller/orders/order-wise-product-upload';
  static const String registration = '/api/v3/seller/registration';
  static const String registrationPoliciesUri = '/api/v3/seller/policies/required';
  static const String registrationPolicyAcceptUri = '/api/v3/seller/policies/accept';
  static const String registrationOtpSendUri = '/api/v3/seller/registration/send-otp';
  static const String registrationOtpVerifyUri = '/api/v3/seller/registration/verify-otp';
  static const String registrationActivationStatusUri = '/api/v3/seller/registration/activation-status';
  static const String registrationActivationTicketUri = '/api/v3/seller/registration/activation-ticket';
  static const String registrationActivationTicketMessagesUri = '/api/v3/seller/registration/activation-ticket/messages';
  static const String registrationReference = 'seller_registration_reference';
  static const String deleteAccount = '/api/v3/seller/account-delete';
  static const String deliveryChargeForDelivery = '/api/v3/seller/orders/delivery-charge-date-update';
  static const String digitalAuthorList = '/api/v3/seller/products/digital-author-list';
  static const String digitalPublishingHouse = '/api/v3/seller/products/digital-publishing-house-list';

  static const String getCouponDiscount = '/api/v3/seller/coupon/check-coupon';
  static const String placeOrderUri = '/api/v3/seller/pos/place-order';
  static const String getProductFromProductCode = '/api/v3/seller/pos/products';
  static const String customerSearchUri = '/api/v3/seller/pos/customers';
  static const String invoice = '/api/v3/seller/pos/get-invoice';
  static const String topSellingProduct = '/api/v3/seller/products/top-selling-product?limit=10&offset=';
  static const String mostPopularProduct = '/api/v3/seller/products/most-popular-product?limit=10&offset=';
  static const String topDeliveryMan = '/api/v3/seller/top-delivery-man';
  static const String deliveryManListUri = '/api/v3/seller/delivery-man/list';
  static const String deliveryManDetails = '/api/v3/seller/delivery-man/details/';
  static const String posProductList = '/api/v3/seller/pos/product-list';
  static const String searchPosProductList = '/api/v3/seller/pos/product-list';
  static const String shippingMethodOnOff = '/api/v3/seller/shipping-method/status';
  static const String updateProductQuantity = '/api/v3/seller/products/quantity-update';
  static const String productWiseReviewList = '/api/v3/seller/products/review-list/';
  static const String addDeliveryMan = '/api/v3/seller/delivery-man/store';
  static const String updateDeliveryMan = '/api/v3/seller/delivery-man/update';
  static const String deleteDeliveryman = '/api/v3/seller/delivery-man/delete/';
  static const String deliveryManOrderHistory = '/api/v3/seller/delivery-man/order-list/';
  static const String deliveryManEarning = '/api/v3/seller/delivery-man/earning/';
  static const String collectCashFromDeliveryMan = '/api/v3/seller/delivery-man/cash-receive';
  static const String emergencyContactAdd = '/api/v3/seller/delivery-man/emergency-contact/store';
  static const String emergencyContactUpdate = '/api/v3/seller/delivery-man/emergency-contact/update';
  static const String getEmergencyContactList = '/api/v3/seller/delivery-man/emergency-contact/list';
  static const String emergencyContactStatusOnOff = '/api/v3/seller/delivery-man/emergency-contact/status-update';
  static const String emergencyContactDelete = '/api/v3/seller/delivery-man/emergency-contact/delete';
  static const String deliveryManWithdrawList = '/api/v3/seller/delivery-man/withdraw/list';
  static const String deliveryManReviewList = '/api/v3/seller/delivery-man/reviews/';
  static const String deliveryManWithdrawDetails = '/api/v3/seller/delivery-man/withdraw/details/';
  static const String deliveryManWithdrawApprovedRejected = '/api/v3/seller/delivery-man/withdraw/status-update';
  static const String addNewCustomer = '/api/v3/seller/pos/customer-store';
  static const String productStatusOnOff = '/api/v3/seller/products/status-update';
  static const String deliveryManStatusOnOff = '/api/v3/seller/delivery-man/status-update';
  static const String businessAnalytics = '/api/v3/seller/order-statistics?statistics_type=';
  static const String productDetails = '/api/v3/seller/products/details/';
  static const String deliveryManOrderChangeLog = '/api/v3/seller/delivery-man/order-status-history/';
  static const String chartFilterData = '/api/v3/seller/get-earning-statitics?type=';
  static const String addNewCoupon = '/api/v3/seller/coupon/store';
  static const String getCouponList = '/api/v3/seller/coupon/list';
  static const String updateCoupon = '/api/v3/seller/coupon/update/';
  static const String deleteCoupon = '/api/v3/seller/coupon/delete/';
  static const String couponStatusUpdate = '/api/v3/seller/coupon/status-update/';
  static const String deliveryManCollectedCashList = '/api/v3/seller/delivery-man/collect-cash-list/';
  static const String couponCustomerList = '/api/v3/seller/coupon/customers?name=';
  // Seller package overview includes the active plan and available package plans.
  static const String sellerPackagesUri = '/api/v3/seller/packages';
  // Package payment endpoints are seller-only and keep offline requests pending for admin approval.
  static const String sellerPackagePayUri = '/api/v3/seller/packages/pay';
  static String sellerPackagePerformanceUri(int subscriptionId) => '/api/v3/seller/packages/$subscriptionId/performance';
  static String sellerPackageCancelUri(int subscriptionId) => '/api/v3/seller/packages/$subscriptionId/cancel';
  static const String sellerPackageOfflinePaymentUri = '/api/v3/seller/packages/offline-payment';
  // Premium promotion quotas are validated by the seller package subscription on the backend.
  static const String sellerSearchPromotionsUri = '/api/v3/seller/promotions/search';
  static const String sellerHomepagePromotionsUri = '/api/v3/seller/promotions/homepage';
  static const String temporaryClose = '/api/v3/seller/temporary-close';
  static const String vacation = '/api/v3/seller/vacation-add';
  static const String dynamicWithdrawMethod = '/api/v3/seller/withdraw-method-list';
  static const String orderAddressEdit = '/api/v3/seller/orders/address-update';
  static const String getNotificationList = '/api/v3/seller/notification?limit=20&offset=';
  static const String seenNotification = '/api/v3/seller/notification/view?id=';
  static const String stockLimitStatus = '/api/v3/seller/products/stock-limit-status';
  static const String reviewReply = '/api/v3/seller/shop-product-reviews-reply';
  static const String deleteDigitalProductVariationFile = '/api/v3/seller/products/delete-digital-product';
  static const String getSingleRefundModel = '/api/v3/seller/refund/single-item?id=';
  static const String getRestockList = '/api/v3/seller/products/restock-request-list';
  static const String restockUpdateProductQuantity = '/api/v3/seller/products/restock-request-stock-update';
  static const String restockBrandListUri = '/api/v3/seller/products/restock-request-brands-list';
  static const String restockRequestDelete = '/api/v3/seller/products/restock-request-delete?id=';
  static const String clearanceSaleProductList = '/api/v3/seller/clearance-sale/product-list';
  static const String clearanceSaleDeleteProduct = '/api/v3/seller/clearance-sale/product-delete?product_id=';
  static const String clearanceSaleDeleteAllProduct = '/api/v3/seller/clearance-sale/all-product-delete';
  static const String clearanceSaleProductStatusUpdate = '/api/v3/seller/clearance-sale/product-status-update';
  static const String clearanceSaleProductDiscountUpdate = '/api/v3/seller/clearance-sale/product-discount-update';
  static const String clearanceSaleConfigStatusUpdate = '/api/v3/seller/clearance-sale/config-status-update';
  static const String clearanceSaleConfigData = '/api/v3/seller/clearance-sale/config-data';
  static const String clearanceSaleConfigDataUpdate = '/api/v3/seller/clearance-sale/config-data-update';
  static const String clearanceSaleProductAdd = '/api/v3/seller/clearance-sale/product-add';
  static const String setUpOrder = '/api/v3/seller/orders/order-detail-info-update';
  static const String businessPagesUri = '/api/v1/business-pages?type=';
  static const String paymentWithdrawalMethodList = '/api/v3/seller/payment-information/withdrawal-method-list';
  static const String paymentInformationAdd = '/api/v3/seller/payment-information/add';
  static const String paymentInformationList = '/api/v3/seller/payment-information/list';
  static const String paymentInformationStatusUpdate = '/api/v3/seller/payment-information/status';
  static const String paymentInformationDelete = '/api/v3/seller/payment-information/delete';
  static const String paymentInformationDefault = '/api/v3/seller/payment-information/default';
  static const String paymentInformationUpdate = '/api/v3/seller/payment-information/update';
  static const String updateSetupGuideApp = '/api/v3/seller/update-setup-guide-app';
  static const String getTaxVatList = '/api/v1/vat-tax/get-taxVat-list';
  static const String getTaxAmount = '/api/v3/seller/pos/get-tax-amount';
  static const String getVatTaxReportList = '/api/v3/seller/get-vat-tax-report-list';
  static const String auctionVatTaxReportList = '/api/v3/seller/auction/get-vat-tax-report-list';
  static const String firebaseAuthTokenStore = '/api/v3/seller/auth/firebase-auth-token-store';
  static const String firebaseAuthVerify = '/api/v3/seller/auth/firebase-auth-verify';
  static const String checkVendorExistInfoPhone = '/api/v3/seller/auth/check-vendor-exist-info';
  static const String generateInvoice = '/api/v1/customer/order/generate-invoice?order_id=';
  static const String editOrderSubmit = '/api/v3/seller/orders/edit-order-submit';

  static const String editOrderValidation = '/api/v3/seller/orders/edit-order-validation';
  static const String switchToCod = '/api/v3/seller/orders/assign-order-in-cod';
  static const String editOrderAllProducts = '/api/v3/seller/products/';

  ///Auction
  static const String addAuctionProductUri = '/api/v3/seller/auction/products/store';
  static const String auctionProductListUri = '/api/v3/seller/auction/products/list';
  static const String deleteAuctionProductUri = '/api/v3/seller/auction/products/delete/';
  static const String updateAuctionProductUri = '/api/v3/seller/auction/products/update';
  static const String vendorAuctionDetailsUri = '/api/v3/seller/auction/products/details/';
  static const String vendorAuctionStatusToggle = '/api/v3/seller/auction/products/status/';
  static const String vendorAuctionBidsList = '/api/v3/seller/auction/bids/list/';
  static const String relaunchAuctionProductUri = '/api/v3/seller/auction/products/relaunch/';
  static const String auctionWithdrawRequest = '/api/v3/seller/auction/withdraws/request';
  static const String auctionPayCommission = '/api/v3/seller/auction/commission/pay/';


  /// TODO: update the below URI when the API is ready
  static const String auctionUploadTrackingUri = '/api/v3/seller/auction/products/tracking-url/';
  static const String auctionAddressUpdateUri = '/api/v3/seller/auction/products/address-update';
  static const String auctionPaymentStatusUri = '/api/v3/seller/auction/products/payment-status/';
  static const String auctionDeliveryStatusUpdateUri = '/api/v3/seller/auction/products/delivery-status/';
  static const String auctionGenerateInvoiceUri = '/api/v3/seller/auction/products/generate-invoice/';
  static const String auctionCancelUri = '/api/v3/seller/auction/products/cancel/';
  static const String auctionSalesReportUri = '/api/v3/seller/auction/sales-report';
  static const String auctionTransactionHistoryUri = '/api/v3/seller/auction/transaction-history';
  static const String auctionNotificationList = '/api/v3/seller/auction/notifications/list';
  static const String auctionMarkNotificationSeen = '/api/v3/seller/auction/notifications/seen';


  ///AI
  static const String productTitleGenerate = '/api/v3/seller/product/title-auto-fill';
  static const String productDescriptionGenerate = '/api/v3/seller/product/description-auto-fill';
  static const String productGeneralSetupGenerate = '/api/v3/seller/product/general-setup-auto-fill';
  static const String productPricingGenerate = '/api/v3/seller/product/price-others-auto-fill';
  static const String productVariationSetupGenerate = '/api/v3/seller/product/variation-setup-auto-fill';
  static const String productSeoSectionGenerate = '/api/v3/seller/product/seo-section-auto-fill';
  static const String productGenerateTitleGenerate = '/api/v3/seller/product/generate-title-suggestions';
  static const String productAnalyzeImageAutoGenerate = '/api/v3/seller/product/analyze-image-auto-fill';
  static const String generateLimitCheck = '/api/v3/seller/product/generate-limit-check';


  static const String auctionTitleAutoFill = '/api/v3/seller/auction/product/title-auto-fill';
  static const String auctionDescriptionAutoFill = '/api/v3/seller/auction/product/description-auto-fill';
  static const String auctionGeneralSetupAutoFill = '/api/v3/seller/auction/product/general-setup-auto-fill';
  static const String auctionShippingPolicyAutoFill = '/api/v3/seller/auction/product/shipping-policy-auto-fill';
  static const String auctionInfoAutoFill = '/api/v3/seller/auction/product/auction-info-auto-fill';
  static const String auctionSeoSectionAutoFill = '/api/v3/seller/auction/product/seo-section-auto-fill';
  static const String auctionAnalyzeImageAutoFill = '/api/v3/seller/auction/product/analyze-image-auto-fill';
  static const String auctionSetupAutoFill = '/api/v3/seller/auction/product/setup-auto-fill';
  static const String auctionGenerateTitleSuggestions = '/api/v3/seller/auction/product/generate-title-suggestions';




  ///address
  static const String geocodeUri = '/api/v1/mapapi/geocode-api';
  static const String searchLocationUri = '/api/v1/mapapi/place-api-autocomplete';
  static const String placeDetailsUri = '/api/v1/mapapi/place-api-details';
  static const String setCurrentLanguageUri = '/api/v3/seller/language-change';

  static const String deleteProductImage = '/api/v3/seller/products/delete-images';
  static const String getProductImage = '/api/v3/seller/products/get-product-images/';
  static const String deleteProductPreview = '/api/v3/seller/products/delete-preview-file';


  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String processing = 'processing';
  static const String processed = 'processed';
  static const String delivered = 'delivered';
  static const String failed = 'failed';
  static const String returned = 'returned';
  static const String cancelled = 'canceled';
  static const String outForDelivery = 'out_for_delivery';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
  static const String done = 'refunded';



  static const String orderWise = 'order_wise';
  static const String productWise = 'product_wise';
  static const String categoryWise = 'category_wise';



  static const String theme = 'theme';
  static const String currency = 'currency';
  static const String shippingType = 'shipping_type';
  static const String token = 'token';
  static const String countryCode = 'country_code';
  static const String languageCode = 'language_code';
  static const String cartList = 'cart_list';
  static const String userAddress = 'user_address';
  static const String userPassword = 'user_password';
  static const String userNumber = 'user_number';
  static const String searchAddress = 'search_address';
  static const String topic = 'six_valley_seller';
  static const String maintenanceModeTopic = 'maintenance_mode_start_vendor';
  static const String userEmail = 'user_email';
  static const String langKey = 'lang';
  static const String showCookies = 'cookies';
  static const String bluetoothMacAddress = 'bluetooth_mac_address';

  static List<LanguageModel> languages = [
    LanguageModel(imageUrl: Images.unitedKingdom, languageName: 'English', countryCode: 'US', languageCode: 'en'),
    LanguageModel(imageUrl: Images.arabic, languageName: 'Arabic', countryCode: 'SA', languageCode: 'ar'),
  ];

  static const double maxSizeOfASingleFile = 10;
  static const double maxLimitOfTotalFileSent = 5;
  static const double maxLimitOfFileSentINConversation = 25;
  static const int fileImageMaxLimit = 2;


  static const List<String> videoExtensions = [
    'mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm', 'mpeg', 'mpg', 'm4v', '3gp', 'ogv'
  ];

  static const List<String> imageExtensions = [
    'png',
    'jpg',
    'jpeg',
    'gif',
    'webp',
  ];

  static const List<String> documentExtensions = [
    'doc', 'docx', 'txt', 'csv', 'xls', 'xlsx', 'pdf',
  ];

  static const List<String> disallowedExtensions = [
    'php','php3','php4','php5','php7','php8','phtml','phar',
    'asp','aspx','jsp','cgi','pl','py','rb',
    'js','mjs','html','htm','xhtml',
    'sh','bash','bat','cmd','ps1','zsh','ksh',
    'exe','dll','so','bin','msi','app',
    'java','class','jar',
    '7z','gz','bz2','xz',
    'env','ini','conf','config','yml','yaml','log',
    'sql','db','bak','old','swp','tmp'
  ];

  static const List<GuidelineModel> inHouseShopGuidelineList = [
    GuidelineModel('store_availability', 'store_availability_description'),
    GuidelineModel('shop_details', 'shop_details_description'),
    GuidelineModel('visit_website', 'visit_website_description'),
    GuidelineModel('edit_shop', 'edit_shop_description'),
  ];

  static const List<GuidelineModel> paymentInfoGuidelineList = [
    GuidelineModel('benefit', 'benefit_description'),
  ];

  static const List<GuidelineModel> otherSetupGuidelineList = [
    GuidelineModel('order_setup', 'order_setup_description'),
    GuidelineModel('business_tin', 'business_tin_description'),
  ];


}
