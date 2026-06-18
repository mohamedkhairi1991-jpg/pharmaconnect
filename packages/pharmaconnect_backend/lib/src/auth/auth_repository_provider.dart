import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../client/supabase_client_provider.dart';
import 'auth_repository.dart';
import 'supabase_auth_repository.dart';

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>(
      (Ref ref) =>
          SupabaseAuthRepository(ref.watch(supabaseClientProvider).auth),
    );
