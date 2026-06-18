import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';

final Provider<MobileAuthController> mobileAuthControllerProvider =
    Provider<MobileAuthController>(
      (Ref ref) => MobileAuthController(
        ref.watch(authRepositoryProvider),
        ref.watch(supabaseConfigProvider).mobileAuthCallbackUrl,
      ),
    );

class MobileAuthController {
  const MobileAuthController(this._repository, this._callbackUrl);

  final AuthRepository _repository;
  final String _callbackUrl;

  Future<SignUpResult> signUp(String email, String password) {
    return _repository.signUp(
      email: email,
      password: password,
      emailRedirectTo: _callbackUrl,
    );
  }

  Future<void> signIn(String email, String password) {
    return _repository.signIn(email: email, password: password);
  }

  Future<void> signOut() => _repository.signOut();

  Future<void> requestPasswordReset(String email) {
    return _repository.requestPasswordReset(
      email: email,
      redirectTo: _callbackUrl,
    );
  }

  Future<void> updateRecoveredPassword(String password) {
    return _repository.updateRecoveredPassword(password);
  }

  Future<void> resendConfirmation(String email) {
    return _repository.resendConfirmation(
      email: email,
      emailRedirectTo: _callbackUrl,
    );
  }
}
