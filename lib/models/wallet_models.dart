import 'package:equatable/equatable.dart';

/// Wallet Balance Model
class WalletBalance extends Equatable {
  final double balance;
  final String? currency;

  const WalletBalance({
    required this.balance,
    this.currency,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    // API returns: {balance, currency, currencyId, countryId, country}
    return WalletBalance(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'KWD',
    );
  }

  @override
  List<Object?> get props => [balance, currency];
}

/// Wallet Transaction Model
class WalletTransaction extends Equatable {
  final String? transactionId;
  final String? title;
  final String? description;
  final double? amount;
  final String? currency;
  final String? transactionType; // "credit", "debit", etc.
  final DateTime? transactionDate;
  final String? status;
  final int? pointsDelta; // For Go Points integration

  const WalletTransaction({
    this.transactionId,
    this.title,
    this.description,
    this.amount,
    this.currency,
    this.transactionType,
    this.transactionDate,
    this.status,
    this.pointsDelta,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    // Parse transaction date from various formats
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is DateTime) return dateValue;
      if (dateValue is String) {
        return DateTime.tryParse(dateValue);
      }
      return null;
    }

    return WalletTransaction(
      transactionId: json['transactionId']?.toString() ?? json['id']?.toString(),
      title: json['title']?.toString() ?? json['description']?.toString() ?? json['transactionType']?.toString(),
      description: json['description']?.toString() ?? json['remarks']?.toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? (json['transactionAmount'] as num?)?.toDouble(),
      currency: json['currency']?.toString() ?? 'KWD',
      transactionType: json['transactionType']?.toString() ?? json['type']?.toString(),
      transactionDate: parseDate(json['transactionDate'] ?? json['createdDate'] ?? json['date']),
      status: json['status']?.toString(),
      pointsDelta: json['pointsDelta'] as int?,
    );
  }

  bool get isPositive => (amount ?? 0) > 0 || (pointsDelta ?? 0) > 0;

  @override
  List<Object?> get props => [
        transactionId,
        title,
        description,
        amount,
        currency,
        transactionType,
        transactionDate,
        status,
        pointsDelta,
      ];
}

/// Payment Channel Model
class PaymentChannel extends Equatable {
  final String code;
  final String name;
  final bool isActive;

  const PaymentChannel({
    required this.code,
    required this.name,
    this.isActive = true,
  });

  factory PaymentChannel.fromJson(Map<String, dynamic> json) {
    return PaymentChannel(
      code: json['code']?.toString() ?? json['paymentChannelCode']?.toString() ?? '',
      name: json['name']?.toString() ?? json['paymentChannelName']?.toString() ?? '',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [code, name, isActive];
}

/// Wallet Top-Up Denomination Model
class WalletDenomination extends Equatable {
  final int denominationId;
  final double buyAmount;
  final double getAmount;
  final String? discountText;
  final String? currency;
  final bool? isActive;
  final List<PaymentChannel>? paymentChannels;

  const WalletDenomination({
    required this.denominationId,
    required this.buyAmount,
    required this.getAmount,
    this.discountText,
    this.currency,
    this.isActive,
    this.paymentChannels,
  });

  factory WalletDenomination.fromJson(Map<String, dynamic> json) {
    // API returns: {id, countryId, country, currencyId, currency, denomination, sellingPrice, topUpValue, ribbon, isActive, paymentChannels, ...}
    List<PaymentChannel>? channels;
    if (json['paymentChannels'] != null) {
      if (json['paymentChannels'] is List) {
        channels = (json['paymentChannels'] as List)
            .map((e) => PaymentChannel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    
    return WalletDenomination(
      denominationId: json['id'] as int? ?? json['denominationId'] as int? ?? 0,
      buyAmount: (json['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      getAmount: (json['topUpValue'] as num?)?.toDouble() ?? 0.0,
      discountText: json['ribbon']?.toString(),
      currency: json['currency']?.toString() ?? 'KWD',
      isActive: json['isActive'] as bool? ?? true,
      paymentChannels: channels,
    );
  }

  @override
  List<Object?> get props => [
        denominationId,
        buyAmount,
        getAmount,
        discountText,
        currency,
        isActive,
        paymentChannels,
      ];
}

/// Top-Up Request Model
class TopUpRequest extends Equatable {
  final int? denominationId;
  final double? amount;
  final String paymentChannelCode;

  const TopUpRequest({
    this.denominationId,
    this.amount,
    required this.paymentChannelCode,
  });

  Map<String, dynamic> toJson() {
    // API requires either denominationId OR amount, not both
    final Map<String, dynamic> json = {
      'paymentChannelCode': paymentChannelCode,
    };
    
    if (denominationId != null) {
      json['denominationId'] = denominationId;
    } else if (amount != null) {
      json['amount'] = amount;
    }
    
    return json;
  }

  @override
  List<Object?> get props => [denominationId, amount, paymentChannelCode];
}

/// Top-Up Response Model
class TopUpResponse extends Equatable {
  final bool success;
  final String? transactionId;
  final String? paymentUrl;
  final String? message;
  final double? newBalance;

  const TopUpResponse({
    required this.success,
    this.transactionId,
    this.paymentUrl,
    this.message,
    this.newBalance,
  });

  factory TopUpResponse.fromJson(Map<String, dynamic> json) {
    // API returns: {success, result: {transactionId, paymentTransactionId, paymentUrl, ...}, message, statusCode}
    final result = json['result'] is Map ? (json['result'] as Map<String, dynamic>) : <String, dynamic>{};
    
    return TopUpResponse(
      success: (json['success'] as bool?) ?? false,
      transactionId: result['transactionId']?.toString() ?? result['paymentTransactionId']?.toString(),
      paymentUrl: result['paymentUrl']?.toString() ?? result['paymentLink']?.toString(),
      message: json['message']?.toString(),
      newBalance: (result['newBalance'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [success, transactionId, paymentUrl, message, newBalance];
}

/// Process Transaction Response Model
class ProcessTransactionResponse extends Equatable {
  final bool success;
  final String? transactionId;
  final String? status;
  final String? message;
  final double? newBalance;
  final String? errorCode;
  final String? errorMessage;

  const ProcessTransactionResponse({
    required this.success,
    this.transactionId,
    this.status,
    this.message,
    this.newBalance,
    this.errorCode,
    this.errorMessage,
  });

  factory ProcessTransactionResponse.fromJson(Map<String, dynamic> json) {
    // API returns: {success, result: {transactionId, status, newBalance, ...}, message, statusCode}
    final result = json['result'] is Map ? (json['result'] as Map<String, dynamic>) : <String, dynamic>{};
    
    return ProcessTransactionResponse(
      success: (json['success'] as bool?) ?? false,
      transactionId: result['transactionId']?.toString(),
      status: result['status']?.toString(),
      message: json['message']?.toString(),
      newBalance: (result['newBalance'] as num?)?.toDouble(),
      errorCode: result['errorCode']?.toString(),
      errorMessage: result['errorMessage']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        success,
        transactionId,
        status,
        message,
        newBalance,
        errorCode,
        errorMessage,
      ];
}

