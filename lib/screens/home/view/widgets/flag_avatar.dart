// lib/presentation/features/home/view/widgets/flag_avatar.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FlagAvatar extends StatelessWidget {
  final String? url;
  final double size;
  const FlagAvatar({super.key, required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    Widget? img;
    if (url != null && url!.isNotEmpty) {
      final isSvg = url!.toLowerCase().endsWith('.svg');
      img =
          isSvg
              ? SvgPicture.network(
                url!,
                width: size,
                height: size,
                fit: BoxFit.cover,
              )
              : Image.network(
                url!,
                width: size,
                height: size,
                fit: BoxFit.cover,
              );
    }
    img ??= const _FlagPlaceholder();

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: img,
    );
  }
}

class _FlagPlaceholder extends StatelessWidget {
  const _FlagPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFDEE3FF), Color(0xFFBFC8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
