// lib/screens/home/view/home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tellgo_app/repository/banner_repository.dart';
import 'package:tellgo_app/responsive.dart';
import 'package:tellgo_app/screens/bundle_revised/bloc/bundles_revised_bloc.dart';
import 'package:tellgo_app/screens/bundle_revised/bloc/bundles_revised_event.dart';
import 'package:tellgo_app/screens/bundle_revised/bloc/bundles_revised_state.dart';
import 'package:tellgo_app/screens/bundle_revised/data/bundles_revised_repository.dart';
import 'package:tellgo_app/screens/bundle_revised/data/models.dart' as bundle_models;
import 'package:tellgo_app/screens/bundles_details/bundle_detail.dart';
import 'package:tellgo_app/screens/profile/user_header.dart';
import 'package:tellgo_app/theme/app_theme.dart';
import 'package:tellgo_app/widgets/banner_carousel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _promoPageCtrl = PageController();
  int _promoPage = 0;
  final _searchCtrl = TextEditingController();

  // Search overlay anchoring
  final LayerLink _searchLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    _promoPageCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = R.scale(screenWidth);
    double sx(double px) => R.sx(screenWidth, px);

    return PopScope(
      canPop: true,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
        create: (_) => BundlesRevisedBloc(BundlesRevisedRepository())
          ..add(const BundlesRevisedInit(categoryIndex: 0)),
          ),
          BlocProvider(
            create: (_) => AppBannerBloc(repository: BannerRepositoryImpl())
              ..add(const LoadAppBanners()),
          ),
        ],
        child: Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            body: SafeArea(
              top: true,
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header using CommonAppHeader
                    CommonAppHeader(
                      notificationCount: 3,
                      onNotificationTap: () {
                        context.push('/notifications');
                      },
                      includeSafeAreaTop: false,
                    ),

                    // Banner Carousel (from API)
                    BannerCarousel(
                      height: sx(200),
                      horizontalMargin: sx(20),
                      topMargin: sx(12),
                      borderRadius: sx(18),
                    ),
                    SizedBox(height: sx(20)),

                    // Search Field
                    _buildSearchField(sx, scale),
                    SizedBox(height: sx(30)),

                    // Bundles Section with Tabs
                    _buildBundlesSection(sx, scale),
                    SizedBox(height: sx(28)),

                    // Promotions Section
                    _buildPromotionsSection(sx, scale),
                    SizedBox(height: sx(20)),

                    // Promo Dots Indicator
                    _buildDotsIndicator(4, _promoPage, sx),
                    SizedBox(height: sx(28)),
                  ],
                ),
              ),
            ),
          ),
      ),
    );
  }

  Widget _buildDotsIndicator(
    int count,
    int currentIndex,
    double Function(double) sx,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: sx(4)),
          width: sx(8),
          height: sx(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentIndex
                    ? AppTheme.primaryPurple
                    : AppTheme.borderLight,
          ),
        );
      }),
    );
  }

  Widget _buildSearchField(double Function(double) sx, double scale) {
    final pad = sx(20).clamp(16.0, 28.0);
    return CompositedTransformTarget(
      link: _searchLink,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: pad),
        child: TextField(
              controller: _searchCtrl,
          onChanged: (q) {},
              style: AppTheme.searchPlaceholder(scale),
              decoration: InputDecoration(
                hintText: 'Search data packs for 200+ countries and regions',
                hintStyle: AppTheme.searchPlaceholder(scale),
                filled: true,
                fillColor: AppTheme.surfaceSearch,
                prefixIcon: Icon(
                  Icons.search,
                  size: sx(24),
                  color: AppTheme.textMuted,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(sx(16)),
                  borderSide: BorderSide(color: AppTheme.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(sx(16)),
                  borderSide: BorderSide(color: AppTheme.borderLight),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: sx(20),
                  vertical: sx(14),
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildPromotionsSection(double Function(double) sx, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: sx(78)),
          child: Text('Promotions', style: AppTheme.h1SectionTitle(scale)),
        ),
        SizedBox(height: sx(28)),
        Container(
          margin: EdgeInsets.symmetric(horizontal: sx(34)),
          height: sx(226),
          child: PageView.builder(
            controller: _promoPageCtrl,
            onPageChanged: (index) => setState(() => _promoPage = index),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: sx(1)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(sx(18)),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, sx(6)),
                      blurRadius: sx(16),
                      spreadRadius: 0,
                      color: Colors.black.withValues(alpha: 0.10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(sx(18)),
                  child: Stack(
                    children: [
                      Container(
                        color: AppTheme.surfaceHero,
                        child: Image.asset(
                          'assets/hero/hero1.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        left: sx(20),
                        top: sx(20),
                        child: Text(
                          'EGYPT eSIM',
                          style: GoogleFonts.poppins(
                            fontSize: 20 * scale,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        left: sx(20),
                        bottom: sx(20),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sx(12),
                            vertical: sx(6),
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.badgeRed,
                            borderRadius: BorderRadius.circular(sx(8)),
                          ),
                          child: Text(
                            'UnlimitedGB',
                            style: GoogleFonts.poppins(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBundlesSection(double Function(double) sx, double scale) {
    final pad = sx(20).clamp(16.0, 28.0);
    final tabs = [
      _BundleTabSpec(label: 'Local eSIMs', bg: const Color(0xFF79C84E)),
      _BundleTabSpec(label: 'Regional eSIMs', bg: const Color(0xFFF2A43A)),
      _BundleTabSpec(label: 'Global eSIMs', bg: const Color(0xFF5AA7D8)),
    ];

    return BlocBuilder<BundlesRevisedBloc, BundlesRevisedState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tabs Row
              _buildBundleTabsRow(tabs, state.selectedCategoryIndex, sx, (i) {
                context.read<BundlesRevisedBloc>().add(
                      BundlesRevisedSelectCategory(categoryIndex: i),
                    );
              }),
              SizedBox(height: sx(14)),
              
              // SubCategories List (countries/regions)
              if (state.isLoading && state.subCategories.isEmpty)
                _buildShimmerLoading(sx)
              else if (state.error != null && state.subCategories.isEmpty)
                Padding(
                  padding: EdgeInsets.all(sx(32)),
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                _buildSubCategoriesList(state.subCategories, sx, scale),
              
              SizedBox(height: sx(16)),
              
              // View More button – when tapped, loads ALL remaining items
              if (state.hasMoreToShow && !state.isLoading)
                _buildViewMoreButton(sx, scale, context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBundleTabsRow(
    List<_BundleTabSpec> tabs,
    int selectedIndex,
    double Function(double) sx,
    ValueChanged<int> onTap,
  ) {
    return Row(
      children: List.generate(tabs.length, (i) {
        final t = tabs[i];
        final selected = i == selectedIndex;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == tabs.length - 1 ? 0 : sx(10)),
            child: InkWell(
              borderRadius: BorderRadius.circular(sx(16)),
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(vertical: sx(10)),
                decoration: BoxDecoration(
                  color: t.bg,
                  borderRadius: BorderRadius.circular(sx(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: selected ? 0.20 : 0.10),
                      blurRadius: selected ? 10 : 7,
                      offset: Offset(0, sx(5)),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    t.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: sx(13),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSubCategoriesList(
    List<bundle_models.BundleSubCategory> subCategories,
    double Function(double) sx,
    double scale,
  ) {
    if (subCategories.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(sx(32)),
        child: const Text(
          'No countries available',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
      );
    }

    return Column(
      children: subCategories
          .map(
            (subCategory) => Padding(
              padding: EdgeInsets.only(bottom: sx(10)),
              child: _SubCategoryPill(
                subCategory: subCategory,
                sx: sx,
                scale: scale,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildShimmerLoading(double Function(double) sx) {
    return Column(
      children: List.generate(5, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: sx(10)),
          child: _ShimmerPill(sx: sx, delay: index * 100),
        );
      }),
    );
  }

  /// "View More" button — dispatches ShowAll so EVERY cached subcategory is
  /// rendered in the scrollable column; the button hides after that.
  Widget _buildViewMoreButton(
    double Function(double) sx,
    double scale,
    BuildContext blocContext,
  ) {
    return Center(
      child: GestureDetector(
        onTap: () {
          // Show ALL remaining subcategories at once
          blocContext.read<BundlesRevisedBloc>().add(
                const BundlesRevisedShowAll(),
              );
        },
        child: Container(
          width: sx(348),
          height: sx(51),
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple,
            borderRadius: BorderRadius.circular(sx(12)),
          ),
          child: Center(
            child: Text('View More', style: AppTheme.primaryButtonText(scale)),
          ),
        ),
      ),
    );
  }
}

// ─── Helper classes ──────────────────────────────────────────────────────────

class _BundleTabSpec {
  final String label;
  final Color bg;
  const _BundleTabSpec({required this.label, required this.bg});
}

class _SubCategoryPill extends StatelessWidget {
  final bundle_models.BundleSubCategory subCategory;
  final double Function(double) sx;
  final double scale;

  const _SubCategoryPill({
    required this.subCategory,
    required this.sx,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    const pillBg = Colors.white;
    const border = Color(0xFFB59AE6);
    const nameColor = Color(0xFF2C2440);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BundleDetailScreen(
              subCategoryId: subCategory.id,
              subCategoryName: subCategory.name,
              subCategoryLogo: subCategory.logo,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(sx(16)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: sx(14), vertical: sx(12)),
        decoration: BoxDecoration(
          color: pillBg,
          borderRadius: BorderRadius.circular(sx(16)),
          border: Border.all(color: border, width: sx(2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: sx(10),
              offset: Offset(0, sx(6)),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: sx(34),
              height: sx(24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(sx(6)),
                color: const Color(0xFFF3EEFF),
              ),
              child: subCategory.logo.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(sx(6)),
                      child: Image.network(
                        subCategory.logo,
                        width: sx(34),
                        height: sx(24),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Text('🏳️',
                              style: TextStyle(fontSize: sx(18)));
                        },
                      ),
                    )
                  : Text('🏳️', style: TextStyle(fontSize: sx(18))),
            ),
            SizedBox(width: sx(12)),
            Expanded(
              child: Text(
                subCategory.name,
                style: TextStyle(
                  color: nameColor,
                  fontWeight: FontWeight.w700,
                  fontSize: sx(14),
                ),
              ),
            ),
            if (subCategory.lowestPrice != null)
              Text(
                '${subCategory.lowestPrice!.toStringAsFixed(0)}\$',
                style: TextStyle(
                  color: nameColor,
                  fontWeight: FontWeight.w800,
                  fontSize: sx(14),
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View',
                    style: TextStyle(
                      color: const Color(0xFF6B3FA6),
                      fontWeight: FontWeight.w600,
                      fontSize: sx(12),
                    ),
                  ),
                  SizedBox(width: sx(4)),
                  Icon(
                    Icons.chevron_right,
                    color: const Color(0xFF6B3FA6),
                    size: sx(18),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerPill extends StatefulWidget {
  final double Function(double) sx;
  final int delay;

  const _ShimmerPill({required this.sx, this.delay = 0});

  @override
  State<_ShimmerPill> createState() => _ShimmerPillState();
}

class _ShimmerPillState extends State<_ShimmerPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sx = widget.sx;
    const border = Color(0xFFE8E0F0);
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: sx(14), vertical: sx(12)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(sx(16)),
            border: Border.all(color: border, width: sx(2)),
          ),
          child: Row(
            children: [
              Container(
                width: sx(34),
                height: sx(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(sx(6)),
                  gradient: LinearGradient(
                    begin: Alignment(_animation.value - 1, 0),
                    end: Alignment(_animation.value, 0),
                    colors: const [
                      Color(0xFFF3EEFF),
                      Color(0xFFE0D4F7),
                      Color(0xFFF3EEFF),
                    ],
                  ),
                ),
              ),
              SizedBox(width: sx(12)),
              Expanded(
                child: Container(
                  height: sx(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(sx(4)),
                    gradient: LinearGradient(
                      begin: Alignment(_animation.value - 1, 0),
                      end: Alignment(_animation.value, 0),
                      colors: const [
                        Color(0xFFF5F5F5),
                        Color(0xFFE8E8E8),
                        Color(0xFFF5F5F5),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: sx(20)),
              Container(
                width: sx(50),
                height: sx(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(sx(4)),
                  gradient: LinearGradient(
                    begin: Alignment(_animation.value - 1, 0),
                    end: Alignment(_animation.value, 0),
                    colors: const [
                      Color(0xFFF5F5F5),
                      Color(0xFFE8E8E8),
                      Color(0xFFF5F5F5),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
