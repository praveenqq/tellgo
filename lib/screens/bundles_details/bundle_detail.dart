import 'package:flutter/material.dart';
import 'package:tellgo_app/screens/bundle_revised/data/models.dart';
import 'package:tellgo_app/screens/bundle_revised/data/bundles_revised_repository.dart';
import 'package:tellgo_app/screens/checkout_revised/checkout_revised.dart';

/// Bundle Detail Screen - Shows bundles for a subcategory with Limited/Unlimited tabs
/// Accepts subcategory info and fetches/displays bundles dynamically

class BundleDetailScreen extends StatefulWidget {
  final int subCategoryId;
  final String subCategoryName;
  final String subCategoryLogo;

  const BundleDetailScreen({
    super.key,
    required this.subCategoryId,
    required this.subCategoryName,
    required this.subCategoryLogo,
  });

  @override
  State<BundleDetailScreen> createState() => _BundleDetailScreenState();
}

class _BundleDetailScreenState extends State<BundleDetailScreen> {
  final _repo = BundlesRevisedRepository();
  
  bool _isLoading = true;
  String? _error;
  List<BundleRevisedItem> _allBundles = [];
  
  // Segment tabs: 0 = Limited, 1 = Data/Calls/SMS, 2 = Unlimited
  int _segmentIndex = 0;
  int? _selectedPlanIndex;
  
