import 'dart:collection';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:open_file/open_file.dart' show OpenFile;
import 'package:open_file_manager/open_file_manager.dart';
import 'package:path/path.dart' as path show join;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_vendor_app/data/model/response/base/api_response.dart';
import 'package:sixvalley_vendor_app/features/order/controllers/order_controller.dart';
import 'package:sixvalley_vendor_app/features/order/domain/models/order_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/domain/models/order_details_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/domain/models/order_setup_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/domain/models/seller_order_insurance_model.dart';
import 'package:sixvalley_vendor_app/features/order_details/domain/services/order_details_service_interface.dart';
import 'package:sixvalley_vendor_app/helper/api_checker.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/main.dart';
import 'package:sixvalley_vendor_app/utill/images.dart';

class OrderDetailsController extends ChangeNotifier {
  final OrderDetailsServiceInterface orderDetailsServiceInterface;
  OrderDetailsController({required this.orderDetailsServiceInterface});

  List<OrderDetailsModel>? _orderDetails;
  List<OrderDetailsModel>? get orderDetails => _orderDetails;
  List<String> _orderStatusList = [];
  List<String> get orderStatusList => _orderStatusList;
  String? _orderStatusType = '';
  String? get orderStatusType => _orderStatusType;
  int _paymentMethodIndex = 0;
  int get paymentMethodIndex => _paymentMethodIndex;
  File? _selectedFileForImport;
  File? get selectedFileForImport => _selectedFileForImport;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUploadLoading = false;
  bool get isUploadLoading => _isUploadLoading;

  final bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  Set<Marker> _markers = HashSet<Marker>();
  Set<Marker> get markers => _markers;
  bool _isDownloadLoading = false;
  bool get isDownloadLoading => _isDownloadLoading;
  int _downloadIndex = -1;
  int get downloadIndex => _downloadIndex;

  late OrderSetupModel orderSetupModel;

  bool _isInvoiceLoading = false;
  bool get isInvoiceLoading => _isInvoiceLoading;

  SellerOrderInsuranceEnvelope? _sellerOrderInsurance;
  SellerOrderInsuranceEnvelope? get sellerOrderInsurance =>
      _sellerOrderInsurance;
  bool _insuranceLoading = false;
  bool get insuranceLoading => _insuranceLoading;
  bool _shippingProofLoading = false;
  bool get shippingProofLoading => _shippingProofLoading;

  String? loadError;
  String? proofError;
  List<Map<String, dynamic>> shippingProofs = [];
  int _detailsGeneration = 0;
  String? _currentReference;
  bool get actionInProgress => _insuranceLoading || _shippingProofLoading;

  Future<void> getOrderDetails(String orderID) async {
    final generation = ++_detailsGeneration;
    final sameOrder = _currentReference == orderID;
    _currentReference = orderID;
    if (!sameOrder) {
      _orderDetails = null;
      _sellerOrderInsurance = null;
      shippingProofs = [];
    }
    loadError = null;
    proofError = null;
    _insuranceLoading = true;
    notifyListeners();
    try {
      final insuranceResponse =
          await orderDetailsServiceInterface.getSellerOrderInsurance(orderID);
      if (generation != _detailsGeneration) return;
      if (insuranceResponse.response?.statusCode != 200) {
        throw StateError('insurance_access_check_failed');
      }
      _sellerOrderInsurance = SellerOrderInsuranceEnvelope.fromJson(
          Map<String, dynamic>.from(insuranceResponse.response!.data));
      if (_sellerOrderInsurance?.insurance?.detailsHidden == true) {
        _orderDetails = [];
        return;
      }
      final apiResponse =
          await orderDetailsServiceInterface.getOrderDetails(orderID);
      if (generation != _detailsGeneration) return;
      if (apiResponse.response?.statusCode != 200 ||
          apiResponse.response?.data is! List) {
        throw StateError('order_load_failed');
      }
      _orderDetails = (apiResponse.response!.data as List)
          .map((item) => OrderDetailsModel.fromJson(item))
          .toList();
      if (_orderDetails!.isNotEmpty) {
        await initOrderStatusList(
            _orderDetails!.first.order?.shippingResponsibility ?? '');
        final id = _orderDetails!.first.order?.id;
        if (id != null) {
          final proofs =
              await orderDetailsServiceInterface.getShippingProofs('$id');
          if (generation != _detailsGeneration) return;
          if (proofs.response?.statusCode == 200) {
            shippingProofs = (proofs.response!.data['proofs'] as List? ?? [])
                .map((p) => Map<String, dynamic>.from(p))
                .toList();
          } else {
            proofError = 'seller_journey_proof_load_failed';
          }
        }
      }
    } catch (_) {
      if (generation == _detailsGeneration) {
        _orderDetails = [];
        loadError = 'seller_journey_load_failed';
      }
    } finally {
      if (generation == _detailsGeneration) {
        _insuranceLoading = false;
        notifyListeners();
      }
    }
  }

