import 'package:equatable/equatable.dart';

/// Order Model
class Order extends Equatable {
  final int? orderId;
  final String? orderNumber;
  final String? appOrderId;
  final String? title;
  final String? description;
  final String? status;
  final String? statusLabel;
  final double? totalPrice;
  final double? unitPrice;
  final double? subTotal;
  final double? discount;
  final int? qty;
  final String? currency;
  final DateTime? deliveredDate;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final String? thumbnailUrl;
  final int? rating;
  // eSIM-specific fields
  final String? iccid;
  final String? smdpAddress;
  final String? matchingId;
  final String? profileId;
  final String? esimStatus;
  final String? bundleState;
  final String? pin;
  final String? puk;
  final String? msisdn;
  final String? qrCodeURL;
  final String? appleInstallUrl;
  final bool allowAssign;
  final String? customerName;
  final String? email;
  final String? mobileNumber;
  final String? userIdentifier;
  final String? orderReference;
  final int? bundleId;
  final String? usage;

  const Order({
    this.orderId,
    this.orderNumber,
    this.appOrderId,
    this.title,
    this.description,
    this.status,
    this.statusLabel,
    this.totalPrice,
    this.unitPrice,
    this.subTotal,
    this.discount,
    this.qty,
    this.currency,
    this.deliveredDate,
    this.createdDate,
    this.updatedDate,
    this.thumbnailUrl,
    this.rating,
    this.iccid,
    this.smdpAddress,
    this.matchingId,
    this.profileId,
    this.esimStatus,
    this.bundleState,
    this.pin,
    this.puk,
    this.msisdn,
    this.qrCodeURL,
    this.appleInstallUrl,
    this.allowAssign = false,
    this.customerName,
    this.email,
    this.mobileNumber,
    this.userIdentifier,
    this.orderReference,
    this.bundleId,
    this.usage,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is DateTime) return dateValue;
      if (dateValue is String) {
        return DateTime.tryParse(dateValue);
      }
      return null;
    }

    // Determine status label from orderStatus code or status text
    String? statusLabel;
    final rawStatus = json['orderStatus']?.toString() ?? json['status']?.toString();
    if (rawStatus != null) {
      final statusStr = rawStatus.toLowerCase();
      // Handle numeric status codes from API
      switch (statusStr) {
        case '1':
          statusLabel = 'Pending';
          break;
        case '2':
          statusLabel = 'Processing';
          break;
        case '3':
          statusLabel = 'Complete';
          break;
        case '4':
          statusLabel = 'Cancelled';
          break;
        case '5':
          statusLabel = 'Refund';
          break;
        default:
          // Handle text-based status
          if (statusStr.contains('complete') || statusStr.contains('completed') || statusStr.contains('delivered')) {
            statusLabel = 'Complete';
          } else if (statusStr.contains('refund') || statusStr.contains('cancelled')) {
            statusLabel = 'Refund';
          } else if (statusStr.contains('pending')) {
            statusLabel = 'Pending';
          } else {
            statusLabel = json['statusLabel']?.toString() ?? rawStatus;
          }
      }
    }

