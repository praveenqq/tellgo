import 'package:equatable/equatable.dart';

/// Gift Card Denomination Model
class GiftCardDenomination extends Equatable {
  final int id;
  final int? countryId;
  final String? country;
  final int? currencyId;
  final String? currency;
  final String? denomination;
  final double sellingPrice;
  final double? topUpValue;
  final String? ribbon;
  final DateTime? createdDate;
  final String? createdBy;
  final bool isActive;

  const GiftCardDenomination({
    required this.id,
    this.countryId,
    this.country,
    this.currencyId,
    this.currency,
    this.denomination,
    required this.sellingPrice,
    this.topUpValue,
    this.ribbon,
    this.createdDate,
    this.createdBy,
    this.isActive = true,
  });

  factory GiftCardDenomination.fromJson(Map<String, dynamic> json) {
    return GiftCardDenomination(
      id: json['id'] as int? ?? 0,
      countryId: json['countryId'] as int?,
      country: json['country']?.toString(),
      currencyId: json['currencyId'] as int?,
      currency: json['currency']?.toString() ?? 'KWD',
      denomination: json['denomination']?.toString(),
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      topUpValue: (json['topUpValue'] as num?)?.toDouble(),
      ribbon: json['ribbon']?.toString(),
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'].toString())
          : null,
      createdBy: json['createdBy']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        id,
        countryId,
        country,
        currencyId,
        currency,
        denomination,
        sellingPrice,
        topUpValue,
        ribbon,
        createdDate,
        createdBy,
        isActive,
      ];
}

/// Gift Card Purchase History Model
class GiftCardPurchaseHistory extends Equatable {
  final int id;
  final String? purchasedByUserIdentifier;
  final String? userName;
  final String? mobileNumber;
  final String? email;
  final String? denomination;
  final String? giftCardId;
  final int? purchasedBy;
  final String? paymentMethod;
  final String? paymentReference;
  final String? paymentStatus;
  final double amount;
  final String? currency;
  final String? transactionStatus;
  final DateTime? createdDate;
  final String? recipientName;
  final String? recipientEmail;
  final String? recipientMessage;
  final String? paymentId;
  final DateTime? completedDate;

  const GiftCardPurchaseHistory({
    required this.id,
    this.purchasedByUserIdentifier,
    this.userName,
    this.mobileNumber,
    this.email,
    this.denomination,
    this.giftCardId,
    this.purchasedBy,
    this.paymentMethod,
    this.paymentReference,
    this.paymentStatus,
    required this.amount,
    this.currency,
    this.transactionStatus,
    this.createdDate,
    this.recipientName,
    this.recipientEmail,
    this.recipientMessage,
    this.paymentId,
    this.completedDate,
  });

  factory GiftCardPurchaseHistory.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is DateTime) return dateValue;
      if (dateValue is String) {
        return DateTime.tryParse(dateValue);
      }
      return null;
    }

    return GiftCardPurchaseHistory(
      id: json['id'] as int? ?? 0,
      purchasedByUserIdentifier: json['purchasedByUserIdentifier']?.toString(),
      userName: json['userName']?.toString(),
      mobileNumber: json['mobileNumber']?.toString(),
      email: json['email']?.toString(),
      denomination: json['denomination']?.toString(),
      giftCardId: json['giftCardId']?.toString(),
      purchasedBy: json['purchasedBy'] as int?,
      paymentMethod: json['paymentMethod']?.toString(),
      paymentReference: json['paymentReference']?.toString(),
      paymentStatus: json['paymentStatus']?.toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'KWD',
      transactionStatus: json['transactionStatus']?.toString(),
      createdDate: parseDate(json['createdDate']),
      recipientName: json['recipientName']?.toString(),
      recipientEmail: json['recipientEmail']?.toString(),
      recipientMessage: json['recipientMessage']?.toString(),
      paymentId: json['paymentId']?.toString(),
      completedDate: parseDate(json['completedDate']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        purchasedByUserIdentifier,
        userName,
        mobileNumber,
        email,
        denomination,
        giftCardId,
        purchasedBy,
        paymentMethod,
        paymentReference,
        paymentStatus,
        amount,
        currency,
        transactionStatus,
        createdDate,
        recipientName,
        recipientEmail,
        recipientMessage,
        paymentId,
        completedDate,
      ];
}

