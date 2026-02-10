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