    return Order(
      orderId: (json['id'] as num?)?.toInt() ?? (json['orderId'] is int ? json['orderId'] as int : null),
      orderNumber: json['orderId']?.toString() ?? json['orderNumber']?.toString(),
      appOrderId: json['appOrderId']?.toString(),
      title: json['title']?.toString() ?? json['productName']?.toString() ?? json['bundleName']?.toString(),
      description: json['description']?.toString() ?? json['bundleDescription']?.toString(),
      status: json['orderStatus']?.toString() ?? json['status']?.toString(),
      statusLabel: statusLabel,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 
                  (json['totalAmount'] as num?)?.toDouble() ?? 
                  (json['finalTotal'] as num?)?.toDouble(),
      unitPrice: (json['unitPrice'] as num?)?.toDouble(),
      subTotal: (json['subTotal'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      qty: (json['qty'] as num?)?.toInt(),
      currency: json['currency']?.toString() ?? 'USD',
      deliveredDate: parseDate(json['deliveredDate'] ?? json['completedDate'] ?? json['deliveryDate']),
      createdDate: parseDate(json['createdDate'] ?? json['orderDate'] ?? json['date']),
      updatedDate: parseDate(json['updatedDate']),
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? json['imageUrl']?.toString(),
      rating: (json['rating'] as num?)?.toInt(),
      // eSIM fields
      iccid: json['iccid']?.toString(),
      smdpAddress: json['smdpAddress']?.toString(),
      matchingId: json['matchingId']?.toString(),
      profileId: json['profileId']?.toString(),
      esimStatus: json['esimStatus']?.toString(),
      bundleState: json['bundleState']?.toString(),
      pin: json['pin']?.toString(),
      puk: json['puk']?.toString(),
      msisdn: json['msisdn']?.toString(),
      qrCodeURL: json['qrCodeURL']?.toString(),
      appleInstallUrl: json['appleInstallUrl']?.toString(),
      allowAssign: json['allowAssign'] == true,
      customerName: json['customerName']?.toString(),
      email: json['email']?.toString(),
      mobileNumber: json['mobileNumber']?.toString(),
      userIdentifier: json['userIdentifier']?.toString(),
      orderReference: json['orderReference']?.toString(),
      bundleId: (json['bundleId'] as num?)?.toInt(),
      usage: json['usage']?.toString(),
    );
  }

  Order copyWith({int? rating}) {
    return Order(
      orderId: orderId,
      orderNumber: orderNumber,
      appOrderId: appOrderId,
      title: title,
      description: description,
      status: status,
      statusLabel: statusLabel,
      totalPrice: totalPrice,
      unitPrice: unitPrice,
      subTotal: subTotal,
      discount: discount,
      qty: qty,
      currency: currency,
      deliveredDate: deliveredDate,
      createdDate: createdDate,
      updatedDate: updatedDate,
      thumbnailUrl: thumbnailUrl,
      rating: rating ?? this.rating,
      iccid: iccid,
      smdpAddress: smdpAddress,
      matchingId: matchingId,
      profileId: profileId,
      esimStatus: esimStatus,
      bundleState: bundleState,
      pin: pin,
      puk: puk,
      msisdn: msisdn,
      qrCodeURL: qrCodeURL,
      appleInstallUrl: appleInstallUrl,
      allowAssign: allowAssign,
      customerName: customerName,
      email: email,
      mobileNumber: mobileNumber,
      userIdentifier: userIdentifier,
      orderReference: orderReference,
      bundleId: bundleId,
      usage: usage,
    );
  }

  // Helper to get status dot color
  String get statusDotColor {
    if (statusLabel?.toLowerCase().contains('complete') ?? false) {
      return '#00C844'; // success green
    } else if (statusLabel?.toLowerCase().contains('refund') ?? false) {
      return '#FF0021'; // error red
    }
    return '#787878'; // default grey
  }

  // Helper to format delivered text
  String get deliveredText {
    if (deliveredDate != null) {
      final month = _getMonthName(deliveredDate!.month);
      final day = deliveredDate!.day;
      final hour = deliveredDate!.hour;
      final minute = deliveredDate!.minute;
      final amPm = hour >= 12 ? 'pm' : 'am';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return 'Delivered $month $day - $displayHour:${minute.toString().padLeft(2, '0')}$amPm';
    } else if (createdDate != null) {
      final month = _getMonthName(createdDate!.month);
      final day = createdDate!.day;
      final hour = createdDate!.hour;
      final minute = createdDate!.minute;
      final amPm = hour >= 12 ? 'pm' : 'am';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return 'Ordered $month $day - $displayHour:${minute.toString().padLeft(2, '0')}$amPm';
    }
    return 'Order date not available';
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String get formattedTotalPrice {
    final price = totalPrice ?? 0.0;
    return '$currency ${price.toStringAsFixed(3)}';
  }

  @override
  List<Object?> get props => [
        orderId,
        orderNumber,
        appOrderId,
        title,
        description,
        status,
        statusLabel,
        totalPrice,
        unitPrice,
        subTotal,
        discount,
        qty,
        currency,
        deliveredDate,
        createdDate,
        updatedDate,
        thumbnailUrl,
        rating,
        iccid,
        esimStatus,
        bundleState,
        msisdn,
        allowAssign,
        customerName,
        bundleId,
      ];
}

/// Order Details Model
class OrderDetails extends Equatable {
  final int? orderId;
  final String? orderNumber;
  final String? customerName;
  final String? status;
  final String? statusLabel;
  final double? totalPrice;
  final double? subTotal;
  final double? discount;
  final String? currency;
  final DateTime? createdDate;
  final DateTime? deliveredDate;
  final List<OrderItem> items;
  final String? paymentMethod;
  final String? paymentStatus;

  const OrderDetails({
    this.orderId,
    this.orderNumber,
    this.customerName,
    this.status,
    this.statusLabel,
    this.totalPrice,
    this.subTotal,
    this.discount,
    this.currency,
    this.createdDate,
    this.deliveredDate,
    this.items = const [],
    this.paymentMethod,
    this.paymentStatus,
  });

  /// Build from a single JSON object (legacy / generic)
  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is DateTime) return dateValue;
      if (dateValue is String) return DateTime.tryParse(dateValue);
      return null;
    }