/// Gift Card Redeem History Model
class GiftCardRedeemHistory extends Equatable {
  final int id;
  final String? giftCardId;
  final String? redeemedByUserIdentifier;
  final String? userName;
  final String? mobileNumber;
  final String? email;
  final String? denomination;
  final double amount;
  final String? currency;
  final DateTime? redeemedDate;
  final String? status;

  const GiftCardRedeemHistory({
    required this.id,
    this.giftCardId,
    this.redeemedByUserIdentifier,
    this.userName,
    this.mobileNumber,
    this.email,
    this.denomination,
    required this.amount,
    this.currency,
    this.redeemedDate,
    this.status,
  });

  factory GiftCardRedeemHistory.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is DateTime) return dateValue;
      if (dateValue is String) {
        return DateTime.tryParse(dateValue);
      }
      return null;
    }

    return GiftCardRedeemHistory(
      id: json['id'] as int? ?? 0,
      giftCardId: json['giftCardId']?.toString(),
      redeemedByUserIdentifier: json['redeemedByUserIdentifier']?.toString(),
      userName: json['userName']?.toString(),
      mobileNumber: json['mobileNumber']?.toString(),
      email: json['email']?.toString(),
      denomination: json['denomination']?.toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'KWD',
      redeemedDate: parseDate(json['redeemedDate'] ?? json['createdDate']),
      status: json['status']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        giftCardId,
        redeemedByUserIdentifier,
        userName,
        mobileNumber,
        email,
        denomination,
        amount,
        currency,
        redeemedDate,
        status,
      ];
}

/// Gift Card Purchase Request Model
class GiftCardPurchaseRequest extends Equatable {
  final int giftCardDenominationId;
  final String paymentChannelCode;
  final String? recipientName;
  final String? recipientEmail;
  final String? recipientMessage;

  const GiftCardPurchaseRequest({
    required this.giftCardDenominationId,
    required this.paymentChannelCode,
    this.recipientName,
    this.recipientEmail,
    this.recipientMessage,
  });

  Map<String, dynamic> toJson() => {
        'giftCardDenominationId': giftCardDenominationId,
        'paymentChannelCode': paymentChannelCode,
        if (recipientName != null) 'recipientName': recipientName,
        if (recipientEmail != null) 'recipientEmail': recipientEmail,
        if (recipientMessage != null) 'recipientMessage': recipientMessage,
      };

  @override
  List<Object?> get props => [
        giftCardDenominationId,
        paymentChannelCode,
        recipientName,
        recipientEmail,
        recipientMessage,
      ];
}

/// Gift Card Purchase Response Model
class GiftCardPurchaseResponse extends Equatable {
  final bool success;
  final String? transactionId;
  final String? paymentTransactionId;
  final String? paymentUrl;
  final String? message;
  final int? httpStatusCode;
  final String? responseContent;

  const GiftCardPurchaseResponse({
    required this.success,
    this.transactionId,
    this.paymentTransactionId,
    this.paymentUrl,
    this.message,
    this.httpStatusCode,
    this.responseContent,
  });

  factory GiftCardPurchaseResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'] is Map
        ? (json['result'] as Map<String, dynamic>)
        : <String, dynamic>{};

    return GiftCardPurchaseResponse(
      success: (json['success'] as bool?) ?? false,
      transactionId: result['transactionId']?.toString(),
      paymentTransactionId: result['paymentTransactionId']?.toString(),
      paymentUrl: result['paymentUrl']?.toString(),
      message: json['message']?.toString(),
      httpStatusCode: result['httpStatusCode'] as int?,
      responseContent: result['responseContent']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        success,
        transactionId,
        paymentTransactionId,
        paymentUrl,
        message,
        httpStatusCode,
        responseContent,
      ];
}

/// Individual Payment Channel Info Model
class PaymentChannelInfo extends Equatable {
  final int id;
  final String name;
  final String code;
  final String? logo;

  const PaymentChannelInfo({
    required this.id,
    required this.name,
    required this.code,
    this.logo,
  });

  factory PaymentChannelInfo.fromJson(Map<String, dynamic> json) {
    return PaymentChannelInfo(
      id: json['paymentChannelId'] as int? ?? 0,
      name: (json['paymentChannelName'] ?? '').toString(),
      code: (json['paymentChannelCode'] ?? '').toString(),
      logo: json['paymentChannelLogo']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, name, code, logo];
}

/// Gift Card Payment Channel Model
class GiftCardPaymentChannel extends Equatable {
  final int serviceId;
  final List<int> paymentChannelIds;
  final List<String> channelCodes;
  final List<PaymentChannelInfo> channels;

