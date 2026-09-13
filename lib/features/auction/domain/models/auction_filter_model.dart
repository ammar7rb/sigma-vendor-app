import 'package:sixvalley_vendor_app/features/auction/domain/enum/auction_status.dart';

class AuctionTabFilterConfig {
  final bool showStatus;
  final bool showAuctionDuration;
  final bool showEndingTime;
  final bool showAuctionStatus;
  final bool showSorting;
  final bool showClaimStatus;
  final bool showDisbursement;
  final bool showBrand;
  final bool showCategory;

  const AuctionTabFilterConfig({
    this.showStatus = false,
    this.showAuctionDuration = false,
    this.showEndingTime = false,
    this.showAuctionStatus = false,
    this.showSorting = false,
    this.showClaimStatus = false,
    this.showDisbursement = false,
    this.showBrand = true,
    this.showCategory = true,
  });

  static AuctionTabFilterConfig forTab(int tabIndex) {
    switch (tabIndex) {
      case 0: // All
        return const AuctionTabFilterConfig(
          showStatus: true,
          showAuctionDuration: true,
          showEndingTime: true,
          showAuctionStatus: true,
          showSorting: true,
          showBrand: true,
          showCategory: true,
        );
      case 1: // Upcoming
        return const AuctionTabFilterConfig(
          showStatus: true,
          showAuctionDuration: true,
          showBrand: true,
          showCategory: true,
        );
      case 2: // Live
        return const AuctionTabFilterConfig(
          showStatus: true,
          showEndingTime: true,
          showSorting: true,
          showBrand: true,
          showCategory: true,
        );
      case 3: // Ready to Claim
        return const AuctionTabFilterConfig(
          showClaimStatus: true,
          showBrand: true,
          showCategory: true,
        );
      case 4: // Purchase Complete
        return const AuctionTabFilterConfig(
          showDisbursement: true,
          showBrand: true,
          showCategory: true,
        );
      case 5: // Ready to Delivery
        return const AuctionTabFilterConfig(
          showBrand: true,
          showCategory: true,
        );
      case 6: // On the Way
        return const AuctionTabFilterConfig(
          showBrand: true,
          showCategory: true,
        );
      case 7: // Delivered
        return const AuctionTabFilterConfig(
          showBrand: true,
          showCategory: true,
        );
      case 8: // Unsold
        return const AuctionTabFilterConfig(
          showSorting: true,
          showBrand: true,
          showCategory: true,
        );
      default:
        return const AuctionTabFilterConfig(
          showBrand: true,
          showCategory: true,
        );
    }
  }

  bool get hasAdvancedFilters =>
      showStatus || showAuctionDuration || showEndingTime || showAuctionStatus || showSorting || showClaimStatus || showDisbursement;
}

class AuctionFilterParams {
  final String? search;
  final ApprovalStatus? approvalStatus;
  final Set<AuctionStatus> selectedAuctionStatuses;
  final DurationFilter? durationFilter;
  final DateTime? from;
  final DateTime? to;
  final SortBy? sortBy;
  final AuctionClaimStatus? auctionClaimStatus;
  final Set<Disbursement> disbursement;
  final Set<ActiveStatus> activeStatuses;
  final AuctionEndingTimeFilter? endingTime;
  final AuctionEndingTimeFilter? claimDuration;
  final Set<int> selectedBrandIds;
  final Set<int> selectedCategoryIds;

  const AuctionFilterParams({
    this.search,
    this.approvalStatus,
    this.selectedAuctionStatuses = const {},
    this.durationFilter,
    this.from,
    this.to,
    this.sortBy,
    this.auctionClaimStatus,
    this.disbursement = const {},
    this.activeStatuses = const {},
    this.endingTime,
    this.claimDuration,
    this.selectedBrandIds = const {},
    this.selectedCategoryIds = const {},
  });


