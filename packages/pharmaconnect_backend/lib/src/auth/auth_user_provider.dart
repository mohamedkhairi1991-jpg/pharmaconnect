import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../client/supabase_client_provider.dart';

final StreamProvider<User?> authUserProvider = StreamProvider<User?>(
  (Ref ref) async* {
    final GoTrueClient auth = ref.watch(supabaseClientProvider).auth;

    yield auth.currentUser;

    await for (final AuthState state in auth.onAuthStateChange) {
      yield state.session?.user;
    }
  },
);
