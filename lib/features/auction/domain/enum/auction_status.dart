enum AuctionStatus {
  all('all'),
  scheduled('scheduled'),
  pending('pending'),
  approved('approved'),
  upcoming('upcoming'),
  live('live'),
  complete('complete'),
  rejected('rejected'),
  unsold('unsold'),
  canceled('canceled'),
  readyToClaim('ready_to_claim'),
  readyToDelivery('ready_to_delivery'),
  onTheWay('on_the_way'),
  delivered('delivered'),
  purchaseComplete('purchase_complete'),
  recreated('recreated');

  final String label;

  const AuctionStatus(this.label);

  String get translationKey => label;

  static AuctionStatus fromLabel(String value) {
    return AuctionStatus.values.firstWhere(
      (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => AuctionStatus.pending,
    );
  }

  static AuctionStatus fromString(String value) {
    final normalized = value.toLowerCase();
    return AuctionStatus.values.firstWhere(
      (e) => e.label.toLowerCase() == normalized || e.name.toLowerCase() == normalized,
      orElse: () => AuctionStatus.pending,
    );
  }

  static AuctionStatus fromAuctionDetails({
    required String? status,
    String? deliveryStatus,
  }) {
    switch (status) {
      case 'upcoming':
        return AuctionStatus.upcoming;
      case 'live':
        return AuctionStatus.live;
      case 'ready_to_claim':
        return AuctionStatus.readyToClaim;
      case 'purchase_complete':
        if (deliveryStatus == null) return AuctionStatus.purchaseComplete;
        return _fromDeliveryStatus(deliveryStatus);
      case 'unsold':
        return AuctionStatus.unsold;
      case 'canceled':
        return AuctionStatus.canceled;
      case 'ready_to_delivery':
        return AuctionStatus.readyToDelivery;
      case 'on_the_way':
        return AuctionStatus.onTheWay;
      case 'delivered':
        return AuctionStatus.delivered;
      default:
        return AuctionStatus.upcoming;
    }
  }

  static AuctionStatus _fromDeliveryStatus(String deliveryStatus) {
    switch (deliveryStatus) {
      case 'ready_to_delivery':
        return AuctionStatus.readyToDelivery;
      case 'on_the_way':
        return AuctionStatus.onTheWay;
      case 'delivered':
        return AuctionStatus.delivered;
      default:
        return AuctionStatus.purchaseComplete;
    }
  }

  static List<AuctionStatus> get filterValues => [
    all,
    upcoming,
    live,
    readyToClaim,
    readyToDelivery,
    onTheWay,
    purchaseComplete,
    unsold,
  ];

  bool get isScheduled => this == AuctionStatus.scheduled;
  bool get isPending => this == AuctionStatus.pending;
  bool get isApproved => this == AuctionStatus.approved;
  bool get isUpcoming => this == AuctionStatus.upcoming;
  bool get isLive => this == AuctionStatus.live;
  bool get isCompleted => this == AuctionStatus.complete;
  bool get isRejected => this == AuctionStatus.rejected;
  bool get isUnsold => this == AuctionStatus.unsold;
  bool get isReadyToClaim => this == AuctionStatus.readyToClaim;
  bool get isReadyToDelivery => this == AuctionStatus.readyToDelivery;
  bool get isOnTheWay => this == AuctionStatus.onTheWay;
  bool get isDelivered => this == AuctionStatus.delivered;
  bool get isPurchaseComplete => this == AuctionStatus.purchaseComplete;
  bool get isCanceled => this == AuctionStatus.canceled;
  bool get isRecreated => this == AuctionStatus.recreated;

  bool get isEditableStatus =>
      this == AuctionStatus.scheduled ||
      this == AuctionStatus.pending ||
      this == AuctionStatus.approved ||
      this == AuctionStatus.upcoming;
}
