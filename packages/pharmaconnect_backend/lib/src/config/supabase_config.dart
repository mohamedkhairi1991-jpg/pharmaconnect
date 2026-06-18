import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupabaseConfig {
  const SupabaseConfig({
    required this.url,
    required this.anonKey,
    required this.mobileAuthCallbackUrl,
    required this.adminAuthCallbackUrl,
  });

  factory SupabaseConfig.fromDartDefines() {
    return const SupabaseConfig(
      url: String.fromEnvironment('SUPABASE_URL'),
      anonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
      mobileAuthCallbackUrl: String.fromEnvironment(
        'MOBILE_AUTH_CALLBACK_URL',
        defaultValue: 'com.pharmaconnect.mobile://auth/callback',
      ),
      adminAuthCallbackUrl: String.fromEnvironment(
        'ADMIN_AUTH_CALLBACK_URL',
        defaultValue: 'http://localhost:3000/auth/callback',
      ),
    );
  }

  final String url;
  final String anonKey;
  final String mobileAuthCallbackUrl;
  final String adminAuthCallbackUrl;

  bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}

final Provider<SupabaseConfig> supabaseConfigProvider =
    Provider<SupabaseConfig>((Ref ref) => SupabaseConfig.fromDartDefines());
