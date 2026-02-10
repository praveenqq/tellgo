import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_bloc.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_event.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_state.dart';
import 'package:tellgo_app/responsive.dart';
import 'package:tellgo_app/widgets/auth_header.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final scale = R.sxScale(w);
    // Common padding for all components (responsive)
    final pad = R.hPad(w).clamp(16.0, 32.0);
    final padding = EdgeInsets.symmetric(horizontal: pad, vertical: pad);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: Background image (edge-to-edge)
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
          // Layer 2: Foreground content
          SafeArea(
            top: true,
            bottom: true,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth = constraints.maxWidth;
                // Logo size: responsive, 48% of content width, clamped
                final logoSize = (contentWidth * 0.48).clamp(120.0, 220.0);

                return Padding(
                  padding: padding,
                  child: Column(
                    children: [
                      // Header (help + language)
                      AuthHeader(showBackButton: false, selectedLanguage: 'EN'),
                      SizedBox(height: 10 * scale),
                      // Center content
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo
                              Image.asset(
                                'assets/icons/logo.png',
                                width: logoSize,
                                height: logoSize,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return SizedBox(
                                    width: logoSize,
                                    height: logoSize * 0.85,
                                  );
                                },
                              ),
                              SizedBox(height: 16 * scale),
                              // World map (decorative)
                              Opacity(
                                opacity: 0.3,
                                child: Image.asset(
                                  'assets/icons/world_map.png',
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                              SizedBox(height: 32 * scale),
                              // Welcome text
                              Text(
                                'Welcome!',
                                style: GoogleFonts.poppins(
                                  fontSize: 34 * scale,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10 * scale),
                              Text(
                                'Ready to try eSIMs and change\nthe way you stay connected?',
                                style: GoogleFonts.poppins(
                                  fontSize: 18 * scale,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 40 * scale),
                              // LOGIN button – full content width
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  height: 50 * scale,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => context.go('/login'),
                                      borderRadius: BorderRadius.circular(999),
                                      child: Center(
                                        child: Text(
                                          'LOGIN',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18 * scale,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1B0B33),
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Bottom Skip row + divider
                      BlocListener<AuthBloc, AuthState>(
                        listener: (context, state) {
                          if (state is AuthLoginSuccess) {
                            // Navigate to home when guest login succeeds
                            context.go('/home');
                          } else if (state is AuthError) {
                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Make Skip text clickable
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      // Trigger guest login
                                      context.read<AuthBloc>().add(
                                            const GuestLoginRequested(),
                                          );
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8 * scale,
                                        vertical: 8 * scale,
                                      ),
                                      child: BlocBuilder<AuthBloc, AuthState>(
                                        builder: (context, state) {
                                          final isLoading = state is AuthLoading;
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (isLoading)
                                                SizedBox(
                                                  width: 16 * scale,
                                                  height: 16 * scale,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        const AlwaysStoppedAnimation<Color>(
                                                      Colors.white,
                                                    ),
                                                  ),
                                                )
                                              else
                                                Text(
                                                  'Skip',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16 * scale,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      // Trigger guest login (same as Skip)
                                      context.read<AuthBloc>().add(
                                            const GuestLoginRequested(),
                                          );
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: EdgeInsets.all(8 * scale),
                                      child: Image.asset(
                                        'assets/icons/ic_chevron_right_white.png',
                                        width: 20 * scale,
                                        height: 20 * scale,
                                        errorBuilder:
                                            (_, __, ___) => Icon(
                                              Icons.chevron_right,
                                              color: Colors.white,
                                              size: 20 * scale,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12 * scale),
                            Container(height: 1, color: Colors.white),
                            SizedBox(height: 8 * scale),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
