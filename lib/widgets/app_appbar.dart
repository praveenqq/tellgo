import 'package:flutter/material.dart';
import 'package:tellgo_app/theme/app_theme.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? titleColor;

  const AppAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.leading,
    this.backgroundColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTheme.headingSmall.copyWith(
          color: titleColor ?? AppTheme.textPrimary,
        ),
      ),
      backgroundColor: backgroundColor ?? AppTheme.backgroundColor,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: showBackButton,
      leading: leading,
      actions: actions,
      iconTheme: IconThemeData(
        color: titleColor ?? AppTheme.textPrimary,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