  Future<String?> paySellerOrderInsurance(
      String orderID, String paymentMethod) async {
    if (actionInProgress) return null;
    _insuranceLoading = true;
    notifyListeners();
    try {
      final response = await orderDetailsServiceInterface
          .paySellerOrderInsurance(orderID, paymentMethod);
      if (response.response?.statusCode == 200) {
        final redirect = response.response!.data['redirect_link']?.toString();
        if (_currentReference == orderID) await getOrderDetails(orderID);
        return redirect;
      }
      ApiChecker.checkApi(response);
      return null;
    } finally {
      _insuranceLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitSellerOrderInsuranceOffline(
      String orderID, String methodId, String proofPath, String note) async {
    if (actionInProgress) return false;
    _insuranceLoading = true;
    notifyListeners();
    try {
      final response =
          await orderDetailsServiceInterface.submitSellerOrderInsuranceOffline(
              orderID, methodId, proofPath, note);
      if (response.response?.statusCode == 200) {
        if (_currentReference == orderID) await getOrderDetails(orderID);
        return true;
      }
      ApiChecker.checkApi(response);
      return false;
    } finally {
      _insuranceLoading = false;
      notifyListeners();
    }
  }

  Future<bool> respondToShipping(
      String orderID, String decision, String reason) async {
    if (actionInProgress) return false;
    final reference = _currentReference;
    _shippingProofLoading = true;
    notifyListeners();
    try {
      final response = await orderDetailsServiceInterface.respondToShipping(
          orderID, decision, reason);
      if (response.response?.statusCode == 200) {
        if (decision != 'reject' && _currentReference == reference) {
          await getOrderDetails(reference ?? orderID);
        }
        return true;
      }
      ApiChecker.checkApi(response);
      return false;
    } finally {
      _shippingProofLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitShippingProof(
      String orderID, String status, String proofPath, String note) async {
    if (actionInProgress) return false;
    final reference = _currentReference;
    _shippingProofLoading = true;
    notifyListeners();
    try {
      final response = await orderDetailsServiceInterface.submitShippingProof(
          orderID, status, proofPath, note);
      if (response.response?.statusCode == 201) {
        if (_currentReference == reference) await getOrderDetails(reference ?? orderID);
        return true;
      }
      ApiChecker.checkApi(response);
      return false;
    } finally {
      _shippingProofLoading = false;
      notifyListeners();
    }
  }

  Future<void> openShippingProof(
      String orderID, int proofId, String originalName) async {
    final response = await orderDetailsServiceInterface.getShippingProofFile(
        orderID, proofId);
    if (response.response?.statusCode != 200)
      throw StateError('proof_download_failed');
    final directory = await getTemporaryDirectory();
    final extension = originalName.split('.').last.toLowerCase();
    if (![
      'jpg',
      'jpeg',
      'png',
      'webp',
      'pdf',
      'mp4',
      'mov',
      'avi',
      'mkv',
      'webm'
    ].contains(extension)) throw StateError('unsupported_proof');
    final file =
        File(path.join(directory.path, 'shipping-proof-$proofId.$extension'));
    await file.writeAsBytes(List<int>.from(response.response!.data));
    await OpenFile.open(file.path);
  }

  Future<void> initOrderStatusList(String type) async {
    ApiResponse apiResponse =
        await orderDetailsServiceInterface.getOrderStatusList(type);
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _orderStatusList = [];
      _orderStatusList.addAll(apiResponse.response!.data);
      _orderStatusType = _orderStatusList.firstOrNull;
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  void setPaymentMethodIndex(int index) {
    _paymentMethodIndex = index;
    notifyListeners();
  }

  void setSelectedFileName(File? fileName) {
    _selectedFileForImport = fileName;
    notifyListeners();
  }

  Future<ApiResponse> uploadReadyAfterSellDigitalProduct(BuildContext context,
      File? digitalProductAfterSellFile, String token, String orderId) async {
    _isUploadLoading = true;
    notifyListeners();
    ApiResponse response =
        await orderDetailsServiceInterface.uploadAfterSellDigitalProduct(
            digitalProductAfterSellFile, token, orderId);
    if (response.response!.statusCode == 200) {
      Navigator.of(Get.context!).pop();
      _isUploadLoading = false;
      showCustomSnackBarWidget(
          getTranslated("digital_product_uploaded_successfully", Get.context!),
          Get.context!,
          isError: false);
    } else {
      _isUploadLoading = false;
    }
    _isUploadLoading = false;
    notifyListeners();
    return response;
  }

  BillingAddressData getAddressForMap(
      BillingAddressData shipping, BillingAddressData? billing) {
    if (shipping.latitude != null && shipping.longitude != null) {
      return shipping;
    } else if (billing?.latitude != null && billing?.longitude != null) {
      return billing!;
    } else {
      return shipping;
    }
  }

  void setMarker(BillingAddressData address) async {
    _markers = HashSet<Marker>();
    Uint8List destinationImageData = await convertAssetToUnit8List(
      Images.marker,
      width: 50,
    );

    _markers.add(Marker(
      markerId: const MarkerId('destination'),
      position: LatLng(
          double.parse(address.latitude!), double.parse(address.longitude!)),
      icon: BitmapDescriptor.bytes(destinationImageData),
    ));

    notifyListeners();
  }

  Future<Uint8List> convertAssetToUnit8List(String imagePath,
      {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void productDownload(
      {required String url,
      required String fileName,
      required int index,
      bool isIos = false}) async {
    _isDownloadLoading = true;
    _downloadIndex = index;
    notifyListeners();

    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    var selectedFolderType = AndroidFolderType.download;
    final subFolderPathCtrl = TextEditingController();

    List<String> fileTypes = [
      '.txt',
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.webp',
      '.mp3',
      '.wav',
      '.ogg',
      '.m4a',
      '.aac',
      '.mp4',
      '.avi',
      '.mkv',
      '.webm',
      '.3gp',
      '.pdf',
      '.doc'
    ];

    if (isIos) {
      HttpClientResponse apiResponse =
          await orderDetailsServiceInterface.productDownload(url);
      if (apiResponse.statusCode == 200) {
        List<int> downloadData = [];
        Directory downloadDirectory;

        if (Platform.isIOS) {
          downloadDirectory = await getApplicationDocumentsDirectory();
        } else {
          downloadDirectory = Directory('/storage/emulated/0/Download');
          if (!await downloadDirectory.exists())
            downloadDirectory = (await getExternalStorageDirectory())!;
        }

        String filePathName = "${downloadDirectory.path}/$fileName";
        File savedFile = File(filePathName);
        bool fileExists = await savedFile.exists();

        if (fileExists) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
              SnackBar(content: Text(getTranslated('file_already_downloaded', Get.context!) ?? '')));
          _isDownloadLoading = false;
        } else {
          apiResponse.listen((d) => downloadData.addAll(d), onDone: () {
            savedFile.writeAsBytes(downloadData);
          });
          showCustomSnackBarWidget(
              getTranslated('product_downloaded_successfully', Get.context!),
              Get.context!,
              isError: false);

          _isDownloadLoading = false;
          Navigator.of(Get.context!).pop();
        }
      } else {
        _isDownloadLoading = false;

        showCustomSnackBarWidget(
            getTranslated('product_download_failed', Get.context!),
            Get.context!);
        Navigator.of(Get.context!).pop();
      }
    } else {
      String? task;
      Directory downloadDirectory = Directory('/storage/emulated/0/Download');
      String filePathName = "${downloadDirectory.path}/$fileName";
      File savedFile = File(filePathName);
      bool fileExists = await savedFile.exists();

      if (fileExists) {
        showCustomSnackBarWidget(
            getTranslated('file_already_downloaded', Get.context!),
            Get.context!);
      } else {
        task = await FlutterDownloader.enqueue(
          url: url,
          savedDir: downloadDirectory.path,
          fileName: fileName,
          showNotification: true,
          saveInPublicStorage: true,
          openFileFromNotification: true,
        );

        if (task != null) {
          if (!fileTypes.contains(getFileExtension(fileName))) {
            showCustomSnackBarWidget(
                getTranslated('product_downloaded_successfully', Get.context!),
                Get.context!,
                isError: false);
            await openFileManager(
              androidConfig: AndroidConfig(
                folderType: selectedFolderType,
              ),
              iosConfig: IosConfig(
                folderPath: subFolderPathCtrl.text.trim(),
              ),
            );
          } else {
            // Navigator.of(Get.context!).pop();
          }
        } else {
          showCustomSnackBarWidget(
              getTranslated('product_download_failed', Get.context!),
              Get.context!);
          // Navigator.of(Get.context!).pop();
        }
      }
      _isDownloadLoading = false;
    }
    notifyListeners();
  }

  String getFileExtension(String fileName) {
    if (fileName.contains('.')) {
      return '.${fileName.split('.').last}';
    }
    return '';
  }

  void emptyOrderDetails() {
    _detailsGeneration++;
    _currentReference = null;
    _sellerOrderInsurance = null;
    shippingProofs = [];
    _orderDetails = null;
    loadError = null;
    _insuranceLoading = false;
    notifyListeners();
  }

  Future<void> setUpOrder({required OrderSetupModel orderSetupModel}) async {
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse =
        await orderDetailsServiceInterface.setUpOrder(orderSetupModel);
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      String? message = getTranslated('updated_successfully', Get.context!);
      showCustomSnackBarWidget(message, Get.context!,
          isToaster: true, isError: false, sanckBarType: SnackBarType.success);

      await getOrderDetails(orderSetupModel.orderId.toString());
      Provider.of<OrderController>(Get.context!, listen: false).getOrderList(
          Get.context!,
          1,
          'all',
          Provider.of<OrderController>(Get.context!, listen: false)
              .filterModel);
      _isLoading = false;
      notifyListeners();
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    _isLoading = false;
    notifyListeners();
  }

  void initializeOrderSetupModel({required Order? order}) {
    orderSetupModel = OrderSetupModel(
        orderId: order?.id,
        paymentStatus: order?.paymentStatus,
        orderStatus: order?.orderStatus);
  }

  Future<ApiResponse> getOrderInvoice(String orderID, context) async {
    _isInvoiceLoading = true;
    notifyListeners();
    ApiResponse apiResponse =
        await orderDetailsServiceInterface.getOrderInvoice(orderID);
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      await requestPermissions();
      final downloadsDirectory = Directory('/storage/emulated/0/Download');
      List<int> intList = List<int>.from(apiResponse.response!.data);

      String fileName = '$orderID.pdf';
      var filePath = path.join(downloadsDirectory.path, '$orderID.pdf');

      int fileCounter = 1;

      while (await File(filePath).exists()) {
        fileName = '$orderID($fileCounter).pdf';
        filePath = path.join(downloadsDirectory.path, fileName);
        fileCounter++;
      }

      final file = File(filePath);
      await file.writeAsBytes(intList);
      await OpenFile.open(filePath);
      showCustomSnackBarWidget(
          getTranslated('invoice_downloaded_successfully', context),
          Get.context!,
          sanckBarType: SnackBarType.success);
    } else {
      showCustomSnackBarWidget(
          getTranslated('invoice_download_failed', context), Get.context!,
          sanckBarType: SnackBarType.success);
    }
    _isInvoiceLoading = false;
    notifyListeners();
    return apiResponse;
  }

  Future<void> requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }
}
