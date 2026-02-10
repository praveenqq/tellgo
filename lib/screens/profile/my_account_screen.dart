import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_bloc.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_state.dart';
import 'package:tellgo_app/screens/profile/user_header.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  bool promoEmails = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.bgPage,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Common header at the top - balance fetched from WalletBloc
            const CommonAppHeader(
              includeSafeAreaTop: false, // SafeArea is already handled by parent
            ),
            // Content area
            Expanded(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final user = authState.user;

            // Split name into first and last name
            String firstName = 'N/A';
            String lastName = 'N/A';
            if (user?.name != null && user!.name.isNotEmpty) {
              final nameParts = user.name.trim().split(' ');
              if (nameParts.length > 1) {
                firstName = nameParts.first;
                lastName = nameParts.sublist(1).join(' ');
              } else {
                firstName = nameParts.first;
                lastName = '';
              }
            }

            final userEmail = user?.email ?? 'N/A';
            final userPhone = user?.phoneNumber ?? 'N/A';

            return LayoutBuilder(
              builder: (context, c) {
                // Base design width from screenshot.
                const double designW = 525.0;

                // IMPORTANT:
                // Lower min clamp to reduce tight vertical constraints on small screens.
                final double scale = (c.maxWidth / designW).clamp(0.60, 1.25);

                double s(double px) => px * scale;

                // Content column width observed (divider/fields span ~401px).
                final double contentW = s(401);

                return SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints.tightFor(width: contentW),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: s(24),
                          bottom: s(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ===== Account Information =====
                            Text(
                              'Account Information',
                              style: AppTokens.h1(scale),
                            ),
                            SizedBox(height: s(24)),

                            // Field 1
                            _LabeledReadonlyField(
                              scale: scale,
                              label: 'First Name',
                              value: firstName,
                            ),
                            SizedBox(height: s(9)),

                            // Field 2
                            _LabeledReadonlyField(
                              scale: scale,
                              label: 'Last Name',
                              value: lastName,
                            ),
                            SizedBox(height: s(9)),

                            // Field 3
                            _LabeledReadonlyField(
                              scale: scale,
                              label: 'Email',
                              value: userEmail,
                            ),
                            SizedBox(height: s(9)),
                            Align(
                              alignment: Alignment.centerRight,
                              child: _EditPillButton(
                                onTap: () {
                                  // TODO: Navigate to edit email screen
                                },
                                scale: scale,
                              ),
                            ),
                            SizedBox(height: s(10)),

                            // Field 4 (Phone)
                            _PhoneField(
                              scale: scale,
                              phoneNumber: userPhone,
                            ),
                            SizedBox(height: s(9)),
                            Align(
                              alignment: Alignment.centerRight,
                              child: _EditPillButton(
                                onTap: () {
                                  // TODO: Navigate to edit phone screen
                                },
                                scale: scale,
                              ),
                            ),
                            SizedBox(height: s(12)),

                            // Field 5 (Password)
                            _LabeledReadonlyField(
                              scale: scale,
                              label: 'Current Password',
                              value: '***************',
                            ),
                            SizedBox(height: s(8)),
                            Align(
                              alignment: Alignment.centerRight,
                              child: _EditPillButton(
                                onTap: () {
                                  // TODO: Navigate to change password screen
                                },
                                scale: scale,
                              ),
                            ),

                            // Promo switch row
                            SizedBox(height: s(22)),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _PromoSwitch(
                                  value: promoEmails,
                                  onChanged: (v) => setState(() => promoEmails = v),
                                  scale: scale,
                                ),
                                SizedBox(width: s(14)),
                                Expanded(
                                  child: Text(
                                    "I'd like to receive promotional emails.",
                                    style: AppTokens.body(scale).copyWith(
                                      height: 1.2,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Save button
                            SizedBox(height: s(42)),
                            Center(
                              child: _PrimaryButton(
                                text: 'Save Changes',
                                onTap: () {
                                  // TODO: Implement save changes API call
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Changes saved successfully'),
                                    ),
                                  );
                                },
                                scale: scale,
                              ),
                            ),

                            // Divider section
                            SizedBox(height: s(41)),
                            Container(
                              width: double.infinity,
                              height: s(1),
                              color: AppTokens.dividerLavender,
                            ),
                            SizedBox(height: s(41)),

                            // ===== Delete Account =====
                            Text(
                              'Delete Account',
                              style: AppTokens.h2(scale),
                            ),
                            SizedBox(height: s(16)),
                            Text(
                              'You can delete your account permanently. "Note that this process\n'
                              'can take a while and cont be undone after completion.',
                              style: AppTokens.body(scale).copyWith(
                                height: 1.35,
                                color: Colors.black,
                              ),
                            ),

                            SizedBox(height: s(32)),
                            Center(
                              child: _DangerOutlineButton(
                                text: 'DELETE ACCOUNT',
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Account'),
                                      content: const Text(
                                        'Are you sure you want to delete your account? This action cannot be undone.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Account deletion requested'),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: AppTokens.danger),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                scale: scale,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===== Tokens (colors/typography/sizing) =====
class AppTokens {
  // Colors sampled/derived from screenshot
  static const Color bgPage = Color(0xFFFFFFFF);
  static const Color fieldFill = Color(0xFFF1F1F1);
  static const Color fieldBorder = Color(0xFFCFAED8);
  static const Color primary = Color(0xFF85209C);
  static const Color editPillFill = Color(0xFF9C9C9C);
  static const Color dividerLavender = Color(0xFFF1E6F2);
  static const Color danger = Color(0xFFFF0024);
  static const Color switchOn = Color(0xFF00C445);

  // Typography
  static TextStyle h1(double scale) => TextStyle(
        fontFamily: 'Inter',
        fontSize: 20 * scale,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: Colors.black,
      );

  static TextStyle h2(double scale) => TextStyle(
        fontFamily: 'Inter',
        fontSize: 18 * scale,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: Colors.black,
      );

  static TextStyle label(double scale) => TextStyle(
        fontFamily: 'Inter',
        fontSize: 10 * scale,
        fontWeight: FontWeight.w400,
        height: 1.0,
        color: const Color(0xFFA0A0A0),
      );

  static TextStyle value(double scale) => TextStyle(
        fontFamily: 'Inter',
        fontSize: 14 * scale,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: const Color(0xFF555555),
      );

  static TextStyle body(double scale) => TextStyle(
        fontFamily: 'Inter',
        fontSize: 12 * scale,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: Colors.black,
      );

  static TextStyle pill(double scale) => TextStyle(
        fontFamily: 'Inter',
        fontSize: 10 * scale,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5 * scale,
        height: 1.0,
        color: Colors.white,
      );

  static TextStyle primaryButton(double scale) => TextStyle(
        fontFamily: 'Inter',
        fontSize: 14 * scale,
        fontWeight: FontWeight.w700,
        height: 1.0,
        color: Colors.white,
      );

  static TextStyle dangerButton(double scale) => TextStyle(
        fontFamily: 'Inter',
        fontSize: 12 * scale,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6 * scale,
        height: 1.0,
        color: danger,
      );
}

/// ===== Reusable Widgets =====

class _LabeledReadonlyField extends StatelessWidget {
  final double scale;
  final String label;
  final String value;

  const _LabeledReadonlyField({
    required this.scale,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    double s(double px) => px * scale;

    return Container(
      height: s(49), // was 47 -> prevents small-screen RenderFlex overflow
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTokens.fieldFill,
        border: Border.all(color: AppTokens.fieldBorder, width: s(2)),
        borderRadius: BorderRadius.circular(s(8)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: s(32),
          right: s(16),
          top: s(6), // was 8
          bottom: s(6), // was 8
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start, // was center
          children: [
            Text(label, style: AppTokens.label(scale)),
            SizedBox(height: s(2)), // was 4
            Text(
              value,
              style: AppTokens.value(scale),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  final double scale;
  final String phoneNumber;

  const _PhoneField({
    required this.scale,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    double s(double px) => px * scale;

    // Extract phone number without country code if present
    String displayPhone = phoneNumber;
    if (phoneNumber.startsWith('+')) {
      displayPhone = phoneNumber.replaceFirst(RegExp(r'^\+\d{1,4}\s*'), '');
    }
    displayPhone = displayPhone.replaceAll(RegExp(r'[^\d]'), '');

    return Container(
      height: s(49), // was 47 -> prevents overflow
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTokens.fieldFill,
        border: Border.all(color: AppTokens.fieldBorder, width: s(2)),
        borderRadius: BorderRadius.circular(s(8)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: s(32),
          right: s(16),
          top: s(6), // was 8
          bottom: s(6), // was 8
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start, // was center
          children: [
            Text('Mobaile No.', style: AppTokens.label(scale)),
            SizedBox(height: s(2)), // was 4
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: s(18),
                  height: s(12),
                  child: Image.asset(
                    'assets/flags/ae.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.black12,
                    ),
                  ),
                ),
                SizedBox(width: s(6)),
                Icon(
                  Icons.arrow_drop_down,
                  size: s(16),
                  color: Colors.black,
                ),
                SizedBox(width: s(6)),
                Text(
                  displayPhone.isNotEmpty && displayPhone != 'N/A' ? displayPhone : 'N/A',
                  style: AppTokens.value(scale),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditPillButton extends StatelessWidget {
  final VoidCallback onTap;
  final double scale;

  const _EditPillButton({
    required this.onTap,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    double s(double px) => px * scale;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(s(11)),
        child: Ink(
          width: s(72),
          height: s(21),
          decoration: BoxDecoration(
            color: AppTokens.editPillFill,
            borderRadius: BorderRadius.circular(s(11)),
          ),
          child: Center(
            child: Text('EDIT', style: AppTokens.pill(scale)),
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double scale;

  const _PrimaryButton({
    required this.text,
    required this.onTap,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    double s(double px) => px * scale;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(s(8)),
        child: Ink(
          width: s(256),
          height: s(38),
          decoration: BoxDecoration(
            color: AppTokens.primary,
            borderRadius: BorderRadius.circular(s(8)),
          ),
          child: Center(
            child: Text(text, style: AppTokens.primaryButton(scale)),
          ),
        ),
      ),
    );
  }
}

class _DangerOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double scale;

  const _DangerOutlineButton({
    required this.text,
    required this.onTap,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    double s(double px) => px * scale;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(s(10)),
        child: Ink(
          width: s(224),
          height: s(36),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: AppTokens.danger, width: s(2)),
            borderRadius: BorderRadius.circular(s(10)),
          ),
          child: Center(
            child: Text(text, style: AppTokens.dangerButton(scale)),
          ),
        ),
      ),
    );
  }
}

/// Custom switch to match screenshot sizing (56×29) and thumb style.
class _PromoSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double scale;

  const _PromoSwitch({
    required this.value,
    required this.onChanged,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    double s(double px) => px * scale;

    final double w = s(56);
    final double h = s(29);
    final double pad = s(3); // inner padding around thumb
    final double thumbW = s(22);
    final double thumbH = s(23);
    final double radius = h / 2;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: w,
        height: h,
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          color: value ? AppTokens.switchOn : const Color(0xFFE3E3E3),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: thumbW,
            height: thumbH,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(thumbH / 2),
            ),
          ),
        ),
      ),
    );
  }
}
