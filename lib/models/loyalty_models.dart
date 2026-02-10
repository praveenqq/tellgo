import 'package:equatable/equatable.dart';

/// Loyalty Points Model
/// API Response: {availablePoints, totalPoints, lastTransactionDate, maximumBurnablePoints, burnConfiguration, burnRule, activeCampaign}
class LoyaltyPoints extends Equatable {
  final double availablePoints;
  final double totalPoints;
  final DateTime? lastTransactionDate;
  final int maximumBurnablePoints;
  final dynamic burnConfiguration;
  final dynamic burnRule;
  final dynamic activeCampaign;

  const LoyaltyPoints({
    required this.availablePoints,
    required this.totalPoints,
    this.lastTransactionDate,
    this.maximumBurnablePoints = 0,
    this.burnConfiguration,
    this.burnRule,
    this.activeCampaign,
  });

  factory LoyaltyPoints.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is DateTime) return dateValue;
      if (dateValue is String && dateValue.isNotEmpty) {
        return DateTime.tryParse(dateValue);
      }
      return null;
    }

    return LoyaltyPoints(
      availablePoints: (json['availablePoints'] as num?)?.toDouble() ?? 0.0,
      totalPoints: (json['totalPoints'] as num?)?.toDouble() ?? 0.0,
      lastTransactionDate: parseDate(json['lastTransactionDate']),
      maximumBurnablePoints: (json['maximumBurnablePoints'] as num?)?.toInt() ?? 0,
      burnConfiguration: json['burnConfiguration'],
      burnRule: json['burnRule'],
      activeCampaign: json['activeCampaign'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'availablePoints': availablePoints,
      'totalPoints': totalPoints,
      'lastTransactionDate': lastTransactionDate?.toIso8601String(),
      'maximumBurnablePoints': maximumBurnablePoints,
      'burnConfiguration': burnConfiguration,
      'burnRule': burnRule,
      'activeCampaign': activeCampaign,
    };
  }

  @override
  List<Object?> get props => [
        availablePoints,
        totalPoints,
        lastTransactionDate,
        maximumBurnablePoints,
        burnConfiguration,
        burnRule,
        activeCampaign,
      ];
}

/// Loyalty Transaction Model
class LoyaltyTransaction extends Equatable {
  final String? transactionId;
  final String? title;
  final String? description;
  final int pointsDelta;
  final DateTime? transactionDate;
  final String? transactionType;
  final String? status;

  const LoyaltyTransaction({
    this.transactionId,
    this.title,
    this.description,
    this.pointsDelta = 0,
    this.transactionDate,
    this.transactionType,
    this.status,
  });

  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is DateTime) return dateValue;
      if (dateValue is String && dateValue.isNotEmpty) {
        return DateTime.tryParse(dateValue);
      }
      return null;
    }

    return LoyaltyTransaction(
      transactionId: json['transactionId']?.toString() ?? json['id']?.toString(),
      title: json['title']?.toString() ?? json['description']?.toString(),
      description: json['description']?.toString() ?? json['remarks']?.toString(),
      pointsDelta: (json['pointsDelta'] as num?)?.toInt() ?? 
                   (json['points'] as num?)?.toInt() ?? 
                   (json['earnedPoints'] as num?)?.toInt() ?? 
                   (json['redeemedPoints'] as num?)?.toInt() ?? 0,
      transactionDate: parseDate(json['transactionDate'] ?? json['createdDate'] ?? json['date']),
      transactionType: json['transactionType']?.toString() ?? json['type']?.toString(),
      status: json['status']?.toString(),
    );
  }

  bool get isEarned => pointsDelta > 0;
  bool get isRedeemed => pointsDelta < 0;

  /// Format the transaction date as a readable string
  String get formattedDate {
    if (transactionDate == null) return '';
    final d = transactionDate!;
    // Format: M-D-YYYY, H:MM:SS AM/PM
    final hour = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final period = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.month}-${d.day}-${d.year}, $hour:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')} $period';
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'title': title,
      'description': description,
      'pointsDelta': pointsDelta,
      'transactionDate': transactionDate?.toIso8601String(),
      'transactionType': transactionType,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [
        transactionId,
        title,
        description,
        pointsDelta,
        transactionDate,
        transactionType,
        status,
      ];
}

