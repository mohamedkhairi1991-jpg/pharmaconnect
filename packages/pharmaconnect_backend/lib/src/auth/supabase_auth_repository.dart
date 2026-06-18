import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_failure.dart';
import 'auth_repository.dart';
import 'auth_session_state.dart';

class SupabaseAuthRepository implements AuthRepository {
  const SupabaseAuthRepository(this._auth);

  final GoTrueClient _auth;

  @override
  Stream<AuthSessionState> observeSession() {
    return _auth.onAuthStateChange.map(_mapAuthState).handleError((
      Object error,
      StackTrace stackTrace,
    ) {
      if (error is AuthException) {
        throw mapAuthException(error);
      }
      throw const AuthFailure(AuthFailureKind.network);
    });
  }

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String emailRedirectTo,
  }) async {
    try {
      final AuthResponse response = await _auth.signUp(
        email: _normalizeEmail(email),
        password: password,
        emailRedirectTo: emailRedirectTo,
      );

      return SignUpResult(confirmationRequired: response.session == null);
    } on AuthException catch (error) {
      throw mapAuthException(error);
    } on Object {
      throw const AuthFailure(AuthFailureKind.network);
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithPassword(
        email: _normalizeEmail(email),
        password: password,
      );
    } on AuthException catch (error) {
      throw mapAuthException(error);
    } on Object {
      throw const AuthFailure(AuthFailureKind.network);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on AuthException catch (error) {
      throw mapAuthException(error);
    } on Object {
      throw const AuthFailure(AuthFailureKind.network);
    }
  }

  @override
  Future<void> requestPasswordReset({
    required String email,
    required String redirectTo,
  }) async {
    try {
      await _auth.resetPasswordForEmail(
        _normalizeEmail(email),
        redirectTo: redirectTo,
      );
    } on AuthException catch (error) {
      throw mapAuthException(error);
    } on Object {
      throw const AuthFailure(AuthFailureKind.network);
    }
  }

  @override
  Future<void> updateRecoveredPassword(String password) async {
    try {
      await _auth.updateUser(UserAttributes(password: password));
    } on AuthException catch (error) {
      throw mapAuthException(error);
    } on Object {
      throw const AuthFailure(AuthFailureKind.network);
    }
  }

  @override
  Future<void> resendConfirmation({
    required String email,
    required String emailRedirectTo,
  }) async {
    try {
      await _auth.resend(
        email: _normalizeEmail(email),
        type: OtpType.signup,
        emailRedirectTo: emailRedirectTo,
      );
    } on AuthException catch (error) {
      throw mapAuthException(error);
    } on Object {
      throw const AuthFailure(AuthFailureKind.network);
    }
  }

  AuthSessionState _mapAuthState(AuthState state) {
    final User? user = state.session?.user;

    if (state.event == AuthChangeEvent.passwordRecovery && user != null) {
      return AuthSessionState.passwordRecovery(
        userId: user.id,
        email: user.email,
      );
    }

    if (user == null) {
      return const AuthSessionState.signedOut();
    }

    return AuthSessionState.authenticated(userId: user.id, email: user.email);
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();
}

AuthFailure mapAuthException(AuthException error) {
  final String code = error.code ?? '';
  final String message = error.message.toLowerCase();

  if (code == 'invalid_credentials' || message.contains('invalid login')) {
    return const AuthFailure(AuthFailureKind.invalidCredentials);
  }
  if (code == 'email_not_confirmed' ||
      message.contains('email not confirmed')) {
    return const AuthFailure(AuthFailureKind.emailNotConfirmed);
  }
  if (code == 'user_already_exists' || message.contains('already registered')) {
    return const AuthFailure(AuthFailureKind.alreadyRegistered);
  }
  if (code == 'weak_password' || error is AuthWeakPasswordException) {
    return const AuthFailure(AuthFailureKind.weakPassword);
  }
  if (error.statusCode == '429' || code == 'over_request_rate_limit') {
    return const AuthFailure(AuthFailureKind.rateLimited);
  }
  if (code == 'flow_state_expired' ||
      code == 'bad_code_verifier' ||
      message.contains('expired')) {
    return const AuthFailure(AuthFailureKind.invalidRecoveryLink);
  }
  if (error is AuthSessionMissingException ||
      code == 'session_expired' ||
      code == 'refresh_token_not_found') {
    return const AuthFailure(AuthFailureKind.sessionExpired);
  }
  if (error is AuthRetryableFetchException) {
    return const AuthFailure(AuthFailureKind.network);
  }

  return const AuthFailure(AuthFailureKind.unexpected);
}
