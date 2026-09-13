class SellerPromotionOverviewModel {
  final SellerPromotionSummary summary;
  final List<SellerPromotionProduct> products;

  SellerPromotionOverviewModel({required this.summary, required this.products});

  factory SellerPromotionOverviewModel.fromJson(Map<String, dynamic> json, {required SellerPromotionType type}) {
    return SellerPromotionOverviewModel(
      summary: SellerPromotionSummary.fromJson(
        Map<String, dynamic>.from(json['summary'] as Map? ?? const {}), type: type,
      ),
      products: (json['products'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => SellerPromotionProduct.fromJson(Map<String, dynamic>.from(item), type: type))
          .toList(),
    );
  }
}

enum SellerPromotionType { search, homepage }

class SellerPromotionSummary {
  final String? activePackage;
  final int limit;
  final int used;
  final int remaining;
  final int durationDays;
  final bool canPromote;

  SellerPromotionSummary({
    required this.activePackage, required this.limit,
    required this.used, required this.remaining, required this.durationDays, required this.canPromote,
  });

  factory SellerPromotionSummary.fromJson(Map<String, dynamic> json, {required SellerPromotionType type}) {
    final prefix = type == SellerPromotionType.search ? 'search_promotion' : 'homepage_promotion';
    return SellerPromotionSummary(
      activePackage: json['active_package']?.toString(),
      limit: _promotionInt(json['${prefix}_limit']),
      used: _promotionInt(json['used_${prefix}_limit']),
      remaining: _promotionInt(json['remaining_${prefix}_limit']),
      durationDays: _promotionInt(json['${prefix}_duration_days']),
      canPromote: _promotionBool(json['can_promote']),
    );
  }
}

class SellerPromotionProduct {
  final int id;
  final String name;
  final bool isPromoted;
  final bool hasPendingRequest;
  final String? approvalStatus;
  final String? reviewNote;
  final String? expiresAt;

  SellerPromotionProduct({required this.id, required this.name, required this.isPromoted, required this.hasPendingRequest, this.approvalStatus, this.reviewNote, this.expiresAt});

  factory SellerPromotionProduct.fromJson(Map<String, dynamic> json, {required SellerPromotionType type}) {
    final prefix = type == SellerPromotionType.search ? 'search' : 'homepage';
    final promotion = json['${prefix}_promotion'] as Map?;
    return SellerPromotionProduct(
      id: _promotionInt(json['id']),
      name: json['name']?.toString() ?? '',
      isPromoted: _promotionBool(json['is_${prefix}_promoted']),
      hasPendingRequest: _promotionBool(json['has_pending_ad_request']),
      approvalStatus: promotion?['approval_status']?.toString(),
      reviewNote: promotion?['review_note']?.toString(),
      expiresAt: promotion?['expires_at']?.toString(),
    );
  }
}

int _promotionInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;
bool _promotionBool(dynamic value) => value == true || value == 1 || value?.toString() == '1';
