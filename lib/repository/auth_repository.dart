import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tellgo_app/core/network/app_dio.dart';
import 'package:tellgo_app/core/storage/token_storage.dart';
import 'package:tellgo_app/models/user_model.dart';
import 'package:tellgo_app/services/sso_service.dart';

abstract class AuthRepository {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signup(String name, String email, String password);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<void> forgotPassword(String email);
  Future<UserModel> loginWithGoogle();
  Future<UserModel> loginWithApple();
  Future<UserModel> loginWithFacebook(); // Placeholder for future implementation
  Future<void> sendEmailVerification();
  Future<UserModel> signInWithEmailLink(String email);
  // New API-based login methods
  Future<UserModel> loginWithEmailPassword(String username, String password);
  Future<UserModel> verifyLoginOTP(String email, String otp);
  Future<UserModel> registerGuest();
  
  /// OTP-based login (email only, no password)
  /// Sends OTP to the provided email address
  Future<void> loginWithOTP(String email);
}

// Firebase Auth implementation
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final AppDio _appDio = AppDio();

  UserModel _userFromFirebase(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? user.email?.split('@')[0] ?? 'User',
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
    );
  }

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      // For email-only login (magic link), we'll send sign-in link
      // But if password is provided, use email/password
      if (password.isNotEmpty) {
        final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (userCredential.user == null) {
          throw Exception('Login failed');
        }
        return _userFromFirebase(userCredential.user!);
      } else {
        // Email link sign-in flow
        await sendSignInLinkToEmail(email);
        throw Exception('Check your email for the sign-in link');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendSignInLinkToEmail(String email) async {
    final actionCodeSettings = ActionCodeSettings(
      url: 'https://tellgo-app-2025.firebaseapp.com/finishSignUp?cartId=1234',
      handleCodeInApp: true,
      iOSBundleId: 'com.example.tellgoApp',
      androidPackageName: 'com.example.tellgo_app',
      androidInstallApp: true,
      androidMinimumVersion: '12',
    );

    await _firebaseAuth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: actionCodeSettings,
    );
  }

  @override
  Future<UserModel> signInWithEmailLink(String email) async {
    try {
      // This would be called when user clicks the email link
      // For now, we'll use a placeholder
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        return _userFromFirebase(user);
      }
      throw Exception('No user signed in');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> loginWithEmailPassword(String username, String password) async {
    try {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🔄 EMAIL/PASSWORD LOGIN STARTED');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📋 Login Parameters:');
      debugPrint('   Username: $username');
      debugPrint('   Password: ${'*' * password.length}');
      debugPrint('───────────────────────────────────────────────────────────');

      final response = await _appDio.post(
        'Authentication/Login',
        data: {
          'username': username,
          'password': password,
        },
        auth: false, // No auth needed for login
      );

      if (kDebugMode) {
        debugPrint('✅ POST Authentication/Login');
        debugPrint('↳ status: ${response.statusCode}');
        debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
      }

      final data = response.data as Map<String, dynamic>;
      
      if (data['success'] != true || data['result'] == null) {
        final message = data['message']?.toString() ?? 'Login failed';
        throw Exception(message);
      }

      final result = data['result'] as Map<String, dynamic>;
      
      // Note: Login API sends OTP to email - don't store tokens yet
      // Tokens will be stored after OTP verification
      debugPrint('📧 OTP sent to email: $username');
      debugPrint('⏳ Please check your email for OTP code');
      debugPrint('⏳ Navigate to OTP verification screen...');

      // Build UserModel from API response (without storing tokens)
      // We'll get full user data after OTP verification
      final userModel = UserModel(
        id: result['id']?.toString() ?? result['userIdentifier']?.toString() ?? '',
        email: result['email']?.toString() ?? username,
        name: '${result['firstName'] ?? ''} ${result['lastName'] ?? ''}'.trim(),
        phoneNumber: result['mobileNumber']?.toString(),
        emailVerified: false, // Will be verified after OTP
      );

      debugPrint('✅ LOGIN API CALLED - OTP SENT TO EMAIL');
      debugPrint('   Email: ${userModel.email}');
      debugPrint('   Next: User should enter OTP');
      debugPrint('═══════════════════════════════════════════════════════════');

      return userModel;
    } catch (e) {
      debugPrint('❌ EMAIL/PASSWORD LOGIN FAILED: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel> verifyLoginOTP(String email, String otp) async {
    try {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🔄 OTP VERIFICATION STARTED');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📋 OTP Parameters:');
      debugPrint('   Email: $email');
      debugPrint('   OTP: $otp');
      debugPrint('───────────────────────────────────────────────────────────');

      final response = await _appDio.post(
        'Authentication/LoginVerifyLoginOTP',
        data: {
          'email': email,
          'otp': otp,
        },
        auth: false, // No auth needed for OTP verification
      );

      if (kDebugMode) {
        debugPrint('✅ POST Authentication/LoginVerifyLoginOTP');
        debugPrint('↳ status: ${response.statusCode}');
        debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
      }

      final data = response.data as Map<String, dynamic>;
      
      if (data['success'] != true || data['result'] == null) {
        final message = data['message']?.toString() ?? 'OTP verification failed';
        throw Exception(message);
      }

      final result = data['result'] as Map<String, dynamic>;
      
      // Extract tokens
      final accessToken = result['accessToken'] as String?;
      final refreshToken = result['refreshToken'] as String?;

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('OTP verification failed: No access token received');
      }

      // Store tokens
      debugPrint('💾 STORING TOKENS...');
      await TokenStorage.I.save(
        access: accessToken,
        refresh: refreshToken,
      );
      debugPrint('✅ Tokens stored successfully');

      // Build UserModel from API response
      final userModel = UserModel(
        id: result['id']?.toString() ?? result['userIdentifier']?.toString() ?? '',
        email: result['email']?.toString() ?? email,
        name: '${result['firstName'] ?? ''} ${result['lastName'] ?? ''}'.trim(),
        phoneNumber: result['mobileNumber']?.toString(),
        emailVerified: result['isOtpVerify'] == true,
      );

      debugPrint('✅ OTP VERIFICATION SUCCESSFUL');
      debugPrint('   User ID: ${userModel.id}');
      debugPrint('   Email: ${userModel.email}');
      debugPrint('   Name: ${userModel.name}');
      debugPrint('═══════════════════════════════════════════════════════════');

      return userModel;
    } catch (e) {
      debugPrint('❌ OTP VERIFICATION FAILED: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel> registerGuest() async {
    try {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🔄 GUEST REGISTRATION STARTED');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📋 Guest Registration: No parameters required');
      debugPrint('───────────────────────────────────────────────────────────');

      final response = await _appDio.post(
        'User/RegisterGuest',
        auth: false, // No auth needed for guest registration
      );

      if (kDebugMode) {
        debugPrint('✅ POST User/RegisterGuest');
        debugPrint('↳ status: ${response.statusCode}');
        debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
      }

      final data = response.data as Map<String, dynamic>;
      
      if (data['success'] != true || data['result'] == null) {
        final message = data['message']?.toString() ?? 'Guest registration failed';
        throw Exception(message);
      }

      final result = data['result'] is Map
          ? (data['result'] as Map<String, dynamic>)
          : <String, dynamic>{};
      
      // Extract tokens
      final accessToken = result['accessToken'] as String?;
      final refreshToken = result['refreshToken'] as String?;

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Guest registration failed: No access token received');
      }

      // Store tokens
      debugPrint('💾 STORING GUEST TOKENS...');
      await TokenStorage.I.save(
        access: accessToken,
        refresh: refreshToken,
      );
      debugPrint('✅ Guest tokens stored successfully');

      // Build UserModel from API response
      final userModel = UserModel(
        id: result['id']?.toString() ?? result['userIdentifier']?.toString() ?? '',
        email: result['email']?.toString() ?? '',
        name: '${result['firstName'] ?? 'Guest'} ${result['lastName'] ?? 'User'}'.trim(),
        phoneNumber: result['mobileNumber']?.toString(),
        emailVerified: result['isOtpVerify'] == true,
      );

      debugPrint('✅ GUEST REGISTRATION SUCCESSFUL');
      debugPrint('   User ID: ${userModel.id}');
      debugPrint('   User Identifier: ${result['userIdentifier']}');
      debugPrint('   Email: ${userModel.email}');
      debugPrint('   Name: ${userModel.name}');
      debugPrint('═══════════════════════════════════════════════════════════');

      return userModel;
    } catch (e) {
      debugPrint('❌ GUEST REGISTRATION FAILED: $e');
      rethrow;
    }
  }

  @override
  Future<void> loginWithOTP(String email) async {
    try {
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🔄 LOGIN WITH OTP STARTED');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📋 OTP Login Parameters:');
      debugPrint('   Email: $email');
      debugPrint('   Mobile: (empty)');
      debugPrint('───────────────────────────────────────────────────────────');

      final response = await _appDio.post(
        'Authentication/LoginWithOTP',
        data: {
          'email': email,
          'mobile': '', // Empty string for mobile as per API spec
        },
        auth: false, // No auth needed for login
      );

      if (kDebugMode) {
        debugPrint('✅ POST Authentication/LoginWithOTP');
        debugPrint('↳ status: ${response.statusCode}');
        debugPrint(const JsonEncoder.withIndent('  ').convert(response.data));
      }

      final data = response.data as Map<String, dynamic>;
      
      if (data['success'] != true) {
        final message = data['message']?.toString() ?? 'Failed to send OTP';
        // Check for email not found/not registered error
        final messageLower = message.toLowerCase();
        if (messageLower.contains('not found') || 
            messageLower.contains('does not exist') ||
            messageLower.contains('not registered') ||
            messageLower.contains('invalid') ||
            messageLower.contains('no user')) {
          throw Exception('Email is not registered. Please sign up first.');
        }
        throw Exception(message);
      }

      debugPrint('✅ LOGIN WITH OTP - OTP SENT TO EMAIL');
      debugPrint('   Email: $email');
      debugPrint('   Message: ${data['message'] ?? 'OTP sent successfully'}');
      debugPrint('═══════════════════════════════════════════════════════════');
    } catch (e) {
      debugPrint('❌ LOGIN WITH OTP FAILED: $e');
      rethrow;
    }
  }

  @override
  Future<UserModel> signup(String name, String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Signup failed');
      }

      // Update display name
      await userCredential.user!.updateDisplayName(name);

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Reload user to get updated data
      await userCredential.user!.reload();
      final updatedUser = _firebaseAuth.currentUser;

      if (updatedUser == null) {
        throw Exception('Failed to get user after signup');
      }

      return _userFromFirebase(updatedUser);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('🚪 LOGOUT STARTED');
    debugPrint('═══════════════════════════════════════════════════════════');
    
    // Clear tokens first
    debugPrint('🗑️  Clearing stored tokens...');
    await TokenStorage.I.clear();
    debugPrint('✅ Tokens cleared');
    
    // Sign out from Firebase
    debugPrint('🔥 Signing out from Firebase...');
    await _firebaseAuth.signOut();
    debugPrint('✅ Firebase sign out completed');
    
    // Also sign out from Google Sign-In to clear cached account
    debugPrint('🔍 Signing out from Google Sign-In...');
    await GoogleSignIn().signOut();
    debugPrint('✅ Google Sign-In sign out completed');
    
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('✅ LOGOUT COMPLETED');
    debugPrint('═══════════════════════════════════════════════════════════');
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      // Check if we have tokens stored (SSO login)
      final accessToken = await TokenStorage.I.getAccess();
      if (accessToken != null && accessToken.isNotEmpty) {
        // User is authenticated via SSO, return Firebase user
        return _userFromFirebase(user);
      }
      // Firebase user but no tokens - might be email/password login
      return _userFromFirebase(user);
    }
    // No Firebase user - clear any stale tokens
    await TokenStorage.I.clear();
    return null;
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseAuthErrorMessage(e.code));
    }
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    try {
      debugPrint('=== GOOGLE SIGN-IN STARTED ===');
      
      // Sign out from Google Sign-In first to ensure account picker is shown
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      await googleSignIn.signOut();
      
      // Trigger the Google authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('❌ Google Sign-In was cancelled by user');
        throw Exception('Google Sign-In was cancelled');
      }

      debugPrint('✅ GoogleSignInAccount received:');
      debugPrint('  - ID: ${googleUser.id}');
      debugPrint('  - Email: ${googleUser.email}');
      debugPrint('  - Display Name: ${googleUser.displayName}');
      debugPrint('  - Photo URL: ${googleUser.photoUrl}');
      debugPrint('  - Server Auth Code: ${googleUser.serverAuthCode}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      debugPrint('✅ GoogleSignInAuthentication received:');
      if (googleAuth.accessToken != null) {
        final accessTokenLength = googleAuth.accessToken!.length;
        final accessTokenPreview = accessTokenLength > 20 
            ? '${googleAuth.accessToken!.substring(0, 20)}...' 
            : googleAuth.accessToken!;
        debugPrint('  - Access Token: $accessTokenPreview (length: $accessTokenLength)');
      } else {
        debugPrint('  - Access Token: NULL ⚠️');
      }

      if (googleAuth.idToken != null) {
        final idTokenLength = googleAuth.idToken!.length;
        final idTokenPreview = idTokenLength > 50 
            ? '${googleAuth.idToken!.substring(0, 50)}...' 
            : googleAuth.idToken!;
        debugPrint('  - ID Token: $idTokenPreview (length: $idTokenLength)');
      } else {
        debugPrint('  - ID Token: NULL ⚠️');
      }

      debugPrint('  - Server Auth Code: ${googleUser.serverAuthCode ?? 'N/A'}');

      // Validate tokens before creating credential
      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        debugPrint('❌ Both accessToken and idToken are null. Cannot create Firebase credential.');
        throw Exception('Google Sign-In failed: Missing authentication tokens');
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('✅ GoogleAuthProvider credential created');

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        debugPrint('❌ Firebase userCredential.user is null');
        throw Exception('Google Sign-In failed');
      }

      final firebaseUser = userCredential.user!;
      debugPrint('✅ Firebase UserCredential received:');
      debugPrint('  - User UID: ${firebaseUser.uid}');
      debugPrint('  - Email: ${firebaseUser.email}');
      debugPrint('  - Display Name: ${firebaseUser.displayName}');
      debugPrint('  - Photo URL: ${firebaseUser.photoURL}');
      debugPrint('  - Email Verified: ${firebaseUser.emailVerified}');
      debugPrint('  - Phone Number: ${firebaseUser.phoneNumber}');
      debugPrint('  - Is Anonymous: ${firebaseUser.isAnonymous}');
      debugPrint('  - Creation Time: ${firebaseUser.metadata.creationTime}');
      debugPrint('  - Last Sign In Time: ${firebaseUser.metadata.lastSignInTime}');
      debugPrint('  - Provider Data:');
      for (var provider in firebaseUser.providerData) {
        debugPrint('    - Provider ID: ${provider.providerId}');
        debugPrint('      UID: ${provider.uid}');
        debugPrint('      Email: ${provider.email}');
        debugPrint('      Display Name: ${provider.displayName}');
        debugPrint('      Photo URL: ${provider.photoURL}');
      }
      debugPrint('  - Additional User Info:');
      debugPrint('    - Is New User: ${userCredential.additionalUserInfo?.isNewUser}');
      debugPrint('    - Provider ID: ${userCredential.additionalUserInfo?.providerId}');
      debugPrint('    - Username: ${userCredential.additionalUserInfo?.username}');
      debugPrint('    - Profile: ${userCredential.additionalUserInfo?.profile}');
      debugPrint('  - Credential Provider: ${userCredential.credential?.providerId}');

      // Register/login with SSO API
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🔄 PROCEEDING TO SSO API REGISTRATION');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📋 SSO API Parameters:');
      debugPrint('   Email: ${firebaseUser.email ?? 'N/A'}');
      debugPrint('   Display Name: ${firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User'}');
      debugPrint('   Phone Number: ${firebaseUser.phoneNumber ?? 'N/A'}');
      debugPrint('   Is New User: ${userCredential.additionalUserInfo?.isNewUser ?? false}');
      debugPrint('   Provider Name: Google');
      debugPrint('   Provider ID: google.com');
      debugPrint('   Email Verified: ${firebaseUser.emailVerified}');
      debugPrint('───────────────────────────────────────────────────────────');
      
      final ssoUser = await SSOService.I.registerSSOUser(
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
        phoneNumber: firebaseUser.phoneNumber,
        isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
        providerName: 'Google',
        providerId: 'google.com',
        isEmailVerified: firebaseUser.emailVerified,
      );

      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('✅ GOOGLE SIGN-IN FLOW COMPLETED SUCCESSFULLY');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📊 FINAL USER DATA:');
      debugPrint('   User ID: ${ssoUser.id}');
      debugPrint('   Email: ${ssoUser.email}');
      debugPrint('   Name: ${ssoUser.name}');
      debugPrint('   Phone: ${ssoUser.phoneNumber ?? 'N/A'}');
      debugPrint('   Email Verified: ${ssoUser.emailVerified}');
      debugPrint('═══════════════════════════════════════════════════════════');
      
      return ssoUser;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ FirebaseAuthException during Google Sign-In:');
      debugPrint('  - Code: ${e.code}');
      debugPrint('  - Message: ${e.message}');
      debugPrint('  - Stack Trace: ${e.stackTrace}');
      // Clean up Firebase session on error
      await _firebaseAuth.signOut();
      await GoogleSignIn().signOut();
      throw Exception(_getFirebaseAuthErrorMessage(e.code));
    } catch (e, stackTrace) {
      debugPrint('❌ Exception during Google Sign-In:');
      debugPrint('  - Error: $e');
      debugPrint('  - Stack Trace: $stackTrace');
      // If SSO registration fails, still sign out from Firebase to clean up
      debugPrint('❌ SSO registration failed, cleaning up Firebase session');
      await _firebaseAuth.signOut();
      await GoogleSignIn().signOut();
      rethrow;
    }
  }

  /// Generates a cryptographically secure random nonce
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] as a hex string
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<UserModel> loginWithApple() async {
    try {
      // Generate a random nonce
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an OAuth credential from the Apple ID credential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in to Firebase with the Apple OAuth credential
      final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);

      if (userCredential.user == null) {
        throw Exception('Apple Sign-In failed');
      }

      final firebaseUser = userCredential.user!;
      
      // Apple only provides name on first sign-in, so update display name if available
      final displayName = appleCredential.givenName != null
          ? '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'.trim()
          : null;

      if (displayName != null && displayName.isNotEmpty && firebaseUser.displayName == null) {
        await firebaseUser.updateDisplayName(displayName);
        await firebaseUser.reload();
      }

      // Register/login with SSO API
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('🔄 PROCEEDING TO SSO API REGISTRATION');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📋 SSO API Parameters:');
      debugPrint('   Email: ${firebaseUser.email ?? appleCredential.email ?? 'N/A'}');
      debugPrint('   Display Name: ${firebaseUser.displayName ?? displayName ?? 'User'}');
      debugPrint('   Phone Number: ${firebaseUser.phoneNumber ?? 'N/A'}');
      debugPrint('   Is New User: ${userCredential.additionalUserInfo?.isNewUser ?? false}');
      debugPrint('   Provider Name: Apple');
      debugPrint('   Provider ID: apple.com');
      debugPrint('   Email Verified: ${firebaseUser.emailVerified || appleCredential.email != null}');
      debugPrint('   Apple Email: ${appleCredential.email ?? 'N/A'}');
      debugPrint('   Apple Given Name: ${appleCredential.givenName ?? 'N/A'}');
      debugPrint('   Apple Family Name: ${appleCredential.familyName ?? 'N/A'}');
      debugPrint('───────────────────────────────────────────────────────────');
      
      final ssoUser = await SSOService.I.registerSSOUser(
        email: firebaseUser.email ?? appleCredential.email ?? '',
        displayName: firebaseUser.displayName ?? displayName ?? 'User',
        phoneNumber: firebaseUser.phoneNumber,
        isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
        providerName: 'Apple',
        providerId: 'apple.com',
        isEmailVerified: firebaseUser.emailVerified || appleCredential.email != null,
      );

      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('✅ APPLE SIGN-IN FLOW COMPLETED SUCCESSFULLY');
      debugPrint('═══════════════════════════════════════════════════════════');
      debugPrint('📊 FINAL USER DATA:');
      debugPrint('   User ID: ${ssoUser.id}');
      debugPrint('   Email: ${ssoUser.email}');
      debugPrint('   Name: ${ssoUser.name}');
      debugPrint('   Phone: ${ssoUser.phoneNumber ?? 'N/A'}');
      debugPrint('   Email Verified: ${ssoUser.emailVerified}');
      debugPrint('═══════════════════════════════════════════════════════════');

      return ssoUser;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw Exception('Apple Sign-In was cancelled');
      }
      throw Exception('Apple Sign-In failed: ${e.message}');
    } on FirebaseAuthException catch (e) {
      // Clean up Firebase session on error
      await _firebaseAuth.signOut();
      throw Exception(_getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      // If SSO registration fails, still sign out from Firebase to clean up
      debugPrint('❌ SSO registration failed, cleaning up Firebase session');
      await _firebaseAuth.signOut();
      rethrow;
    }
  }

  @override
  Future<UserModel> loginWithFacebook() async {
    // TODO: Implement Facebook login when Facebook SDK is integrated
    throw Exception('Facebook login is not yet implemented');
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many requests. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'invalid-credential':
        return 'Invalid email or password';
      default:
        return 'Authentication failed: $code';
    }
  }
}

