import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupabaseConfig {
  const SupabaseConfig({
    required this.url,
    required this.anonKey,
  });

  factory SupabaseConfig.fromDartDefines() {
    return const SupabaseConfig(
      url: String.fromEnvironment('SUPABASE_URL'),
      anonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
  }

  final String url;
  final String anonKey;

  bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}

final Provider<SupabaseConfig> supabaseConfigProvider =
    Provider<SupabaseConfig>(
      (Ref ref) => SupabaseConfig.fromDartDefines(),
    );
