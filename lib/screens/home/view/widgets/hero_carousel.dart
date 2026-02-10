// lib/presentation/features/home/view/widgets/hero_carousel.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeroCarousel extends StatelessWidget {
  final double height, sx;
  final PageController controller;
  final List<String> images;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onDownload;

  const HeroCarousel({
    super.key,
    required this.height,
    required this.controller,
    required this.images,
    required this.sx,
    required this.onPageChanged,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(55),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: controller,
              itemCount: images.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, i) {
                return Ink.image(
                  image: AssetImage(images[i]),
                  fit: BoxFit.cover,
                  child: const SizedBox.expand(),
                );
              },
            ),
            Positioned(
              left: 14 * sx,
              right: 14 * sx,
              bottom: 14 * sx,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Travel Smart, Stay Connected.',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: .90),
                      fontWeight: FontWeight.w600,
                      fontSize: 12 * sx,
                    ),
                  ),
                  SizedBox(height: 6 * sx),
                  Row(
                    children: [
                      _StoreBadge.apple(onTap: onDownload, sx: sx),
                      SizedBox(width: 8 * sx),
                      _StoreBadge.play(onTap: onDownload, sx: sx),
                    ],
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

class _StoreBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double sx;
  const _StoreBadge._(this.label, this.icon, this.onTap, this.sx);
  factory _StoreBadge.apple({
    required VoidCallback onTap,
    required double sx,
  }) => _StoreBadge._('App Store', Icons.apple, onTap, sx);
  factory _StoreBadge.play({required VoidCallback onTap, required double sx}) =>
      _StoreBadge._('Google Play', Icons.play_arrow_rounded, onTap, sx);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10 * sx, vertical: 8 * sx),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: .70),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: .25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16 * sx, color: Colors.white),
            SizedBox(width: 6 * sx),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 11 * sx,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Dots extends StatelessWidget {
  final int count, index;
  const Dots({super.key, required this.count, required this.index});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 8 : 6,
          height: active ? 8 : 6,
          decoration: BoxDecoration(
            color: active ? Colors.white : const Color(0xFF6D5AA3),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