  bool detailsExpanded = true;
  bool moreDetailsExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadBundles();
  }

  Future<void> _loadBundles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final page = await _repo.getBundlesBySubCategoryId(
        subCategoryId: widget.subCategoryId,
        page: 1,
        pageSize: 50, // Load all bundles for this subcategory
      );

      setState(() {
        _allBundles = page.bundles;
        _isLoading = false;
        // Auto-select first plan if available
        final filtered = _getFilteredBundles();
        if (filtered.isNotEmpty) {
          _selectedPlanIndex = 0;
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load bundles. Please try again.';
        _isLoading = false;
      });
    }
  }

  /// Get bundles filtered by selected segment
  List<BundleRevisedItem> _getFilteredBundles() {
    if (_allBundles.isEmpty) return [];
    
    // Filter by bundle type (case-insensitive match)
    final filtered = _allBundles.where((b) {
      final type = b.bundleType.toLowerCase();
      if (_segmentIndex == 0) {
        return type.contains('limited') && !type.contains('unlimited');
      } else if (_segmentIndex == 1) {
        return type.contains('data') || type.contains('call') || type.contains('sms');
      } else {
        return type.contains('unlimited');
      }
    }).toList();
    
    // If no bundles match the filter, show all bundles
    if (filtered.isEmpty) {
      return _allBundles;
}

    return filtered;
  }

  /// Get the currently selected bundle
  BundleRevisedItem? get _selectedBundle {
    final filtered = _getFilteredBundles();
    if (_selectedPlanIndex == null || _selectedPlanIndex! >= filtered.length) {
      return filtered.isNotEmpty ? filtered.first : null;
    }
    return filtered[_selectedPlanIndex!];
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final w = media.size.width;
    final horizontalPadding = w <= 340 ? 16.0 : 20.0;
    final contentMaxWidth = w >= 430 ? 410.0 : double.infinity;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            _TopHeader(
              height: 56,
              title: widget.subCategoryName,
              logoUrl: widget.subCategoryLogo,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: _buildBody(horizontalPadding, contentMaxWidth),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(double horizontalPadding, double contentMaxWidth) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBundles,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_allBundles.isEmpty) {
      return const Center(
        child: Text(
          'No bundles available for this region',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
      );
    }

    final filteredBundles = _getFilteredBundles();
    final selectedBundle = _selectedBundle;

    return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      12,
                      horizontalPadding,
                      24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
              // Promo Card
                        _PromoCard(
                          height: 82,
                          borderWidth: 2,
                          borderColor: AppColors.lavenderBorder,
                          radius: 16,
                          padding: const EdgeInsets.all(16),
                          iconSize: 44,
                          iconToTextGap: 12,
                title: "${widget.subCategoryName} Data eSim – Instant Activation",
                subtitle: "Stay online from the moment you land.\nChoose the best plan for your needs.",
                        ),
                        const SizedBox(height: AppSpacing.s14),

              // Segmented Control (Limited / Data Calls SMS / Unlimited)
                        _SegmentedControl(
                          height: 44,
                          radiusOuter: AppRadii.segmentOuter12,
                          radiusInner: AppRadii.segmentInner10,
                          borderWidth: 2,
                          borderColor: AppColors.primary,
                          items: const ["Limited", "Data/Calls/SMS", "Unlimited"],
                selectedIndex: _segmentIndex,
                onChanged: (i) {
                  setState(() {
                    _segmentIndex = i;
                    // Reset selection when changing tabs
                    final filtered = _getFilteredBundles();
                    _selectedPlanIndex = filtered.isNotEmpty ? 0 : null;
                  });
                },
                        ),
                        const SizedBox(height: AppSpacing.s14),

              // Plans list
              if (filteredBundles.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  child: const Center(
                    child: Text(
                      'No plans available in this category',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                        Column(
                  children: List.generate(filteredBundles.length, (i) {
                    final bundle = filteredBundles[i];
                            return Padding(
                      padding: EdgeInsets.only(bottom: i == filteredBundles.length - 1 ? 0 : 12),
                              child: _PlanOptionCard(
                        height: 88,
                                radius: 16,
                        padding: const EdgeInsets.all(10),
                                dividerWidth: 1,
                                dividerColor: AppColors.divider,
                        isSelected: _selectedPlanIndex == i,
                        bundle: bundle,
                        onTap: () => setState(() => _selectedPlanIndex = i),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: AppSpacing.s18),

              // Countries & Operators Card
              if (selectedBundle != null)
                        _CountriesOperatorsCard(
                          radius: 16,
                          padding: const EdgeInsets.all(16),
                  height: 100,
                  countryName: widget.subCategoryName,
                  countryLogo: widget.subCategoryLogo,
                  operatorName: selectedBundle.operatorName,
                          onAllCountries: () {},
                        ),

              if (selectedBundle != null)
                        const SizedBox(height: AppSpacing.s14),

              // Details Accordion
              if (selectedBundle != null)
                        _AccordionSection(
                          title: "Details",
                          expanded: detailsExpanded,
                          onToggle: () => setState(() => detailsExpanded = !detailsExpanded),
                  children: [
                    if (selectedBundle.isDataPlan)
                      const _DetailRow(
                              icon: Icons.public,
                              label: "PLAN TYPE",
                              value: "Data only eSIM, does not come with a number",
                            ),
                            _DetailRow(
                              icon: Icons.network_cell,
                              label: "CONNECTION TYPE",
                      value: selectedBundle.speed ?? "4G LTE",
                            ),
                            _DetailRow(
                              icon: Icons.calendar_month,
                      label: "VALIDITY",
                      value: "${selectedBundle.validity} Days",
                            ),
                            _DetailRow(
                      icon: Icons.autorenew,
                      label: "AUTO START",
                      value: selectedBundle.autostart ? "Yes" : "No",
                            ),
                          ],
                        ),

              if (selectedBundle != null)
                        const SizedBox(height: AppSpacing.s12),

              // More Details Accordion
              if (selectedBundle != null && (selectedBundle.vendorDetails != null || selectedBundle.tellGoDetails != null))
                        _AccordionSection(
                          title: "More Details",
                          expanded: moreDetailsExpanded,
                          onToggle: () => setState(() => moreDetailsExpanded = !moreDetailsExpanded),
                  children: [
                    if (selectedBundle.vendorDetails != null)
                      _PlainLine(text: selectedBundle.vendorDetails!),
                    if (selectedBundle.tellGoDetails != null)
                      _PlainLine(text: selectedBundle.tellGoDetails!),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.s22),

              // Checkout Button
              if (selectedBundle != null)
                        Center(
                          child: SizedBox(
                    width: 260,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.onPrimary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppRadii.cta16),
                                ),
                              ),
                      onPressed: () {
                        // Navigate to checkout with selectedBundle
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentScreen(
                              bundle: selectedBundle,
                              quantity: 1,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Buy Now - ${selectedBundle.displayPrice}",
                        style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  height: 18 / 14.5,
                                  color: AppColors.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.s28),
                      ],
                    ),
        ),
      ),
    );
  }
}

// ============== UI Components ==============

class AppColors {
  static const primary = Color(0xFF6F49A8);
  static const primaryDark = Color(0xFF3F2A64);
  static const lavenderBorder = Color(0xFFCDBBE8);
  static const bg = Color(0xFFF6F6F8);
  static const surface = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFF111111);
  static const textSecondary = Color(0xFF6B6B6B);
  static const divider = Color(0xFFE7E7EE);

  static const darkButton = Color(0xFF2F2F2F);
  static const danger = Color(0xFFE54242);

  static const onPrimary = Color(0xFFFFFFFF);
  static const selectedLabel = Color(0xFFEDEAF6);
  static const oldPriceUnselected = Color(0xFF9A9AA3);
  static const oldPriceSelected = Color(0xFFD3CAE6);
}

class AppSpacing {
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s14 = 14.0;
  static const s16 = 16.0;
  static const s18 = 18.0;
  static const s20 = 20.0;
  static const s22 = 22.0;
  static const s24 = 24.0;
  static const s28 = 28.0;
  static const s32 = 32.0;
}

class AppRadii {
  static const card16 = 16.0;
  static const segmentOuter12 = 12.0;
  static const segmentInner10 = 10.0;
  static const cta16 = 16.0;
  static const badge10 = 10.0;
  static const navTop32 = 32.0;
}

class AppShadows {
  static const card = [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 10,
      spreadRadius: 0,
      color: Color.fromRGBO(0, 0, 0, 0.06),
    ),
  ];
}

class AppTextStyles {
  static const appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 24 / 20,
    color: AppColors.textPrimary,
  );

  static const sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 20 / 16,
    color: AppColors.textPrimary,
  );

  static const promoTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 18 / 14,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    color: AppColors.textSecondary,
  );

  static const segmentLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 16 / 13,
    letterSpacing: 0.0,
  );

  static const planValue = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    height: 18 / 16,
  );

  static const planLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 14 / 11,
  );

  static const priceValue = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    height: 18 / 15,
  );

  static const oldPrice = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 12 / 10,
    decoration: TextDecoration.lineThrough,
  );
}

