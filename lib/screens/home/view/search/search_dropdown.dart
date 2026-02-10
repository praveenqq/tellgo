// lib/presentation/features/home/view/search/search_dropdown.dart
import 'package:flutter/material.dart';
import '../widgets/flag_avatar.dart';
import 'country_index.dart';

enum SearchScope { local, regional, global }

class SearchPick {
  final SearchScope scope;
  final String label; // "China", "Africa", or "Global"
  final CountryMeta? country; // populated for Local when available
  const SearchPick({required this.scope, required this.label, this.country});
}

/// Updated dropdown that can match by:
/// - Country (Local) name or ISO
/// - Region (Regional) name
/// - Global (always available; also triggers on "global/world")
///
/// The UI shows a pill (Local/Regional/Global) and a single line beneath it,
/// left-aligned, exactly like the provided screenshots.
class SearchDropdown extends StatelessWidget {
  final String query;
  final List<CountryMeta> countries;
  final List<String> regions;
  final ValueChanged<SearchPick> onPick;
  final double sx;
  const SearchDropdown({
    super.key,
    required this.query,
    required this.countries,
    required this.regions,
    required this.onPick,
    this.sx = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final needle = query.trim();
    if (needle.isEmpty) return const SizedBox.shrink();
    final bestCountry = _bestCountryMatch(needle, countries);
    final bestRegion =
        _bestRegionMatch(needle, regions) ??
        // if we found a country, take its region to display Regional row
        bestCountry?.region;
    // choose a representative local country if region matched but no country did
    final localCountry =
        bestCountry ?? _firstCountryOfRegion(bestRegion, countries);
    final showGlobal = _matchesGlobal(needle) || needle.isNotEmpty;
    // if nothing at all is relevant, don't show
    if (localCountry == null && bestRegion == null && !showGlobal) {
      return const SizedBox.shrink();
    }
    // Colors tuned to match the attached UI
    const cardBg = Color(0xFF0F0E1F);
    const stroke = Color(0xFF3A2E59);
    const pillBg = Color(0xFF1E153B);
    const pillStroke = Color(0xFFB6AEC9);
    // Compact spacing (as requested)
    final hp = (16 * sx).clamp(12.0, 20.0).toDouble();
    final sectionGap = (10 * sx).clamp(6.0, 14.0).toDouble();
    final pillToRowGap = (6 * sx).clamp(4.0, 10.0).toDouble();
    final rowVPad = (4 * sx).clamp(3.0, 8.0).toDouble();
    final titleSize = (13 * sx).clamp(12.0, 14.0);
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: stroke, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(height: 1, thickness: 1, color: stroke),
            Padding(
              padding: EdgeInsets.fromLTRB(hp, 10 * sx, hp, 10 * sx),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LOCAL
                  _ScopePill(
                    label: 'Local',
                    sx: sx,
                    bg: pillBg,
                    border: pillStroke,
                  ),
                  SizedBox(height: pillToRowGap),
                  if (localCountry != null)
                    _ResultRow(
                      sx: sx,
                      vPad: rowVPad,
                      title: localCountry.name,
                      titleSize: titleSize,
                      trailing: FlagAvatar(
                        url: localCountry.logo,
                        size: 26 * sx,
                      ),
                      onTap:
                          () => onPick(
                            SearchPick(
                              scope: SearchScope.local,
                              label: localCountry.name,
                              country: localCountry,
                            ),
                          ),
                    )
                  else
                    _MutedRow(sx: sx, vPad: rowVPad, title: 'No local match'),
                  SizedBox(height: sectionGap),
                  // REGIONAL
                  _ScopePill(
                    label: 'Regional',
                    sx: sx,
                    bg: pillBg,
                    border: pillStroke,
                  ),
                  SizedBox(height: pillToRowGap),
                  if (bestRegion != null && bestRegion.trim().isNotEmpty)
                    _ResultRow(
                      sx: sx,
                      vPad: rowVPad,
                      title: bestRegion,
                      titleSize: titleSize,
                      trailingIcon: Icons.language,
                      onTap:
                          () => onPick(
                            SearchPick(
                              scope: SearchScope.regional,
                              label: bestRegion,
                            ),
                          ),
                    )
                  else
                    _MutedRow(
                      sx: sx,
                      vPad: rowVPad,
                      title: 'No regional match',
                    ),
                  SizedBox(height: sectionGap),
                  // GLOBAL
                  _ScopePill(
                    label: 'Global',
                    sx: sx,
                    bg: pillBg,
                    border: pillStroke,
                  ),
                  SizedBox(height: pillToRowGap),
                  _ResultRow(
                    sx: sx,
                    vPad: rowVPad,
                    title: 'Global',
                    titleSize: titleSize,
                    trailingIcon: Icons.public,
                    onTap:
                        () => onPick(
                          const SearchPick(
                            scope: SearchScope.global,
                            label: 'Global',
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ----------------------------- matching ----------------------------- */
  CountryMeta? _bestCountryMatch(String q, List<CountryMeta> all) {
    final nq = q.trim().toLowerCase();
    if (nq.isEmpty) return null;
    int rank(CountryMeta c) {
      final name = c.name.toLowerCase();
      final iso = (c.iso ?? '').toLowerCase();
      if (nq == iso && iso.isNotEmpty) return 0; // ISO exact ("CN")
      if (name == nq) return 0; // exact name
      if (name.startsWith(nq)) return 1; // prefix
      if (name.split(RegExp(r'[\s\-]+')).any((w) => w.startsWith(nq))) {
        return 2; // word start
      }
      if (name.contains(nq)) return 3; // contains
      if (nq.length >= 4 && _lev1(name, nq)) return 4; // small typo
      return 999;
    }

    CountryMeta? best;
    var bestRank = 999;
    for (final c in all) {
      final r = rank(c);
      if (r < bestRank ||
          (r == bestRank && best != null && c.name.compareTo(best.name) < 0)) {
        best = c;
        bestRank = r;
      }
      if (bestRank == 0) break;
    }
    return (bestRank < 999) ? best : null;
  }

  String? _bestRegionMatch(String q, List<String> all) {
    final nq = q.trim().toLowerCase();
    if (nq.isEmpty) return null;
    int rank(String r) {
      final name = r.toLowerCase();
      if (name == nq) return 0; // exact
      if (name.startsWith(nq)) return 1; // prefix
      if (name.contains(nq)) return 2; // contains
      if (nq.length >= 4 && _lev1(name, nq)) return 3; // small typo
      return 999;
    }

    String? best;
    var bestRank = 999;
    for (final r in all) {
      final k = rank(r);
      if (k < bestRank ||
          (k == bestRank && best != null && r.compareTo(best) < 0)) {
        best = r;
        bestRank = k;
      }
      if (bestRank == 0) break;
    }
    return (bestRank < 999) ? best : null;
  }

  CountryMeta? _firstCountryOfRegion(String? region, List<CountryMeta> all) {
    if (region == null) return null;
    final r = region.trim().toLowerCase();
    final list =
        all.where((c) => c.region.trim().toLowerCase() == r).toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    if (list.isEmpty) return null;
    return list.first;
  }

  bool _matchesGlobal(String q) {
    final nq = q.toLowerCase();
    return nq.contains('global') ||
        nq.contains('world') ||
        nq.contains('international');
  }

  // edit-distance <= 1
  bool _lev1(String a, String b) {
    if ((a.length - b.length).abs() > 1) return false;
    int i = 0, j = 0, edits = 0;
    while (i < a.length && j < b.length) {
      if (a.codeUnitAt(i) == b.codeUnitAt(j)) {
        i++;
        j++;
      } else {
        edits++;
        if (edits > 1) return false;
        if (a.length > b.length) {
          i++;
        } else if (b.length > a.length) {
          j++;
        } else {
          i++;
          j++;
        }
      }
    }
    edits += (a.length - i) + (b.length - j);
    return edits <= 1;
  }
}

/* ----------------------------- widgets ----------------------------- */
class _ScopePill extends StatelessWidget {
  final String label;
  final double sx;
  final Color bg;
  final Color border;
  const _ScopePill({
    required this.label,
    required this.sx,
    required this.bg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * sx, vertical: 6 * sx),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 1.1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12 * sx,
          height: 1,
          letterSpacing: .2,
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final double sx;
  final double vPad;
  final String title;
  final double titleSize;
  final Widget? trailing;
  final IconData? trailingIcon;
  final VoidCallback onTap;
  const _ResultRow({
    required this.sx,
    required this.vPad,
    required this.title,
    required this.titleSize,
    required this.onTap,
    this.trailing,
    this.trailingIcon,
  }) : assert(trailing != null || trailingIcon != null);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: vPad),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null)
              Icon(trailingIcon, color: Colors.white, size: 20 * sx),
          ],
        ),
      ),
    );
  }
}

class _MutedRow extends StatelessWidget {
  final double sx, vPad;
  final String title;
  const _MutedRow({required this.sx, required this.vPad, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vPad),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: .55),
          fontSize: (12 * sx).clamp(11.0, 13.0),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
