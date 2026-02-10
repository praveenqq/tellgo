// lib/presentation/features/home/view/widgets/skeletons.dart
import 'package:flutter/material.dart';

class LoadingTabsSkeleton extends StatelessWidget {
  final double sx;
  const LoadingTabsSkeleton({super.key, required this.sx});
  @override
  Widget build(BuildContext context) {
    Widget box(double w) => Container(
      width: w,
      height: 36 * sx.clamp(0.9, 1.2),
      decoration: BoxDecoration(
        color: const Color(0xFF1E153B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3A2E59)),
      ),
    );
    return Wrap(
      spacing: 10 * sx,
      runSpacing: 10 * sx,
      children: [box(130 * sx), box(140 * sx), box(130 * sx)],
    );
  }
}

class ChipsSkeleton extends StatelessWidget {
  final double sx;
  const ChipsSkeleton({super.key, required this.sx});
  @override
  Widget build(BuildContext context) {
    Widget chip(double w) => Container(
      height: 40 * sx.clamp(0.9, 1.2),
      width: w,
      decoration: BoxDecoration(
        color: const Color(0xFF1E153B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF3A2E59)),
      ),
    );
    return Wrap(
      spacing: 10 * sx,
      runSpacing: 10 * sx,
      children: List.generate(10, (i) => chip(130 + (i % 3) * 20.0)),
    );
  }
}
