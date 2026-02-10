import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Common header widget for auth screens
/// Provides consistent positioning of back button, title, help icon, and language dropdown
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    this.showBackButton = false,
    this.title,
    this.onBackPressed,
    this.selectedLanguage = 'EN',
    this.onLanguageChanged,
  });

  final bool showBackButton;
  final String? title;
  final VoidCallback? onBackPressed;
  final String selectedLanguage;
  final ValueChanged<String>? onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top row: Back button (optional) + Title (optional) + Help icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back button (if enabled)
            if (showBackButton)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap:
                      onBackPressed ??
                      () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/onboarding');
                        }
                      },
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else
              const SizedBox(width: 44), // Spacer to maintain alignment
            // Title (if provided)
            if (title != null)
              Text(
                title!,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              )
            else
              const Spacer(),
            // Help icon (always shown)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // TODO: Show help dialog
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Image.asset(
                    'assets/icons/ic_help.png',
                    width: 16,
                    height: 16,
                    errorBuilder:
                        (_, __, ___) => const Icon(
                          Icons.help_outline,
                          size: 20,
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Language dropdown (always shown, right-aligned)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // TODO: Show language selector
                  onLanguageChanged?.call(selectedLanguage);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedLanguage,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Image.asset(
                        'assets/icons/ic_chevron_down_white.png',
                        width: 14,
                        height: 14,
                        errorBuilder:
                            (_, __, ___) => const Icon(
                              Icons.keyboard_arrow_down,
                              size: 14,
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
