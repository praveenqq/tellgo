import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_bloc.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_event.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_state.dart';
import 'package:tellgo_app/theme/app_theme.dart';
import 'package:tellgo_app/widgets/auth_header.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // OTP input controllers
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  // Language selection
  final String _selectedLanguage = 'EN';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupFocusListeners();
    // Auto focus first OTP field
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _otpFocusNodes[0].requestFocus();
      }
    });
  }

  void _setupFocusListeners() {
    for (var node in _otpFocusNodes) {
      node.addListener(() {
        setState(() {});
      });
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _handleOtpChange(String value, int index) {
    // Handle paste - if value is longer than 1, it's a paste
    if (value.length > 1) {
      // Paste the entire OTP
      final otp = value.substring(0, value.length.clamp(0, 4));
      for (int i = 0; i < otp.length && i < _otpControllers.length; i++) {
        _otpControllers[i].text = otp[i];
      }
      if (otp.length == 4) {
        _otpFocusNodes[3].unfocus();
        // Auto-verify when all 4 digits are pasted
        _verifyOtp();
      } else if (otp.length < 4) {
        _otpFocusNodes[otp.length].requestFocus();
      }
      return;
    }

    if (value.isNotEmpty) {
      if (index < 3) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        // Last digit entered - unfocus and auto-verify
        _otpFocusNodes[index].unfocus();
        _verifyOtp();
      }
    } else {
      if (index > 0) {
        _otpFocusNodes[index - 1].requestFocus();
      }
    }
  }

  void _verifyOtp() {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length == 4) {
      // Call OTP verification API
      context.read<AuthBloc>().add(
        VerifyLoginOTPRequested(
          email: widget.email,
          otp: otp,
        ),
      );
    }
  }

  void _resendCode() {
    // Clear OTP fields
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _otpFocusNodes[0].requestFocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verification code sent to ${widget.email}'),
        backgroundColor: AppTheme.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    // Figma frame: 1049.94 × 2201.91
    final scale = screenSize.width / 1049.94;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoginSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Email verified successfully!'),
              backgroundColor: AppTheme.accentGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          );

          Future.delayed(const Duration(milliseconds: 1500), () {
            if (!mounted) return;
            context.go('/home');
          });
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.png'),
              fit: BoxFit.cover,
            ),
            ),
          child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(26, 30, 26, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header (back button + title + help + language)
                      AuthHeader(
                        showBackButton: true,
                        title: 'Register',
                        selectedLanguage: _selectedLanguage,
                      ),
                      const SizedBox(height: 20),
                      // Main content - centered when space available
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Primary heading
                          Text(
                            'Verify your Email',
                            style: GoogleFonts.poppins(
                              fontSize: (36 * scale).clamp(24.0, 40.0),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16 * scale),
                          // Supporting subtitle
                          Text(
                            'We\'ll text you on ${widget.email}',
                            style: GoogleFonts.poppins(
                              fontSize: (16 * scale).clamp(14.0, 18.0),
                              fontWeight: FontWeight.normal,
                              color: Colors.white.withValues(alpha: 0.80),
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 48 * scale),
                          // OTP display row (4 slots: 2 visible, 2 masked)
                          _buildOtpDisplay(scale),
                          SizedBox(height: 32 * scale),
                          // Resend link
                          GestureDetector(
                            onTap: _resendCode,
                            child: Text(
                              'Send me a new code',
                              style: GoogleFonts.poppins(
                                fontSize: (14 * scale).clamp(12.0, 16.0),
                                fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.80),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      // SizedBox(height: 32 * scale),
                      // // Bottom primary CTA button (commented – OTP auto-submits on 4-digit entry)
                      // _buildRegisterButton(scale),
                    ],
                  ),
                ),
              ),
            ),
        ),
      ),
    );
  }

  Widget _buildOtpDisplay(double scale) {
    final boxSize = (60 * scale).clamp(52.0, 68.0);
    final fontSize = (26 * scale).clamp(22.0, 30.0);
    final spacing = (18 * scale).clamp(14.0, 22.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isFocused = _otpFocusNodes[index].hasFocus;
        final hasValue = _otpControllers[index].text.isNotEmpty;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _otpFocusNodes[index].requestFocus(),
              child: Container(
                width: boxSize,
                height: boxSize,
                        decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: isFocused 
                        ? const Color(0xFF7B4DC7)
                        : hasValue
                            ? const Color(0xFF7B4DC7).withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.6),
                    width: isFocused ? 2.5 : 1.5,
                  ),
                ),
                // Stack: invisible TextField behind, visible digit text on top
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Invisible text field to capture keyboard input
                    Opacity(
                      opacity: 0,
                      child: SizedBox(
                        width: 1,
                        height: 1,
                  child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _otpFocusNodes[index],
                      keyboardType: TextInputType.number,
                    maxLength: index == 0 ? 4 : 1,
                          showCursor: false,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                      isDense: true,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _handleOtpChange(value, index);
                        });
                      },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                    ),
                      ),
                    ),
                    // Visible digit
                    Text(
                      _otpControllers[index].text,
                      style: GoogleFonts.poppins(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1B0B33),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (index < 3) SizedBox(width: spacing),
          ],
        );
      }),
    );
  }

  // Register button commented out – OTP auto-submits when all 4 digits are entered
  // Widget _buildRegisterButton(double scale) {
  //   return Material(
  //     color: Colors.white,
  //     borderRadius: BorderRadius.circular(999),
  //     child: InkWell(
  //       onTap: _verifyOtp,
  //       borderRadius: BorderRadius.circular(999),
  //       child: Container(
  //         height: (60 * scale).clamp(56.0, 64.0),
  //         alignment: Alignment.center,
  //         child: Text(
  //           'Register',
  //           style: GoogleFonts.poppins(
  //             fontSize: (16 * scale).clamp(14.0, 18.0),
  //             fontWeight: FontWeight.w600,
  //             color: const Color(0xFF1B0B33),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
