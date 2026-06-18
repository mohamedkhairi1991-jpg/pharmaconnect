import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:pharmaconnect_core/pharmaconnect_core.dart';
import 'package:pharmaconnect_mobile/app/mobile_app.dart';

Future<void> bootstrapMobileApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppEnvironment environment = AppEnvironment.fromDartDefines();
  final SupabaseConfig supabaseConfig = SupabaseConfig.fromDartDefines();

  AppLogger.configure(environment);
  await initializeSupabaseIfConfigured(supabaseConfig);

  runApp(
    ProviderScope(
      overrides: <Override>[
        appEnvironmentProvider.overrideWithValue(environment),
        supabaseConfigProvider.overrideWithValue(supabaseConfig),
      ],
      child: const MobileApp(),
    ),
  );
}
