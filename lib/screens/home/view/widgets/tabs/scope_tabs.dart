// lib/presentation/features/home/view/widgets/tabs/scope_tabs.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScopeTabs extends StatelessWidget {
  final List<dynamic> categories; // expects Local / Regional / Global
  final int? selectedId;
  final ValueChanged<int> onChanged;
  final double sx;

  const ScopeTabs({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onChanged,
    required this.sx,
  });

  LinearGradient _gradientFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('local')) {
      return const LinearGradient(
        colors: [Color(0xFF9FBF47), Color(0xFF8AB84B), Color(0xFF72AD48)],
        stops: [0.0, 0.5, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    }
    if (n.contains('regional') || n.contains('reginal')) {
      return const LinearGradient(
        colors: [Color(0xFFEFA33A), Color(0xFFDF642E)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    }
    if (n.contains('global')) {
      return const LinearGradient(
        colors: [Color(0xFF5EA9D5), Color(0xFF507CB6), Color(0xFF47559C)],
        stops: [0.0, 0.52, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
    }
    return const LinearGradient(colors: [Color(0xFF6D5AA3), Color(0xFF6D5AA3)]);
  }

  static const _underline = Color(0xFF8A6BCF);

  double _textWidth(String t, TextStyle s) {
    final p = TextPainter(
      text: TextSpan(text: t, style: s),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return p.width;
  }

  @override
  Widget build(BuildContext context) {
    final pillStyle = GoogleFonts.poppins(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontSize: 12.0 * sx,
      height: 1.0,
    );

    final items =
        categories.map((c) {
          final id = c.id as int;
          final name = c.name as String;
          final txtW = _textWidth(name, pillStyle);
          final pillW = txtW + (40 * sx);
          return _TabItem(id: id, name: name, pillWidth: pillW);
        }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenW = MediaQuery.sizeOf(context).width;
        final targetW = (screenW * 0.78).clamp(420.0, 980.0).toDouble();

        final totalPills = items.fold<double>(0, (a, b) => a + b.pillWidth);
        const minGap = 12.0;
        const maxGap = 32.0;

        var gap = (targetW - totalPills) / 2;
        gap = gap.clamp(minGap, maxGap);

        final needsWrap = totalPills + 2 * minGap > targetW;

        final row = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              _TabPill(
                item: items[i],
                selected: items[i].id == selectedId,
                style: pillStyle,
                sx: sx,
                gradient: _gradientFor(items[i].name),
                underlineColor: _underline,
                onTap: () => onChanged(items[i].id),
              ),
              if (i != items.length - 1) SizedBox(width: gap),
            ],
          ],
        );

        final wrap = Wrap(
          alignment: WrapAlignment.center,
          spacing: minGap,
          runSpacing: 10 * sx,
          children: [
            for (final it in items)
              _TabPill(
                item: it,
                selected: it.id == selectedId,
                style: pillStyle,
                sx: sx,
                gradient: _gradientFor(it.name),
                underlineColor: _underline,
                onTap: () => onChanged(it.id),
              ),
          ],
        );

        return Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: targetW),
            child: needsWrap ? wrap : row,
          ),
        );
      },
    );
  }
}

class _TabItem {
  final int id;
  final String name;
  final double pillWidth;
  _TabItem({required this.id, required this.name, required this.pillWidth});
}

class _TabPill extends StatelessWidget {
  final _TabItem item;
  final bool selected;
  final TextStyle style;
  final double sx;
  final LinearGradient gradient;
  final Color underlineColor;
  final VoidCallback onTap;

  const _TabPill({
    required this.item,
    required this.selected,
    required this.style,
    required this.sx,
    required this.gradient,
    required this.underlineColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textW = TextPainter(
      text: TextSpan(text: item.name, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final lineW = (textW.width * 0.80).clamp(110.0, 220.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(35),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * sx,
                  vertical: 9 * sx,
                ),
                child: Text(item.name, style: style),
              ),
            ),
            SizedBox(height: 10 * sx),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 160),
              opacity: selected ? 1 : 0,
              child: Container(
                width: lineW,
                height: 4,
                decoration: BoxDecoration(
                  color: underlineColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
