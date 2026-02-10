// lib/presentation/features/home/view/search/search_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBarPill extends StatefulWidget {
  final TextEditingController controller;
  final double sx;
  final ValueChanged<String> onChanged;
  final LayerLink link; // overlay anchor
  final ValueChanged<Size> onSized; // notify measured size

  const SearchBarPill({
    super.key,
    required this.controller,
    required this.sx,
    required this.onChanged,
    required this.link,
    required this.onSized,
  });

  @override
  State<SearchBarPill> createState() => _SearchBarPillState();
}

class _SearchBarPillState extends State<SearchBarPill> {
  final GlobalKey _barKey = GlobalKey();
  Size? _lastSent;

  static const _hint = Color(0xFFC9C2D6);
  static const _text = Color(0xFFECEAF2);
  static const _fill = Color(0xFF0F0D27);
  static const _stroke = Color(0xFF292446);

  void _measure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _barKey.currentContext;
      final box = ctx?.findRenderObject() as RenderBox?;
      final size = box?.size;
      if (size != null && size != _lastSent) {
        _lastSent = size;
        widget.onSized(size); // notify only when changed
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _measure();
  }

  @override
  void didUpdateWidget(covariant SearchBarPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    _measure();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final h = (65 * widget.sx).clamp(48.0, 64.0).toDouble();
    final targetW = (screenW * 0.45).clamp(420.0, 980.0).toDouble();

    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: CompositedTransformTarget(
            link: widget.link,
            child: SizedBox(
              key: _barKey,
              width: targetW,
              height: h,
              child: Container(
                decoration: BoxDecoration(
                  color: _fill,
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(color: _stroke, width: 2),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20 * widget.sx),
                child: Row(
                  children: [
                    Icon(Icons.search, color: _hint, size: 18 * widget.sx),
                    SizedBox(width: 12 * widget.sx),
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        onChanged: widget.onChanged,
                        cursorColor: _hint,
                        style: GoogleFonts.poppins(
                          color: _text,
                          fontSize: 14.5 * widget.sx,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintText:
                              'Search data packs for 200+ countries and regions',
                          hintStyle: GoogleFonts.poppins(
                            color: _hint,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.5 * widget.sx,
                            letterSpacing: .2,
                          ),
                        ),
                      ),
                    ),
                    if (widget.controller.text.isNotEmpty) ...[
                      SizedBox(width: 8 * widget.sx),
                      GestureDetector(
                        onTap: () {
                          widget.controller.clear();
                          widget.onChanged('');
                        },
                        child: Icon(
                          Icons.close_rounded,
                          color: _hint,
                          size: 18 * widget.sx,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 26 * widget.sx),
      ],
    );
  }
}
