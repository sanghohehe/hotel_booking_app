class VoucherModel {
  final String id;
  final String code;
  final int discountPercent;
  final int maxUses;
  final int usedCount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;

  VoucherModel({
    required this.id,
    required this.code,
    required this.discountPercent,
    required this.maxUses,
    required this.usedCount,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.createdAt,
  });

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isNotStarted => DateTime.now().isBefore(startDate);
  bool get isFull => usedCount >= maxUses;
  bool get isValid => isActive && !isExpired && !isNotStarted && !isFull;

  double discountAmount(double totalPrice) {
    return totalPrice * discountPercent / 100;
  }

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'] as String,
      code: json['code'] as String,
      discountPercent: json['discount_percent'] as int,
      maxUses: json['max_uses'] as int,
      usedCount: json['used_count'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'discount_percent': discountPercent,
    'max_uses': maxUses,
    'start_date': startDate.toIso8601String().split('T').first,
    'end_date': endDate.toIso8601String().split('T').first,
    'is_active': isActive,
  };
}
