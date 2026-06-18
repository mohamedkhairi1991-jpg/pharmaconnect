import 'auth_session_state.dart';

abstract interface class AuthRepository {
  Stream<AuthSessionState> observeSession();

  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String emailRedirectTo,
  });

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  Future<void> requestPasswordReset({
    required String email,
    required String redirectTo,
  });

  Future<void> updateRecoveredPassword(String password);

  Future<void> resendConfirmation({
    required String email,
    required String emailRedirectTo,
  });
}
