import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';

import '../domain/profile.dart';
import 'identity_repository_provider.dart';

final FutureProvider<Profile?> currentProfileProvider =
    FutureProvider<Profile?>((Ref ref) async {
      final AuthSessionState authState = await ref.watch(
        authStateProvider.future,
      );

      if (!authState.isAuthenticated) {
        return null;
      }

      return ref.watch(identityRepositoryProvider).getCurrentProfile();
    });
