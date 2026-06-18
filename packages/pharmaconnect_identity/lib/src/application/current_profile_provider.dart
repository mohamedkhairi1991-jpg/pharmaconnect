import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/profile.dart';
import 'identity_repository_provider.dart';

final FutureProvider<Profile?> currentProfileProvider =
    FutureProvider<Profile?>(
      (Ref ref) async {
        final User? user = await ref.watch(authUserProvider.future);

        if (user == null) {
          return null;
        }

        return ref.watch(identityRepositoryProvider).getCurrentProfile();
      },
    );
