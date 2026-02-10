// lib/presentation/features/home/view/widgets/chips/chips_grid.dart
import 'package:flutter/material.dart';

class ChipsGrid extends StatelessWidget {
  final List<Widget> children;
  final double sx;

  /// Optional: force a fixed number of columns (e.g., 2 for Regional tab).
  final int? fixedCols;

  const ChipsGrid({
    super.key,
    required this.children,
    required this.sx,
    this.fixedCols,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final maxW = c.maxWidth;

        const shrinkFactor = 0.80;
        final containerW = (maxW * shrinkFactor).clamp(320.0, maxW);

        // If fixedCols is provided, use it; otherwise fall back to responsive rule
        final int cols =
            (fixedCols != null && fixedCols! > 0)
                ? fixedCols!.clamp(1, 6)
                : (containerW >= 900 ? 4 : (containerW >= 660 ? 3 : 2));

        final hGap = (14 * sx).clamp(8.0, 18.0).toDouble();
        final vGap = (10 * sx).clamp(6.0, 14.0).toDouble();

        final colW = (containerW - hGap * (cols - 1)) / cols;

        return Center(
          child: SizedBox(
            width: containerW,
            child: Wrap(
              spacing: hGap,
              runSpacing: vGap,
              children:
                  children.map((w) => SizedBox(width: colW, child: w)).toList(),
            ),
          ),
        );
      },
    );
  }
}
