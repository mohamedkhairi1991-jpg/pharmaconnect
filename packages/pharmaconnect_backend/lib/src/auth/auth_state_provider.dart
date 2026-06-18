import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_repository_provider.dart';
import 'auth_session_state.dart';

final StreamProvider<AuthSessionState> authStateProvider =
    StreamProvider<AuthSessionState>(
      (Ref ref) => ref.watch(authRepositoryProvider).observeSession(),
    );
