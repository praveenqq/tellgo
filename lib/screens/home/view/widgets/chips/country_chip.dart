// lib/presentation/features/home/view/widgets/chips/country_chip.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../flag_avatar.dart';

class CountryChip extends StatelessWidget {
  final String name;
  final String countryCode;
  final String? logo;
  final VoidCallback onTap;
  final double sx;

  const CountryChip({
    super.key,
    required this.name,
    required this.countryCode,
    required this.onTap,
    required this.sx,
    this.logo,
  });

  static const _fill = Color(0xFF0F0D27);
  static const _stroke = Color(0xFF292446);
  static const _text = Colors.white;

  @override
  Widget build(BuildContext context) {
    final minH = (30 * sx).clamp(40.0, 52.0).toDouble();
    final radius = 40.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: minH),
          padding: EdgeInsets.symmetric(horizontal: 5 * sx, vertical: 4 * sx),
          decoration: BoxDecoration(
            color: _fill,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: _stroke, width: 2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FlagAvatar(url: logo, size: 23 * sx),
              SizedBox(width: 8 * sx),
              Expanded(
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: _text,
                    fontWeight: FontWeight.w500,
                    fontSize: 10 * sx,
                    height: 1.05,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
