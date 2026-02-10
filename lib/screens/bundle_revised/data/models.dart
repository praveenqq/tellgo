// lib/screens/bundle_revised/data/models.dart

/// Category model (Local eSIMs, Regional eSIMs, Global eSIMs)
/// From: /Bundles/GetAllCategories
class BundleCategory {
  final int id;
  final String name;
  final String code;
  final bool isActive;

  const BundleCategory({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
  });

  factory BundleCategory.fromJson(Map<String, dynamic> j) => BundleCategory(
        id: j['id'] ?? 0,
        name: (j['name'] ?? '').toString(),
        code: (j['code'] ?? '').toString(),
        isActive: j['isActive'] == true,
      );
}

/// SubCategory model (countries for Local, regions for Regional, global options for Global)
/// From: /Bundles/GetSubCategoryByCategoryId
class BundleSubCategory {
  final int id;
  final int categoryId;
  final String code;
  final String name;
  final String logo;
  final bool isActive;
  final String categoryName;
  final double? lowestPrice;

  const BundleSubCategory({
    required this.id,
    required this.categoryId,
    required this.code,
    required this.name,
    required this.logo,
    required this.isActive,
    required this.categoryName,
    this.lowestPrice,
  });

  factory BundleSubCategory.fromJson(Map<String, dynamic> j) {
    // Parse lowestPrice - can be number or string like "1.430 USD"
    double? price;
    final rawPrice = j['lowestPrice'];
    if (rawPrice is num) {
      price = rawPrice.toDouble();
    } else if (rawPrice is String && rawPrice.isNotEmpty) {
      // Parse string format like "1.430 USD" or "7.590 USD"
      final numericPart = rawPrice.replaceAll(RegExp(r'[^0-9.]'), '');
      if (numericPart.isNotEmpty) {
        price = double.tryParse(numericPart);
      }
    }
    
    return BundleSubCategory(
      id: j['id'] ?? 0,
      categoryId: j['categoryId'] ?? 0,
      code: (j['code'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      logo: (j['logo'] ?? '').toString(),
      isActive: j['isActive'] == true,
      categoryName: (j['categoryName'] ?? '').toString(),
      lowestPrice: price,
    );
  }
}

class BundleRevisedItem {
  final int id;
  final String name;
  final String description;
  final double? costAmountInDollar;
  final double? sellingPriceInDollar;
  final double? merchantSellingPrice;  // Numeric merchant price for calculations
  final String? merchantSellingPriceStr;
  final String data; // e.g., "1GB/day UNLIMITED" or "50 GB"
  final String validity; // e.g., "7", "30"
  final bool autostart;
  final String? imageUrl;
  final String? tellGoImageUrl;
  final String? vendorDetails;
  final String? tellGoDetails;
  final String? speed;
  final bool isDataPlan;
  final bool isActive;
  final bool isRoaming;
  final String? operatorName;
  final int categoryId;
  final String categoryName;
  final int subCategoryId;
  final String subCategoryName;
  final String? subCategoryLogo;
  final int bundleTypeId;
  final String bundleType;
  final List<BundleRevisedCountry> bundleCountries;
  final String? bundleGroupDescription;

  const BundleRevisedItem({
    required this.id,
    required this.name,
    required this.description,
    required this.costAmountInDollar,
    required this.sellingPriceInDollar,
    required this.merchantSellingPrice,
    required this.merchantSellingPriceStr,
    required this.data,
    required this.validity,
    required this.autostart,
    required this.imageUrl,
    required this.tellGoImageUrl,
    required this.vendorDetails,
    required this.tellGoDetails,
    required this.speed,
    required this.isDataPlan,
    required this.isActive,
    required this.isRoaming,
    required this.operatorName,
    required this.categoryId,
    required this.categoryName,
    required this.subCategoryId,
    required this.subCategoryName,
    required this.subCategoryLogo,
    required this.bundleTypeId,
    required this.bundleType,
    required this.bundleCountries,
    required this.bundleGroupDescription,
  });

  factory BundleRevisedItem.fromJson(Map<String, dynamic> j) {
    // Debug: Check if bundleCountries exists and what it contains
    final rawCountries = j['bundleCountries'];
    List<BundleRevisedCountry> countries = const [];
    
    if (rawCountries != null && rawCountries is List && rawCountries.isNotEmpty) {
      countries = rawCountries
          .map((e) => BundleRevisedCountry.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    
    return BundleRevisedItem(
        id: j['id'] ?? 0,
        name: (j['name'] ?? '').toString(),
        description: (j['description'] ?? '').toString(),
        costAmountInDollar: (j['costAmountInDollar'] is num)
            ? (j['costAmountInDollar'] as num).toDouble()
            : null,
        sellingPriceInDollar: (j['sellingPriceInDollar'] is num)
            ? (j['sellingPriceInDollar'] as num).toDouble()
            : null,
        merchantSellingPrice: (j['merchantSellingPrice'] is num)
            ? (j['merchantSellingPrice'] as num).toDouble()
            : null,
        merchantSellingPriceStr: j['merchantSellingPriceStr']?.toString(),
        data: (j['data'] ?? '').toString(),
        validity: (j['validity'] ?? '').toString(),
        autostart: j['autostart'] == true,
        imageUrl: j['imageUrl']?.toString(),
        tellGoImageUrl: j['tellGoImageUrl']?.toString(),
        vendorDetails: j['vendorDetails']?.toString(),
        tellGoDetails: j['tellGoDetails']?.toString(),
        speed: j['speed']?.toString(),
        isDataPlan: j['isDataPlan'] == true,
        isActive: j['isActive'] == true,
        isRoaming: j['isRoaming'] == true,
        operatorName: j['operatorName']?.toString(),
        categoryId: j['categoryId'] ?? 0,
        categoryName: (j['categoryName'] ?? '').toString(),
        subCategoryId: j['subCategoryId'] ?? 0,
        subCategoryName: (j['subCategoryName'] ?? '').toString(),
        subCategoryLogo: j['subCategoryLogo']?.toString(),
        bundleTypeId: j['bundleTypeId'] ?? 0,
        bundleType: (j['bundleType'] ?? '').toString(),
        bundleCountries: countries,
        bundleGroupDescription: j['bundleGroupDescription']?.toString(),
      );
  }

  // Helper to get display price
  String get displayPrice {
    if (merchantSellingPriceStr != null && merchantSellingPriceStr!.isNotEmpty) {
      return merchantSellingPriceStr!;
    }
    if (sellingPriceInDollar != null) {
      return '\$${sellingPriceInDollar!.toStringAsFixed(2)}';
    }
    if (costAmountInDollar != null) {
      return '\$${costAmountInDollar!.toStringAsFixed(2)}';
    }
    return 'N/A';
  }
}

class BundleRevisedCountry {
  final int id;
  final int bundleId;
  final String name;
  final String region;
  final String iso;
  final String type;
  final String logo;
  final bool isActive;
  final List<BundleRevisedNetwork> networks;

  const BundleRevisedCountry({
    required this.id,
    required this.bundleId,
    required this.name,
    required this.region,
    required this.iso,
    required this.type,
    required this.logo,
    required this.isActive,
    required this.networks,
  });

  factory BundleRevisedCountry.fromJson(Map<String, dynamic> j) =>
      BundleRevisedCountry(
        id: j['id'] ?? 0,
        bundleId: j['bundleId'] ?? 0,
        name: (j['name'] ?? '').toString(),
        region: (j['region'] ?? '').toString(),
        iso: (j['iso'] ?? '').toString(),
        type: (j['type'] ?? '').toString(),
        logo: (j['logo'] ?? '').toString(),
        isActive: j['isActive'] == true,
        networks: ((j['networks'] as List?) ?? const [])
            .map((e) => BundleRevisedNetwork.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class BundleRevisedNetwork {
  final int id;
  final int bundleCountryId;
  final String name;
  final String brandName;
  final String speed;
  final bool isActive;

  const BundleRevisedNetwork({
    required this.id,
    required this.bundleCountryId,
    required this.name,
    required this.brandName,
    required this.speed,
    required this.isActive,
  });

  factory BundleRevisedNetwork.fromJson(Map<String, dynamic> j) =>
      BundleRevisedNetwork(
        id: j['id'] ?? 0,
        bundleCountryId: j['bundleCountryId'] ?? 0,
        name: (j['name'] ?? '').toString(),
        brandName: (j['brandName'] ?? '').toString(),
        speed: (j['speed'] ?? '').toString(),
        isActive: j['isActive'] == true,
      );
}

class BundlesRevisedPage {
  final List<BundleRevisedItem> bundles;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const BundlesRevisedPage({
    required this.bundles,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory BundlesRevisedPage.fromEnvelope(Map<String, dynamic> env) {
    final r = env['result'] ?? {};
    final list = (r['bundles'] as List?) ?? const [];
    return BundlesRevisedPage(
      bundles: list
          .map((e) => BundleRevisedItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: r['totalCount'] ?? 0,
      page: r['page'] ?? 1,
      pageSize: r['pageSize'] ?? 50,
      totalPages: r['totalPages'] ?? 0,
      hasNextPage: r['hasNextPage'] == true,
      hasPreviousPage: r['hasPreviousPage'] == false,
    );
  }
}

