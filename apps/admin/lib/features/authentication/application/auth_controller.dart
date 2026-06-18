import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmaconnect_backend/pharmaconnect_backend.dart';

final Provider<AdminAuthController> adminAuthControllerProvider =
    Provider<AdminAuthController>(
      (Ref ref) => AdminAuthController(
        ref.watch(authRepositoryProvider),
        ref.watch(supabaseConfigProvider).adminAuthCallbackUrl,
      ),
    );

class AdminAuthController {
  const AdminAuthController(this._repository, this._callbackUrl);

  final AuthRepository _repository;
  final String _callbackUrl;

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
}
