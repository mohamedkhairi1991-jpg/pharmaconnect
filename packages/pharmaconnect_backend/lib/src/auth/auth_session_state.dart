enum AuthSessionPhase { signedOut, authenticated, passwordRecovery }

class AuthSessionState {
  const AuthSessionState._({required this.phase, this.userId, this.email});

  const AuthSessionState.signedOut()
    : this._(phase: AuthSessionPhase.signedOut);

  const AuthSessionState.authenticated({
    required String userId,
    required String? email,
  }) : this._(
         phase: AuthSessionPhase.authenticated,
         userId: userId,
         email: email,
       );

  const AuthSessionState.passwordRecovery({
    required String userId,
    required String? email,
  }) : this._(
         phase: AuthSessionPhase.passwordRecovery,
         userId: userId,
         email: email,
       );

  final AuthSessionPhase phase;
  final String? userId;
  final String? email;

  bool get isAuthenticated => phase != AuthSessionPhase.signedOut;
}

class SignUpResult {
  const SignUpResult({required this.confirmationRequired});

  final bool confirmationRequired;
}
