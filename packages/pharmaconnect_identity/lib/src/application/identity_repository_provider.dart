import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';

import '../data/supabase_identity_repository.dart';
import '../domain/identity_repository.dart';

final Provider<IdentityRepository> identityRepositoryProvider =
    Provider<IdentityRepository>(
      (Ref ref) =>
          SupabaseIdentityRepository(ref.watch(supabaseClientProvider)),
    );
