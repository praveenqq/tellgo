import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_bloc.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_event.dart';
import 'package:tellgo_app/screens/auth/bloc/auth/auth_state.dart';
import 'package:tellgo_app/theme/app_theme.dart';
import 'package:tellgo_app/widgets/auth_header.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _mobileFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  String _selectedCountryCode = '+1';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final String _selectedLanguage = 'EN';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Common country codes
  final List<Map<String, String>> _countryCodes = [
    {'code': '+1', 'flag': '🇺🇸', 'country': 'US'},
    {'code': '+44', 'flag': '🇬🇧', 'country': 'UK'},
    {'code': '+91', 'flag': '🇮🇳', 'country': 'IN'},
    {'code': '+61', 'flag': '🇦🇺', 'country': 'AU'},
    {'code': '+86', 'flag': '🇨🇳', 'country': 'CN'},
    {'code': '+81', 'flag': '🇯🇵', 'country': 'JP'},
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _mobileFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    _firstNameFocusNode.unfocus();
    _lastNameFocusNode.unfocus();
    _emailFocusNode.unfocus();
    _mobileFocusNode.unfocus();
    _passwordFocusNode.unfocus();
    _confirmPasswordFocusNode.unfocus();

    if (_formKey.currentState!.validate()) {
      final fullName =
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
      context.read<AuthBloc>().add(
        SignupRequested(
          name: fullName,
          email: _emailController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        ),
      );
    }
  }

  bool _checkPasswordRequirement(String requirement) {
    final password = _passwordController.text;
    switch (requirement) {
      case '8+ characters':
        return password.length >= 8;
      case '1 uppercase':
        return password.contains(RegExp(r'[A-Z]'));
      case '1 number':
        return password.contains(RegExp(r'[0-9]'));
      case '1 symbols':
        return password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSignupSuccess) {
          final router = GoRouter.of(context);
          final email = _emailController.text.trim();
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            router.go('/verify-email?email=${Uri.encodeComponent(email)}');
          });
        } else if (state is AuthLoginSuccess) {
          final router = GoRouter.of(context);
          Future.delayed(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            router.go('/home');
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
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4A3FA0), // Dark purple
                Color(0xFF6C5CE7), // Medium purple
                Color(0xFF8B7EF8), // Light purple
              ],
            ),
          ),
          child: SafeArea(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state.isLoading;
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Stack(
                    children: [
                      // Background wave pattern
                      Positioned.fill(
                        child: CustomPaint(painter: _WavePatternPainter()),
                      ),
                      // Main content
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(26, 30, 26, 24),
                        child: Column(
                          children: [
                            // Header (back button + title + help + language)
                            AuthHeader(
                              showBackButton: true,
                              title: 'Registar',
                              selectedLanguage: _selectedLanguage,
                            ),
                            const SizedBox(height: AppTheme.spacing32),
                            // Profile Picture Placeholder
                            Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.black87,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTheme.spacing32),
                            // White container with form
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacing24,
                              ),
                              padding: const EdgeInsets.all(AppTheme.spacing24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // First Name
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        left: 4,
                                        bottom: AppTheme.spacing8,
                                      ),
                                      child: Text(
                                        'First Name*',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: TextFormField(
                                        controller: _firstNameController,
                                        focusNode: _firstNameFocusNode,
                                        textInputAction: TextInputAction.next,
                                        enabled: !isLoading,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                        onFieldSubmitted: (_) {
                                          _lastNameFocusNode.requestFocus();
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'First name is required';
                                          }
                                          return null;
                                        },
                                        decoration: const InputDecoration(
                                          hintText: 'First Name*',
                                          hintStyle: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: AppTheme.spacing16,
                                            vertical: AppTheme.spacing16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.spacing20),
                                    // Last Name
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        left: 4,
                                        bottom: AppTheme.spacing8,
                                      ),
                                      child: Text(
                                        'Last Name*',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: TextFormField(
                                        controller: _lastNameController,
                                        focusNode: _lastNameFocusNode,
                                        textInputAction: TextInputAction.next,
                                        enabled: !isLoading,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                        onFieldSubmitted: (_) {
                                          _emailFocusNode.requestFocus();
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Last name is required';
                                          }
                                          return null;
                                        },
                                        decoration: const InputDecoration(
                                          hintText: 'Last Name*',
                                          hintStyle: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: AppTheme.spacing16,
                                            vertical: AppTheme.spacing16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.spacing20),
                                    // Email Address
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        left: 4,
                                        bottom: AppTheme.spacing8,
                                      ),
                                      child: Text(
                                        'Email Address*',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: TextFormField(
                                        controller: _emailController,
                                        focusNode: _emailFocusNode,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        enabled: !isLoading,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                        onFieldSubmitted: (_) {
                                          _mobileFocusNode.requestFocus();
                                        },
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
                                        decoration: const InputDecoration(
                                          hintText: 'Email Address*',
                                          hintStyle: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: AppTheme.spacing16,
                                            vertical: AppTheme.spacing16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.spacing20),
                                    // Mobile Number
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        left: 4,
                                        bottom: AppTheme.spacing8,
                                      ),
                                      child: Text(
                                        'Mobile Number*',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        // Country Code
                                        Container(
                                          width: 110,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                              width: 1,
                                            ),
                                          ),
                                          child: DropdownButtonFormField<
                                            String
                                          >(
                                            value: _selectedCountryCode,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal:
                                                        AppTheme.spacing12,
                                                    vertical:
                                                        AppTheme.spacing16,
                                                  ),
                                              isDense: true,
                                            ),
                                            items:
                                                _countryCodes.map((country) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: country['code'],
                                                    child: Text(
                                                      country['code']!,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                            onChanged:
                                                isLoading
                                                    ? null
                                                    : (value) {
                                                      if (value != null) {
                                                        setState(() {
                                                          _selectedCountryCode =
                                                              value;
                                                        });
                                                      }
                                                    },
                                            icon: const Icon(
                                              Icons.keyboard_arrow_down,
                                              color: Colors.grey,
                                              size: 20,
                                            ),
                                            iconSize: 20,
                                            isExpanded: false,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: AppTheme.spacing12,
                                        ),
                                        // Mobile Number Input
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: TextFormField(
                                              controller: _mobileController,
                                              focusNode: _mobileFocusNode,
                                              keyboardType: TextInputType.phone,
                                              textInputAction:
                                                  TextInputAction.next,
                                              enabled: !isLoading,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                              onFieldSubmitted: (_) {
                                                _passwordFocusNode
                                                    .requestFocus();
                                              },
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Mobile number is required';
                                                }
                                                if (value.length < 10) {
                                                  return 'Please enter a valid mobile number';
                                                }
                                                return null;
                                              },
                                              decoration: const InputDecoration(
                                                hintText: 'Mobile Number*',
                                                hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16,
                                                ),
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal:
                                                          AppTheme.spacing16,
                                                      vertical:
                                                          AppTheme.spacing16,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppTheme.spacing20),
                                    // Password
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        left: 4,
                                        bottom: AppTheme.spacing8,
                                      ),
                                      child: Text(
                                        'Password*',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: TextFormField(
                                        controller: _passwordController,
                                        focusNode: _passwordFocusNode,
                                        obscureText: _obscurePassword,
                                        textInputAction: TextInputAction.next,
                                        enabled: !isLoading,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                        onChanged: (_) => setState(() {}),
                                        onFieldSubmitted: (_) {
                                          _confirmPasswordFocusNode
                                              .requestFocus();
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Password is required';
                                          }
                                          if (value.length < 8) {
                                            return 'Password must be at least 8 characters';
                                          }
                                          if (!value.contains(
                                            RegExp(r'[A-Z]'),
                                          )) {
                                            return 'Password must contain uppercase';
                                          }
                                          if (!value.contains(
                                            RegExp(r'[0-9]'),
                                          )) {
                                            return 'Password must contain numbers';
                                          }
                                          if (!value.contains(
                                            RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
                                          )) {
                                            return 'Password must contain symbols';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Password*',
                                          hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                      .visibility_off_outlined,
                                              color: Colors.grey,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword =
                                                    !_obscurePassword;
                                              });
                                            },
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: AppTheme.spacing16,
                                                vertical: AppTheme.spacing16,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.spacing12),
                                    // Password Requirements
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _PasswordRequirement(
                                                text: '*8+ characters',
                                                isValid:
                                                    _checkPasswordRequirement(
                                                      '8+ characters',
                                                    ),
                                              ),
                                              const SizedBox(
                                                height: AppTheme.spacing8,
                                              ),
                                              _PasswordRequirement(
                                                text: '*1 symbols',
                                                isValid:
                                                    _checkPasswordRequirement(
                                                      '1 symbols',
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _PasswordRequirement(
                                                text: '*1 uppercase',
                                                isValid:
                                                    _checkPasswordRequirement(
                                                      '1 uppercase',
                                                    ),
                                              ),
                                              const SizedBox(
                                                height: AppTheme.spacing8,
                                              ),
                                              _PasswordRequirement(
                                                text: '*1 number',
                                                isValid:
                                                    _checkPasswordRequirement(
                                                      '1 number',
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppTheme.spacing20),
                                    // Re-Type Password
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        left: 4,
                                        bottom: AppTheme.spacing8,
                                      ),
                                      child: Text(
                                        'Re-Type Password*',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: TextFormField(
                                        controller: _confirmPasswordController,
                                        focusNode: _confirmPasswordFocusNode,
                                        obscureText: _obscureConfirmPassword,
                                        textInputAction: TextInputAction.done,
                                        enabled: !isLoading,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                        onFieldSubmitted:
                                            (_) => _handleSignup(),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please confirm your password';
                                          }
                                          if (value !=
                                              _passwordController.text) {
                                            return 'Passwords do not match';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Re-Type Password*',
                                          hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscureConfirmPassword
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                      .visibility_off_outlined,
                                              color: Colors.grey,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscureConfirmPassword =
                                                    !_obscureConfirmPassword;
                                              });
                                            },
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: AppTheme.spacing16,
                                                vertical: AppTheme.spacing16,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.spacing24),
                                    // Disclaimer
                                    const Text(
                                      'Disclaimer*',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.spacing8),
                                    const Text(
                                      'Dear customer, please be aware that H&S Store does not take any responsibility for the advice, Dear customer, please be aware that H&S Store does not take.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.spacing32),
                                    // Register Button
                                    ElevatedButton(
                                      onPressed:
                                          isLoading ? null : _handleSignup,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black87,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: AppTheme.spacing18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          side: BorderSide(
                                            color: Colors.grey[300]!,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child:
                                          isLoading
                                              ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.black87),
                                                ),
                                              )
                                              : const Text(
                                                'Register',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacing32),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Password Requirement Widget
class _PasswordRequirement extends StatelessWidget {
  final String text;
  final bool isValid;

  const _PasswordRequirement({required this.text, required this.isValid});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: isValid ? AppTheme.primaryPurple : Colors.grey[300]!,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppTheme.spacing8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isValid ? Colors.black87 : Colors.grey,
            decoration: isValid ? null : TextDecoration.lineThrough,
          ),
        ),
      ],
    );
  }
}

// Wave Pattern Painter for background
class _WavePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final path = Path();

    // Create subtle wavy pattern
    for (double i = 0; i < size.height; i += 100) {
      path.reset();
      path.moveTo(0, i);

      for (double x = 0; x < size.width; x += 20) {
        final y =
            i +
            10 *
                (0.5 +
                    0.5 *
                        math.sin(x / size.width * math.pi * 2) *
                        math.cos(i / size.height * math.pi * 2));
        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
