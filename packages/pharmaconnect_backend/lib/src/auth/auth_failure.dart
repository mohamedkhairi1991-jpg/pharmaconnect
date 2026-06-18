enum AuthFailureKind {
  invalidCredentials,
  emailNotConfirmed,
  alreadyRegistered,
  weakPassword,
  rateLimited,
  invalidRecoveryLink,
  sessionExpired,
  network,
  unexpected,
}

class AuthFailure implements Exception {
  const AuthFailure(this.kind);

  final AuthFailureKind kind;
}