    List<OrderItem> parseItems(dynamic itemsData) {
      if (itemsData == null) return [];
      if (itemsData is List) {
        return itemsData
            .map((item) => OrderItem.fromJson(
                  item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item),
                ))
            .toList();
      }
      return [];
    }

    String statusLabel = _resolveStatusLabel(
      json['orderStatus']?.toString() ?? json['status']?.toString(),
    );

    return OrderDetails(
      orderId: (json['id'] as num?)?.toInt() ?? (json['orderId'] is int ? json['orderId'] as int : null),
      orderNumber: json['orderId']?.toString() ?? json['orderNumber']?.toString() ?? json['appOrderId']?.toString(),
      customerName: json['customerName']?.toString(),
      status: json['orderStatus']?.toString() ?? json['status']?.toString(),
      statusLabel: statusLabel,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 
                  (json['totalAmount'] as num?)?.toDouble() ?? 
                  (json['finalTotal'] as num?)?.toDouble(),
      subTotal: (json['subTotal'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      currency: json['currency']?.toString() ?? 'KWD',
      createdDate: parseDate(json['createdDate'] ?? json['orderDate'] ?? json['date']),
      deliveredDate: parseDate(json['deliveredDate'] ?? json['completedDate'] ?? json['deliveryDate']),
      items: parseItems(json['items'] ?? json['orderItems'] ?? json['purchaseItems']),
      paymentMethod: json['paymentMethod']?.toString(),
      paymentStatus: json['paymentStatus']?.toString(),
    );
  }

  /// Build from the API response where result is a list of order line items
  factory OrderDetails.fromItemsList(String orderNumber, List<dynamic> itemsList) {
    final items = itemsList
        .map((item) => OrderItem.fromJson(
              item is Map<String, dynamic> ? item : Map<String, dynamic>.from(item),
            ))
        .toList();

    // Aggregate order-level data from the items
    double totalAmount = 0;
    double totalSubTotal = 0;
    double totalDiscount = 0;
    String? currency;
    String? customerName;
    DateTime? createdDate;
    String? status;
    String? statusLabel;

    for (final itemJson in itemsList) {
      final map = itemJson is Map<String, dynamic> ? itemJson : Map<String, dynamic>.from(itemJson);
      totalAmount += (map['totalAmount'] as num?)?.toDouble() ?? 0;
      totalSubTotal += (map['subTotal'] as num?)?.toDouble() ?? 0;
      totalDiscount += (map['discount'] as num?)?.toDouble() ?? 0;
      currency ??= map['currency']?.toString();
      customerName ??= map['customerName']?.toString();
      if (map['createdDate'] != null && createdDate == null) {
        createdDate = DateTime.tryParse(map['createdDate'].toString());
      }
      if (status == null) {
        status = map['status']?.toString();
        statusLabel = _resolveStatusLabel(status);
      }
    }

    return OrderDetails(
      orderNumber: orderNumber,
      customerName: customerName,
      status: status,
      statusLabel: statusLabel,
      totalPrice: totalAmount,
      subTotal: totalSubTotal,
      discount: totalDiscount,
      currency: currency ?? 'KWD',
      createdDate: createdDate,
      items: items,
    );
  }

  /// Helper for status label resolution
  static String _resolveStatusLabel(String? rawStatus) {
    if (rawStatus == null) return 'Unknown';
    switch (rawStatus) {
      case '1':
        return 'Pending';
      case '2':
        return 'Processing';
      case '3':
        return 'Complete';
      case '4':
        return 'Cancelled';
      case '5':
        return 'Refund';
      default:
        final s = rawStatus.toLowerCase();
        if (s.contains('complete') || s.contains('delivered')) return 'Complete';
        if (s.contains('refund') || s.contains('cancel')) return 'Refund';
        if (s.contains('pending')) return 'Pending';
        return rawStatus;
    }
  }

  /// Formatted total
  String get formattedTotalPrice {
    final price = totalPrice ?? 0.0;
    return '${currency ?? 'KWD'} ${price.toStringAsFixed(3)}';
  }

  /// Formatted date text
  String get formattedDate {
    if (createdDate == null) return '';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final d = createdDate!;
    final month = months[d.month - 1];
    final hour = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final amPm = d.hour >= 12 ? 'pm' : 'am';
    return '$month ${d.day} - $hour:${d.minute.toString().padLeft(2, '0')}$amPm';
  }

  @override
  List<Object?> get props => [
        orderId,
        orderNumber,
        customerName,
        status,
        statusLabel,
        totalPrice,
        subTotal,
        discount,
        currency,
        createdDate,
        deliveredDate,
        items,
        paymentMethod,
        paymentStatus,
      ];
}

