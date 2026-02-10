// lib/presentation/features/home/view/widgets/shared_widgets.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilledPill extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final double sx;
  const FilledPill({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    required this.sx,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: (32 * sx).clamp(32.0, 40.0),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10 * sx,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorPill extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final double sx;
  const ErrorPill({
    super.key,
    required this.message,
    required this.onRetry,
    required this.sx,
  });
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: const Color(0xFF3A2E59),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onRetry,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 14 * sx,
              vertical: 10 * sx,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
                SizedBox(width: 8 * sx),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 12 * sx,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
