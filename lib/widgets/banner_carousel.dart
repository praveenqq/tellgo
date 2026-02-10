import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:tellgo_app/repository/banner_repository.dart';
import 'package:tellgo_app/theme/app_theme.dart';

// =============================================================================
// BLOC (Events + States + BLoC – kept here to avoid cross-file import issues)
// =============================================================================

// ── Events ──

abstract class AppBannerEvent {
  const AppBannerEvent();
}

class LoadAppBanners extends AppBannerEvent {
  const LoadAppBanners();
}

// ── States ──

abstract class AppBannerState {
  const AppBannerState();
}

class AppBannerInitial extends AppBannerState {
  const AppBannerInitial();
}

class AppBannerLoading extends AppBannerState {
  const AppBannerLoading();
}

class AppBannerLoaded extends AppBannerState {
  final List<BannerItem> banners;
  const AppBannerLoaded(this.banners);
}

class AppBannerError extends AppBannerState {
  final String message;
  const AppBannerError(this.message);
}

// ── BLoC ──

class AppBannerBloc extends Bloc<AppBannerEvent, AppBannerState> {
  final BannerRepository repository;

  AppBannerBloc({required this.repository}) : super(const AppBannerInitial()) {
    on<LoadAppBanners>(_onLoad);
  }

  Future<void> _onLoad(LoadAppBanners event, Emitter<AppBannerState> emit) async {
    emit(const AppBannerLoading());
    try {
      final banners = await repository.getBanners();
      if (kDebugMode) debugPrint('🎨 AppBannerBloc: Loaded ${banners.length} banners');
      emit(AppBannerLoaded(banners));
    } on DioException catch (e) {
      if (kDebugMode) debugPrint('❌ AppBannerBloc DioError: ${e.message}');
      final msg = e.response?.data is Map
          ? (e.response!.data['message'] ?? 'Failed to load banners')
          : 'Failed to load banners';
      emit(AppBannerError(msg.toString()));
    } catch (e) {
      if (kDebugMode) debugPrint('❌ AppBannerBloc Error: $e');
      emit(AppBannerError(e.toString()));
    }
  }
}

// =============================================================================
// BANNER CAROUSEL WIDGET
// =============================================================================

/// A reusable banner carousel that fetches banners from the API and displays
/// them in a PageView with auto-scroll and animated dot indicators.
///
/// Wrap with:
/// ```dart
/// BlocProvider(
///   create: (_) => AppBannerBloc(repository: BannerRepositoryImpl())
///     ..add(const LoadAppBanners()),
///   child: const BannerCarousel(),
/// )
/// ```
class BannerCarousel extends StatelessWidget {
  final double height;
  final double horizontalMargin;
  final double topMargin;
  final double borderRadius;
  final bool autoScroll;
  final void Function(BannerItem banner)? onBannerTap;

  const BannerCarousel({
    super.key,
    this.height = 200,
    this.horizontalMargin = 20,
    this.topMargin = 12,
    this.borderRadius = 18,
    this.autoScroll = true,
    this.onBannerTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBannerBloc, AppBannerState>(
      builder: (context, state) {
        if (state is AppBannerLoading) {
          return _BannerShimmer(
            height: height,
            horizontalMargin: horizontalMargin,
            topMargin: topMargin,
            borderRadius: borderRadius,
          );
        }

        if (state is AppBannerLoaded && state.banners.isNotEmpty) {
          return _BannerCarouselContent(
            banners: state.banners,
            height: height,
            horizontalMargin: horizontalMargin,
            topMargin: topMargin,
            borderRadius: borderRadius,
            autoScroll: autoScroll,
            onBannerTap: onBannerTap,
          );
        }

        if (state is AppBannerError) {
          return _BannerErrorPlaceholder(
            height: height,
            horizontalMargin: horizontalMargin,
            topMargin: topMargin,
            borderRadius: borderRadius,
            message: state.message,
            onRetry: () {
              context.read<AppBannerBloc>().add(const LoadAppBanners());
            },
          );
        }

        // Initial / empty
        return SizedBox(height: height + topMargin);
      },
    );
  }
}

// ─── Carousel body ───────────────────────────────────────────────────────────

class _BannerCarouselContent extends StatefulWidget {
  final List<BannerItem> banners;
  final double height;
  final double horizontalMargin;
  final double topMargin;
  final double borderRadius;
  final bool autoScroll;
  final void Function(BannerItem banner)? onBannerTap;

