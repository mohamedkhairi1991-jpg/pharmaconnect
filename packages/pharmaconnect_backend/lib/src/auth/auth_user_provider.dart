import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_repository_provider.dart';
import 'auth_session_state.dart';
import 'auth_state_provider.dart';

final Provider<AsyncValue<String?>> authUserIdProvider =
    Provider<AsyncValue<String?>>(
      (Ref ref) => ref
          .watch(authStateProvider)
          .whenData((AuthSessionState state) => state.userId),
    );

@Deprecated('Use authStateProvider or authUserIdProvider.')
final StreamProvider<String?> authUserProvider = StreamProvider<String?>(
  (Ref ref) => ref
      .watch(authRepositoryProvider)
      .observeSession()
      .map((AuthSessionState state) => state.userId),
);
