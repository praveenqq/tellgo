// lib/presentation/features/home/view/widgets/promo_card.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PromoCard extends StatelessWidget {
  final double height, sx;
  final VoidCallback onTap;
  const PromoCard({
    super.key,
    required this.height,
    required this.sx,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: height,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            gradient: LinearGradient(
              colors: [Color(0xFF4D3291), Color(0xFF3B336E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.fromLTRB(16 * sx, 14 * sx, 16 * sx, 14 * sx),
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Stay Connected, Anywhere, Anytime',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5 * sx,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4 * sx),
                          Text(
                            'Global connectivity at your fingertips\nwith eSIM technology',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 11.5 * sx,
                              color: Colors.white70,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: const [
                              _TinyFlag('ae'),
                              _TinyFlag('gb'),
                              _TinyFlag('us'),
                              _TinyFlag('sa'),
                              _TinyFlag('th'),
                              _TinyFlag('tr'),
                              _TinyFlag('ma'),
                              _TinyFlag('es'),
                            ],
                          ),
                          SizedBox(height: 4 * sx),
                          Text(
                            'More than 200+ Countries',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5 * sx,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                flex: 5,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: _Skyline(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TinyFlag extends StatelessWidget {
  final String iso2; // lowercase
  const _TinyFlag(this.iso2);

  @override
  Widget build(BuildContext context) {
    final url = 'https://flagcdn.com/24x18/$iso2.png';
    return ClipOval(
      child: Image.network(url, width: 32, height: 32, fit: BoxFit.cover),
    );
  }
}

class _Skyline extends StatelessWidget {
  const _Skyline();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _monoBuilding(40, 70, 0),
          _monoBuilding(48, 90, 14),
          _monoBuilding(56, 65, 28),
          Positioned(
            right: 10,
            bottom: 0,
            child: Transform.rotate(
              angle: -math.pi / 20,
              child: Icon(
                Icons.rocket_launch_rounded,
                size: 48,
                color: Colors.white.withValues(alpha: .85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _monoBuilding(double w, double h, double right) => Positioned(
    right: right,
    bottom: 0,
    child: Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: .2)),
      ),
    ),
  );
}