  const GiftCardPaymentChannel({
    required this.serviceId,
    required this.paymentChannelIds,
    required this.channelCodes,
    this.channels = const [],
  });

  factory GiftCardPaymentChannel.fromJson(Map<String, dynamic> json) {
    // Parse paymentChannelId which can be a single int or List<int>
    List<int> parseChannelIds(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e as int).toList();
      }
      if (value is int) return [value];
      return [];
    }

    // Parse channelCode which can be a single string or List<String>
    List<String> parseChannelCodes(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      if (value is String) return [value];
      return [];
    }

    return GiftCardPaymentChannel(
      serviceId: json['serviceId'] as int? ?? 0,
      paymentChannelIds: parseChannelIds(json['paymentChannelId']),
      channelCodes: parseChannelCodes(json['channelCode']),
    );
  }

  /// Create from list of individual payment channel info (new API format)
  factory GiftCardPaymentChannel.fromChannelsList(List<PaymentChannelInfo> channels) {
    return GiftCardPaymentChannel(
      serviceId: 0,
      paymentChannelIds: channels.map((c) => c.id).toList(),
      channelCodes: channels.map((c) => c.code).toList(),
      channels: channels,
    );
  }

  /// Get display name for a channel code
  static String getDisplayName(String code) {
    switch (code.toLowerCase()) {
      case 'myfatoorah':
        return 'MyFatoorah';
      case 'tgwallet':
      case 'tellgowallet':
        return 'TellGo Wallet';
      case 'knet':
        return 'KNET';
      case 'applepay':
        return 'Apple Pay';
      case 'mastercard':
      case 'master':
        return 'Master Card';
      case 'visa':
        return 'Visa';
      default:
        return code;
    }
  }

  /// Get icon for a channel code
  static String? getIconAsset(String code) {
    switch (code.toLowerCase()) {
      case 'applepay':
        return 'assets/icons/apple_pay.png';
      case 'knet':
        return 'assets/icons/knet.png';
      case 'mastercard':
      case 'master':
        return 'assets/icons/mastercard.png';
      case 'visa':
        return 'assets/icons/visa.png';
      default:
        return null;
    }
  }

  @override
  List<Object?> get props => [serviceId, paymentChannelIds, channelCodes, channels];
}

/// Result from loading gift card denominations (includes payment channels)
class GiftCardDenominationResult {
  final List<GiftCardDenomination> denominations;
  final List<GiftCardPaymentChannel> paymentChannels;

  const GiftCardDenominationResult({
    required this.denominations,
    required this.paymentChannels,
  });
}

/// Gift Card Process Transaction Response Model
class GiftCardProcessTransactionResponse extends Equatable {
  final bool success;
  final String? transactionId;
  final int? giftCardId;
  final String? giftCardCode;
  final double? amount;
  final String? currency;
  final bool? emailSent;
  final String? status;
  final String? message;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;

  const GiftCardProcessTransactionResponse({
    required this.success,
    this.transactionId,
    this.giftCardId,
    this.giftCardCode,
    this.amount,
    this.currency,
    this.emailSent,
    this.status,
    this.message,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  factory GiftCardProcessTransactionResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'] is Map
        ? (json['result'] as Map<String, dynamic>)
        : <String, dynamic>{};

    return GiftCardProcessTransactionResponse(
      success: (json['success'] as bool?) ?? false,
      transactionId: result['transactionId']?.toString(),
      giftCardId: result['giftCardId'] as int?,
      giftCardCode: result['giftCardCode']?.toString(),
      amount: (result['amount'] as num?)?.toDouble(),
      currency: result['currency']?.toString() ?? 'KWD',
      emailSent: result['emailSent'] as bool?,
      status: result['status']?.toString(),
      message: json['message']?.toString(),
      statusCode: json['statusCode'] as int?,
      errorCode: result['errorCode']?.toString(),
      errorMessage: result['errorMessage']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        success,
        transactionId,
        giftCardId,
        giftCardCode,
        amount,
        currency,
        emailSent,
        status,
        message,
        statusCode,
        errorCode,
        errorMessage,
      ];
}

