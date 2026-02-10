import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_bloc.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_state.dart';
import 'package:tellgo_app/core/storage/token_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _imagesPreloaded = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPreloaded) {
      _imagesPreloaded = true;
      _preloadImages();
    }
  }

  Future<void> _preloadImages() async {
    // Preload images before showing the screen
    if (!mounted) return;
    await precacheImage(const AssetImage('assets/background.png'), context);

    if (!mounted) return;
    await precacheImage(const AssetImage('assets/icons/logo.png'), context);
  }

  void _checkAuthAndNavigate() async {
    // Wait a moment for the splash to be visible
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Check if user has a valid token stored (persisted login)
    final storedToken = await TokenStorage.I.getAccess();
    final hasValidToken = storedToken != null && storedToken.isNotEmpty;

    // Also check BLoC state for in-memory auth
    final authState = context.read<AuthBloc>().state;
    final isAuthenticatedInMemory = authState is AuthLoginSuccess || authState is AuthSignupSuccess;

    if (hasValidToken || isAuthenticatedInMemory) {
      if (mounted) {
        context.go('/home');
      }
    } else {
      if (mounted) {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoginSuccess || state is AuthSignupSuccess) {
            context.go('/home');
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image - loads immediately from assets
            Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
              gaplessPlayback: true,
              // Remove frameBuilder to show image immediately without color flash
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.black);
              },
            ),
            // Centered logo
            Center(
              child: Image.asset(
                'assets/icons/logo.png',
                width: 250,
                height: 150,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded || frame != null) {
                    return child;
                  }
                  // Show empty space while loading (logo will appear when ready)
                  return const SizedBox(width: 150, height: 185.49000549316406);
                },
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    width: 518.4000244140625,
                    height: 185.49000549316406,
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
