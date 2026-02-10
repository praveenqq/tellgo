import 'package:flutter/material.dart';
import 'package:tellgo_app/theme/app_theme.dart';

enum AppButtonType { primary, secondary, outlined, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonContent = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textOnPrimary),
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: AppTheme.spacing8),
              ],
              Text(
                text,
                style: AppTheme.button.copyWith(
                  color: _getTextColor(),
                ),
              ),
            ],
          );

    final button = _buildButton(buttonContent);

    if (!isFullWidth) {
      return button;
    }

    return SizedBox(
      width: double.infinity,
      child: button,
    );
  }

  Widget _buildButton(Widget content) {
    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: content,
        );
      case AppButtonType.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.secondaryColor,
            foregroundColor: AppTheme.textOnPrimary,
          ),
          child: content,
        );
      case AppButtonType.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: content,
        );
      case AppButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          child: content,
        );
    }
  }

  Color _getTextColor() {
    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.secondary:
        return AppTheme.textOnPrimary;
      case AppButtonType.outlined:
      case AppButtonType.text:
        return AppTheme.primaryPurple;
    }
  }
}

