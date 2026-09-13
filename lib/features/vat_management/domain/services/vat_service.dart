import 'package:sixvalley_vendor_app/features/vat_management/domain/repositories/vat_repository_interface.dart';
import 'package:sixvalley_vendor_app/features/vat_management/domain/services/vat_service_interface.dart';

class VatService implements VatServiceInterface {
  final VatRepositoryInterface vatRepoInterface;
  VatService({required this.vatRepoInterface});

  @override
  Future getVatReport(int? limit, int? offset, String? startDate, String? endDate) {
    return vatRepoInterface.getVatReport(limit, offset, startDate, endDate);
  }
}