  int get activeCount {
    int count = 0;
    if (sortBy != null) count++;
    if (activeStatuses.isNotEmpty) count++;
    if (endingTime != null) count++;
    if (claimDuration != null) count++;
    if (durationFilter != null) count++;
    if (selectedBrandIds.isNotEmpty) count++;
    if (selectedCategoryIds.isNotEmpty) count++;
    if (selectedAuctionStatuses.isNotEmpty) count++;
    if (auctionClaimStatus != null) count++;
    if (disbursement.isNotEmpty) count++;
    return count;
  }


  int activeCountForTab(int tabIndex) {
    final config = AuctionTabFilterConfig.forTab(tabIndex);
    int count = 0;
    if (config.showSorting && sortBy != null) count++;
    if (config.showStatus && activeStatuses.isNotEmpty) count++;
    if (config.showAuctionDuration && durationFilter != null) count++;
    if (config.showEndingTime && endingTime != null) count++;
    if (config.showAuctionStatus && selectedAuctionStatuses.isNotEmpty) count++;
    if (config.showClaimStatus && auctionClaimStatus != null) count++;
    if (config.showClaimStatus && claimDuration != null &&
        (claimDuration!.min != 0 || claimDuration!.max != claimDuration!.unit.maxRange)) {
      count++;
    }
    if (config.showDisbursement && disbursement.isNotEmpty) count++;
    if (config.showBrand && selectedBrandIds.isNotEmpty) count++;
    if (config.showCategory && selectedCategoryIds.isNotEmpty) count++;
    return count;
  }

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {};
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (approvalStatus != null) params['approval_status'] = approvalStatus!.value;
    if (selectedAuctionStatuses.isNotEmpty) {
      params['auction_status'] = selectedAuctionStatuses.map((s) => s.label).toList();
    }
    if (durationFilter != null) {
      params['auction_duration'] = durationFilter!.value;
    }
    if (from != null) params['start_date'] = from!.toIso8601String().split('T').first;
    if (to != null) params['end_date'] = to!.toIso8601String().split('T').first;
    if (sortBy != null) params['sort_by'] = sortBy!.value;
    if (auctionClaimStatus != null) params['auction_claim_status'] = auctionClaimStatus!.value;
    if (activeStatuses.isNotEmpty) {
      params['auction_active_status'] = activeStatuses.map((s) => s.numericValue).toList();
    }
    if (disbursement.isNotEmpty) {
      params['disbursement'] = disbursement.first.value;
    }
    if (selectedBrandIds.isNotEmpty) {
      params['brand_ids'] = selectedBrandIds.toList();
    }
    if (selectedCategoryIds.isNotEmpty) {
      params['category_ids'] = selectedCategoryIds.toList();
    }
    if (endingTime != null) params.addAll(endingTime!.toQueryParams());
    if (claimDuration != null) params.addAll(claimDuration!.toClaimQueryParams());
    return params;
  }

  AuctionFilterParams copyWith({
    String? search,
    ApprovalStatus? approvalStatus,
    Set<AuctionStatus>? selectedAuctionStatuses,
    DurationFilter? durationFilter,
    DateTime? from,
    DateTime? to,
    SortBy? sortBy,
    Set<ActiveStatus>? activeStatuses,
    AuctionEndingTimeFilter? endingTime,
    AuctionEndingTimeFilter? claimDuration,
    Set<int>? selectedBrandIds,
    Set<int>? selectedCategoryIds,
    AuctionClaimStatus? auctionClaimStatus,
    Set<Disbursement>? disbursement,
    bool clearSortBy = false,
    bool clearEndingTime = false,
    bool clearClaimDuration = false,
    bool clearDates = false,
    bool clearAuctionStatus = false,
    bool clearDuration = false,
    bool clearClaimStatus = false,
    bool clearDisbursement = false,
  }) {
    return AuctionFilterParams(
      search: search ?? this.search,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      selectedAuctionStatuses:
      clearAuctionStatus ? {} : (selectedAuctionStatuses ?? this.selectedAuctionStatuses),
      durationFilter: clearDuration ? null : (durationFilter ?? this.durationFilter),
      from: clearDates ? null : (from ?? this.from),
      to: clearDates ? null : (to ?? this.to),
      sortBy: clearSortBy ? null : (sortBy ?? this.sortBy),
      activeStatuses: activeStatuses ?? this.activeStatuses,
      endingTime: clearEndingTime ? null : (endingTime ?? this.endingTime),
      claimDuration: clearClaimDuration ? null : (claimDuration ?? this.claimDuration),
      selectedBrandIds: selectedBrandIds ?? this.selectedBrandIds,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      auctionClaimStatus:
      clearClaimStatus ? null : (auctionClaimStatus ?? this.auctionClaimStatus),
      disbursement: clearDisbursement ? {} : (disbursement ?? this.disbursement),
    );
  }
}

