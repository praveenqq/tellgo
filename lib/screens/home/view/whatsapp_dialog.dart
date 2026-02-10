// lib/presentation/widgets/need_help_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// Call this from anywhere:
/// await showNeedHelpDialog(context, phone: '+965 41 000 999');
Future<void> showNeedHelpDialog(
  BuildContext context, {
  String phone = '+965 41 000 999',
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Need Help',
    transitionDuration: const Duration(milliseconds: 170),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder:
        (_, anim, __, ___) => Opacity(
          opacity: Curves.easeOut.transform(anim.value),
          child: Center(child: NeedHelpDialog(phone: phone)),
        ),
  );
}

class NeedHelpDialog extends StatelessWidget {
  final String phone;
  const NeedHelpDialog({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final sx = (w / 390).clamp(0.85, 1.25);

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16 * sx),
        padding: EdgeInsets.fromLTRB(20 * sx, 18 * sx, 20 * sx, 18 * sx),
        constraints: BoxConstraints(maxWidth: 560 * sx),
        decoration: BoxDecoration(
          color: const Color(0xFF241445), // dialog background
          borderRadius: BorderRadius.circular(18 * sx),
          border: Border.all(color: const Color(0xFF3A2E59)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .45),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Close button
            Positioned(
              right: 4,
              top: 4,
              child: InkResponse(
                onTap: () => Navigator.of(context).pop(),
                radius: 20,
                child: const Icon(Icons.close, color: Colors.white70),
              ),
            ),

            // Content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Need Help?',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20 * sx,
                    ),
                  ),
                ),
                SizedBox(height: 10 * sx),
                const Divider(color: Color(0xFF4E3B77), height: 1),
                SizedBox(height: 18 * sx),

                // Centered body copy + WhatsApp-like icon
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8 * sx),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18 * sx,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Please contact us for your\nWhatsApp number ',
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: SvgPicture.asset(
                            'assets/icons/whatsapp_icon.svg',
                            width: 24 * sx,
                            height: 24 * sx,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20 * sx),

                // Big phone number
                Text(
                  phone,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 30 * sx,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 24 * sx),

                // Done button
                SizedBox(
                  width: 240 * sx,
                  height: 48 * sx,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C61C9),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12 * sx),
                      ),
                      textStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 16 * sx,
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