  const _BannerCarouselContent({
    required this.banners,
    required this.height,
    required this.horizontalMargin,
    required this.topMargin,
    required this.borderRadius,
    required this.autoScroll,
    this.onBannerTap,
  });

  @override
  State<_BannerCarouselContent> createState() => _BannerCarouselContentState();
}

class _BannerCarouselContentState extends State<_BannerCarouselContent> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.autoScroll && widget.banners.length > 1) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    final secs = widget.banners.first.timer > 0 ? widget.banners.first.timer : 5;
    _autoScrollTimer = Timer.periodic(Duration(seconds: secs), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % widget.banners.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(
            left: widget.horizontalMargin,
            right: widget.horizontalMargin,
            top: widget.topMargin,
          ),
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return GestureDetector(
                onTap: widget.onBannerTap != null
                    ? () => widget.onBannerTap!(banner)
                    : null,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceHero,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 6),
                        blurRadius: 16,
                        color: Colors.black.withValues(alpha: 0.10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: Image.network(
                      banner.bannerUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (ctx, child, prog) {
                        if (prog == null) return child;
                        return Container(
                          color: AppTheme.surfaceHero,
                          child: const Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppTheme.primaryPurple,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (ctx, err, st) => Container(
                        color: AppTheme.surfaceHero,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.broken_image_outlined,
                                size: 36, color: AppTheme.textMuted),
                            const SizedBox(height: 8),
                            Text(banner.bannerName,
                                style: const TextStyle(
                                    fontSize: 13, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 12),
          _DotsIndicator(count: widget.banners.length, currentIndex: _currentPage),
        ],
      ],
    );
  }
}

// ─── Dot indicators ──────────────────────────────────────────────────────────

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  const _DotsIndicator({required this.count, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: active ? AppTheme.primaryPurple : AppTheme.borderLight,
          ),
        );
      }),
    );
  }
}

// ─── Shimmer placeholder ─────────────────────────────────────────────────────

class _BannerShimmer extends StatefulWidget {
  final double height, horizontalMargin, topMargin, borderRadius;
  const _BannerShimmer({
    required this.height,
    required this.horizontalMargin,
    required this.topMargin,
    required this.borderRadius,
  });
  @override
  State<_BannerShimmer> createState() => _BannerShimmerState();
}

class _BannerShimmerState extends State<_BannerShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this)
      ..repeat();
    _anim = Tween(begin: -1.0, end: 2.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(
            left: widget.horizontalMargin,
            right: widget.horizontalMargin,
            top: widget.topMargin,
          ),
          height: widget.height,
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: LinearGradient(
                  begin: Alignment(_anim.value - 1, 0),
                  end: Alignment(_anim.value, 0),
                  colors: const [
                    Color(0xFFEEEEEE),
                    Color(0xFFE0E0E0),
                    Color(0xFFEEEEEE),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == 0 ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: const Color(0xFFE0E0E0),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─── Error placeholder ───────────────────────────────────────────────────────

class _BannerErrorPlaceholder extends StatelessWidget {
  final double height, horizontalMargin, topMargin, borderRadius;
  final String message;
  final VoidCallback onRetry;

  const _BannerErrorPlaceholder({
    required this.height,
    required this.horizontalMargin,
    required this.topMargin,
    required this.borderRadius,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: horizontalMargin,
        right: horizontalMargin,
        top: topMargin,
      ),
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.surfaceHero,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_not_supported_outlined,
                size: 36, color: AppTheme.textMuted),
            const SizedBox(height: 8),
            const Text('Could not load banners',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Retry',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