// Mock implementation - for testing without Firebase
class MockAuthRepository implements AuthRepository {
  @override
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email.isEmpty) {
      throw Exception('Email is required');
    }

    if (!email.contains('@')) {
      throw Exception('Invalid email format');
    }

    return UserModel(
      id: '1',
      email: email,
      name: email.split('@')[0],
    );
  }

  @override
  Future<UserModel> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (name.isEmpty) {
      throw Exception('Name is required');
    }

    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Invalid email format');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    return UserModel(
      id: '1',
      email: email,
      name: name,
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return null;
  }

  @override
  Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    if (!email.contains('@')) {
      throw Exception('Invalid email format');
    }
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    return UserModel(
      id: '2',
      email: 'user@gmail.com',
      name: 'Google User',
    );
  }

  @override
  Future<UserModel> loginWithApple() async {
    await Future.delayed(const Duration(seconds: 1));
    return UserModel(
      id: '3',
      email: 'user@icloud.com',
      name: 'Apple User',
    );
  }

  @override
  Future<UserModel> loginWithFacebook() async {
    await Future.delayed(const Duration(seconds: 1));
    return UserModel(
      id: '4',
      email: 'user@facebook.com',
      name: 'Facebook User',
    );
  }

  @override
  Future<void> sendEmailVerification() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<UserModel> signInWithEmailLink(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    return UserModel(
      id: '1',
      email: email,
      name: email.split('@')[0],
    );
  }

  @override
  Future<UserModel> loginWithEmailPassword(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return UserModel(
      id: '1',
      email: username,
      name: username.split('@')[0],
    );
  }

  @override
  Future<UserModel> verifyLoginOTP(String email, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    return UserModel(
      id: '1',
      email: email,
      name: email.split('@')[0],
    );
  }

  @override
  Future<UserModel> registerGuest() async {
    await Future.delayed(const Duration(seconds: 1));
    return UserModel(
      id: 'guest-1',
      email: 'guest@test.com',
      name: 'Guest User',
    );
  }

  @override
  Future<void> loginWithOTP(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    if (!email.contains('@')) {
      throw Exception('Invalid email format');
    }
    // Mock success - OTP sent
  }
}
