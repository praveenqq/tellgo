// lib/presentation/features/home/view/widgets/faq_panel.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

typedef FaqItem = ({String q, String a});

class FaqPanel extends StatefulWidget {
  final List<FaqItem> items;
  final double sx;
  const FaqPanel({super.key, required this.items, required this.sx});

  @override
  State<FaqPanel> createState() => _FaqPanelState();
}

class _FaqPanelState extends State<FaqPanel> {
  int? open;

  @override
  Widget build(BuildContext context) {
    final sx = widget.sx;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF241445),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          for (int i = 0; i < widget.items.length; i++) ...[
            _faqRow(widget.items[i], i, sx),
            if (i != widget.items.length - 1)
              const Divider(height: 1, color: Color(0xFF3A2E59)),
          ],
        ],
      ),
    );
  }

  Widget _faqRow(FaqItem item, int i, double sx) {
    final expanded = open == i;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => open = expanded ? null : i),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14 * sx, vertical: 12 * sx),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.q,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 10.5 * sx,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFFC9C2D6),
                  ),
                ],
              ),
              if (expanded) ...[
                SizedBox(height: 8 * sx),
                Text(
                  item.a,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5 * sx,
                    color: Colors.white70,
                    height: 1.42,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