/// ---------------- TOP HEADER ----------------

class _TopHeader extends StatelessWidget {
  final double height;
  final String title;
  final String? logoUrl;
  final VoidCallback onBack;

  const _TopHeader({
    required this.height,
    required this.title,
    this.logoUrl,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            SizedBox(
                width: 44,
                height: 44,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: onBack,
                  child: const Center(
                    child: Icon(
                      Icons.chevron_left,
                    size: 28,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 8),
            // Flag/Logo
            if (logoUrl != null && logoUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  logoUrl!,
                  width: 28,
                  height: 20,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Text('🏳️', style: TextStyle(fontSize: 16)),
                ),
              ),
            if (logoUrl != null && logoUrl!.isNotEmpty)
              const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.appBarTitle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- PROMO CARD ----------------

class _PromoCard extends StatelessWidget {
  final double height;
  final double borderWidth;
  final Color borderColor;
  final double radius;
  final EdgeInsets padding;
  final double iconSize;
  final double iconToTextGap;
  final String title;
  final String subtitle;

  const _PromoCard({
    required this.height,
    required this.borderWidth,
    required this.borderColor,
    required this.radius,
    required this.padding,
    required this.iconSize,
    required this.iconToTextGap,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: height),
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: iconSize,
              height: iconSize,
            child: const Icon(Icons.sim_card, size: 40, color: AppColors.primary),
            ),
            SizedBox(width: iconToTextGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AppTextStyles.promoTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.body,
                  maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
      ),
    );
  }
}

/// ---------------- SEGMENTED CONTROL ----------------

class _SegmentedControl extends StatelessWidget {
  final double height;
  final double radiusOuter;
  final double radiusInner;
  final double borderWidth;
  final Color borderColor;
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _SegmentedControl({
    required this.height,
    required this.radiusOuter,
    required this.radiusInner,
    required this.borderWidth,
    required this.borderColor,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radiusOuter),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final selected = i == selectedIndex;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: InkWell(
                borderRadius: BorderRadius.circular(radiusInner),
                onTap: () => onChanged(i),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(radiusInner),
                  ),
                  child: Text(
                    items[i],
                    style: AppTextStyles.segmentLabel.copyWith(
                      color: selected ? AppColors.onPrimary : AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// ---------------- PLAN OPTION CARD ----------------

class _PlanOptionCard extends StatelessWidget {
  final double height;
  final double radius;
  final EdgeInsets padding;
  final double dividerWidth;
  final Color dividerColor;
  final bool isSelected;
  final BundleRevisedItem bundle;
  final VoidCallback onTap;

  const _PlanOptionCard({
    required this.height,
    required this.radius,
    required this.padding,
    required this.dividerWidth,
    required this.dividerColor,
    required this.isSelected,
    required this.bundle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? AppColors.primaryDark : AppColors.surface;
    final valueColor = isSelected ? AppColors.onPrimary : AppColors.textPrimary;
    final labelColor = isSelected ? AppColors.selectedLabel : AppColors.textSecondary;

    return InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Container(
            height: height,
            width: double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              children: [
                _PlanCol(
              top: bundle.data.isNotEmpty ? bundle.data : "N/A",
                  bottom: "Data",
                  topStyle: AppTextStyles.planValue.copyWith(color: valueColor),
                  bottomStyle: AppTextStyles.planLabel.copyWith(color: labelColor),
                ),
                _VHairline(color: dividerColor, width: dividerWidth),
                _PlanCol(
              top: bundle.validity,
              bottom: "Days",
                  topStyle: AppTextStyles.planValue.copyWith(color: valueColor),
                  bottomStyle: AppTextStyles.planLabel.copyWith(color: labelColor),
                ),
                _VHairline(color: dividerColor, width: dividerWidth),
                _PlanCol(
              top: bundle.speed ?? "4G",
              bottom: "Speed",
              topStyle: AppTextStyles.planValue.copyWith(color: valueColor, fontSize: 12),
                  bottomStyle: AppTextStyles.planLabel.copyWith(color: labelColor),
                ),
                _VHairline(color: dividerColor, width: dividerWidth),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    bundle.displayPrice,
                    style: AppTextStyles.priceValue.copyWith(
                      color: isSelected ? const Color(0xFF79C84E) : AppColors.primary,
                ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFF3EEFF),
                      borderRadius: BorderRadius.circular(4),
              ),
                    child: Text(
                      bundle.bundleType,
                style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.primary,
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
}

class _PlanCol extends StatelessWidget {
  final String top;
  final String bottom;
  final TextStyle topStyle;
  final TextStyle bottomStyle;

  const _PlanCol({
    required this.top,
    required this.bottom,
    required this.topStyle,
    required this.bottomStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(top, style: topStyle, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: 2),
          Text(bottom, style: bottomStyle, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _VHairline extends StatelessWidget {
  final Color color;
  final double width;

  const _VHairline({required this.color, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: color,
    );
  }
}

/// ---------------- COUNTRIES & OPERATORS CARD ----------------

class _CountriesOperatorsCard extends StatelessWidget {
  final double radius;
  final EdgeInsets padding;
  final double height;
  final VoidCallback onAllCountries;
  final String? countryName;
  final String? countryLogo;
  final String? operatorName;

  const _CountriesOperatorsCard({
    required this.radius,
    required this.padding,
    required this.height,
    required this.onAllCountries,
    this.countryName,
    this.countryLogo,
    this.operatorName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Countries & Operators", style: AppTextStyles.sectionTitle),
          const SizedBox(height: 10),
          Row(
            children: [
              // Flag/Logo
              if (countryLogo != null && countryLogo!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Image.network(
                    countryLogo!,
                    width: 22,
                    height: 16,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                width: 22,
                height: 16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: AppColors.divider, width: 1),
                ),
                      child: const Center(child: Text('🏳️', style: TextStyle(fontSize: 10))),
                    ),
                  ),
                )
              else
                Container(
                  width: 22,
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: AppColors.divider, width: 1),
                  ),
                  child: const Center(child: Text('🏳️', style: TextStyle(fontSize: 10))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  countryName ?? "Unknown",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 16 / 13,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (operatorName != null && operatorName!.isNotEmpty) ...[
              const SizedBox(width: 8),
              Row(
                  children: [
                  Text(
                      operatorName!,
                      style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 16 / 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                    const SizedBox(width: 6),
                    const Icon(Icons.wifi_tethering, size: 18, color: AppColors.textPrimary),
                ],
              ),
            ],
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------- ACCORDION SECTION ----------------

class _AccordionSection extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  const _AccordionSection({
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card16),
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.card16),
        child: Column(
          children: [
            InkWell(
              onTap: onToggle,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Expanded(child: Text(title, style: AppTextStyles.sectionTitle)),
                    Icon(
                      expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
            ),
            Container(height: 1, color: AppColors.divider),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: ConstrainedBox(
                constraints: expanded ? const BoxConstraints() : const BoxConstraints(maxHeight: 0),
                child: Column(
                  children: [
                    ...List.generate(children.length, (i) {
                      final isLast = i == children.length - 1;
                      return Column(
                        children: [
                          children[i],
                          if (!isLast) Container(height: 1, color: AppColors.divider),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.textPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$label\n",
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      height: 14 / 11.5,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.4,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlainLine extends StatelessWidget {
  final String text;

  const _PlainLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 16 / 13,
          color: AppColors.textPrimary,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
