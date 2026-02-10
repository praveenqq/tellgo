import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage._();
  static final TokenStorage I = TokenStorage._();

  SharedPreferences? _prefs;
  Future<SharedPreferences> _ensure() async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<void> save({
    required String access,
    String? refresh,
    String? refreshExpIso,
  }) async {
    // Console log the tokens when saved (especially for SSO login)
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('🔑 TOKEN STORAGE - SAVING TOKENS');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('📝 Access Token:');
    debugPrint('   Full Token: $access');
    debugPrint('   Token Length: ${access.length}');
    if (access.length > 50) {
      debugPrint('   Token Preview (first 50 chars): ${access.substring(0, 50)}...');
      debugPrint('   Token Preview (last 50 chars): ...${access.substring(access.length - 50)}');
    }
    
    if (refresh != null && refresh.isNotEmpty) {
      debugPrint('📝 Refresh Token:');
      debugPrint('   Full Token: $refresh');
      debugPrint('   Token Length: ${refresh.length}');
      if (refresh.length > 50) {
        debugPrint('   Token Preview (first 50 chars): ${refresh.substring(0, 50)}...');
        debugPrint('   Token Preview (last 50 chars): ...${refresh.substring(refresh.length - 50)}');
      }
    } else {
      debugPrint('📝 Refresh Token: Not provided');
    }
    
    if (refreshExpIso != null) {
      debugPrint('📅 Refresh Token Expiry: $refreshExpIso');
    }
    
    debugPrint('═══════════════════════════════════════════════════════════');
    
    final p = await _ensure();
    await p.setString('auth_access_token', access);
    if (refresh != null) await p.setString('auth_refresh_token', refresh);
    if (refreshExpIso != null) {
      await p.setString('auth_refresh_token_expiry', refreshExpIso);
    }
    
    debugPrint('✅ Tokens saved to SharedPreferences successfully');
    debugPrint('═══════════════════════════════════════════════════════════');
  }

  Future<String?> getAccess() async =>
      (await _ensure()).getString('auth_access_token');

  Future<void> clear() async {
    final p = await _ensure();
    await p.remove('auth_access_token');
    await p.remove('auth_refresh_token');
    await p.remove('auth_refresh_token_expiry');
  }
}


