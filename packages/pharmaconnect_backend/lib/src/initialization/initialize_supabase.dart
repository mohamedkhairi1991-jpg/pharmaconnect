import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

Future<void> initializeSupabaseIfConfigured(SupabaseConfig config) async {
  if (!config.isConfigured) {
    return;
  }

  await Supabase.initialize(
    url: config.url,
    publishableKey: config.anonKey,
  );
}
