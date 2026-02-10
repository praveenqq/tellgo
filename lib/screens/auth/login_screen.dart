import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_bloc.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_event.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_state.dart';
import 'package:tellgo_app/theme/app_theme.dart';
import 'package:tellgo_app/widgets/auth_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  bool _isEmailFocused = false;
  final String _selectedLanguage = 'EN';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupFocusListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        precacheImage(const AssetImage('assets/background.png'), context);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/background.png'), context);
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

  void _setupFocusListeners() {
    _emailFocusNode.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    _emailFocusNode.unfocus();

    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      // Call OTP-based login API (sends OTP to email)
      context.read<AuthBloc>().add(
        LoginWithOTPRequested(email: email),
      );
    }
  }

  void _handleAppleLogin() {
    context.read<AuthBloc>().add(const AppleLoginRequested());
  }

  void _handleGoogleLogin() {
    context.read<AuthBloc>().add(const GoogleLoginRequested());
  }

  void _handleFacebookLogin() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Facebook login coming soon')));
  }

  void _handleWhatsAppLogin() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('WhatsApp login coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOTPSent) {
          // OTP sent successfully - navigate to OTP verification screen
          final router = GoRouter.of(context);
          final email = Uri.encodeComponent(state.email);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP sent to ${state.email}'),
              backgroundColor: AppTheme.accentGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            router.go('/verify-email?email=$email');
          });
        } else if (state is AuthLoginSuccess) {
          // SSO login success - go directly to home
          final router = GoRouter.of(context);
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            router.go('/home');
          });
        } else if (state is AuthError) {
          // Filter out "method not enabled" errors
          final messageLower = state.message.toLowerCase();
          final isMethodNotEnabledError =
              messageLower.contains('method') &&
              messageLower.contains('not enabled');
          if (!isMethodNotEnabledError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image - full bleed (matching onboarding_screen)
              Positioned.fill(
                child: Image.asset(
                  'assets/background.png',
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: const Color(0xFF1B0B33));
                  },
                ),
              ),
              // Content directly on background
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state.isLoading; // For continue button
                      final loadingProvider =
                          state
                              .loadingProvider; // Track which SSO provider is loading
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(26, 30, 26, 30),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header (back button + title + help + language)
                              AuthHeader(
                                showBackButton: true,
                                title: 'Login',
                                selectedLanguage: _selectedLanguage,
                              ),
                              const SizedBox(height: 20),
                              // Social login buttons
                              _buildSocialButton(
                                text: 'Continue with Apple',
                                assetIconPath: 'assets/icons/login/apple.png',
                                backgroundColor: const Color(0xFF000000),
                                isLoading: loadingProvider == SSOProvider.apple,
                                isDisabled: isLoading || state.isAnySSOLoading,
                                onPressed:
                                    (isLoading || state.isAnySSOLoading)
                                        ? null
                                        : _handleAppleLogin,
                              ),
                              const SizedBox(height: 16),
                              _buildSocialButton(
                                text: 'Continue with Google',
                                assetIconPath: 'assets/icons/login/google.png',
                                backgroundColor: const Color(0xFFEA4435),
                                isLoading:
                                    loadingProvider == SSOProvider.google,
                                isDisabled: isLoading || state.isAnySSOLoading,
                                onPressed:
                                    (isLoading || state.isAnySSOLoading)
                                        ? null
                                        : _handleGoogleLogin,
                              ),
                              const SizedBox(height: 16),
                              _buildSocialButton(
                                text: 'Continue with Facebook',
                                assetIconPath:
                                    'assets/icons/login/facebook.png',
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4373B9),
                                    Color(0xFF2DAFEA),
                                  ],
                                ),
                                isLoading:
                                    loadingProvider == SSOProvider.facebook,
                                isDisabled: isLoading || state.isAnySSOLoading,
                                onPressed:
                                    (isLoading || state.isAnySSOLoading)
                                        ? null
                                        : _handleFacebookLogin,
                              ),
                              const SizedBox(height: 16),
                              _buildSocialButton(
                                text: 'Continue with WhatsApp',
                                assetIconPath:
                                    'assets/icons/login/whatsapp.png',
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00A44D),
                                    Color(0xFF008F49),
                                  ],
                                ),
                                isLoading:
                                    loadingProvider == SSOProvider.whatsapp,
                                isDisabled: isLoading || state.isAnySSOLoading,
                                onPressed:
                                    (isLoading || state.isAnySSOLoading)
                                        ? null
                                        : _handleWhatsAppLogin,
                              ),
                              const SizedBox(height: 20),
                              // OR divider
                              _buildOrDivider(),
                              const SizedBox(height: 24),
                              // Email label
                              Text(
                                'EMAIL ADDRESS',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Email input
                              _buildEmailInput(),
                              const SizedBox(height: 24),
                              // Continue button
                              _buildContinueButton(isLoading),
                              const SizedBox(height: 25),
                              // Forgot email link
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    // TODO: Handle forgot email
                                  },
                                  child: Text(
                                    "Don't remember your email?",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 50),
                              // Footer
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't have an account? ",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap:
                                            isLoading
                                                ? null
                                                : () {
                                                  context.go('/signup');
                                                },
                                        child: Text(
                                          'SIGN UP',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Container(height: 1, color: Colors.white),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String text,
    required String assetIconPath,
    Color? backgroundColor,
    Gradient? gradient,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    final opacity = (isDisabled && !isLoading) ? 0.5 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: gradient,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: (isDisabled || isLoading) ? null : onPressed,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Fixed-width icon container (ensures consistent text start position)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child:
                        isLoading
                            ? null
                            : Image.asset(
                              assetIconPath,
                              width: 24,
                              height: 24,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                  size: 24,
                                );
                              },
                            ),
                  ),
                  const SizedBox(width: 40),
                  // Text or loader (left-aligned, starts at same position)
                  if (isLoading)
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    Expanded(
                      child: Text(
                        text,
                        style: GoogleFonts.poppins(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.white)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11),
          child: Text(
            'OR',
            style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.white),
          ),
        ),
        Expanded(child: Container(height: 1, color: Colors.white)),
      ],
    );
  }

  Widget _buildEmailInput() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        // Remove fill color, make fully transparent
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isEmailFocused ? Colors.white : Colors.white.withAlpha(90),
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: _emailController,
        focusNode: _emailFocusNode,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
        onFieldSubmitted: (_) => _handleContinue(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Email is required';
          }
          final emailRegex = RegExp(
            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
          );
          if (!emailRegex.hasMatch(value)) {
            return 'Please enter a valid email';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: 'Enter your email',
          hintStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red.withAlpha(200),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red.withAlpha(230),
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          filled: false, // no fill color
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(bool isLoading) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : _handleContinue,
          borderRadius: BorderRadius.circular(999),
          child: Center(
            child:
                isLoading
                    ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF1B0B33),
                        ),
                      ),
                    )
                    : Text(
                      'CONTINUE',
                      style: GoogleFonts.poppins(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1B0B33),
                        letterSpacing: 1.2,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
