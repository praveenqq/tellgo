// lib/presentation/features/home/view/search/country_index.dart
import 'dart:collection';
import 'package:tellgo_app/screens/home/data/models.dart';

class CountryMeta {
  final String name;
  final String region;
  final String? iso;
  final String? logo; // flag svg/png

  const CountryMeta({
    required this.name,
    required this.region,
    this.iso,
    this.logo,
  });
}

/// If you have the raw API json bundles, use this:
List<CountryMeta> countryIndexFromBundles(List<dynamic> bundlesJson) {
  final map = <String, CountryMeta>{}; // keyed by lowercase country name

  for (final b in bundlesJson) {
    final bcList = (b as Map)['bundleCountries'] as List<dynamic>? ?? const [];
    for (final cRaw in bcList) {
      final c = cRaw as Map;
      final name = (c['name'] ?? '').toString().trim();
      if (name.isEmpty) continue;

      final key = name.toLowerCase();
      final region = (c['region'] ?? '').toString().trim();
      final iso = (c['iso'] ?? '').toString().trim();
      final logo = (c['logo'] ?? '').toString().trim();

      final existing = map[key];
      if (existing == null ||
          ((existing.logo == null || existing.logo!.isEmpty) &&
              logo.isNotEmpty)) {
        map[key] = CountryMeta(
          name: name,
          region: region.isEmpty ? 'Global' : region,
          iso: iso.isEmpty ? null : iso,
          logo: logo.isEmpty ? null : logo,
        );
      }
    }
  }

  final list = map.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  return UnmodifiableListView(list);
}

/// ✅ Use this one in the app since you already parse models:
List<CountryMeta> countryIndexFromBundleModels(List<Bundle> bundles) {
  final map = <String, CountryMeta>{}; // key: lowercase name

  for (final b in bundles) {
    for (final c in b.countries) {
      final name = c.name.trim();
      if (name.isEmpty) continue;

      final key = name.toLowerCase();
      final region = c.region.trim().isEmpty ? 'Global' : c.region.trim();
      final iso = c.iso.trim().isEmpty ? null : c.iso.trim();
      final logo = (c.logo ?? '').trim().isEmpty ? null : c.logo!.trim();

      final existing = map[key];
      if (existing == null ||
          ((existing.logo == null || (existing.logo?.isEmpty ?? true)) &&
              (logo != null))) {
        map[key] = CountryMeta(
          name: name,
          region: region,
          iso: iso,
          logo: logo,
        );
      }
    }
  }

  final list = map.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  return UnmodifiableListView(list);
}