/// Order Item Model (for order details)
class OrderItem extends Equatable {
  final int? itemId;
  final int? bundleId;
  final String? name;
  final String? description;
  final int quantity;
  final double pricePerUnit;
  final double discount;
  final double? subTotal;
  final double? totalPrice;
  final String? currency;
  final int? status;
  final String? statusLabel;
  // eSIM related fields
  final String? iccid;
  final String? smdpAddress;
  final String? matchingId;
  final String? qrCodeURL;
  final String? appleInstallUrl;
  final bool allowAssign;

  const OrderItem({
    this.itemId,
    this.bundleId,
    this.name,
    this.description,
    required this.quantity,
    required this.pricePerUnit,
    this.discount = 0.0,
    this.subTotal,
    this.totalPrice,
    this.currency,
    this.status,
    this.statusLabel,
    this.iccid,
    this.smdpAddress,
    this.matchingId,
    this.qrCodeURL,
    this.appleInstallUrl,
    this.allowAssign = false,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Determine status label
    String? statusLabel;
    final rawStatus = json['status']?.toString();
    if (rawStatus != null) {
      switch (rawStatus) {
        case '1':
          statusLabel = 'Pending';
          break;
        case '2':
          statusLabel = 'Processing';
          break;
        case '3':
          statusLabel = 'Complete';
          break;
        case '4':
          statusLabel = 'Cancelled';
          break;
        case '5':
          statusLabel = 'Refund';
          break;
        default:
          statusLabel = rawStatus;
      }
    }

    return OrderItem(
      itemId: (json['itemId'] as num?)?.toInt() ?? (json['id'] as num?)?.toInt(),
      bundleId: (json['bundleId'] as num?)?.toInt(),
      name: json['name']?.toString() ?? json['bundleName']?.toString() ?? json['productName']?.toString(),
      description: json['description']?.toString() ?? json['bundleDescription']?.toString(),
      quantity: (json['qty'] as num?)?.toInt() ?? (json['quantity'] as num?)?.toInt() ?? (json['purchasedQuantity'] as num?)?.toInt() ?? 1,
      pricePerUnit: (json['unitPrice'] as num?)?.toDouble() ?? 
                    (json['pricePerUnit'] as num?)?.toDouble() ?? 
                    (json['pricePerunit'] as num?)?.toDouble() ?? 
                    (json['price'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      subTotal: (json['subTotal'] as num?)?.toDouble(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? (json['totalAmount'] as num?)?.toDouble(),
      currency: json['currency']?.toString() ?? 'KWD',
      status: (json['status'] as num?)?.toInt(),
      statusLabel: statusLabel,
      iccid: json['iccid']?.toString(),
      smdpAddress: json['smdpAddress']?.toString(),
      matchingId: json['matchingId']?.toString(),
      qrCodeURL: json['qrCodeURL']?.toString(),
      appleInstallUrl: json['appleInstallUrl']?.toString(),
      allowAssign: json['allowAssign'] == true,
    );
  }

  @override
  List<Object?> get props => [
        itemId,
        bundleId,
        name,
        description,
        quantity,
        pricePerUnit,
        discount,
        subTotal,
        totalPrice,
        currency,
        status,
        statusLabel,
      ];
}

/// Purchase Item Model (for ValidateBundlePurchase request)
class PurchaseItem extends Equatable {
  final int bundleId;
  final int categoryId;
  final int subCategoryId;
  final int purchasedQuantity;
  final double pricePerunit;

  const PurchaseItem({
    required this.bundleId,
    required this.categoryId,
    required this.subCategoryId,
    required this.purchasedQuantity,
    required this.pricePerunit,
  });

  Map<String, dynamic> toJson() => {
        'bundleId': bundleId,
        'categoryId': categoryId,
        'subCategoryId': subCategoryId,
        'purchasedQuantity': purchasedQuantity,
        'pricePerunit': pricePerunit,
      };

  @override
  List<Object?> get props => [
        bundleId,
        categoryId,
        subCategoryId,
        purchasedQuantity,
        pricePerunit,
      ];
}

/// Validate Bundle Purchase Request Model
class ValidateBundlePurchaseRequest extends Equatable {
  final String paymentChannelCode;
  final String? loyalityRedeemPoints;
  final double cartTotal;
  final String? discountCoupon;
  final double finalTotal;
  final List<PurchaseItem> purchaseItems;
  final String? giftCardCode;
  final String currency;

  const ValidateBundlePurchaseRequest({
    required this.paymentChannelCode,
    this.loyalityRedeemPoints,
    required this.cartTotal,
    this.discountCoupon,
    required this.finalTotal,
    required this.purchaseItems,
    this.giftCardCode,
    this.currency = 'KWD',
  });

  Map<String, dynamic> toJson() => {
        'paymentChannelCode': paymentChannelCode,
        if (loyalityRedeemPoints != null) 'loyalityRedeemPoints': loyalityRedeemPoints,
        'cartTotal': cartTotal,
        if (discountCoupon != null) 'discountCoupon': discountCoupon,
        'finalTotal': finalTotal,
        'purchaseItems': purchaseItems.map((item) => item.toJson()).toList(),
        if (giftCardCode != null) 'giftCardCode': giftCardCode,
        'currency': currency,
      };

  @override
  List<Object?> get props => [
        paymentChannelCode,
        loyalityRedeemPoints,
        cartTotal,
        discountCoupon,
        finalTotal,
        purchaseItems,
        giftCardCode,
        currency,
      ];
}

/// Validate Bundle Purchase Response Model
class ValidateBundlePurchaseResponse extends Equatable {
  final bool success;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? result;

  const ValidateBundlePurchaseResponse({
    required this.success,
    this.message,
    this.statusCode,
    this.result,
  });

  factory ValidateBundlePurchaseResponse.fromJson(Map<String, dynamic> json) {
    return ValidateBundlePurchaseResponse(
      success: (json['success'] as bool?) ?? false,
      message: json['message']?.toString(),
      statusCode: (json['statusCode'] as num?)?.toInt(),
      result: json['result'] is Map
          ? (json['result'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [success, message, statusCode, result];
}

