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
    name: j['name']?.toString() ?? '',
    code: j['code']?.toString() ?? '',
    isActive: j['isActive'] == true,
  );
}

class BundleSubCategory {
  final int id;
  final int categoryId;
  final String code; // e.g. AE, US-HI, LATAM
  final String name;
  final String? logo; // may be null or an svg url

  const BundleSubCategory({
    required this.id,
    required this.categoryId,
    required this.code,
    required this.name,
    this.logo,
  });

  factory BundleSubCategory.fromJson(Map<String, dynamic> j) =>
      BundleSubCategory(
        id: j['id'] ?? 0,
        categoryId: j['categoryId'] ?? 0,
        code: j['code']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        logo: j['logo']?.toString(),
      );
}

class Bundle {
  final int id;
  final String name;
  final String categoryName; // Local eSIMs / Regional eSIMs / Global …
  final String subCategoryName; // e.g., Africa / France
  final String? subCategoryLogo;
  final List<BundleCountry> countries;

  const Bundle({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.subCategoryName,
    required this.subCategoryLogo,
    required this.countries,
  });

  factory Bundle.fromJson(Map<String, dynamic> j) => Bundle(
    id: j['id'] ?? 0,
    name: j['name']?.toString() ?? '',
    categoryName: j['categoryName']?.toString() ?? '',
    subCategoryName: j['subCategoryName']?.toString() ?? '',
    subCategoryLogo: j['subCategoryLogo']?.toString(),
    countries:
        ((j['bundleCountries'] as List?) ?? const [])
            .map((e) => BundleCountry.fromJson(e as Map<String, dynamic>))
            .toList(),
  );
}

class BundleCountry {
  final String name, iso, region;
  final String? logo;
  const BundleCountry({
    required this.name,
    required this.iso,
    required this.region,
    this.logo,
  });

  factory BundleCountry.fromJson(Map<String, dynamic> j) => BundleCountry(
    name: j['name']?.toString() ?? '',
    iso: j['iso']?.toString() ?? '',
    region: j['region']?.toString() ?? '',
    logo: j['logo']?.toString(),
  );
}