enum DurationFilter {
  today('today'),
  thisWeek('this_week'),
  thisMonth('this_month'),
  thisYear('this_year'),
  custom('custom');

  const DurationFilter(this.value);
  final String value;
  String get translationKey => value;

  static DurationFilter? fromString(String? value) =>
      DurationFilter.values.where((e) => e.value == value).firstOrNull;
}

enum ApprovalStatus {
  pending('pending'),
  rejected('rejected'),
  approved('approved');

  const ApprovalStatus(this.value);
  final String value;
  String get translationKey => value;

  static ApprovalStatus? fromString(String? value) =>
      ApprovalStatus.values.where((e) => e.value == value).firstOrNull;
}


enum SortBy {
  topBidding('top_bidding'),
  noBidsYet('no_bids_yet'),
  notClaimed('not_claimed'),
  endingSoon('ending_soon'),
  trending('trending'),
  latest('latest');

  const SortBy(this.value);
  final String value;
  String get translationKey => value;

  static SortBy? fromString(String? value) =>
      SortBy.values.where((e) => e.value == value).firstOrNull;
}

enum AuctionClaimStatus {
  notClaimed('not_claimed'),
  noBidsYet('no_bids_yet');

  const AuctionClaimStatus(this.value);
  final String value;
  String get translationKey => value;

  static AuctionClaimStatus? fromString(String? value) => AuctionClaimStatus.values.where((e) => e.value == value).firstOrNull;
}

enum Disbursement {
  adminWillPay('admin_will_pay'),
  sellerWillPay('seller_will_pay');

  const Disbursement(this.value);
  final String value;
  String get translationKey => value;

  static Disbursement? fromString(String? value) => Disbursement.values.where((e) => e.value == value).firstOrNull;
}

enum ActiveStatus {
  active('active'),
  inactive('inactive');

  const ActiveStatus(this.value);
  final String value;
  String get translationKey => value;
  int get numericValue => this == ActiveStatus.active ? 1 : 0;

  static ActiveStatus? fromString(String? value) =>
      ActiveStatus.values.where((e) => e.value == value).firstOrNull;
}

enum EndingTimeUnit {
  minute('minute'),
  hour('hour'),
  day('day');

  const EndingTimeUnit(this.value);
  final String value;
  String get translationKey => value;

  int get maxRange {
    switch (this) {
      case EndingTimeUnit.minute:
        return 60;
      case EndingTimeUnit.hour:
        return 24;
      case EndingTimeUnit.day:
        return 30;
    }
  }

  static EndingTimeUnit fromString(String value) => EndingTimeUnit.values.firstWhere((e) => e.value == value, orElse: () => EndingTimeUnit.hour);
}

class AuctionEndingTimeFilter {
  final EndingTimeUnit unit;
  final int min;
  final int max;

  const AuctionEndingTimeFilter({
    required this.unit,
    required this.min,
    required this.max,
  });

  Map<String, dynamic> toQueryParams() => {
    'ending_duration_unit': unit.value,
    'ending_duration_min': min,
    'ending_duration_max': max,
  };

  Map<String, dynamic> toClaimQueryParams() => {
    'claim_duration_unit': unit.value,
    'claim_duration_min': min,
    'claim_duration_max': max,
  };
}